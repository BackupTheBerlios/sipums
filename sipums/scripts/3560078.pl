#!/usr/bin/perl

#main.pl
close STDERR; 
open STDERR, ">>/var/log/ser/script.err";

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
$log->debug("path = $path"); 
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


#my ($uname,$domain) = &get_user_domain($ser_to); 
my ($caller,$caller_domain); ## = &get_caller_id($ser_from); 
$caller = &get_caller_id($ser_from); 

$log->debug("-----------------------------------");
$log->debug("NEW CALL");
$log->debug("-- -- CALL TO $uname,$domain ");
$log->debug("-- -- CALL FROM --$caller--");

## get the dbh, get extension and change to the voicemail database to use
#my $dbh = OpenUMS::Common::get_dbh();
my $dbh = OpenUMS::Common::get_dbh("conference");

## create a ctport, a phonesys and load global settings
my $ctport    = new Telephony::CTPortJr($PORT);
my $phone_sys = new OpenUMS::PhoneSystem::SIP;

syslog('info', "NEW CALL ON IS $PORT"); 
my $i=0;
my $valid_code=0;
my $conference_room; 

while ($i < 5 && !$valid_code) { 
  $ctport->play($path . "conference_code.wav"); 
  $log->debug("calling collect ");
  my $conference_code = $ctport->collect(7,10); 
  $log->debug("collect got  $conference_code ");

  if (length($conference_code) == 7 ) {
     ($valid_code,$conference_room) = &validate_code($dbh, $conference_code); 
     if (!$valid_code) {    
       $log->debug("invalid code");
       $ctport->play($path . "invalid.wav");
     } 

  } 

  $log->debug("collected $conference_code");
  if ($valid_code) { 
    $log->debug("There code is valid, let's redirect them");
  }
  $i++;

}

$log->debug("sending them to conference_room $conference_room");

$phone_sys->send_to_conference_room($conference_room); 

sleep (4);

$dbh->disconnect(); 
exit; 



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

sub validate_code {
  my ($dbh,$code_input) = @_; 
  my $sql = qq{select c.conference_id, i.invitee_username, i.invitee_name  from invitees i, conferences  c
     WHERE i.conference_id = c.conference_id
     AND i.invitee_code = $code_input};
  $log->debug("sql = $sql");

  my @row = $dbh->selectrow_array($sql);
  if (!$row[0] ) {
    $log->debug("code is not valid");
    return (0,0); 
  }  else { 
    my $conference_room =  $row[0]; 
    $log->debug("code is valid '$conference_room' ");
    return (1, $conference_room); 
  }

}


sub validate_time {
  ## this will return 0,  and the sound if it is the wrong time
  ## this will return 1,  if it's ok for them to enter
  my ($dbh,$conference_id) = @_; 
  my $sql = qq(select conference_number, invitee_username, invitee_name  
     FROM  invitees i, conferences  c
     WHERE conference_id = $conference_id );

  $log->debug("sql = $sql");

  my @row = $dbh->selectrow_array($sql);
  if (!$row[0] ) {
    $log->debug("code is not valid");
    return (0,0); 
  }  else { 
    my $conference_room =  $row[0]; 
    $log->debug("code is valid '$conference_room' ");
    return (1, $conference_room); 
  }

}




