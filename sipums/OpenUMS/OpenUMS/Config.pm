package OpenUMS::Config;
### $Id: Config.pm,v 1.9 2004/11/18 00:10:18 kenglish Exp $
#
# Config.pm
#
# This is where (most) of the configuration constants for the OpenUMS
# are stored. 
#
# Copyright (C) 2004 Servpac Inc.
# 
#  This library is free software; you can redistribute it and/or modify it
#  under the terms of the GNU Lesser General Public License as published by the
#  Free Software Foundation; either version 2.1 of the license, or (at your
#  option) any later version.
# 
#  This library is distributed in the hope that it will be useful, but WITHOUT
#  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
#  FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public License for more
#  details.
# 
#  You should have received a copy of the GNU Lesser General Public License
#  License along with this library; if not, write to the Free Software
#  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  US
use Exporter;

our @ISA = ('Exporter');

use constant SAFE_PATH => "/bin:/usr/bin";

################################################################# Config

### These are the basic paths for the OpenUMS directory tree.
### All paths are relative to the BASE_PATH.
use constant BASE_PATH          => "/var/spool/openums/";
use constant PROMPT_PATH        => "prompts/";
use constant TEMP_PATH          => "spool/temp/";
use constant STORE_PATH         =>  "spool/store/";
use constant USER_PATH          => "users/";
use constant USER_REL_PATH          => "users/";
use constant DEFAULT_INVALID_SOUND => "invalid.wav";

### These constants configure the basic box and phone system.
use constant MAX_PORTS                   => 4;
use constant MAX_EXTENSION_DIGITS        => 3;
use constant DEFAULT_PASSWORD            => '\$extension';

### Delay and timeout configuration
use constant MAX_TIME_TO_WAIT_FOR_DIGITS => 4;
use constant INTER_DIGIT_DELAY           => 4;

## now a part of global settings...
##  use constant MESSAGE_TIMEOUT             => 180;

use constant SILENCE_TIMEOUT             => 9;
use constant MIN_MESSAGE_LENGTH          => 5;    ### (8000kb == 1sec)
use constant RC_TIMEOUT                  => 3600; 
use constant RC_SILENCE_TIMEOUT          => 15 ; 

use constant AREA_CODE => '808'; 
### Buttons with a specialized meaning
use constant EXTENSION_BUTTON   => '*';
use constant OPERATOR_BUTTON    => '0';  ### Zero, not capital o
use constant OPERATOR_EXTENSION => '301';  
## add by kenglish...
use constant EXTENSION_LENGTH => '3';  
use constant PASSWORD_LENGTH  => '4';  
use constant MAX_PASSWORD_LENGTH  => '10';  
use constant MIN_PASSWORD_LENGTH  => '3';  
## now a part of global settings...
##  use constant COLLECT_TIME     => '5';  

### These are the buttons a user can press to break out of a state
use constant TERM_KEYS        => "*#";
use constant RECORD_TERM_KEYS => "9*#";

## Menu flags... i made them in the hundreds so we will not confuse them with number
## entered by the user
use constant PREV_MENU_FLAG   => "900"; ## used by the menus to go back in the menu tree 
use constant REPEAT_MENU_FLAG => "100"; ## used by the menus to go back in the menu tree 

## Database Values
use constant DB_NAME => 'voicemail' ; 
use constant SER_DB_NAME => 'ser' ; 
use constant DB_USER => 'ser' ; 
use constant DB_PASS => 'SIPUMS_MYSQL_PASSORD' ; 

#use constant "VMINBOX"       => "Inbox";
#use constant "VMINBOX"       => "\"In Box Voicemail\"";
use constant "VMSAVED"       => "\"Saved Voicemail\"";

### IMAP connection values
use constant IMAP_PORT      => 143;
use constant IMAP_AUTH_MODE => 'CRAM-MD5';
use constant IMAP_DEBUG     => 0;
use constant IMAP_TIMEOUT   => 60;

### POP connection values
use constant POP_PORT      => 110;
use constant POP_AUTH_MODE => 'BEST';
use constant POP_DEBUG     => 0;
use constant POP_TIMEOUT   => 30;
use constant POP_USESSL    => 0;

use constant DEFAULT_EMAIL_PASSWORD     => '';
use constant DEFAULT_EMAIL_SERVERNAME   => '';
use constant DEFAULT_EMAIL_SERVER       => '';

use constant EMAIL_ON_ERROR     => 0;

### Configuration of the syncmail process
use constant SYNC_LOGPATH   => "/var/log/openums/";
use constant SYNC_LOGFILE   => "syncmail.log";
use constant SYNC_PIDPATH   => "/var/run/openums/";
use constant SYNC_PIDFILE   => "syncmail.pid";
use constant SYNC_LOOPDELAY => 300;
use constant SYNC_PATH      => "/usr/local/openums/";
use constant SYNC_SYNCMAIL  => "syncmail";
use constant SYNC_LOGLEVEL  => 3;

### Define to 1 for extra verbosity
use constant TEXT_MODE => 0;
use constant DEBUG => 1;

## 603 will always be the holiday menu id
use constant HOLIDAY_MENU_ID => 603;
use constant PHONE_SYSTEM => 'NECASPIRE' ;
use constant VT_CARD_TYPE => 'OPENSWITCH' ;

### Sound file bit rates (CBR)
use constant WAV_BITRATE  => 8000.0;
use constant VOX_BITRATE  => 4000.0;

### Process unsent messages process
use constant DELIVERMAIL_PIDFILE => '/var/log/openums/delivermail.pid';
use constant DELIVERMAIL_LOGFILE => '/var/log/openums/delivermail.log';
use constant DELIVERMAIL_ERRFILE => '/var/log/openums/delivermail.err';


our @EXPORT=qw(SAFE_PATH

               BASE_PATH PROMPT_PATH TEMP_PATH STORE_PATH USER_PATH USER_REL_PATH
               AUTOATTENDANT_PATH DEFAULT_INVALID_SOUND 

               MAX_PORTS MAX_EXTENSION_DIGITS DEFAULT_PASSWORD

               MAX_TIME_TO_WAIT_FOR_DIGITS INTER_DIGIT_DELAY MESSAGE_TIMEOUT
               SILENCE_TIMEOUT

 RC_TIMEOUT RC_SILENCE_TIMEOUT

         AREA_CODE 
         EXTENSION_BUTTON OPERATOR_BUTTON OPERATOR_EXTENSION EXTENSION_LENGTH PASSWORD_LENGTH
         COLLECT_TIME MIN_MESSAGE_LENGTH

               TERM_KEYS RECORD_TERM_KEYS

               PREV_MENU_FLAG REPEAT_MENU_FLAG

               POP_PORT POP_AUTH_MODE POP_DEBUG POP_TIMEOUT POP_USESSL

               IMAP_PORT IMAP_AUTH_MODE IMAP_DEBUG IMAP_TIMEOUT
             
               DB_NAME SER_DB_NAME DB_USER DB_PASS

               EMAIL_ON_ERROR 

               DEFAULT_EMAIL_PASSWORD DEFAULT_EMAIL_SERVERNAME
               DEFAULT_EMAIL_SERVER VMSAVED

               SYNC_LOGPATH SYNC_LOGFILE SYNC_PIDPATH SYNC_PIDFILE
               SYNC_LOOPDELAY SYNC_PATH SYNC_SYNCMAIL SYNC_LOGLEVEL
               MAX_PASSWORD_LENGTH MIN_PASSWORD_LENGTH 

               DEBUG TEXT_MODE HOLIDAY_MENU_ID PHONE_SYSTEM VT_CARD_TYPE

               WAV_BITRATE VOX_BITRATE

               DELIVERMAIL_PIDFILE DELIVERMAIL_LOGFILE DELIVERMAIL_ERRFILE);


our @EXPORT_OK = qw(DEBUG_TEXT_MODE);
our @EXPORT_TAGS = 
  (
    PATHS    => [qw(BASE_PATH PROMPT_PATH TEMP_PATH STORE_PATH USER_PATH AUTOATTENDANT_PATH)],
    POP      => [qw(POP_PORT POP_AUTH_MODE POP_DEBUG POP_TIMEOUT POP_USESSL)],
    IMAP     => [qw(IMAP_PORT IMAP_AUTH_MODE IMAP_DEBUG IMAP_TIMEOUT)],
    SYNCMAIL => [qw(SYNC_LOGPATH SYNC_LOGFILE SYNC_PIDPATH SYNC_PIDFILE 
                    SYNC_LOOPDELAY SYNC_PATH SYNC_SYNCMAIL SYNC_LOGLEVEL)],
    EMAIL    => [qw(DEFAULT_EMAIL_PASSWORD
                    DEFAULT_EMAIL_SERVERNAME
                    DEFAULT_EMAIL_SERVER
                    VMINBOX VMSAVED)]
  );

1;

