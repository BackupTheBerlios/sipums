#test.pl
my $sleep = 2;
use Sys::Syslog qw(:DEFAULT setlogsock);

syslog('info', 'this is the beginning');
my $wav_path = '/var/spool/openums/prompts/';
ivr::enableDTMFDetection();
syslog('info', 'setting DTMF callback: '. ivr::setCallback('onDTMF', 'onDTMF') );
syslog('info', 'setting BYE callback: '. ivr::setCallback('on_BYE', 'onBYE') );
ivr::setCallback(onMQE, "onMediaQueueEmpty");

syslog('info', 'filling media '. ivr::enqueueMediaFile($wav_path . 'ha_and_ty4_calling.wav', 0));
syslog('info', 'filling media '. ivr::enqueueMediaFile($wav_path . 'aloha_and_ty4_calling.wav', 0));


sub on_BYE {
	syslog('info', 'callback says: a bye in detected');
	ivr::wakeUp();
}

sub onDTMF {
    ($key) = @_;
    print "onDTMF, key = ", $key;
    if ($key eq '1') {
       $sleep -= 1;
       if ($sleep <= 0) {
            $sleep=1;
       }
       ivr::emptyMediaQueue();
       print ('SLEEP time is now ' . $sleep) ;
       ivr::say('sleep time is currently ' . ($sleep) . ' times');
    }
    if ($key eq '2') {
       $sleep += 1;
       ivr::emptyMediaQueue();
       print ('SLEEP time is now ' . $sleep_time) ;
       ivr::say('sleep time is currently ' . ($sleep) . ' times');
    }

    if ($key eq '0') {
       ivr::emptyMediaQueue();
  for ($i=0;$i<$sleep;$i++) {     
	syslog('info', 'filling media '. ivr::enqueueMediaFile($wav_path . '0.wav', 0));
	syslog('info', 'filling media '. ivr::enqueueMediaFile($wav_path . '1.wav', 0));
	syslog('info', 'filling media '. ivr::enqueueMediaFile($wav_path . '2.wav', 0));
	syslog('info', 'filling media '. ivr::enqueueMediaFile($wav_path . '3.wav', 0));
	syslog('info', 'filling media '. ivr::enqueueMediaFile($wav_path . '4.wav', 0));
	syslog('info', 'filling media '. ivr::enqueueMediaFile($wav_path . '5.wav', 0));
	syslog('info', 'filling media '. ivr::enqueueMediaFile($wav_path . '6.wav', 0));
	syslog('info', 'filling media '. ivr::enqueueMediaFile($wav_path . '7.wav', 0));
	syslog('info', 'filling media '. ivr::enqueueMediaFile($wav_path . '8.wav', 0));
	syslog('info', 'filling media '. ivr::enqueueMediaFile($wav_path . '9.wav', 0));
  }
#       ivr::mediaThreadUSleep($sleep_time);
    }
}


sub onMQE {
	syslog('info', 'filling media '. ivr::enqueueMediaFile($wav_path . 'aloha_and_ty4_calling.wav', 0));
}
           
$d = ivr.sleep(3600);

print "slept $d seconds ";

 

