#!/usr/bin/perl

#main.pl
open STDERR, ">>/var/log/openums/script.err";
print STDERR "HEllo kevin!";

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
my ($caller,$caller_domain,$caller_number); ## = &get_caller_id($ser_from); 

$caller = &get_caller_id($ser_from); 
$caller_number = &get_caller_number($ser_from); 

$log->debug("-----------------------------------");
$log->debug("NEW CALL");
$log->debug("-- -- CALL TO $uname,$domain ");
$log->debug("-- -- CALL FROM --$caller--");
$log->debug("-- -- CALL NUMBER --$caller_number--");

## get the dbh, get extension and change to the voicemail database to use
#my $dbh = OpenUMS::Common::get_dbh();
my $dbh = OpenUMS::Common::get_dbh("ser");

my $client_id = &get_client_id($dbh, $uname,$domain); 
my $main_number_flag = &is_client_main_number($dbh, $uname,$client_id); 

$log->debug("$uname client_id is $client_id");
my $extension_to  = &get_user_extention($dbh,$uname,$domain); 
my $extension_from=undef;


## create a ctport, a phonesys and load global settings
my $ctport    = new Telephony::CTPortJr($PORT);
my $phone_sys = new OpenUMS::PhoneSystem::SIP;

 syslog('info', "NEW CALL ON IS $PORT"); 


 $log->debug("User $ser_to is extension_to $extension_to ");

 my $action = 'auto_attendant';  ## default is always auto_attendant
 $log->log('action = ' . $action); 
 my $login_ext;  
 if  (!$extension_to || $main_number_flag) {
   $action = 'auto_attendant';  
   $log->log('no extension_to or main_number_flag, action = ' . $action); 
   if (&is_user_calling($dbh,$caller_number,$domain) ) {
      $action    = 'station_login';  
      $extension_from = $caller_number;
      $log->log('station_login extension or main_number_flag, action = ' . $action); 
   } 
 } else {
   ## default, take a message for that extension
   $action = 'take_message';
 }  

my $client_vm_db =  &change_client_db($dbh,$client_id); 
$CONF->load_settings($client_vm_db);

my $menu_id = OpenUMS::DbQuery::get_action_menu_id($dbh, $action);
  
## force them to leave a mesasge...
my ($data1,$data2); 
if ($extension_from ) { 
  ($data1,$data2)= ($extension_from,$caller);
} else {
  ($data1,$data2)= ($extension_to,$caller);
}

my $menu = new OpenUMS::Menu::Menu($dbh, $ctport, $phone_sys, $data1, $data2);

$log->debug("CALLING CREATE MENU");
$menu->create_menu(); 

## check the auto login 
if ($action eq 'station_login') { 
  $log->debug("It's stationg login, calling is_auto_login_new_user $extension_from");
  my ($auto_login_flag,$new_user_flag,$auto_new_messages) = OpenUMS::DbQuery::is_auto_login_new_user($dbh,$extension_from);

  $log->debug("auto_login_flag=$auto_login_flag,new_user_flag=$new_user_flag");

  if ($auto_login_flag) {
     $log->debug("User is auto_login");
     $menu_id = OpenUMS::DbQuery::get_action_menu_id($dbh, "auto_login");
     my $user = $menu->get_user();
     $user->auto_login($extension_from);
  }
  if($new_user_flag) {
    $log->debug("User is new_user");
    $menu_id = OpenUMS::DbQuery::get_action_menu_id($dbh, "user_tutorial");
  }
}
## dupe the shit!
$menu->run_menu($menu_id, $data1, $data2); 

$log->debug("Signalling delivermail");
&OpenUMS::Common::signal_delivermail;

$log->debug("finalize");
$ctport->finalize();

$log->debug("exit");

sleep(5); 

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


sub get_user_domain {
  my $ser_from  = shift ; 
  $ser_from =~ s/^<sip://g;
  $ser_from =~ s/>$//g;
  print "$ser_from\n";

  my ($user,$domain) = split('@',$ser_from);
  return ($user,$domain) ; 

}
sub change_client_db {
  my ($dbh,$client_id) = @_;

  my $sql = "SELECT voicemail_db FROM clients WHERE client_id = $client_id "; 
  my $arr = $dbh->selectrow_arrayref($sql);
  my $db = $arr->[0];
  if (!$db) {
    die "FATAL ERROR: No voicemail_db found for $client_id";
  } 
  $log->debug("Client DB is $db");

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
sub get_caller_number {
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
    return $num;
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
sub is_user_calling{
  my ($dbh,$caller,$domain) =@_; 
  my $sql = qq{SELECT count(*) FROM subscriber WHERE username ='$caller' AND domain = '$domain'};
  $log->debug('is_user_calling ' . $sql);
  my $arr = $dbh->selectrow_arrayref($sql);
  my $count = $arr->[0];
  return $count; 

}
sub get_client_id {
  my ($dbh, $number,$domain) = @_;
  my $sql = qq{SELECT client_id FROM subscriber 
     WHERE username = '$number'
       AND domain ='$domain' };

  $log->debug("$sql-----\n$number"); 

  my $arr = $dbh->selectrow_arrayref($sql);
  my $client_id = $arr->[0];
  return $client_id ; 

}
sub is_client_main_number {
  my ($dbh, $number,$client_id) = @_;
  my $sql = qq{SELECT count(*) FROM clients 
     WHERE client_main_number = '$number' 
        AND client_id ='$client_id' } ; 

  $log->debug(' gonna look for ' . $sql); 
  my $arr = $dbh->selectrow_arrayref($sql);
  my $count = $arr->[0];
  return $count ; 
}


