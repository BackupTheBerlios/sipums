#test.pl

use strict; 
use lib '/usr/local/openums/lib';

require 'playrec.pl';

use Sys::Syslog qw(:DEFAULT setlogsock);
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
use OpenUMS::Mwi;
use OpenUMS::CallRecorder ;

use DBI; 

my $program = 'ivr';

## connect to the database 
my $dbh = OpenUMS::Common::get_dbh(); 

## create a ctport and a phonesys object and load the global settings
my $pid = $$;
my $PORT = $pid ; 
my $ctport = new Telephony::CTPortJr( $PORT );
my $phone_sys = new OpenUMS::PhoneSystem::SIP;
$GLOBAL_SETTINGS->load_settings();

  ## we write this stuff to a sys log
  openlog($program, 'cons,pid', 'local6');
  syslog('info', '-----------------------------------');
  syslog('info', 'New call recieved ');
  syslog('info', "from is " . ivr::getTo ) ; 
  syslog('info', "PORT IS $PORT"); 

  ## find out who they are calling...translate that to an extension

  my $ser_to = ivr::getTo; 
  my $ext = OpenUMS::Common::ser_to_extension($dbh, $ser_to); 
  $log->debug("User $ser_to is extension $ext ");
  
  $log = new OpenUMS::Log($PORT);
  $log->debug("User $ser_to is extension $ext ");
  $log->debug("PLEASE WRITE TO SYS LOG");
  
  # set to 1 to test , if this doesn't work we can guarentee that nothing else will 

  my $TEST = 0 ; 
  if ($TEST){ 

     $ctport->play("/var/spool/openums/prompts/1.wav /var/spool/openums/prompts/2.wav /var/spool/openums/prompts/3.wav /var/spool/openums/prompts/3.wav /var/spool/openums/prompts/4.wav /var/spool/openums/prompts/5.wav /var/spool/openums/prompts/6.wav /var/spool/openums/prompts/7.wav /var/spool/openums/prompts/8.wav /var/spool/openums/prompts/9.wav /var/spool/openums/prompts/1000.wav");

     my $keys = $ctport->collect(5,10); 
     $ctport->play("/var/spool/openums/prompts/goodbye.wav"); 
     $log->debug("GOT BACK $keys ");
  

     sleep(10);

   exit ;
 } 


##  create the OpenUMS

my ($data1,$data2) = ($ext,undef);
my $menu = new OpenUMS::Menu::Menu($dbh, $ctport, $phone_sys, $data1, $data2);
$log->debug("CALLING CREATE MENU");
$menu->create_menu(); 

##  RUN menu 801 - which is leave a message

$menu->run_menu(801, $data1, $data2); 

## tell delivermail to  deliver the mail
&OpenUMS::Common::signal_delivermail;

$ctport->finalize();
