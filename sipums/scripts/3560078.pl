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

$log->debug("path = $path"); 
$log->debug("-----------------------------------");
$log->debug("NEW CALL");
$log->debug("-- -- CALL TO $uname,$domain ");
$log->debug("-- -- CALL FROM --$caller--");

## get the dbh, get extension and change to the voicemail database to use
#my $dbh = OpenUMS::Common::get_dbh();
my $dbh = OpenUMS::Common::get_dbh("conference");
$CONF->load_settings('conference'); 
$log->debug("VM_PATH = " . $CONF->get_var('VM_PATH') );

## create a ctport, a phonesys and load global settings
my $ctport    = new Telephony::CTPortJr($PORT);
my $phone_sys = new OpenUMS::PhoneSystem::SIP;

syslog('info', "NEW CALL ON IS $PORT"); 
my $i=0;
my $valid_flag=0;

my $conference_id ; 
my $continue = 1; 
do {
  #  (($continue i < 5 && !$valid_flag)) { 
  $ctport->play($path . "conference_code.wav"); 
  $log->debug("calling collect ");
  my $conference_code = $ctport->collect(7,10); 
  $log->debug("collect got  $conference_code ");

  if (length($conference_code) == 7 ) {
     ($valid_flag,$conference_id ) = &validate_code($dbh, $conference_code); 
     if (!$valid_flag) {    
       $log->debug("invalid code");
       $ctport->play($path . "invalid.wav");
     }  else { 
       my ($valid_time,$sound) = is_valid_time($dbh,$conference_id); 
       $log->debug("sound - $sound "); 
       if (!$valid_time ) {    
         $log->debug("invalid code");
         if ($sound) {
           $ctport->play($path . "invalid_conf_time.wav $sound");
         }  else { 
           $ctport->play($path . "invalid_conf_time.wav");
         }
         ## it's invalid time so let's just hang up on them 
         $continue = 0; 
         $valid_flag = 0; 
       }  else {
         $log->debug("THE CONFERENCE is happening now!");
         $valid_flag = 1; 
         $continue = 0; 
       } 
     } 
  } 

  $log->debug("collected $conference_code");
  if ($valid_flag) { 
    $log->debug("There code is valid, let's redirect them");
  }
  $i++;

} while(($i < 5) && ($continue) ) ; 

$log->debug("sending them to conference_id $conference_id");
if ($valid_flag && $conference_id ) { 
  $phone_sys->send_to_conference_room($conference_id); 
} else {
  $log->debug("They blew it");
  sleep (8);
  $ctport->play($path . "goodbye.wav");
}
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
     AND i.invitee_code = $code_input 
     AND concat(c.conference_date, ' ', c.end_time) > now() } ;
  $log->debug("sql = $sql");

  my @row = $dbh->selectrow_array($sql);
  if (!$row[0] ) {
    $log->debug("code is not valid");
    return (0,0); 
  }  else { 
    my $conference_id =  $row[0]; 
    $log->debug("code is valid , conference_id is '$conference_id' ");
    return (1, $conference_id); 
  }

}


sub is_valid_time {
  ## this will return 0,  and the sound if it is the wrong time
  ## this will return 1,  if it's ok for them to enter
  my ($dbh,$conference_id) = @_; 
  
  my $sql = qq(SELECT YEAR(conference_date),MONTH(conference_date),DAYOFMONTH(conference_date), HOUR(begin_time), MINUTE(begin_time),HOUR(end_time),MINUTE(end_time)  FROM conferences  WHERE conference_id = $conference_id);
  
  $log->debug("isvalidtime sql =$sql");                                                                                                                                              
  my ($nyear,$nmonth,$nday, $nhour,$nmin,$nsec) = Date::Calc::Today_and_Now();

  my ($cyear,$cmonth,$cday, $chour,$cmin,$ehour,$emin) = $dbh->selectrow_array($sql);
  my $csec =0; 

  my ($D_y,$D_m,$D_d, $Dh,$Dm,$Ds) = Date::Calc::Delta_YMDHMS(
    $nyear,$nmonth,$nday, $nhour,$nmin,$nsec,$cyear,$cmonth,$cday, $chour,$cmin,$csec);

  $log->debug("Dh=$Dh Dm $Dm");
    
  if ($D_y == 0 && $D_m == 0 && $D_d == 0 &&
    $Dh == 0 && $Dm < 6 ) {
    $log->debug("the conferenc is going on now!");
    return (1); 
  } 
  my ($ampm,$hour,$minute) = ("","","");
  if ($cmin) {
    $minute=OpenUMS::Common::count_sound_gen($cmin);
  }  else {
    $minute=undef;
  } 
  if ($chour == 0) {
       $hour = "12.wav" ;
       $ampm = $path . "am.wav";
  } elsif ($chour < 12 )  {
       $hour = "$path$chour.wav" ;
       $ampm = $path . "am.wav";
  } elsif ($chour == 12 )  {
       $hour = "$path$chour.wav" ;
       $ampm = $path . "pm.wav";
  } else {
       $hour = "$path" . ($chour -12) . ".wav" ;
       $ampm = $path . "pm.wav";
  }

  my $time_sound; 
  if ($minute) {
    $time_sound = "$hour $minute $ampm"; 
  }  else { 
    $time_sound = "$hour $ampm"; 
  } 

  if ($D_y > 0 || $D_m > 0 || $D_d > 0) {
    $log->debug("future day --- ");
    my $sound ; 
    my $dow_name = Date::Calc::Day_of_Week_to_Text(
                Date::Calc::Day_of_Week($cyear, $cmonth, $cday)) 
              . '.wav' ;
    my $month_name = lcfirst(Date::Calc::Month_to_Text($cmonth)) . '.wav' ;

    $sound =  "$time_sound " . $path . "$dow_name $path$month_name" ; 
    $sound .= " " . OpenUMS::Common::count_sound_gen($cday,1);
    return (0,$sound); 
  } else { 
    ## it's going on today, but they are early
    my $sound =  "$time_sound " . $path . "today.wav" ; 
    return (0,$sound); 
  }
}
