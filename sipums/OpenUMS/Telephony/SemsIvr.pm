package Telephony::SemsIvr;

use strict; 
use Sys::Syslog qw(:DEFAULT setlogsock);

my @keys;



use Exporter;
                                                                                                                                               
our @ISA = ('Exporter');
## These tell us what the IVR is doing...

use constant MEDIA_IDLE    => 0; 
use constant MEDIA_PLAYING    => 100; 
use constant MEDIA_RECORDING    => 200; 

our @EXPORT = qw(MEDIA_PLAYING MEDIA_RECORDING );

my $MEDIA_STATE; 
my $CALLER_HUNG_UP =0 ; 

######################## 
## sub play_done
##   Callback function for onBye 
######################## 

sub hang_up {
  $Telephony::SemsIvr::CALLER_HUNG_UP = 1; 
  syslog('info', "onBye: hang up call "); 
  ivr::wakeUp(); 

}

######################## 
## sub get_keys
##   call back function for onDTMF
######################## 

sub get_key {
  my ($key) = @_;
  if ($key eq '10') {
    $key ='*'; 
  } elsif ($key eq '11') {
    $key ='#'; 
  } 
  push @Telephony::SemsIvr::keys, $key;

  if ($Telephony::SemsIvr::MEDIA_STATE == MEDIA_PLAYING ) { 
     ## stop the media from playing, 
     ivr::emptyMediaQueue();
     $Telephony::SemsIvr::MEDIA_STATE = MEDIA_IDLE; 
  } elsif ($Telephony::SemsIvr::MEDIA_STATE == MEDIA_RECORDING) {
     ## stop the recording 
     ivr::stopRecording() ; 
     my $val = pop @Telephony::SemsIvr::keys; 
     syslog('info', "POPPED KEY val\n"); 
     ## the DTMF stopped the record so pop it
  } 
  syslog('info', "CALLED GET KEYS $key\n"); 
  ivr::wakeUp(); 
}

######################## 
## sub play_done
##   Callback function for onMediaEmpty 
######################## 

sub play_done {
  $Telephony::SemsIvr::MEDIA_STATE = MEDIA_IDLE;
  syslog('info', "onMedieaQueueEmpty:  play_done called "); 
  ivr::wakeUp(); 
}

######################## 
## sub init
##   Initialize the IVR, set call backs, initialize variables, etc
######################## 

sub init() {
   ## empty the array, clear the flag
   @Telephony::SemsIvr::keys = (); 

   $Telephony::SemsIvr::MEDIA_STATE = MEDIA_IDLE; 
   $Telephony::SemsIvr::CALLER_HUNG_UP = 0 ; 

   ## Turn on the DTMF Detection and set the onDTMF callback sub
   ivr::enableDTMFDetection();
   ivr::resumeDTMFDetection();

   ## Whenever a DTMF is pressed, get_keys will be called
   ivr::setCallback("Telephony::SemsIvr::get_key", "onDTMF");
   ivr::setCallback("Telephony::SemsIvr::play_done", "onMediaQueueEmpty");
   ivr::setCallback("Telephony::SemsIvr::hang_up", "onBye");

}

########################
### sub init
###   Initialize the IVR, set call backs, initialize variables, etc
#########################
#
sub cleanup() {
## empty the array, clear the flag
#  @Telephony::SemsIvr::keys = ();
## Turn on the DTMF Detection and set the onDTMF callback sub

  ivr::setCallback(undef, "onDTMF");
  ivr::setCallback(undef, "onMediaQueueEmpty");
  ivr::setCallback(undef, "onBye");

#  ivr::setCallback("Telephony::SemsIvr::play_done", undef);
#  ivr::setCallback("Telephony::SemsIvr::hang_up", undef);

  ivr::wakeUp(); 

}
#

######################## 
## sub play
##   Plays one media file
######################## 

sub play {
  my $file = shift; 

  syslog('info', "Play called: $file "); 
  $Telephony::SemsIvr::MEDIA_STATE=MEDIA_PLAYING;
  ivr::enqueueMediaFile($file, 0)

}

######################## 
## sub collect
##   collect x digits, wait for y secs, 
##    Inter digit delay not yet implemented
######################## 

sub collect {
  my ($digits, $sec,$idd) = @_;

  ## block until the media is done playing
  ## sleep initiazlly 

  syslog('info', "BEGIN COLLLECT:$digits,$sec"); 

  my $woke_up ;  

  if ($Telephony::SemsIvr::MEDIA_STATE==MEDIA_PLAYING ) { 
    $woke_up = ivr::msleep(3600000); 
  }

  syslog('info', "collecting : array size = ". scalar(@Telephony::SemsIvr::keys) . " digits = $digits"  ); ## BEGIN COLLLECT, sleep til wake up "); 

  my $sleep_time = $sec * 1000;
  my $slept_for = 0; 
  
  while ((scalar(@Telephony::SemsIvr::keys) < $digits) && $slept_for < $sleep_time && !$Telephony::SemsIvr::CALLER_HUNG_UP){  

     my $this_sleep = $sleep_time - $slept_for ; 
     my $slept = ivr::msleep( $this_sleep ); 
     $slept_for += $slept; 
     #"SemsIvr::keys size " . scalar(@Telephony::SemsIvr::keys) . "\n";
  } 

  my $collected_values = join('',@Telephony::SemsIvr::keys);
  syslog('info', "COLLECT RETURNING $collected_values ");
  @Telephony::SemsIvr::keys = () ;
  return $collected_values; 

}

######################## 
## sub record
##   record a media file
######################## 

sub record {
   my ($file,$length,$term_digits,$silence_timeout,$nobeepflag) = @_; 
   

   syslog('info', "Record gonna pl beep out $Telephony::SemsIvr::MEDIA_STATE "); 


   if (!($nobeepflag)) { 
     Telephony::SemsIvr::play("/var/spool/openums/prompts/beep.wav")  ;  
   } 
   while ($Telephony::SemsIvr::MEDIA_STATE == MEDIA_PLAYING) {
      ## you must wait until media is done playing
      ivr::msleep(10);     
      syslog('info', "MEDIA STATE = $Telephony::SemsIvr::MEDIA_STATE "); 
   } 
   syslog('info', "MEDIA STATE CHANGED = $Telephony::SemsIvr::MEDIA_STATE "); 

   ## make sure we are blocking everything else with the MEDIA State
   $Telephony::SemsIvr::MEDIA_STATE = MEDIA_RECORDING; 
   syslog('info', "STARTING RECORD $file (MEDIA STATE = $Telephony::SemsIvr::MEDIA_STATE) "); 
   ivr::startRecording($file) ; 
   $Telephony::SemsIvr::MEDIA_STATE = MEDIA_RECORDING; 
   ivr::sleep($length); 

   syslog('info', "done recordingyieldyield  ...."); 

#  my $yield_for = ivr::yield(); 
#  syslog('info', "yield_for = $yield_for "); 
   #ivr::msleep($length); 

   if ($Telephony::SemsIvr::MEDIA_STATE == MEDIA_RECORDING) {
     ## if it was not stoped by DTMF's, then it timed out, 
     ## so we stop it
     ivr::stopRecording() ;
     $Telephony::SemsIvr::MEDIA_STATE = MEDIA_IDLE; 
   }
   #$Telephony::SemsIvr::MEDIA_STATE = MEDIA_IDLE; 
}

1;
