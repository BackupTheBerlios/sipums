#!/usr/bin/perl

#main.pl
open STDERR, ">>/var/log/openums/script.err";

use strict; 

use Sys::Syslog qw(:DEFAULT setlogsock);

my $program = 'ivr';

openlog($program, 'cons,pid', 'local6');

use lib '/usr/local/openums/lib';

use Audio::Wav; 
use Date::Calc; 
use Telephony::SemsIvr;
use Telephony::CTPortJr;

use OpenUMS::CallOut;
use OpenUMS::Config;
use OpenUMS::Log;
use OpenUMS::GlobalSettings;
use OpenUMS::PhoneSystem::SIP ;

use OpenUMS::Common;
use OpenUMS::DbQuery;
use OpenUMS::IMAP;
use OpenUMS::Menu::Menu ;
use OpenUMS::CallRecorder ;

use DBI; 

my $PORT = $$;  ## use pid as uniqure port identifier
$log = new OpenUMS::Log($PORT);

## open the syslog 

## get the user and domain

my $ser_to = ivr::getTo; 
my $ser_from = ivr::getFrom; 
my $uri_from = ivr::getFromURI;
$log->debug("ivr::getFrom ='$ser_from'"); 
$log->debug("ivr::getTo ='$ser_to'"); 
$log->debug("ivr::getFromURI ='$uri_from'"); 

my ($uname,$domain) ;  # = &get_user_domain($ser_to); 
$uname = ivr::getUser();
$domain = ivr::getDomain();


#my ($uname,$domain) = &get_user_domain($ser_to); 
my ($caller,$caller_domain); ## = &get_caller_id($ser_from); 

$caller = &get_caller_id($ser_from); 

$log->debug("-----------------------------------");
$log->debug("NEW CALL");
$log->debug("-- -- CALL TO $uname,$domain ");
$log->debug("-- -- CALL FROM --$caller--");

## get the dbh, get extension and change to the voicemail database to use
#my $dbh = OpenUMS::Common::get_dbh();
my $dbh = OpenUMS::Common::get_dbh("ser");

my $main_number_flag = &is_domain_main_number($dbh, $uname,$domain); 

my $extension  = &get_user_extention($dbh,$uname,$domain); 
my $domain_vm_db =  &change_domain_db($dbh,$domain); 


## create a ctport, a phonesys and load global settings
my $ctport    = new Telephony::CTPortJr($PORT);
my $phone_sys = new OpenUMS::PhoneSystem::SIP;
$CONF->load_settings($domain_vm_db);

  syslog('info', "NEW CALL ON IS $PORT"); 


  $log->debug("User $ser_to is extension $extension ");

  my $TEST = 0 ; 
   if ($TEST){ 

      $ctport->play("/var/spool/openums/prompts/7.wav /var/spool/openums/prompts/2.wav /var/spool/openums/prompts/3.wav /var/spool/openums/prompts/3.wav /var/spool/openums/prompts/4.wav /var/spool/openums/prompts/5.wav /var/spool/openums/prompts/6.wav /var/spool/openums/prompts/7.wav /var/spool/openums/prompts/8.wav /var/spool/openums/prompts/9.wav /var/spool/openums/prompts/1000.wav");

      my $keys = $ctport->collect(5,10); 
      $ctport->play("/var/spool/openums/prompts/goodbye.wav"); 
      $log->debug("GOT BACK $keys ");

     sleep(10);
     exit ;
  } 
 ## this figures out what menu to play
 my $action = 'auto_attendant';  ## default is always auto_attendant
 if  (!$extension || $main_number_flag) {
   $action = 'auto_attendant';  
 }  elsif ($caller eq $uname){
   ## if the phone called from is the same as the number, they are checking voicemail
   $action = 'station_login'; 
 } else {
   ## default, take a message for that extension
   $action = 'take_message';
 }  
 # $action = 'auto_attendant';

 my $menu_id = OpenUMS::DbQuery::get_action_menu_id($dbh, $action);

## force them to leave a mesasge...

my ($data1,$data2)= ($extension,$caller);

my $menu = new OpenUMS::Menu::Menu($dbh, $ctport, $phone_sys, $data1, $data2);

$log->debug("CALLING CREATE MENU");
$menu->create_menu(); 

## dupe the shit!
$menu->run_menu($menu_id, $data1, $data2); 
$log->debug("Signalling delivermail");
&OpenUMS::Common::signal_delivermail;

$log->debug("finalize");
$ctport->finalize();
$log->debug("exit");
ivr::sleep(3); 
exit; 

## open the sys log
#  
#
#
#Telephony::SemsIvr::init();
#Telephony::SemsIvr::record("/tmp/kevin.wav",4);
#
#ivr::sleep(2); 
#
#Telephony::SemsIvr::play("/tmp/kevin.wav");
## Telephony::SemsIvr::play("/var/spool/openums/prompts/goodbye.wav");
#playrec();                       


sub get_dbh() {
 
  my $dsn = 'DBI:mysql:database=ser;host=localhost';
  my $user = "ser";
  my $password = "olseh";
  syslog('info', "conneting to ser db...");
  my $dbh = DBI->connect($dsn, $user, $password) || die "Database connection not made: $DBI::errstr";
 
}
sub get_user_domain {
  my $ser_from  = shift ; 
  $ser_from =~ s/^<sip://g;
  $ser_from =~ s/>$//g;
  print "$ser_from\n";

  my ($user,$domain) = split('@',$ser_from);
  return ($user,$domain) ; 

}
sub change_domain_db {
  my ($dbh,$domain) = @_;

  my $sql = "SELECT voicemail_db FROM domain WHERE domain = '$domain'"; 
  my $arr = $dbh->selectrow_arrayref($sql);
  my $db = $arr->[0];
  if (!$db) {
    die "FATAL ERROR: No voicemail_db found for $domain";
  } 
  $log->debug("Domain DB is $db");

  $dbh->do("use $db") || die "Could not use $db " . $dbh->errstr;
  return $db;

}
sub get_caller_id {
  my $sip_from = shift;
  if ($sip_from =~ /unknown/){ 
     return "unknown";
  } 

  if ($sip_from =~ /^<sip:/) {
    $sip_from =~ s/^<sip://g;
    $sip_from =~ s/>$//g;
    my ($num,$d) = split(/\@/,$sip_from);
    return $num;
  } elsif ($sip_from =~ /"/) {
    $sip_from =~ s/>$//g;
    my ($name,$sip_from) = split(/\<sip:/,$sip_from);
    my ($num,$d) = split(/\@/,$sip_from);
    $name =~ s/\"//g;
    $log->debug("$name "); 
    $name =~ s/\s+$//;
    $log->debug("$name "); 
    return "$name $num";
  }
                                                                                                                                               
}

sub get_user_extention {
  my ($dbh,$uname,$domain) = @_; 
  my $sql = qq{SELECT mailbox FROM subscriber WHERE username ='$uname' AND domain = '$domain'};
  my $arr = $dbh->selectrow_arrayref($sql);
  my $ext = $arr->[0];
  $log->debug("$sql-----\n$ext"); 
  if (!$ext ) {
    return undef;
  } else { 
    return $ext ;
  }

}
sub is_domain_main_number {
  my ($dbh, $number,$domain) = @_;
  my $sql = qq{SELECT count(*) FROM domain 
     WHERE company_number = '$number' 
        AND domain ='$domain' } ; 
  my $arr = $dbh->selectrow_arrayref($sql);
  my $count = $arr->[0];
  return $count ; 
}


