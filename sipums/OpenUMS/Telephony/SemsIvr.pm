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
my $TERM_KEYS; 
my $CALLER_HUNG_UP =0 ; 

######################## 
## sub play_done
##   Callback function for onBye 
######################## 

sub hang_up {
  if ($Telephony::SemsIvr::CALLER_HUNG_UP) { 
    syslog('info', "[SemsIvr::hang_up] onBye: hang_up called but CALLER_HUNG_UP flag already set, returning"); 
    return ;
  } 
  $Telephony::SemsIvr::CALLER_HUNG_UP = 1; 

  my $sleep_time_ms = int(rand 250) + 250;
  syslog('info', "[SemsIvr::hang_up] onBye: hang_up called "); 
#  select(undef, undef, undef, $sleep_time_ms/1000 );
#  if ($Telephony::SemsIvr::CALLER_HUNG_UP) {
#    syslog('info', "[SemsIvr::hang_up] onBye: woke up and found CALLER_HUNG_UP flag is set, returning.");
#    return ;
#  }else {
#    syslog('info', "[SemsIvr::hang_up] onBye: woke up and found NO CALLER_HUNG_UP flag is set.");
#  } 
  ivr::wakeUp(); 
  syslog('info', "[SemsIvr::hang_up] onBye: after wakeUp() "); 
}

######################## 
## sub get_keys
##   call back function for onDTMF
######################## 

sub get_key {
  my ($key) = @_;

  if ($Telephony::SemsIvr::CALLER_HUNG_UP) { 
     syslog('info', "[SemsIvr::get_key] called but caller hung up"); 
     return ;
  }

  if (($key < 0)  || ($key > 11) ) {
     syslog('info', "[SemsIvr::get_key] called with invalid key $key\n"); 
     return ;
  } 
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
     syslog('info', "[SemsIvr::get_key] CALLED GET KEYS $key\n"); 
     ivr::wakeUp(); 
  } elsif ($Telephony::SemsIvr::MEDIA_STATE == MEDIA_RECORDING) {
     ## stop the recording 
     my $val = pop @Telephony::SemsIvr::keys; 
     if ($val =~ /\*/) {
        $val =~ s/\*/\\*/;
     }

     if ($Telephony::SemsIvr::TERM_KEYS =~ /$val/) { 
        syslog('info', "[SemsIvr::get_key] RECORD INTERUPTED TERM_KEYS (" . $Telephony::SemsIvr::TERM_KEYS . ") pressed=$val "); 
        ivr::stopRecording() ; 
        $Telephony::SemsIvr::MEDIA_STATE = MEDIA_IDLE; 
        ivr::wakeUp(); 
     }  else {
        syslog('info', "[SemsIvr::get_key] Key pressed but not TERM_KEYS (" . $Telephony::SemsIvr::TERM_KEYS . ") pressed=$val "); 
     } 
     ## the DTMF stopped the record so pop it
  } 
  #ivr::wakeUp(); 
}

######################## 
## sub play_done
##   Callback function for onMediaEmpty 
######################## 

sub play_done {
  $Telephony::SemsIvr::MEDIA_STATE = MEDIA_IDLE;
  syslog('info', "[SemsIvr::play_done] onMedieaQueueEmpty:  play_done called "); 
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
  syslog('info', "[SemsIvr::cleanup] cleanup called, setting all callbacks to null"); 

  ivr::setCallback(undef, "onDTMF");
  ivr::setCallback(undef, "onMediaQueueEmpty");
  ivr::emptyMediaQueue();
  ivr::setCallback(undef, "onBye");

#  ivr::setCallback("Telephony::SemsIvr::play_done", undef);
#  ivr::setCallback("Telephony::SemsIvr::hang_up", undef);

  ivr::wakeUp(); 
  syslog('info', "[SemsIvr::cleanup] cleanup done"); 

}
#

######################## 
## sub play
##   Plays one media file
######################## 

sub play {
  my $file = shift; 
  if ($Telephony::SemsIvr::CALLER_HUNG_UP) { 
     syslog('info', "[SemsIvr::play] called but caller hung up"); 
     return ;
  }  

  syslog('info', "[SemsIvr::play] Play called: $file "); 
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
  if ($Telephony::SemsIvr::CALLER_HUNG_UP) {
     syslog('info', "[SemsIvr::collect] called but caller hung up");
     return ;
  }


  ## block until the media is done playing
  ## sleep initiazlly 

  syslog('info', "[SemsIvr::collect] BEGIN COLLLECT:$digits,$sec"); 

  my $woke_up ;  

  if ($Telephony::SemsIvr::MEDIA_STATE==MEDIA_PLAYING ) { 
    syslog('info', "[SemsIvr::collect] waiting for play to finish, call ivr::msleep(3600000) "); 
    $woke_up = ivr::msleep(3600000); 
    syslog('info', "[SemsIvr::collect] play done moving on with collect"); 
  }

  if ($Telephony::SemsIvr::CALLER_HUNG_UP) {
     syslog('info', "[SemsIvr::collect] MEDIA STATE CHANGED but caller hung up");
     return ;
  }

  syslog('info', "[SemsIvr::collect] collecting : array size = ". scalar(@Telephony::SemsIvr::keys) . " digits = $digits"  ); ## BEGIN COLLLECT, sleep til wake up "); 

  my $sleep_time = $sec * 1000;
  my $slept_for = 0; 
  
  while ((scalar(@Telephony::SemsIvr::keys) < $digits) && $slept_for < $sleep_time && !$Telephony::SemsIvr::CALLER_HUNG_UP){  

     my $this_sleep = $sleep_time - $slept_for ; 
     syslog('info', "[SemsIvr::collect] ivr::msleep($this_sleep) " . $Telephony::SemsIvr::CALLER_HUNG_UP) ; 
     my $slept = ivr::msleep( $this_sleep ); 
     $slept_for += $slept; 
     #"SemsIvr::keys size " . scalar(@Telephony::SemsIvr::keys) . "\n";
  } 
  syslog('info', "[SemsIvr::collect] collect while loop done ");
  my $collected_values = join('',@Telephony::SemsIvr::keys);
  syslog('info', "[SemsIvr::collect] COLLECT RETURNING $collected_values ");
  @Telephony::SemsIvr::keys = () ;
  return $collected_values; 

}

######################## 
## sub record
##   record a media file
######################## 

sub record {
   my ($file,$length,$term_keys,$silence_timeout,$nobeepflag) = @_; 
   if ($Telephony::SemsIvr::CALLER_HUNG_UP) { 
      syslog('info', "[SemsIvr::record] called but caller hung up"); 
      return ;
   }  

   if ($term_keys) { 
     $Telephony::SemsIvr::TERM_KEYS=$term_keys; 
   } else {
     # set it to all keys...
     $Telephony::SemsIvr::TERM_KEYS="1234567890#*"; 
   } 

   syslog('info', "[SemsIvr::record] Record gonna pl beep out $Telephony::SemsIvr::MEDIA_STATE "); 


   if (!($nobeepflag)) { 
     Telephony::SemsIvr::play("/var/spool/openums/prompts/beep.wav")  ;  
   } 
   while ($Telephony::SemsIvr::MEDIA_STATE == MEDIA_PLAYING) {
      ## you must wait until media is done playing
      my $woke_up = ivr::msleep(3600000); 
      # ivr::msleep(1000);     
   } 


   syslog('info', "[SemsIvr::record] MEDIA STATE CHANGED = $Telephony::SemsIvr::MEDIA_STATE "); 

   ## make sure we are blocking everything else with the MEDIA State
   $Telephony::SemsIvr::MEDIA_STATE = MEDIA_RECORDING; 
   syslog('info', "[SemsIvr::record] STARTING RECORD $file (MEDIA STATE = $Telephony::SemsIvr::MEDIA_STATE) "); 
   ivr::startRecording($file) ; 
   $Telephony::SemsIvr::MEDIA_STATE = MEDIA_RECORDING; 
   ivr::sleep($length); 

   syslog('info', "[SemsIvr::record] done recordingyieldyield  ...."); 

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
