#!/usr/bin/perl

#main.pl
close STDERR; 
open STDERR, ">>/var/log/ser/script.err";

my $demo_code_length=4;
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

my $path = BASE_PATH . PROMPT_PATH;

use OpenUMS::Log;
use OpenUMS::GlobalSettings;
use OpenUMS::PhoneSystem::SIP ;

use OpenUMS::Common;
use OpenUMS::DbQuery;

use DBI; 

my $PORT = $$;  ## use pid as uniqure port identifier
$log = new OpenUMS::Log($PORT);

## open the syslog 

## get the user and domain

my $ser_to = ivr::getTo; 
my $ser_from = ivr::getFrom; 

my ($uname,$domain) ;  # = &get_user_domain($ser_to); 
$uname = ivr::getUser();
$domain = ivr::getDomain();

#  my ($uname,$domain) = &get_user_domain($ser_to); 
my ($caller,$caller_domain); ## = &get_caller_id($ser_from); 
$caller = &get_caller_id($ser_from); 

$log->debug("path = $path"); 
$log->debug("-----------------------------------");
$log->debug("NEW CALL");
$log->debug("-- -- CALL TO $uname,$domain ");
$log->debug("-- -- CALL FROM --$caller--");

## get the dbh, get extension and change to the voicemail database to use
#my $dbh = OpenUMS::Common::get_dbh();
my $dbh = OpenUMS::Common::get_dbh("um_demo");
$log->debug("dbh = $dbh");
## create a ctport, a phonesys and load global settings

my $ctport    = new Telephony::CTPortJr($PORT);
my $phone_sys = new OpenUMS::PhoneSystem::SIP;

syslog('info', "NEW CALL ON IS $PORT"); 

my $i=0;
my $valid_flag=0;

my $conference_id ; 
my $continue = 1; 
my $code =''; 

do {
  #  (($continue i < 5 && !$valid_flag)) { 
  $ctport->play($path . "um_demo_passcode.wav"); 
  $log->debug("calling collect ");

  $code = $ctport->collect(4,10); 

  $log->debug("collect got  $code ");

  if (&validate_code($dbh,$code ) ) { 
     $valid_flag = 1; 
     $continue = 0; 
  } 

  if (!$valid_flag) { 
    $ctport->play($path ."invalid.wav"); 
    $log->debug("There code is valid, let's redirect them");
  }

  $i++;

} while(($i < 5) && ($continue) ) ; 
$log->debug("done, valid_flag = " . $valid_flag ); 

if (!$valid_flag) { 
  exit; 
} 

  my $rec_path  = "/var/spool/openums/spool/temp/$code.wav" ; 
  $ctport->play("$path/rec_msg_kev.wav $path/beep.wav");
  &update_demo_table($dbh, $code,$rec_path, $caller); 
 
  $ctport->record($rec_path,60); 
  $log->debug("OpenUMS::Common::signal_delivermail() "); 
  OpenUMS::Common::signal_delivermail(); 
  
  sleep 5;
exit ;

$dbh->disconnect(); 
exit; 

sub validate_code {
  my ($dbh, $code)   = @_;
  if (!$code) { 
    return 0; 
  } 
  my $sql = "SELECT count(*) FROM um_demo_message WHERE code = '$code'";

  $log->debug("sql=$sql"); 
  $log->debug("dbh=$dbh"); 
  my $retval=0;  
  my $sth = $dbh->prepare($sql);
#  $log->debug("after prepare ". $DBI::errstr); 
  $sth->execute();
#  $log->debug("after execute ". $DBI::errstr); 
  my $retval = $sth->fetchrow();  
#  $log->debug("after fetchrow ". $DBI::errstr); 
  $sth->finish(); 
#  $log->debug("retval = " . $retval ); 
#
  return $retval ; 

}

sub get_caller_id  {
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
    chop($name);
    return "$name $num";
  }
}
sub update_demo_table {
  my ($dbh, $code, $message_file, $caller_id) = @_;

  my $upd = "UPDATE um_demo_message SET  message_datetime=NOW(), "
          . " message_file ='$message_file', caller_id='$caller_id' "    
          . " WHERE code = '$code' "; 
  $log->debug("$dbh $upd"); 
  $dbh->do($upd) ; 

} 

