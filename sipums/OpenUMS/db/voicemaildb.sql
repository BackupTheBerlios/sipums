-- MySQL dump 9.10
--
-- Host: localhost    Database: vm_omatrix_net
-- ------------------------------------------------------
-- Server version	4.0.18-log

--
-- Table structure for table `VM_Greetings`
--

DROP TABLE IF EXISTS VM_Greetings;
CREATE TABLE VM_Greetings (
  greeting_id int(11) NOT NULL auto_increment,
  extension smallint(6) NOT NULL default '0',
  user_greeting_no smallint(5) NOT NULL default '1',
  current_greeting tinyint(1) NOT NULL default '0',
  professional tinyint(1) NOT NULL default '0',
  greeting_wav_path varchar(200) NOT NULL default '',
  greeting_wav_file varchar(100) NOT NULL default '''''',
  last_updated timestamp(14) NOT NULL,
  PRIMARY KEY  (greeting_id),
  KEY idx_VM_Greetings_extension (extension)
) TYPE=MyISAM COMMENT='Greeting files for each user';

--
-- Dumping data for table `VM_Greetings`
--


--
-- Table structure for table `VM_Message_Status`
--

DROP TABLE IF EXISTS VM_Message_Status;
CREATE TABLE VM_Message_Status (
  message_status_id char(1) NOT NULL default '',
  message_status_descr varchar(50) default NULL,
  PRIMARY KEY  (message_status_id)
) TYPE=MyISAM COMMENT='This is a lookup table for message_status_id';

--
-- Dumping data for table `VM_Message_Status`
--


--
-- Table structure for table `VM_Messages`
--

DROP TABLE IF EXISTS VM_Messages;
CREATE TABLE VM_Messages (
  message_id int(11) NOT NULL auto_increment,
  message_created datetime NOT NULL default '0000-00-00 00:00:00',
  message_status_changed datetime default NULL,
  message_last_played datetime default NULL,
  message_status_id char(1) NOT NULL default 'N',
  extension_to smallint(6) NOT NULL default '0',
  extension_from varchar(35) default '0',
  message_wav_path varchar(100) NOT NULL default '''''',
  message_wav_file varchar(50) NOT NULL default '''''',
  message_mail_sync_status tinyint(1) NOT NULL default '0',
  record_call_flag tinyint(1) NOT NULL default '0',
  forward_message_flag tinyint(1) NOT NULL default '0',
  PRIMARY KEY  (message_id),
  UNIQUE KEY message_wav_file (message_wav_file),
  KEY idx_VM_Messages_extension_to (extension_to),
  KEY idx_VM_Messages_message_status_id (message_status_id)
) TYPE=MyISAM COMMENT='The messages recieved by a user.';

--
-- Dumping data for table `VM_Messages`
--


--
-- Table structure for table `VM_Permissions`
--

DROP TABLE IF EXISTS VM_Permissions;
CREATE TABLE VM_Permissions (
  permission_id varchar(20) NOT NULL default '',
  permission_level smallint(6) unsigned NOT NULL default '0',
  permission_desc varchar(200) NOT NULL default '',
  PRIMARY KEY  (permission_id),
  UNIQUE KEY permission_level (permission_level)
) TYPE=MyISAM COMMENT='A lookup table for permissions. The highest level has the mo';

--
-- Dumping data for table `VM_Permissions`
--

INSERT INTO VM_Permissions VALUES ('ANON',1,'Annonymous/Outside Caller Permissions');
INSERT INTO VM_Permissions VALUES ('USER',2,'Regular User Permissions');
INSERT INTO VM_Permissions VALUES ('ADMIN',3,'Local Phone Sys Administrator');
INSERT INTO VM_Permissions VALUES ('SUPER',4,'Super User - Ultra Admin');

--
-- Table structure for table `VM_Users`
--

DROP TABLE IF EXISTS VM_Users;
CREATE TABLE VM_Users (
  extension smallint(6) NOT NULL default '0',
  password varchar(20) NOT NULL default '',
  permission_id varchar(10) NOT NULL default 'USER',
  active tinyint(1) NOT NULL default '0',
  first_name varchar(100) NOT NULL default '',
  last_name varchar(100) NOT NULL default '',
  mi char(1) default NULL,
  store_flag enum('E','V') NOT NULL default 'V',
  transfer tinyint(1) NOT NULL default '0',
  mwi_flag tinyint(1) NOT NULL default '0',
  call_out_number varchar(10) default NULL,
  new_user_flag tinyint(1) NOT NULL default '0',
  phone_keys_first_name smallint(6) default NULL,
  phone_keys_last_name smallint(6) default NULL,
  personal_operator_extension smallint(6) default '0',
  email_delivery enum('I','F','S') NOT NULL default 'I',
  email_server_address varchar(50) NOT NULL default '',
  email_address varchar(150) NOT NULL default '',
  email_user_name varchar(50) NOT NULL default '',
  email_password varchar(50) NOT NULL default '',
  email_type enum('T','H') NOT NULL default 'H',
  name_wav_path varchar(200) default NULL,
  name_wav_file varchar(100) default NULL,
  mobile_email varchar(100) default NULL,
  mobile_email_flag tinyint(1) default '0',
  last_visit datetime default '2001-01-01 00:00:00',
  vstore_email enum('N','C','S') NOT NULL default 'N',
  auto_login_flag tinyint(1) unsigned NOT NULL default '0',
  auto_new_messages_flag tinyint(1) default '0',
  PRIMARY KEY  (extension),
  KEY idx_phone_keys_last_name (phone_keys_last_name),
  KEY idx_phone_keys_first_name (phone_keys_first_name)
) TYPE=MyISAM COMMENT='VM_User = Voicemail Users, nuff said';

--
-- Dumping data for table `VM_Users`
--

INSERT INTO VM_Users VALUES (0,'77eecc750f0e0c90','USER',1,'Outside','Caller','','V',0,1,NULL,0,688,225,0,'S','','','','','H','\'\'',NULL,NULL,0,'2001-01-01 00:00:00','C',1,0);
INSERT INTO VM_Users VALUES (799,'6dddeb0074689d69','SUPER',1,'Supervisor','','','V',1,0,NULL,0,787,NULL,0,'I','','','','','T',NULL,NULL,'',0,'2004-09-10 16:54:28','N',0,0);
INSERT INTO VM_Users VALUES (798,'6dddeb0074689d69','ADMIN',1,'Administrator','',NULL,'V',0,0,NULL,0,236,NULL,0,'I','','','','','T',NULL,NULL,'',0,'2001-01-01 00:00:00','N',0,0);

--
-- Table structure for table `auto_attendant`
--

DROP TABLE IF EXISTS auto_attendant;
CREATE TABLE auto_attendant (
  aa_dayofweek tinyint(3) unsigned NOT NULL default '0',
  aa_start_hour tinyint(3) unsigned NOT NULL default '0',
  aa_start_minute tinyint(3) unsigned NOT NULL default '0',
  menu_sound varchar(100) NOT NULL default 'aa_default.wav',
  PRIMARY KEY  (aa_dayofweek,aa_start_hour,aa_start_minute)
) TYPE=MyISAM COMMENT='Holds configuration for main auto attendant greeting.';

--
-- Dumping data for table `auto_attendant`
--

INSERT INTO auto_attendant VALUES (1,0,0,'aa_default_night.wav');
INSERT INTO auto_attendant VALUES (2,0,0,'aa_default_night.wav');
INSERT INTO auto_attendant VALUES (2,8,0,'aa_default.wav');
INSERT INTO auto_attendant VALUES (2,17,0,'aa_default_night.wav');
INSERT INTO auto_attendant VALUES (3,0,0,'aa_default_night.wav');
INSERT INTO auto_attendant VALUES (3,8,0,'aa_default.wav');
INSERT INTO auto_attendant VALUES (3,17,0,'aa_default_night.wav');
INSERT INTO auto_attendant VALUES (4,0,0,'aa_default_night.wav');
INSERT INTO auto_attendant VALUES (4,8,0,'aa_default.wav');
INSERT INTO auto_attendant VALUES (4,17,0,'aa_default_night.wav');
INSERT INTO auto_attendant VALUES (5,0,0,'aa_default_night.wav');
INSERT INTO auto_attendant VALUES (5,8,0,'aa_default.wav');
INSERT INTO auto_attendant VALUES (5,17,0,'aa_default_night.wav');
INSERT INTO auto_attendant VALUES (6,0,0,'aa_default_night.wav');
INSERT INTO auto_attendant VALUES (6,8,0,'aa_default.wav');
INSERT INTO auto_attendant VALUES (6,17,0,'aa_default_night.wav');
INSERT INTO auto_attendant VALUES (7,0,0,'aa_default_night.wav');

--
-- Table structure for table `call_log`
--

DROP TABLE IF EXISTS call_log;
CREATE TABLE call_log (
  log_id int(11) NOT NULL auto_increment,
  intergration_digs varchar(50) default NULL,
  caller_id varchar(15) default NULL,
  vm_function varchar(20) default NULL,
  call_recieved timestamp(14) NOT NULL,
  PRIMARY KEY  (log_id)
) TYPE=MyISAM COMMENT='A log all calls made to the system. Used mainly for reportin';

--
-- Dumping data for table `call_log`
--


--
-- Table structure for table `email_failures`
--

DROP TABLE IF EXISTS email_failures;
CREATE TABLE email_failures (
  extension smallint(6) NOT NULL default '0',
  first_sent datetime NOT NULL default '0000-00-00 00:00:00',
  last_sent datetime NOT NULL default '0000-00-00 00:00:00',
  email_address varchar(150) NOT NULL default '',
  PRIMARY KEY  (extension)
) TYPE=MyISAM COMMENT='Tracks people we could not deliver voicemail via email to.';

--
-- Dumping data for table `email_failures`
--

INSERT INTO email_failures VALUES (0,'2004-08-29 14:38:15','2004-08-29 14:38:15','');

--
-- Table structure for table `global_settings`
--

DROP TABLE IF EXISTS global_settings;
CREATE TABLE global_settings (
  var_name varchar(50) NOT NULL default '',
  var_display_name varchar(100) NOT NULL default '',
  var_value varchar(150) NOT NULL default '',
  var_type varchar(10) NOT NULL default 'INTEGER',
  var_min_value int(11) NOT NULL default '0',
  var_max_value int(11) NOT NULL default '100000',
  description varchar(254) NOT NULL default '',
  PRIMARY KEY  (var_name)
) TYPE=MyISAM COMMENT='These are dynamic setting variables that are used throughout';

--
-- Dumping data for table `global_settings`
--

INSERT INTO global_settings VALUES ('COLLECT_TIME','Time to wait for digits','5','INTEGER',1,25,'');
INSERT INTO global_settings VALUES ('MESSAGE_TIMEOUT','Maximum message time in seconds','200','INTEGER',5,900,'');
INSERT INTO global_settings VALUES ('MIN_MESSAGE_LENGTH','Shortest message allowed in seconds','4','INTEGER',0,900,'');
INSERT INTO global_settings VALUES ('RC_TIMEOUT','Maximum length of a recorded call in minutes','60','INTEGER',0,900,'');
INSERT INTO global_settings VALUES ('OPERATOR_EXTENSION','Operator extension','301','INTEGER',0,100000,'');
INSERT INTO global_settings VALUES ('REWIND_SECS','Number of Seconds rewind/fast forward will jump','5','INTEGER',1,25,'');
INSERT INTO global_settings VALUES ('INTERGRATION_WAIT','Time to wait for Intergration Digits','4','INTEGER',1,10,'');
INSERT INTO global_settings VALUES ('VOICEMAIL_DB','Voicemail Database','vm_omatrix_net','CHAR',0,100000,'');
INSERT INTO global_settings VALUES ('VM_PATH','Voicemail Directory','o-matrix.net','CHAR',0,100000,'');

--
-- Table structure for table `holiday_names`
--

DROP TABLE IF EXISTS holiday_names;
CREATE TABLE holiday_names (
  holiday_name varchar(25) NOT NULL default '',
  holiday_desc varchar(255) NOT NULL default '',
  holiday_ord_num smallint(5) NOT NULL default '0',
  state_holiday_flag tinyint(1) NOT NULL default '0',
  holiday_sound_file varchar(100) default '',
  PRIMARY KEY  (holiday_name)
) TYPE=MyISAM COMMENT='These are all the holidays we know of.  ';

--
-- Dumping data for table `holiday_names`
--

INSERT INTO holiday_names VALUES ('New Years Day','',1,0,'new_years_day.wav');
INSERT INTO holiday_names VALUES ('MLK Day','',2,0,'martin_luther_king_junior_day.wav');
INSERT INTO holiday_names VALUES ('Presidents Day','',3,0,'presidents_day.wav');
INSERT INTO holiday_names VALUES ('Kuhio Day','',4,1,'kuhio_day.wav');
INSERT INTO holiday_names VALUES ('Kamehameha Day','',6,1,'kamehameha_day.wav');
INSERT INTO holiday_names VALUES ('Independence Day','',7,0,'independence_day.wav');
INSERT INTO holiday_names VALUES ('Admissions Day','',8,1,'adminssions_day.wav');
INSERT INTO holiday_names VALUES ('Labor Day','',9,0,'labor_day.wav');
INSERT INTO holiday_names VALUES ('Columbus Day','',10,0,'columbus_day.wav');
INSERT INTO holiday_names VALUES ('Election Day','',11,0,'Tuesday.wav');
INSERT INTO holiday_names VALUES ('Veterans Day','',12,0,'veterans_day.wav');
INSERT INTO holiday_names VALUES ('Thanksgiving Day','',13,0,'thanksgiving_holiday.wav');
INSERT INTO holiday_names VALUES ('Day After Thanksgiving','',14,0,'thanksgiving_holiday.wav');
INSERT INTO holiday_names VALUES ('Boxing Day','',15,0,'christmas_holiday.wav');
INSERT INTO holiday_names VALUES ('Christmas Eve','',16,0,'christmas_holiday.wav');
INSERT INTO holiday_names VALUES ('Christmas Day','',17,0,'christmas_holiday.wav');
INSERT INTO holiday_names VALUES ('Day After Christmas','',18,0,'christmas_holiday.wav');
INSERT INTO holiday_names VALUES ('New Years Eve','',19,0,'new_years_day.wav');
INSERT INTO holiday_names VALUES ('Memorial Day','',5,0,'memorial_day.vox');

--
-- Table structure for table `holiday_sounds`
--

DROP TABLE IF EXISTS holiday_sounds;
CREATE TABLE holiday_sounds (
  holiday_name varchar(25) NOT NULL default '',
  sound_file varchar(100) default NULL,
  order_no smallint(6) NOT NULL default '0',
  custom_sound_flag tinyint(1) NOT NULL default '0',
  PRIMARY KEY  (holiday_name,order_no)
) TYPE=MyISAM COMMENT='These are all the holiday sounds.  ';

--
-- Dumping data for table `holiday_sounds`
--

INSERT INTO holiday_sounds VALUES ('Day After Christmas','xmas_greeting.wav',1,0);
INSERT INTO holiday_sounds VALUES ('Christmas Day','xmas_greeting.wav',1,0);
INSERT INTO holiday_sounds VALUES ('New Years Day','new_years_day.wav',2,0);
INSERT INTO holiday_sounds VALUES ('New Years Day','nancy_closed_in_honor_of.wav',1,0);
INSERT INTO holiday_sounds VALUES ('New Years Day','aa_comtel_no_intro.wav',3,0);
INSERT INTO holiday_sounds VALUES ('Memorial Day','aloha_and_ty4_calling.vox',1,0);
INSERT INTO holiday_sounds VALUES ('Memorial Day','memorial_day.vox',2,0);
INSERT INTO holiday_sounds VALUES ('Memorial Day','aa_menu.vox',3,0);
INSERT INTO holiday_sounds VALUES ('Labor Day','closed_in_honor_of.wav',1,0);
INSERT INTO holiday_sounds VALUES ('Labor Day','labor_day.wav',2,0);

--
-- Table structure for table `holidays`
--

DROP TABLE IF EXISTS holidays;
CREATE TABLE holidays (
  holiday_date date NOT NULL default '0000-00-00',
  holiday_name varchar(25) NOT NULL default '',
  start_hour smallint(4) unsigned NOT NULL default '0',
  start_minute smallint(4) unsigned NOT NULL default '0',
  end_hour smallint(4) unsigned NOT NULL default '0',
  end_minute smallint(4) unsigned NOT NULL default '0',
  menu_id int(9) unsigned NOT NULL default '0',
  PRIMARY KEY  (holiday_date)
) TYPE=MyISAM COMMENT='Holiday auto attendant settings.';

--
-- Dumping data for table `holidays`
--

INSERT INTO holidays VALUES ('2012-12-25','Christmas Day',0,0,23,59,603);
INSERT INTO holidays VALUES ('2011-12-26','Day After Christmas',0,0,23,59,603);
INSERT INTO holidays VALUES ('2010-12-27','Christmas Day',0,0,23,59,603);
INSERT INTO holidays VALUES ('2009-12-25','Christmas Day',0,0,23,59,603);
INSERT INTO holidays VALUES ('2008-12-25','Christmas Day',0,0,23,59,603);
INSERT INTO holidays VALUES ('2007-12-25','Christmas Day',0,0,23,59,603);
INSERT INTO holidays VALUES ('2006-12-25','Christmas Day',0,0,23,59,603);
INSERT INTO holidays VALUES ('2005-12-26','Day After Christmas',0,0,23,59,603);
INSERT INTO holidays VALUES ('2004-12-27','Christmas Day',0,0,23,59,603);
INSERT INTO holidays VALUES ('2003-12-25','Christmas Day',0,0,23,59,603);
INSERT INTO holidays VALUES ('2003-12-26','Day After Christmas',0,0,23,59,603);
INSERT INTO holidays VALUES ('2004-12-26','Day After Christmas',0,0,23,59,603);
INSERT INTO holidays VALUES ('2006-12-26','Day After Christmas',0,0,23,59,603);
INSERT INTO holidays VALUES ('2007-12-26','Day After Christmas',0,0,23,59,603);
INSERT INTO holidays VALUES ('2008-12-26','Day After Christmas',0,0,23,59,603);
INSERT INTO holidays VALUES ('2009-12-26','Day After Christmas',0,0,23,59,603);
INSERT INTO holidays VALUES ('2010-12-26','Day After Christmas',0,0,23,59,603);
INSERT INTO holidays VALUES ('2012-12-26','Day After Christmas',0,0,23,59,603);
INSERT INTO holidays VALUES ('2012-01-02','New Years Day',0,0,23,59,603);
INSERT INTO holidays VALUES ('2011-01-03','New Years Day',0,0,23,59,603);
INSERT INTO holidays VALUES ('2010-01-01','New Years Day',0,0,23,59,603);
INSERT INTO holidays VALUES ('2009-01-01','New Years Day',0,0,23,59,603);
INSERT INTO holidays VALUES ('2008-01-01','New Years Day',0,0,23,59,603);
INSERT INTO holidays VALUES ('2007-01-01','New Years Day',0,0,23,59,603);
INSERT INTO holidays VALUES ('2006-01-02','New Years Day',0,0,23,59,603);
INSERT INTO holidays VALUES ('2005-01-03','New Years Day',0,0,23,59,603);
INSERT INTO holidays VALUES ('2004-09-06','Labor Day',0,0,23,59,603);
INSERT INTO holidays VALUES ('2003-01-01','New Years Day',0,0,23,59,603);
INSERT INTO holidays VALUES ('2004-05-31','Memorial Day',8,0,23,59,603);
INSERT INTO holidays VALUES ('2005-05-30','Memorial Day',8,0,23,59,603);
INSERT INTO holidays VALUES ('2006-05-29','Memorial Day',8,0,23,59,603);
INSERT INTO holidays VALUES ('2007-05-28','Memorial Day',8,0,23,59,603);
INSERT INTO holidays VALUES ('2008-05-26','Memorial Day',8,0,23,59,603);
INSERT INTO holidays VALUES ('2009-05-25','Memorial Day',8,0,23,59,603);
INSERT INTO holidays VALUES ('2010-05-31','Memorial Day',8,0,23,59,603);
INSERT INTO holidays VALUES ('2011-05-30','Memorial Day',8,0,23,59,603);
INSERT INTO holidays VALUES ('2012-05-28','Memorial Day',8,0,23,59,603);
INSERT INTO holidays VALUES ('2013-05-27','Memorial Day',8,0,23,59,603);

--
-- Table structure for table `menu`
--

DROP TABLE IF EXISTS menu;
CREATE TABLE menu (
  menu_id int(11) NOT NULL auto_increment,
  title varchar(50) NOT NULL default '',
  menu_type_code varchar(10) NOT NULL default '',
  max_attempts smallint(6) NOT NULL default '5',
  permission_id varchar(10) NOT NULL default 'USER',
  collect_time tinyint(3) unsigned default NULL,
  param1 varchar(15) default NULL,
  param2 varchar(15) default NULL,
  param3 varchar(15) default NULL,
  param4 varchar(15) default NULL,
  PRIMARY KEY  (menu_id),
  KEY permission_id (permission_id)
) TYPE=MyISAM COMMENT='These are all the holidays we know of.  ';

--
-- Dumping data for table `menu`
--

INSERT INTO menu VALUES (240,'Get ID for System Sound','ADMIN',3,'ADMIN',NULL,'GETID','SOUND','','');
INSERT INTO menu VALUES (238,'Mobile Deactivate Notification Menu','USERSET',3,'USER',NULL,'MOBILEDEACT','','','');
INSERT INTO menu VALUES (237,'Moblie Notification Status','USERSET',1,'ANON',NULL,'MOBILESTAT','','','');
INSERT INTO menu VALUES (236,'Plays back the AA greeting they just record','ADMIN',1,'ADMIN',NULL,'RECPLAY','MENU','','');
INSERT INTO menu VALUES (235,'Record Auto Attendant Greeting Options','ADMIN',5,'ADMIN',NULL,'RECOPTS','MENU','','');
INSERT INTO menu VALUES (233,'Get the box number to administer','ADMIN',5,'ADMIN',NULL,'GETID','MENU','','');
INSERT INTO menu VALUES (234,'Record File for Box','ADMIN',5,'ADMIN',NULL,'RECFILE','MENU','','');
INSERT INTO menu VALUES (232,'Confirm Password Reset','ADMIN',4,'ADMIN',NULL,'CONFPWR',NULL,NULL,NULL);
INSERT INTO menu VALUES (230,'Mailbox Add','ADMIN',5,'ADMIN',NULL,'ADDEXT',NULL,NULL,NULL);
INSERT INTO menu VALUES (228,'Admin Main Menu','BASIC',5,'ADMIN',NULL,NULL,NULL,NULL,NULL);
INSERT INTO menu VALUES (229,'Password reset, enter mailbox','ADMIN',5,'ADMIN',NULL,'PWREXT',NULL,NULL,NULL);
INSERT INTO menu VALUES (231,'Confirm Add Mailbox','ADMIN',5,'ADMIN',NULL,'SAVEADDEXT',NULL,NULL,NULL);
INSERT INTO menu VALUES (227,'Thank you For setting up your mailbox','UINFO',5,'USER',NULL,NULL,NULL,NULL,NULL);
INSERT INTO menu VALUES (226,'Tutorial Change Password Confirm Menu','USERSET',5,'USER',NULL,'CONFPASSWD','','','');
INSERT INTO menu VALUES (225,'Tutorial New Password Prompt','USERSET',3,'USER',NULL,'GETPASSWD','','','');
INSERT INTO menu VALUES (224,'Tutorial Info about password','UINFO',3,'USER',NULL,'',NULL,NULL,NULL);
INSERT INTO menu VALUES (601,'Auto Attendant Greeting','AAG',2,'ANON',NULL,NULL,NULL,NULL,NULL);
INSERT INTO menu VALUES (602,'Auto Attendant Night Time Greeting','AAG',1,'ANON',NULL,'','','','');
INSERT INTO menu VALUES (603,'Auto Attendant Holiday Greeting','AAG',3,'ANON',NULL,NULL,NULL,NULL,NULL);
INSERT INTO menu VALUES (605,'Dial By Name Menu','DBNM',2,'ANON',NULL,'BOTH','','','');
INSERT INTO menu VALUES (606,'Dial By Name Result','DBNMRES',3,'ANON',NULL,'BOTH',NULL,NULL,NULL);
INSERT INTO menu VALUES (801,'Record Message','RECMSG',1,'ANON',NULL,NULL,NULL,NULL,NULL);
INSERT INTO menu VALUES (802,'Transfer to Extension','XFER',3,'ANON',NULL,NULL,NULL,NULL,NULL);
INSERT INTO menu VALUES (808,'Post Message Menu...','POSTRECMSG',3,'ANON',NULL,'','','','');
INSERT INTO menu VALUES (809,'Play Back the Message','POSTRECMSG',3,'ANON',NULL,'PLAYMSG','','','');
INSERT INTO menu VALUES (810,'Append to The mesage','APPENDMSG',3,'ANON',NULL,'','','','');
INSERT INTO menu VALUES (222,'Tutorial Greeting Menu','USERSET',3,'USER',NULL,'','','','');
INSERT INTO menu VALUES (223,'Tutorial Play Greeting','USERSET',3,'USER',NULL,'PLAYGREET','','','');
INSERT INTO menu VALUES (220,'Tutorial Information about user greeting','UINFO',3,'USER',NULL,'','','','');
INSERT INTO menu VALUES (221,'Tutorial Record Greeting','USERSET',3,'USER',NULL,'RECGREET','','','');
INSERT INTO menu VALUES (219,'Tutorial Play Name','USERSET',4,'USER',NULL,'PLAYNAME','','','');
INSERT INTO menu VALUES (214,'Change Password Confirm Menu','USERSET',3,'USER',NULL,'CONFPASSWD','','','');
INSERT INTO menu VALUES (215,'User Intro','UINTRO',1,'USER',NULL,NULL,NULL,NULL,NULL);
INSERT INTO menu VALUES (216,'WElcome message for User tutorial','UINFO',3,'USER',NULL,NULL,NULL,NULL,NULL);
INSERT INTO menu VALUES (217,'Tutorial Record Name','USERSET',1,'USER',NULL,'RECNAME','','','');
INSERT INTO menu VALUES (218,'Tutorial Name Menu','USERSET',4,'USER',NULL,'','','','');
INSERT INTO menu VALUES (211,'Record Greeting','USERSET',5,'USER',NULL,'RECGREET','','','');
INSERT INTO menu VALUES (212,'Record Name','USERSET',5,'USER',NULL,'RECNAME','','','');
INSERT INTO menu VALUES (213,'Change Password','USERSET',5,'USER',NULL,'GETPASSWD','','','');
INSERT INTO menu VALUES (210,'Play Name','USERSET',5,'USER',NULL,'PLAYNAME','','','');
INSERT INTO menu VALUES (209,'Play Greeting','USERSET',2,'USER',NULL,'PLAYGREET','','','');
INSERT INTO menu VALUES (207,'Greeting Menu','USERSET',5,'USER',NULL,'','','','');
INSERT INTO menu VALUES (208,'Name Menu','BASIC',5,'USER',NULL,NULL,NULL,NULL,NULL);
INSERT INTO menu VALUES (206,'User Personal Settings','BASIC',5,'USER',NULL,NULL,NULL,NULL,NULL);
INSERT INTO menu VALUES (205,'Saved Messaged','MSGS',3,'USER',NULL,'S',NULL,NULL,NULL);
INSERT INTO menu VALUES (204,'New Messages','MSGS',3,'USER',NULL,'N',NULL,NULL,NULL);
INSERT INTO menu VALUES (255,'Foward Dial by Name Results','FWDMSG',3,'USER',NULL,'DBNMRES','','','');
INSERT INTO menu VALUES (99,'Exit The System','EXIT',1,'ANON',NULL,'EXIT',NULL,NULL,NULL);
INSERT INTO menu VALUES (201,'User Login','LOGIN',5,'ANON',NULL,'','','','');
INSERT INTO menu VALUES (202,'Password Prompt','PASSWD',10,'ANON',NULL,'','','','');
INSERT INTO menu VALUES (203,'User Main Menu','BASIC',5,'USER',NULL,'','','','');
INSERT INTO menu VALUES (257,'Ip  Hear address','ADMIN',1,'ADMIN',0,'','','','');
INSERT INTO menu VALUES (256,'Ip Menu','BASIC',3,'SUPER',NULL,'','','','');
INSERT INTO menu VALUES (258,'IP enter ip address','ADMIN',3,'SUPER',NULL,'GETIPADDRESS','','','');
INSERT INTO menu VALUES (239,'Mobile Notification Activation Menu','USERSET',3,'ANON',NULL,'MOBILEACT','','','');
INSERT INTO menu VALUES (241,'Record Sound Menu','ADMIN',3,'ADMIN',NULL,'RECOPTS','SOUND','','');
INSERT INTO menu VALUES (242,'Play back the Sound','ADMIN',3,'ADMIN',NULL,'RECPLAY','SOUND','','');
INSERT INTO menu VALUES (244,'Record your new sound','ADMIN',3,'ADMIN',NULL,'RECFILE','NEWSOUNDS','','');
INSERT INTO menu VALUES (243,'Record a Sound','ADMIN',3,'ADMIN',NULL,'RECFILE','SOUND','','');
INSERT INTO menu VALUES (247,'Forward Enter Mailbox','FWDMSG',3,'USER',NULL,'GETFWDMB','','','');
INSERT INTO menu VALUES (245,'Record New Sound Menu','ADMIN',3,'ADMIN',NULL,'RECOPTS','NEWSOUND','','');
INSERT INTO menu VALUES (248,'Forward add Another','BASIC',3,'ANON',NULL,'','','','');
INSERT INTO menu VALUES (246,'Play back the new sound','ADMIN',3,'ADMIN',NULL,'RECPLAY','NEWSOUNDS','','');
INSERT INTO menu VALUES (249,'Forward Add Comment Options','BASIC',3,'USER',NULL,'','','','');
INSERT INTO menu VALUES (251,'Record Comments at the end','FWDMSG',3,'USER',NULL,'RECCOMEND','','','');
INSERT INTO menu VALUES (250,'Foward Record Comments','FWDMSG',3,'USER',NULL,'RECCOMBEG','','','');
INSERT INTO menu VALUES (252,'Forward Message Final Process','FWDMSG',1,'USER',NULL,'FWD','','','');
INSERT INTO menu VALUES (253,'Session Detect Messages','MSGS',3,'USER',NULL,'U',NULL,NULL,NULL);
INSERT INTO menu VALUES (254,'Foward MEssage Dial by name enter chars','FWDMSG',3,'USER',NULL,'DBNM','','','');
INSERT INTO menu VALUES (259,'IP enter internal gateway','ADMIN',3,'ADMIN',NULL,'GETIPGATEWAY','','','');
INSERT INTO menu VALUES (260,'IP - Enter subnet mask','ADMIN',3,'SUPER',NULL,'GETIPNETMASK','','','');
INSERT INTO menu VALUES (261,'Ip Set playback','ADMIN',3,'ADMIN',NULL,'','','','');
INSERT INTO menu VALUES (262,'IP Play externel address','ADMIN',1,'ADMIN',0,'','','','');

--
-- Table structure for table `menu_functions`
--

DROP TABLE IF EXISTS menu_functions;
CREATE TABLE menu_functions (
  menu_func_name varchar(25) NOT NULL default '',
  menu_id int(11) NOT NULL default '0',
  PRIMARY KEY  (menu_func_name)
) TYPE=MyISAM COMMENT='These are used by the to tell us which menu to play for a gi';

--
-- Dumping data for table `menu_functions`
--

INSERT INTO menu_functions VALUES ('station_login',202);
INSERT INTO menu_functions VALUES ('take_message',801);
INSERT INTO menu_functions VALUES ('auto_attendant',601);
INSERT INTO menu_functions VALUES ('N_messages',204);
INSERT INTO menu_functions VALUES ('auto_login',215);
INSERT INTO menu_functions VALUES ('S_messages',205);
INSERT INTO menu_functions VALUES ('user_tutorial',216);

--
-- Table structure for table `menu_items`
--

DROP TABLE IF EXISTS menu_items;
CREATE TABLE menu_items (
  menu_item_id int(11) NOT NULL auto_increment,
  menu_id int(11) NOT NULL default '0',
  menu_item_title varchar(100) NOT NULL default '',
  menu_item_option varchar(10) NOT NULL default '',
  dest_menu_id int(11) default NULL,
  menu_item_action varchar(10) default NULL,
  PRIMARY KEY  (menu_item_id)
) TYPE=MyISAM COMMENT='The menu options, their actions and destination menus.  ';

--
-- Dumping data for table `menu_items`
--

INSERT INTO menu_items VALUES (7392,228,'Record a new sound','6',244,'');
INSERT INTO menu_items VALUES (7391,245,'Cancel and go back to main menu','9',228,'CANCEL');
INSERT INTO menu_items VALUES (7390,245,'Play back the new sound','1',246,'');
INSERT INTO menu_items VALUES (7388,243,'Go back to record system sound menu','DEFAULT',241,'');
INSERT INTO menu_items VALUES (7389,244,'Go to record new sound menu','DEFAULT',245,'');
INSERT INTO menu_items VALUES (7387,241,'Save the new sound','3',228,'RECSAVE');
INSERT INTO menu_items VALUES (7386,241,'GO back to admin menu','9',228,'CANCEL');
INSERT INTO menu_items VALUES (7385,241,'Record system greeting','2',243,'');
INSERT INTO menu_items VALUES (7383,241,'Go to play the sound file','1',242,'');
INSERT INTO menu_items VALUES (7384,242,'Go back to System Sound menu','DEFAULT',245,'');
INSERT INTO menu_items VALUES (7382,239,'Activate the mobile notification','1',206,'SAVEMOBILE');
INSERT INTO menu_items VALUES (7380,228,'ReRecord A System Sound','5',240,'');
INSERT INTO menu_items VALUES (7381,239,'Press 9 to exit','9',206,'');
INSERT INTO menu_items VALUES (7378,207,'Save The Greeting','3',206,'SAVEGREET');
INSERT INTO menu_items VALUES (7379,238,'Press 9 to cancel','9',206,'');
INSERT INTO menu_items VALUES (7377,238,'Deactivate Mobile NOtification','2',206,'SAVEMOBILE');
INSERT INTO menu_items VALUES (7376,222,'Save Greeting And Continue','3',224,'SAVEGREET');
INSERT INTO menu_items VALUES (7375,218,'Save and Continue','3',220,'SAVENAME');
INSERT INTO menu_items VALUES (7373,240,'Enter the...','????',241,'');
INSERT INTO menu_items VALUES (7374,236,'Return to Record options','DEFAULT',235,NULL);
INSERT INTO menu_items VALUES (7372,235,'To save the greeting, press 3','3',228,'RECSAVE');
INSERT INTO menu_items VALUES (7371,233,'User Enters box they wish to add','???',235,'ADDEXT');
INSERT INTO menu_items VALUES (7370,235,'To hear the greeting press 1','1',236,'');
INSERT INTO menu_items VALUES (7369,234,'Goes to the next menu','DEFAULT',235,NULL);
INSERT INTO menu_items VALUES (7368,235,'to cancel Press 9','9',228,'CANCEL');
INSERT INTO menu_items VALUES (7367,235,'To re-record this greeting, Press 2','2',234,'');
INSERT INTO menu_items VALUES (7366,232,'Press 1 to save password reset','1',228,'SAVEPWR');
INSERT INTO menu_items VALUES (7365,231,'Press 9 to cancel add  mailbox','9',228,NULL);
INSERT INTO menu_items VALUES (7364,232,'Press 9 to cancel password reset','9',228,NULL);
INSERT INTO menu_items VALUES (7363,230,'User Enters extension they wish to add','DEFAULT',231,'ADDEXT');
INSERT INTO menu_items VALUES (7362,231,'Press 1 to add this mailbox','1',228,'SAVEADDEXT');
INSERT INTO menu_items VALUES (7361,228,'Send em back to the main menu','9',203,NULL);
INSERT INTO menu_items VALUES (7360,229,'Enter the extension to reset the password for','DEFAULT',232,'PWREXT');
INSERT INTO menu_items VALUES (7359,228,'Press 3 to record a greeting for a user','3',233,'');
INSERT INTO menu_items VALUES (7358,228,'Press 1 to reset the password for mailbox','1',229,NULL);
INSERT INTO menu_items VALUES (7357,227,'Thanks for...','DEFAULT',215,'UNSETNUF');
INSERT INTO menu_items VALUES (7355,225,'Return to Password Menu','DEFAULT',226,NULL);
INSERT INTO menu_items VALUES (7356,226,'Press 2 to Do Over','2',225,NULL);
INSERT INTO menu_items VALUES (7354,228,'Press 2 to add a mailbox','2',230,NULL);
INSERT INTO menu_items VALUES (7353,226,'Press 1 to Save','1',227,'SAVEPASSWD');
INSERT INTO menu_items VALUES (7352,224,'Tutorial Record Greeting','DEFAULT',225,NULL);
INSERT INTO menu_items VALUES (7351,220,'Default action for the Record explanation thingie','DEFAULT',221,NULL);
INSERT INTO menu_items VALUES (7350,222,'Press 2 to record your greeting','9',224,NULL);
INSERT INTO menu_items VALUES (7349,221,'Tutorial Record Greeting','DEFAULT',222,NULL);
INSERT INTO menu_items VALUES (7348,222,'Press 2 to record your greeting','2',221,NULL);
INSERT INTO menu_items VALUES (7347,222,'Press 1 to hear your greeting','1',223,NULL);
INSERT INTO menu_items VALUES (7346,223,'Return to Tutorial Greeting Menu','DEFAULT',222,NULL);
INSERT INTO menu_items VALUES (7345,223,'Return to Tutorial Greeting Menu','9',222,NULL);
INSERT INTO menu_items VALUES (7344,218,'Press Go to the next item press 9','9',220,NULL);
INSERT INTO menu_items VALUES (7342,219,'Press to the next item press 9','DEFAULT',218,NULL);
INSERT INTO menu_items VALUES (7343,218,'Press 2 to record your name','2',217,NULL);
INSERT INTO menu_items VALUES (7341,218,'Press 1 to hear your name','1',219,NULL);
INSERT INTO menu_items VALUES (7340,217,'Return to Tutorial Record Name','DEFAULT',218,NULL);
INSERT INTO menu_items VALUES (7339,219,'Press to the next item press 9','9',218,NULL);
INSERT INTO menu_items VALUES (7338,216,'Default action for the intro to the tutorial','DEFAULT',217,NULL);
INSERT INTO menu_items VALUES (7337,215,'Press 4 to go the secret admin menu','4',228,NULL);
INSERT INTO menu_items VALUES (7335,215,'Press 3 to for your personal options','3',206,NULL);
INSERT INTO menu_items VALUES (7336,215,'Press 9 to exit','9',0,NULL);
INSERT INTO menu_items VALUES (7334,215,'Press 2 to Hear Your Saved Messages','2',205,NULL);
INSERT INTO menu_items VALUES (7332,215,'Press 1 to Hear New Messages','1',204,NULL);
INSERT INTO menu_items VALUES (7333,215,'Default','DEFAULT',203,NULL);
INSERT INTO menu_items VALUES (7331,214,'Press 2 to Retry','2',213,NULL);
INSERT INTO menu_items VALUES (7329,214,'Press 9 to Cancel','9',206,'');
INSERT INTO menu_items VALUES (7330,214,'Default','DEFAULT',206,NULL);
INSERT INTO menu_items VALUES (7328,214,'Press 1 to Save','1',206,'SAVEPASSWD');
INSERT INTO menu_items VALUES (7326,211,'Return to Greeting Menu','9',207,'CANCEL');
INSERT INTO menu_items VALUES (7327,212,'Return to Name Menu','DEFAULT',208,'SAVENAME');
INSERT INTO menu_items VALUES (7325,213,'Return to User Admin Menu','DEFAULT',214,NULL);
INSERT INTO menu_items VALUES (7427,601,'transfer to extension','EXT',802,'');
INSERT INTO menu_items VALUES (7101,601,'Record Message to Extension Entered','8EXT',801,'');
INSERT INTO menu_items VALUES (7102,601,'User Login','*',201,'');
INSERT INTO menu_items VALUES (7104,601,'Dial By Name Menu','#',605,'');
INSERT INTO menu_items VALUES (7105,602,'Transfer to Extension Entered','EXT',802,'');
INSERT INTO menu_items VALUES (7106,602,'Record Message to Extension Entered','8EXT',801,'');
INSERT INTO menu_items VALUES (7107,602,'User Login','*',201,'');
INSERT INTO menu_items VALUES (7109,602,'Dial By Name Menu','#',605,'');
INSERT INTO menu_items VALUES (7113,605,'They Entered some chars','DEFAULT',606,'');
INSERT INTO menu_items VALUES (7115,606,'Select This options','#',802,'');
INSERT INTO menu_items VALUES (7116,606,'Go Next Match','1',606,'NEXTNAME');
INSERT INTO menu_items VALUES (7117,606,'Try Dial by name again','2',605,'');
INSERT INTO menu_items VALUES (7118,606,'Try Dial by name again','9',601,'');
INSERT INTO menu_items VALUES (7119,801,'Exit','DEFAULT',0,'');
INSERT INTO menu_items VALUES (7135,801,'Transfer to Operator','0',802,'CANCEL');
INSERT INTO menu_items VALUES (7121,801,'Exit','*',202,'LOGIN');
INSERT INTO menu_items VALUES (7122,808,'Delete the message','3',801,'CANCELMSG');
INSERT INTO menu_items VALUES (7123,808,'Save message and go back to AA','9',601,'SAVEMSG');
INSERT INTO menu_items VALUES (7124,809,'send them back to post message menu','DEFAULT',808,'');
INSERT INTO menu_items VALUES (7125,808,'Play back the message','1',809,'');
INSERT INTO menu_items VALUES (7126,808,'Cancel the message','*',601,'CANCELMSG');
INSERT INTO menu_items VALUES (7127,808,'Append to Message','2',810,'APPMSG');
INSERT INTO menu_items VALUES (7137,601,'Special Login','6',203,'SPECLOGIN');
INSERT INTO menu_items VALUES (7138,602,'Special Login','6',203,'SPECLOGIN');
INSERT INTO menu_items VALUES (7324,212,'Return to Name Menu','9',208,'CANCEL');
INSERT INTO menu_items VALUES (7323,210,'Return to Name Menu','9',208,NULL);
INSERT INTO menu_items VALUES (7148,603,'Record Message to Extension Entered','8EXT',801,'');
INSERT INTO menu_items VALUES (7149,603,'User Login','*',201,'');
INSERT INTO menu_items VALUES (7428,601,'Say Goodbye','DEFAULT',99,'');
INSERT INTO menu_items VALUES (7151,603,'Transfer to Extension Entered','EXT',802,NULL);
INSERT INTO menu_items VALUES (7152,603,'Special Login','6',203,'SPECLOGIN');
INSERT INTO menu_items VALUES (7322,211,'Return to Greeting Menu','DEFAULT',207,'');
INSERT INTO menu_items VALUES (7321,208,'Press 9 to go back to the personal settings','9',206,NULL);
INSERT INTO menu_items VALUES (7320,209,'Return to Greeting Menu','DEFAULT',207,NULL);
INSERT INTO menu_items VALUES (7319,210,'Return to Name Menu','DEFAULT',208,NULL);
INSERT INTO menu_items VALUES (7318,208,'Press 1 to hear your name','1',210,NULL);
INSERT INTO menu_items VALUES (7317,208,'Press 2 to record your name','2',212,'');
INSERT INTO menu_items VALUES (7316,207,'Press 9 to go back to the personal settings','9',206,NULL);
INSERT INTO menu_items VALUES (7315,207,'Press 2 to record your greeti','2',211,NULL);
INSERT INTO menu_items VALUES (7314,207,'Press 1 to hear your greeting','1',209,'');
INSERT INTO menu_items VALUES (7313,206,'Press 4 for Mail notification options','4',237,'');
INSERT INTO menu_items VALUES (7312,206,'Press 9 to go back to the main menu','9',203,NULL);
INSERT INTO menu_items VALUES (7311,206,'Press 3 to change your password','3',213,NULL);
INSERT INTO menu_items VALUES (7310,206,'Press 1 to change your greeting','1',207,NULL);
INSERT INTO menu_items VALUES (7309,206,'Press 2 to change your name','2',208,NULL);
INSERT INTO menu_items VALUES (7308,205,'Return to the Main Menu','9',203,'EXITMSG');
INSERT INTO menu_items VALUES (7307,205,'Save the message','3',205,'SAVEMSG');
INSERT INTO menu_items VALUES (7306,205,'message time and date stamp','4',205,'TDSMSG');
INSERT INTO menu_items VALUES (7305,205,'Mark Message New','5',205,'NEWMSG');
INSERT INTO menu_items VALUES (7304,205,'Repeat the Message','2',205,'REPMSG');
INSERT INTO menu_items VALUES (7303,204,'Mark Message New/Skip Message','5',204,'NEWMSG');
INSERT INTO menu_items VALUES (7302,204,'message time and date stamp','4',204,'TDSMSG');
INSERT INTO menu_items VALUES (7301,204,'Return to the Main Menu','9',203,'EXITMSG');
INSERT INTO menu_items VALUES (7300,205,'Delete the Message','1',205,'DELMSG');
INSERT INTO menu_items VALUES (7299,204,'Save the message','3',204,'SAVEMSG');
INSERT INTO menu_items VALUES (7298,204,'Repeat the Message','2',204,'REPMSG');
INSERT INTO menu_items VALUES (7297,203,'Press 9 to Exit','9',601,'');
INSERT INTO menu_items VALUES (7296,204,'Delete the Message','1',204,'DELMSG');
INSERT INTO menu_items VALUES (7295,203,'Press 4 to go the secret admin menu','4',228,NULL);
INSERT INTO menu_items VALUES (7294,203,'Press 3 to for your personal opts','3',206,NULL);
INSERT INTO menu_items VALUES (7293,203,'Press 2 to Hear Your Saved Messag','2',205,NULL);
INSERT INTO menu_items VALUES (7292,203,'Press 1 to Hear New Messages','1',204,NULL);
INSERT INTO menu_items VALUES (7291,202,'SEnd them to the user tutorials','UTUT',216,NULL);
INSERT INTO menu_items VALUES (7290,202,'Please enter your password','????',215,NULL);
INSERT INTO menu_items VALUES (7289,201,'Please enter your mailbox','???',202,NULL);
INSERT INTO menu_items VALUES (7288,252,'Forward Message','DEFAULT',253,'FWDMSG');
INSERT INTO menu_items VALUES (7287,250,'Send to Final','DEFAULT',252,'');
INSERT INTO menu_items VALUES (7286,249,'go to process','3',252,'');
INSERT INTO menu_items VALUES (7285,249,'Cancel','9',253,'');
INSERT INTO menu_items VALUES (7284,205,'Forward this message','*',247,'');
INSERT INTO menu_items VALUES (7283,254,'Go to results','DEFAULT',255,'');
INSERT INTO menu_items VALUES (7393,245,'Go to record your new sound','2',244,'');
INSERT INTO menu_items VALUES (7394,245,'Save new sound','3',228,'RECSAVE');
INSERT INTO menu_items VALUES (7395,246,'GO back to new sound menu','DEFAULT',245,'');
INSERT INTO menu_items VALUES (7396,204,'Fast Forward Buddy..','8',204,'FFMSG');
INSERT INTO menu_items VALUES (7397,204,'Rewind Message','7',204,'REWMSG');
INSERT INTO menu_items VALUES (7398,205,'Fast Forward','8',205,'FFMSG');
INSERT INTO menu_items VALUES (7399,204,'Forward The Message','*',247,'');
INSERT INTO menu_items VALUES (7400,205,'Rewind Message','7',205,'REWMSG');
INSERT INTO menu_items VALUES (7401,247,'Go TO Forward Message Dbnm','#',254,'');
INSERT INTO menu_items VALUES (7402,248,'Enter another extension','1',247,'');
INSERT INTO menu_items VALUES (7403,247,'Extension Entered','EXT',248,'ADDEXT');
INSERT INTO menu_items VALUES (7404,248,'Cancel and go back to messages','9',253,'');
INSERT INTO menu_items VALUES (7405,248,'Go to comments','2',249,'');
INSERT INTO menu_items VALUES (7406,249,'Add comment to the beginning','1',250,'');
INSERT INTO menu_items VALUES (7407,249,'Add comment to end','2',251,'');
INSERT INTO menu_items VALUES (7408,251,'Send to Final','DEFAULT',252,'');
INSERT INTO menu_items VALUES (7409,255,'Add Extension','#',248,'ADDEXT');
INSERT INTO menu_items VALUES (7410,255,'Go to next name','1',255,'NEXTNAME');
INSERT INTO menu_items VALUES (7411,255,'Try the DBNM again','2',254,'');
INSERT INTO menu_items VALUES (7412,255,'Cancel and go back','9',248,'');
INSERT INTO menu_items VALUES (7413,257,'Go back to menu','DEFAULT',256,'');
INSERT INTO menu_items VALUES (7414,228,'press 4 for ip information','4',256,'');
INSERT INTO menu_items VALUES (7415,256,'Press 1 to hear ip','1',257,'');
INSERT INTO menu_items VALUES (7416,256,'Press 2 to enter IP','2',258,'');
INSERT INTO menu_items VALUES (7417,259,'User Entered IP','IP',260,'');
INSERT INTO menu_items VALUES (7418,258,'Go back to menu','DEFAULT',256,'');
INSERT INTO menu_items VALUES (7419,258,'Enter ip address','IP',259,NULL);
INSERT INTO menu_items VALUES (7420,260,'Enter ip address','IP',261,NULL);
INSERT INTO menu_items VALUES (7421,262,'Go back to the menu','DEFAULT',256,'');
INSERT INTO menu_items VALUES (7422,256,'Press 3 to hear externale ip','3',262,'');
INSERT INTO menu_items VALUES (7423,256,'Go back to the admin menu','9',228,'');
INSERT INTO menu_items VALUES (7424,261,'Save Ip Address','1',256,'SAVEIP');
INSERT INTO menu_items VALUES (7425,261,'Cancel Ip Entry','9',256,'');

--
-- Table structure for table `menu_sound_types`
--

DROP TABLE IF EXISTS menu_sound_types;
CREATE TABLE menu_sound_types (
  menu_type_code varchar(10) NOT NULL default '',
  menu_type_code_descr varchar(200) NOT NULL default '',
  PRIMARY KEY  (menu_type_code)
) TYPE=MyISAM;

--
-- Dumping data for table `menu_sound_types`
--

INSERT INTO menu_sound_types VALUES ('M','Main Sound, played every time');
INSERT INTO menu_sound_types VALUES ('I','Invalid Sound');
INSERT INTO menu_sound_types VALUES ('V','Variable sound, if a certain variable is set, it will be played');
INSERT INTO menu_sound_types VALUES ('S','Played once per session, usually after user logs in');

--
-- Table structure for table `menu_sounds`
--

DROP TABLE IF EXISTS menu_sounds;
CREATE TABLE menu_sounds (
  menu_sound_id int(11) NOT NULL auto_increment,
  menu_id int(11) NOT NULL default '0',
  sound_title varchar(100) NOT NULL default '',
  var_name varchar(50) default NULL,
  sound_file varchar(100) NOT NULL default '',
  order_no smallint(6) NOT NULL default '0',
  sound_type char(1) NOT NULL default 'M',
  menu_text varchar(255) default NULL,
  custom_sound_flag tinyint(1) NOT NULL default '0',
  PRIMARY KEY  (menu_sound_id)
) TYPE=MyISAM COMMENT='Menu sounds to be played, their order, should be either a va';

--
-- Dumping data for table `menu_sounds`
--

INSERT INTO menu_sounds VALUES (2323,249,'Forward Comments Options',NULL,'forward_comment_menu.wav',1,'M',NULL,0);
INSERT INTO menu_sounds VALUES (2320,245,'Added','','added.wav',1,'V',NULL,0);
INSERT INTO menu_sounds VALUES (2321,247,'Forward Enter Mailbox',NULL,'forward_enter_mailbox.wav',1,'M',NULL,0);
INSERT INTO menu_sounds VALUES (2319,244,'Record Greeting',NULL,'admin_sys_snd_record.wav',1,'M',NULL,0);
INSERT INTO menu_sounds VALUES (2318,245,'Admin Greeting Options',NULL,'admin_sys_snd_rec_opts.wav',1,'M',NULL,0);
INSERT INTO menu_sounds VALUES (2317,204,'No New Messages','NOMSG','no_new_messages.wav',0,'V','No New Messages',0);
INSERT INTO menu_sounds VALUES (2316,204,'No More Messages','NOMOREMSG','no_more_new_messages.wav',0,'V','No More Messages',0);
INSERT INTO menu_sounds VALUES (2260,206,'Message Saved','SAVEMSG','messagesaved.wav',0,'V','Message Saved',0);
INSERT INTO menu_sounds VALUES (2261,206,'User Personal Settings Invalid',NULL,'invalid.wav',1,'I','',0);
INSERT INTO menu_sounds VALUES (2263,218,'Tutorial Record Name Menu',NULL,'utut_name.wav',1,'M',NULL,0);
INSERT INTO menu_sounds VALUES (2264,226,'PASSWORD SAID TO THEM: ONE THREE NINER TWO','NEW_PASSWORD','',2,'M',NULL,0);
INSERT INTO menu_sounds VALUES (2259,207,'Greeting Menu',NULL,'greeting_menu.wav',1,'M','Press 1 to hear your greeting|Press 2 to record your greeting|Press 9 to go back to the personal settings',0);
INSERT INTO menu_sounds VALUES (2315,239,'To activate mobile press 1, to exit press 9',NULL,'mobile_notification_activate_menu.wav',1,'M',NULL,0);
INSERT INTO menu_sounds VALUES (2314,237,'Mobile Notification is currently',NULL,'mobile_notification_status.wav',1,'M',NULL,0);
INSERT INTO menu_sounds VALUES (2312,237,'Mobile Notification Status Variable','MOBILE_STATUS','',2,'M',NULL,0);
INSERT INTO menu_sounds VALUES (2313,240,'Enter box to admin',NULL,'admin_enter_sys_snd_number.wav',1,'M',NULL,0);
INSERT INTO menu_sounds VALUES (2310,241,'Record Admin Greeting Options',NULL,'admin_sys_snd_rec_opts.wav',1,'M',NULL,0);
INSERT INTO menu_sounds VALUES (2311,238,'Mobile Notification Deactivated',NULL,'mobile_notification_deactivate_menu.wav',1,'M',NULL,0);
INSERT INTO menu_sounds VALUES (2309,233,'Enter the box numb you wish to record',NULL,'admin_enter_box_number.wav',1,'M',NULL,0);
INSERT INTO menu_sounds VALUES (2307,232,'Play back extension/new password',NULL,'admin_passconf5.wav',5,'M',NULL,0);
INSERT INTO menu_sounds VALUES (2308,232,'Play back extension/new password','ADMINEXT','',4,'M',NULL,0);
INSERT INTO menu_sounds VALUES (2306,234,'Please record your greeting after the tone',NULL,'greeting_record.wav',1,'M',NULL,0);
INSERT INTO menu_sounds VALUES (2305,235,'Options for after they record a greeting',NULL,'admin_greet_rec_opts.wav',1,'M',NULL,0);
INSERT INTO menu_sounds VALUES (2303,230,'That is an invalid mailbox',NULL,'invalid_mailbox.wav',1,'I',NULL,0);
INSERT INTO menu_sounds VALUES (2304,243,'Record Greeting After Tone',NULL,'admin_sys_snd_record.wav',1,'M',NULL,0);
INSERT INTO menu_sounds VALUES (2302,231,'You have entered mailbox ###',NULL,'admin_mb_add_conf1.wav',1,'M',NULL,0);
INSERT INTO menu_sounds VALUES (2300,231,'Mailbox Added',NULL,'admin_mailbox_added.wav',1,'V',NULL,0);
INSERT INTO menu_sounds VALUES (2301,231,'You have entered mailbox ###',NULL,'admin_mb_add_conf3.wav',3,'M',NULL,0);
INSERT INTO menu_sounds VALUES (2297,232,'Play back extension','ADMINEXT','',2,'M',NULL,0);
INSERT INTO menu_sounds VALUES (2298,232,'The password for mailbox',NULL,'admin_passconf1.wav',1,'M',NULL,0);
INSERT INTO menu_sounds VALUES (2299,231,'Play back extension','ADMINEXT','',2,'M',NULL,0);
INSERT INTO menu_sounds VALUES (2296,232,'has been set to',NULL,'admin_passconf3.wav',3,'M',NULL,0);
INSERT INTO menu_sounds VALUES (2295,228,'To reset a user\'s password press 1,',NULL,'admin_main_menu.wav',1,'M','To reset a user\'s password press 1,',0);
INSERT INTO menu_sounds VALUES (2294,229,'Enter the mailbox for the password u wanna reset',NULL,'admin_password_ext.wav',1,'M',NULL,0);
INSERT INTO menu_sounds VALUES (2292,230,'Enter the mailbox u wish to add',NULL,'admin_mb_add.wav',1,'M',NULL,0);
INSERT INTO menu_sounds VALUES (2293,229,'That is an invalid mailbox',NULL,'invalid_mailbox.wav',1,'I',NULL,0);
INSERT INTO menu_sounds VALUES (2291,210,'Name Play',NULL,'name_play.wav',1,'M','Your Name is Recorded as...',0);
INSERT INTO menu_sounds VALUES (2290,211,'Greeting Record',NULL,'greeting_record.wav',1,'M','Record your greeting at the tone ...',0);
INSERT INTO menu_sounds VALUES (2289,212,'Name Record',NULL,'name_record.wav',1,'M','Record Your Name at the tone ...',0);
INSERT INTO menu_sounds VALUES (2286,213,'Change Password',NULL,'password_change_prompt.wav',1,'M','Enter your new password...',0);
INSERT INTO menu_sounds VALUES (2284,213,'Invalid Change Password',NULL,'invalid.wav',1,'I','',0);
INSERT INTO menu_sounds VALUES (2282,213,'Invalid Change Password',NULL,'invalid.wav',1,'I','',0);
INSERT INTO menu_sounds VALUES (2283,214,'Your Password will be saved as',NULL,'password_save_as.wav',1,'M',NULL,0);
INSERT INTO menu_sounds VALUES (2281,214,'To Confimr press 1, to retry 2, exit is 9',NULL,'password_change_menu.wav',3,'M',NULL,0);
INSERT INTO menu_sounds VALUES (2280,214,'PASSWORD SAID TO THEM: ONE THREE NINER TWO','NEW_PASSWORD','',2,'M',NULL,0);
INSERT INTO menu_sounds VALUES (2279,215,'You have','NAME','',2,'M','',0);
INSERT INTO menu_sounds VALUES (2277,215,'You have',NULL,'you_have.wav',3,'M','',0);
INSERT INTO menu_sounds VALUES (2278,215,'blah','NEW_MESSAGE_COUNT','',4,'M','',0);
INSERT INTO menu_sounds VALUES (2274,215,'saved message(s)','SAVED_MESSAGE_SOUND','',8,'M','',0);
INSERT INTO menu_sounds VALUES (2275,215,'new messages','NEW_MESSAGE_SOUND','',5,'M','',0);
INSERT INTO menu_sounds VALUES (2272,215,'and',NULL,'and.wav',6,'M','',0);
INSERT INTO menu_sounds VALUES (2273,215,'saved message count','SAVED_MESSAGE_COUNT','',7,'M','',0);
INSERT INTO menu_sounds VALUES (2271,216,'Welcome to the User tutorial...',NULL,'utut_intro.wav',1,'M',NULL,0);
INSERT INTO menu_sounds VALUES (2268,208,'Name Menu Invalid',NULL,'invalid.wav',1,'I','',0);
INSERT INTO menu_sounds VALUES (2269,209,'Greeting Play',NULL,'greeting_play.wav',1,'M','Your Greeting is Recorded as...',0);
INSERT INTO menu_sounds VALUES (2270,217,'Name Record',NULL,'name_record.wav',1,'M',NULL,0);
INSERT INTO menu_sounds VALUES (2266,207,'Greeting Menu Invalid',NULL,'invalid.wav',1,'I','',0);
INSERT INTO menu_sounds VALUES (2267,208,'Name Menu',NULL,'name_menu.wav',1,'M','Press 1 to hear your name|Press 2 to record your name|Press 9 to go back to the personal settings',0);
INSERT INTO menu_sounds VALUES (2265,227,'Thank u for setting up...',NULL,'utut_done.wav',1,'M',NULL,0);
INSERT INTO menu_sounds VALUES (2090,601,'Auto Attendant Greeting',NULL,'aa_default.wav',1,'M','Aloha, thank you for calling ...',1);
INSERT INTO menu_sounds VALUES (2091,602,'Auto Attendant Greeting',NULL,'aa_default_night.wav',1,'M','Aloha, thank you for calling ...',1);
INSERT INTO menu_sounds VALUES (2092,611,'Dial by Name Menu',NULL,'directorylastname.wav',1,'M','Enter the first letters of your parties first or last name...',0);
INSERT INTO menu_sounds VALUES (2093,612,'Dial by Name Menu Options',NULL,'dial_by_name_options.wav',1,'M','To except, blah...',0);
INSERT INTO menu_sounds VALUES (2095,802,'XFER Sound',NULL,'pleasehold.wav',1,'M','Please Hold',0);
INSERT INTO menu_sounds VALUES (2096,808,'Post Message Menu',NULL,'post_message_menu1.wav',1,'M',NULL,0);
INSERT INTO menu_sounds VALUES (2097,808,'Post message Menu WITHOUT the add to your message option',NULL,'post_message_menu2.wav',2,'M',NULL,0);
INSERT INTO menu_sounds VALUES (2098,810,'Greeting for box 249',NULL,'post_message_append.wav',1,'M',NULL,0);
INSERT INTO menu_sounds VALUES (2100,605,'',NULL,'dial_by_name_prompt.wav',1,'M',NULL,0);
INSERT INTO menu_sounds VALUES (2101,606,'Dial by name options',NULL,'dial_by_name_options.wav',1,'M',NULL,0);
INSERT INTO menu_sounds VALUES (2258,226,'Your Password will be saved as',NULL,'password_save_as.wav',1,'M',NULL,0);
INSERT INTO menu_sounds VALUES (2257,226,'To Confimr press 1, to retry 2',NULL,'utut_password_conf.wav',3,'M',NULL,0);
INSERT INTO menu_sounds VALUES (2256,221,'Record your greeting now...',NULL,'greeting_record.wav',1,'M',NULL,0);
INSERT INTO menu_sounds VALUES (2255,223,'Greeting Menu Invalid',NULL,'invalid.wav',1,'I',NULL,0);
INSERT INTO menu_sounds VALUES (2254,223,'Record Greeting Prompt',NULL,'greeting_play.wav',1,'M',NULL,0);
INSERT INTO menu_sounds VALUES (2252,220,'Welcome to the User tutorial...',NULL,'utut_greet.wav',1,'M',NULL,0);
INSERT INTO menu_sounds VALUES (2253,222,'Greeting Menu',NULL,'utut_greet_menu.wav',1,'M',NULL,0);
INSERT INTO menu_sounds VALUES (2250,225,'Enter Your New Password...',NULL,'password_change_prompt.wav',1,'M',NULL,0);
INSERT INTO menu_sounds VALUES (2249,224,'Password info tutorial...',NULL,'utut_password.wav',1,'M',NULL,0);
INSERT INTO menu_sounds VALUES (2248,219,'Your name is recorded as',NULL,'name_play.wav',1,'M',NULL,0);
INSERT INTO menu_sounds VALUES (2247,222,'Greeting Menu Invalid',NULL,'invalid.wav',1,'I',NULL,0);
INSERT INTO menu_sounds VALUES (2246,218,'Tutorial Record Name Menu Invalid',NULL,'invalid.wav',1,'I',NULL,0);
INSERT INTO menu_sounds VALUES (2245,206,'User Personal Settings',NULL,'user_settings_menu.wav',1,'M','Press 1 to change your greeting|Press 2 to change your name|Press 3 to change your password|Press 9 to go back to the main menu',0);
INSERT INTO menu_sounds VALUES (2244,205,'Message Deleted','DELMSG','messagedeleted.wav',0,'V','Message Deleted',0);
INSERT INTO menu_sounds VALUES (2243,205,'No Saved Messages','NOMSG','no_saved_messages.wav',0,'V','No Saved Messages',0);
INSERT INTO menu_sounds VALUES (2242,205,'Saved Messages',NULL,'message_menu.wav',1,'M','brb',0);
INSERT INTO menu_sounds VALUES (2241,205,'Saved Messages Invalid',NULL,'invalid.wav',1,'I','',0);
INSERT INTO menu_sounds VALUES (2240,205,'No More Messages','NOMOREMSG','no_more_saved_messages.wav',0,'V','No More Messages',0);
INSERT INTO menu_sounds VALUES (2239,204,'Message Deleted','DELMSG','messagedeleted.wav',0,'V','Message Deleted',0);
INSERT INTO menu_sounds VALUES (2238,204,'Message Saved','SAVEMSG','messagedsaved.wav',0,'V','Message Saved',0);
INSERT INTO menu_sounds VALUES (2237,205,'Next Message','NEWMSG','next_message.wav',0,'V','Next Message',0);
INSERT INTO menu_sounds VALUES (2236,204,'New Message Invalid',NULL,'invalid.wav',1,'I','Please enter your mailbox',0);
INSERT INTO menu_sounds VALUES (2235,204,'New Messages',NULL,'message_menu.wav',1,'M','brb',0);
INSERT INTO menu_sounds VALUES (2234,203,'Main Menu Prompt',NULL,'user_main_menu.wav',1,'M','Press 1 to Hear New Messages|Press 2 to Hear Your Saved Messages|Press 3 to for your personal options|Press 9 to exit',0);
INSERT INTO menu_sounds VALUES (2233,203,'Main Menu Prompt Invalid',NULL,'invalid.wav',1,'I','',0);
INSERT INTO menu_sounds VALUES (2232,202,'Password Prompt',NULL,'password_prompt.wav',1,'M','Please enter your password',0);
INSERT INTO menu_sounds VALUES (2231,202,'Password Prompt Invalid',NULL,'passwordbad.wav',1,'I','',0);
INSERT INTO menu_sounds VALUES (2230,204,'Next Message','NEWMSG','next_message.wav',0,'V','Next Message',0);
INSERT INTO menu_sounds VALUES (2229,201,'Please enter your mailbox',NULL,'mailbox_prompt.wav',1,'M',NULL,0);
INSERT INTO menu_sounds VALUES (2228,201,'Mailbox Prompt Invalid',NULL,'invalid.wav',1,'I','',0);
INSERT INTO menu_sounds VALUES (2227,205,'Message Saved','SAVEMSG','messagedsaved.wav',0,'V','Message Saved',0);
INSERT INTO menu_sounds VALUES (2226,256,'',NULL,'ip_main_menu.wav',1,'M',NULL,0);
INSERT INTO menu_sounds VALUES (2225,257,'',NULL,'ip_play_internal.wav',1,'M',NULL,0);
INSERT INTO menu_sounds VALUES (2324,248,'Forward Mailbox Options',NULL,'forward_mailbox_menu.wav',1,'M',NULL,0);
INSERT INTO menu_sounds VALUES (2325,250,'Forward Record Comments Prompt',NULL,'forward_record.wav',1,'M',NULL,0);
INSERT INTO menu_sounds VALUES (2326,251,'Forward Record Comments Prompt',NULL,'forward_record.wav',1,'M',NULL,0);
INSERT INTO menu_sounds VALUES (2328,252,'',NULL,'message_forwarded_conf_short.wav',1,'M',NULL,0);
INSERT INTO menu_sounds VALUES (2329,254,'',NULL,'dial_by_name_prompt.wav',1,'M',NULL,0);
INSERT INTO menu_sounds VALUES (2330,255,'',NULL,'dial_by_name_options.wav',1,'M',NULL,0);
INSERT INTO menu_sounds VALUES (2333,258,'',NULL,'ip_set_internal.wav',1,'M',NULL,0);
INSERT INTO menu_sounds VALUES (2334,259,'',NULL,'ip_set_internal_gateway.wav',1,'M',NULL,0);
INSERT INTO menu_sounds VALUES (2335,260,'',NULL,'ip_set_internal_subnet.wav',1,'M',NULL,0);
INSERT INTO menu_sounds VALUES (2336,261,'',NULL,'ip_playback.wav',1,'M',NULL,0);
INSERT INTO menu_sounds VALUES (2337,261,'','NEW_IPADDRESS','',2,'M',NULL,0);
INSERT INTO menu_sounds VALUES (2338,261,'',NULL,'ip_gateway_playback.wav',3,'M',NULL,0);
INSERT INTO menu_sounds VALUES (2339,262,'',NULL,'ip_play_external.wav',1,'M',NULL,0);
INSERT INTO menu_sounds VALUES (2340,262,'','IPEXTERNAL','',2,'M',NULL,0);
INSERT INTO menu_sounds VALUES (2341,257,'','IPADDRESS','',2,'M',NULL,0);
INSERT INTO menu_sounds VALUES (2342,257,'',NULL,'ip_play_internal_gateway.wav',3,'M',NULL,0);
INSERT INTO menu_sounds VALUES (2343,257,'','IPGATEWAY','',4,'M',NULL,0);
INSERT INTO menu_sounds VALUES (2344,257,'',NULL,'ip_play_internal_subnet.wav',5,'M',NULL,0);
INSERT INTO menu_sounds VALUES (2345,257,'','IPNETMASK','',6,'M',NULL,0);
INSERT INTO menu_sounds VALUES (2346,261,'','NEW_IPGATEWAY','',4,'M',NULL,0);
INSERT INTO menu_sounds VALUES (2347,261,'',NULL,'ip_subnet_playback.wav',5,'M',NULL,0);
INSERT INTO menu_sounds VALUES (2348,261,'','NEW_IPNETMASK','',6,'M',NULL,0);
INSERT INTO menu_sounds VALUES (2349,261,'',NULL,'ip_set_menu.wav',7,'M',NULL,0);

--
-- Table structure for table `menu_types`
--

DROP TABLE IF EXISTS menu_types;
CREATE TABLE menu_types (
  menu_type_code varchar(10) NOT NULL default '',
  menu_type_code_descr varchar(200) NOT NULL default '',
  PRIMARY KEY  (menu_type_code)
) TYPE=MyISAM COMMENT='All the different types of menus. Each one has a correspondi';

--
-- Dumping data for table `menu_types`
--

INSERT INTO menu_types VALUES ('AAG','Auto Attendant Main Greeting');
INSERT INTO menu_types VALUES ('BASIC','Basic single input options');
INSERT INTO menu_types VALUES ('DBNM','Dial By Name Menu');
INSERT INTO menu_types VALUES ('DBNMRES','Dial By Name Results');
INSERT INTO menu_types VALUES ('LOGIN','Prompts user for Extension to login');
INSERT INTO menu_types VALUES ('MSGS','Plays User their messages.');
INSERT INTO menu_types VALUES ('PASSWD','Prompts user for password');
INSERT INTO menu_types VALUES ('RECMSG','Records a message for the given extension');
INSERT INTO menu_types VALUES ('SETGET','Record/Get a Setting (Greeting, Name).');
INSERT INTO menu_types VALUES ('SETPLAY','Play a Setting (Greeting, Name).');
INSERT INTO menu_types VALUES ('XFER','Transfer to an extension');
INSERT INTO menu_types VALUES ('UINTRO','Intro to User');
INSERT INTO menu_types VALUES ('UINFO','Information played only once.');
INSERT INTO menu_types VALUES ('SQ','Sound Queue');
INSERT INTO menu_types VALUES ('GREETGET','Gets a greeting from a user');
INSERT INTO menu_types VALUES ('ADMIN','Administration Menu');
INSERT INTO menu_types VALUES ('POSTRECMSG','Post Record Message Processing and Menu');
INSERT INTO menu_types VALUES ('APPENDMSG','Append to the existing message');

--
-- Table structure for table `mwi_status`
--

DROP TABLE IF EXISTS mwi_status;
CREATE TABLE mwi_status (
  extension varchar(10) NOT NULL default '',
  last_sent datetime NOT NULL default '2001-01-01 00:00:00',
  last_new_message_count int(11) NOT NULL default '0',
  PRIMARY KEY  (extension)
) TYPE=MyISAM COMMENT='Who need mwi sent. differs how it is implemented depending o';

--
-- Dumping data for table `mwi_status`
--

INSERT INTO mwi_status VALUES ('342','2001-01-01 00:00:00',0);
INSERT INTO mwi_status VALUES ('473','2001-01-01 00:00:00',0);
INSERT INTO mwi_status VALUES ('474','2004-08-04 19:22:35',0);
INSERT INTO mwi_status VALUES ('475','2004-08-05 16:12:45',0);
INSERT INTO mwi_status VALUES ('798','2001-01-01 00:00:00',0);
INSERT INTO mwi_status VALUES ('799','2004-08-04 18:49:51',2);
INSERT INTO mwi_status VALUES ('479','2001-01-01 00:00:00',0);
INSERT INTO mwi_status VALUES ('478','2001-01-01 00:00:00',0);

--
-- Table structure for table `sound_files`
--

DROP TABLE IF EXISTS sound_files;
CREATE TABLE sound_files (
  file_id int(10) NOT NULL auto_increment,
  sound_file varchar(100) NOT NULL default '',
  file_description varchar(254) default NULL,
  professional tinyint(1) NOT NULL default '0',
  PRIMARY KEY  (file_id),
  UNIQUE KEY sound_file (sound_file)
) TYPE=MyISAM COMMENT='All the files available in /var/spool/openums/prompts';

--
-- Dumping data for table `sound_files`
--

INSERT INTO sound_files VALUES (3001,'0.wav',NULL,1);
INSERT INTO sound_files VALUES (3002,'1.wav',NULL,1);
INSERT INTO sound_files VALUES (3003,'10.wav',NULL,1);
INSERT INTO sound_files VALUES (3004,'100.wav',NULL,1);
INSERT INTO sound_files VALUES (3005,'1000.wav',NULL,1);
INSERT INTO sound_files VALUES (3006,'1000000.wav',NULL,1);
INSERT INTO sound_files VALUES (3007,'101.wav',NULL,1);
INSERT INTO sound_files VALUES (3008,'101_alt.wav',NULL,1);
INSERT INTO sound_files VALUES (3009,'106.wav',NULL,1);
INSERT INTO sound_files VALUES (3010,'10card.wav',NULL,1);
INSERT INTO sound_files VALUES (3011,'11.wav',NULL,1);
INSERT INTO sound_files VALUES (3012,'110.wav',NULL,1);
INSERT INTO sound_files VALUES (3013,'11card.wav',NULL,1);
INSERT INTO sound_files VALUES (3014,'12.wav',NULL,1);
INSERT INTO sound_files VALUES (3015,'122.wav',NULL,1);
INSERT INTO sound_files VALUES (3016,'123.wav',NULL,1);
INSERT INTO sound_files VALUES (3017,'125.wav',NULL,1);
INSERT INTO sound_files VALUES (3018,'125_alt.wav',NULL,1);
INSERT INTO sound_files VALUES (3019,'125_alt2.wav',NULL,1);
INSERT INTO sound_files VALUES (3020,'126.wav',NULL,1);
INSERT INTO sound_files VALUES (3021,'12card.wav',NULL,1);
INSERT INTO sound_files VALUES (3022,'13.wav',NULL,1);
INSERT INTO sound_files VALUES (3023,'13card.wav',NULL,1);
INSERT INTO sound_files VALUES (3024,'14.wav',NULL,1);
INSERT INTO sound_files VALUES (3025,'147.wav',NULL,1);
INSERT INTO sound_files VALUES (3026,'14card.wav',NULL,1);
INSERT INTO sound_files VALUES (3027,'15.wav',NULL,1);
INSERT INTO sound_files VALUES (3028,'155.wav',NULL,1);
INSERT INTO sound_files VALUES (3029,'15card.wav',NULL,1);
INSERT INTO sound_files VALUES (3030,'16.wav',NULL,1);
INSERT INTO sound_files VALUES (3031,'16card.wav',NULL,1);
INSERT INTO sound_files VALUES (3032,'17.wav',NULL,1);
INSERT INTO sound_files VALUES (3033,'17card.wav',NULL,1);
INSERT INTO sound_files VALUES (3034,'18.wav',NULL,1);
INSERT INTO sound_files VALUES (3035,'18card.wav',NULL,1);
INSERT INTO sound_files VALUES (3036,'19.wav',NULL,1);
INSERT INTO sound_files VALUES (3037,'19card.wav',NULL,1);
INSERT INTO sound_files VALUES (3038,'1card.wav',NULL,1);
INSERT INTO sound_files VALUES (3039,'2.wav',NULL,1);
INSERT INTO sound_files VALUES (3040,'20.wav',NULL,1);
INSERT INTO sound_files VALUES (3041,'20card.wav',NULL,1);
INSERT INTO sound_files VALUES (3042,'2card.wav',NULL,1);
INSERT INTO sound_files VALUES (3043,'3.wav',NULL,1);
INSERT INTO sound_files VALUES (3044,'30.wav',NULL,1);
INSERT INTO sound_files VALUES (3045,'301.wav',NULL,1);
INSERT INTO sound_files VALUES (3046,'30card.wav',NULL,1);
INSERT INTO sound_files VALUES (3047,'31card.wav',NULL,1);
INSERT INTO sound_files VALUES (3048,'3card.wav',NULL,1);
INSERT INTO sound_files VALUES (3049,'4.wav',NULL,1);
INSERT INTO sound_files VALUES (3050,'40.wav',NULL,1);
INSERT INTO sound_files VALUES (3051,'4card.wav',NULL,1);
INSERT INTO sound_files VALUES (3052,'5.wav',NULL,1);
INSERT INTO sound_files VALUES (3053,'50.wav',NULL,1);
INSERT INTO sound_files VALUES (3054,'5card.wav',NULL,1);
INSERT INTO sound_files VALUES (3055,'6.wav',NULL,1);
INSERT INTO sound_files VALUES (3056,'60.wav',NULL,1);
INSERT INTO sound_files VALUES (3057,'6card.wav',NULL,1);
INSERT INTO sound_files VALUES (3058,'7.wav',NULL,1);
INSERT INTO sound_files VALUES (3059,'70.wav',NULL,1);
INSERT INTO sound_files VALUES (3060,'7card.wav',NULL,1);
INSERT INTO sound_files VALUES (3061,'8.wav',NULL,1);
INSERT INTO sound_files VALUES (3062,'80.wav',NULL,1);
INSERT INTO sound_files VALUES (3063,'8card.wav',NULL,1);
INSERT INTO sound_files VALUES (3064,'9.wav',NULL,1);
INSERT INTO sound_files VALUES (3065,'90.wav',NULL,1);
INSERT INTO sound_files VALUES (3066,'9card.wav',NULL,1);
INSERT INTO sound_files VALUES (3067,'Friday.wav',NULL,1);
INSERT INTO sound_files VALUES (3068,'January.wav',NULL,1);
INSERT INTO sound_files VALUES (3069,'Monday.wav',NULL,1);
INSERT INTO sound_files VALUES (3070,'Saturday.wav',NULL,1);
INSERT INTO sound_files VALUES (3071,'Sunday.wav',NULL,1);
INSERT INTO sound_files VALUES (3072,'Thursday.wav',NULL,1);
INSERT INTO sound_files VALUES (3073,'Tuesday.wav',NULL,1);
INSERT INTO sound_files VALUES (3074,'Wednesday.wav',NULL,1);
INSERT INTO sound_files VALUES (3075,'aa_601_default.wav',NULL,1);
INSERT INTO sound_files VALUES (3076,'aa_700.wav',NULL,1);
INSERT INTO sound_files VALUES (3077,'aa_710.wav',NULL,1);
INSERT INTO sound_files VALUES (3078,'aa_720.wav',NULL,1);
INSERT INTO sound_files VALUES (3079,'aa_800.wav',NULL,1);
INSERT INTO sound_files VALUES (3080,'aa_800_alt.wav',NULL,1);
INSERT INTO sound_files VALUES (3081,'aa_820.wav',NULL,1);
INSERT INTO sound_files VALUES (3082,'aa_820_alt.wav',NULL,1);
INSERT INTO sound_files VALUES (3083,'aa_default.wav',NULL,1);
INSERT INTO sound_files VALUES (3084,'aa_default_night.wav',NULL,1);
INSERT INTO sound_files VALUES (3085,'aa_menu.wav',NULL,1);
INSERT INTO sound_files VALUES (3086,'accessing_messages.wav',NULL,1);
INSERT INTO sound_files VALUES (3087,'activated.wav',NULL,1);
INSERT INTO sound_files VALUES (3088,'added.wav',NULL,1);
INSERT INTO sound_files VALUES (3089,'admin_enter_box_number.wav',NULL,1);
INSERT INTO sound_files VALUES (3090,'admin_enter_sys_snd_number.wav',NULL,1);
INSERT INTO sound_files VALUES (3091,'admin_greet_no_saved.wav',NULL,1);
INSERT INTO sound_files VALUES (3092,'admin_greet_rec_as.wav',NULL,1);
INSERT INTO sound_files VALUES (3093,'admin_greet_rec_opts.wav',NULL,1);
INSERT INTO sound_files VALUES (3094,'admin_greet_saved.wav',NULL,1);
INSERT INTO sound_files VALUES (3095,'admin_mailbox_added.wav',NULL,1);
INSERT INTO sound_files VALUES (3096,'admin_main_menu.wav',NULL,1);
INSERT INTO sound_files VALUES (3097,'admin_mb_add.wav',NULL,1);
INSERT INTO sound_files VALUES (3098,'admin_mb_add_conf1.wav',NULL,1);
INSERT INTO sound_files VALUES (3099,'admin_mb_add_conf3.wav',NULL,1);
INSERT INTO sound_files VALUES (3100,'admin_menu.wav',NULL,1);
INSERT INTO sound_files VALUES (3101,'admin_passconf1.wav',NULL,1);
INSERT INTO sound_files VALUES (3102,'admin_passconf3.wav',NULL,1);
INSERT INTO sound_files VALUES (3103,'admin_passconf5.wav',NULL,1);
INSERT INTO sound_files VALUES (3104,'admin_password_ext.wav',NULL,1);
INSERT INTO sound_files VALUES (3105,'admin_sys_snd_rec_opts.wav',NULL,1);
INSERT INTO sound_files VALUES (3106,'admin_sys_snd_record.wav',NULL,1);
INSERT INTO sound_files VALUES (3107,'admissions_day.wav',NULL,1);
INSERT INTO sound_files VALUES (3108,'aloha.wav',NULL,1);
INSERT INTO sound_files VALUES (3109,'aloha_and_ty4_calling.wav',NULL,1);
INSERT INTO sound_files VALUES (3110,'am.wav',NULL,1);
INSERT INTO sound_files VALUES (3111,'and.wav',NULL,1);
INSERT INTO sound_files VALUES (3112,'april.wav',NULL,1);
INSERT INTO sound_files VALUES (3113,'at.wav',NULL,1);
INSERT INTO sound_files VALUES (3114,'august.wav',NULL,1);
INSERT INTO sound_files VALUES (3115,'beep.wav',NULL,1);
INSERT INTO sound_files VALUES (3116,'callout_main.wav',NULL,1);
INSERT INTO sound_files VALUES (3117,'callout_menu_intro.wav',NULL,1);
INSERT INTO sound_files VALUES (3118,'callout_message_menu.wav',NULL,1);
INSERT INTO sound_files VALUES (3119,'christmas_holiday.wav',NULL,1);
INSERT INTO sound_files VALUES (3120,'closed_in_honor_of.wav',NULL,1);
INSERT INTO sound_files VALUES (3121,'columbus_day.wav',NULL,1);
INSERT INTO sound_files VALUES (3122,'custom_aa_601.wav',NULL,1);
INSERT INTO sound_files VALUES (3123,'custom_aa_602.wav',NULL,1);
INSERT INTO sound_files VALUES (3124,'custom_aa_607.wav',NULL,1);
INSERT INTO sound_files VALUES (3125,'custom_aa_608.wav',NULL,1);
INSERT INTO sound_files VALUES (3126,'custom_aa_609.wav',NULL,1);
INSERT INTO sound_files VALUES (3127,'deactivated.wav',NULL,1);
INSERT INTO sound_files VALUES (3128,'december.wav',NULL,1);
INSERT INTO sound_files VALUES (3129,'dial_by_name_options.wav',NULL,1);
INSERT INTO sound_files VALUES (3130,'dial_by_name_prompt.wav',NULL,1);
INSERT INTO sound_files VALUES (3131,'directoryfirstname.wav',NULL,1);
INSERT INTO sound_files VALUES (3132,'directorylastname.wav',NULL,1);
INSERT INTO sound_files VALUES (3133,'doesnotanswer.wav',NULL,1);
INSERT INTO sound_files VALUES (3134,'dot.wav',NULL,1);
INSERT INTO sound_files VALUES (3135,'extension.wav',NULL,1);
INSERT INTO sound_files VALUES (3136,'external_ip_error.wav',NULL,1);
INSERT INTO sound_files VALUES (3137,'february.wav',NULL,1);
INSERT INTO sound_files VALUES (3138,'forward_comment_menu.wav',NULL,1);
INSERT INTO sound_files VALUES (3139,'forward_conf.wav',NULL,1);
INSERT INTO sound_files VALUES (3140,'forward_enter_mailbox.wav',NULL,1);
INSERT INTO sound_files VALUES (3141,'forward_mailbox_conf.wav',NULL,1);
INSERT INTO sound_files VALUES (3142,'forward_mailbox_menu.wav',NULL,1);
INSERT INTO sound_files VALUES (3143,'forward_mb_options.wav',NULL,1);
INSERT INTO sound_files VALUES (3144,'forward_record.wav',NULL,1);
INSERT INTO sound_files VALUES (3145,'gateway_invalid.wav',NULL,1);
INSERT INTO sound_files VALUES (3146,'goodbye.wav',NULL,1);
INSERT INTO sound_files VALUES (3147,'greeting_activate.wav',NULL,1);
INSERT INTO sound_files VALUES (3148,'greeting_delete.wav',NULL,1);
INSERT INTO sound_files VALUES (3149,'greeting_menu.wav',NULL,1);
INSERT INTO sound_files VALUES (3150,'greeting_play.wav',NULL,1);
INSERT INTO sound_files VALUES (3151,'greeting_record.wav',NULL,1);
INSERT INTO sound_files VALUES (3152,'here_now.wav',NULL,1);
INSERT INTO sound_files VALUES (3153,'imsorry.wav',NULL,1);
INSERT INTO sound_files VALUES (3154,'independence_day.wav',NULL,1);
INSERT INTO sound_files VALUES (3155,'invalid.wav',NULL,1);
INSERT INTO sound_files VALUES (3156,'invalid_mailbox.wav',NULL,1);
INSERT INTO sound_files VALUES (3157,'ip_gateway_playback.wav',NULL,1);
INSERT INTO sound_files VALUES (3158,'ip_invalid.wav',NULL,1);
INSERT INTO sound_files VALUES (3159,'ip_main_menu.wav',NULL,1);
INSERT INTO sound_files VALUES (3160,'ip_play_external.wav',NULL,1);
INSERT INTO sound_files VALUES (3161,'ip_play_internal.wav',NULL,1);
INSERT INTO sound_files VALUES (3162,'ip_play_internal_gateway.wav',NULL,1);
INSERT INTO sound_files VALUES (3163,'ip_play_internal_subnet.wav',NULL,1);
INSERT INTO sound_files VALUES (3164,'ip_playback.wav',NULL,1);
INSERT INTO sound_files VALUES (3165,'ip_set_internal.wav',NULL,1);
INSERT INTO sound_files VALUES (3166,'ip_set_internal_gateway.wav',NULL,1);
INSERT INTO sound_files VALUES (3167,'ip_set_internal_subnet.wav',NULL,1);
INSERT INTO sound_files VALUES (3168,'ip_set_menu.wav',NULL,1);
INSERT INTO sound_files VALUES (3169,'ip_subnet_playback.wav',NULL,1);
INSERT INTO sound_files VALUES (3170,'july.wav',NULL,1);
INSERT INTO sound_files VALUES (3171,'june.wav',NULL,1);
INSERT INTO sound_files VALUES (3172,'kamehameha_day.wav',NULL,1);
INSERT INTO sound_files VALUES (3173,'kuhio_day.wav',NULL,1);
INSERT INTO sound_files VALUES (3174,'labor_day.wav',NULL,1);
INSERT INTO sound_files VALUES (3175,'mailbox_prompt.wav',NULL,1);
INSERT INTO sound_files VALUES (3176,'main_menu.wav',NULL,1);
INSERT INTO sound_files VALUES (3177,'march.wav',NULL,1);
INSERT INTO sound_files VALUES (3178,'martin_luther_king_junior_day.wav',NULL,1);
INSERT INTO sound_files VALUES (3179,'matts_greeting.wav',NULL,1);
INSERT INTO sound_files VALUES (3180,'may.wav',NULL,1);
INSERT INTO sound_files VALUES (3181,'memorial_day.wav',NULL,1);
INSERT INTO sound_files VALUES (3182,'message_forwarded_conf.wav',NULL,1);
INSERT INTO sound_files VALUES (3183,'message_forwarded_conf_short.wav',NULL,1);
INSERT INTO sound_files VALUES (3184,'message_forwarded_info.wav',NULL,1);
INSERT INTO sound_files VALUES (3185,'message_menu.wav',NULL,1);
INSERT INTO sound_files VALUES (3186,'message_menu_30.wav',NULL,1);
INSERT INTO sound_files VALUES (3187,'message_menu_noforward_noreturn.wav',NULL,1);
INSERT INTO sound_files VALUES (3188,'message_menu_noreturn.wav',NULL,1);
INSERT INTO sound_files VALUES (3189,'message_sent.wav',NULL,1);
INSERT INTO sound_files VALUES (3190,'messagecanceled.wav',NULL,1);
INSERT INTO sound_files VALUES (3191,'messagedeleted.wav',NULL,1);
INSERT INTO sound_files VALUES (3192,'messagedsaved.wav',NULL,1);
INSERT INTO sound_files VALUES (3193,'messages.wav',NULL,1);
INSERT INTO sound_files VALUES (3194,'messagesaved.wav',NULL,1);
INSERT INTO sound_files VALUES (3195,'minute.wav',NULL,1);
INSERT INTO sound_files VALUES (3196,'minutes.wav',NULL,1);
INSERT INTO sound_files VALUES (3197,'mobile_notification_activate_menu.wav',NULL,1);
INSERT INTO sound_files VALUES (3198,'mobile_notification_activated.wav',NULL,1);
INSERT INTO sound_files VALUES (3199,'mobile_notification_deactivate_menu.wav',NULL,1);
INSERT INTO sound_files VALUES (3200,'mobile_notification_deactivated.wav',NULL,1);
INSERT INTO sound_files VALUES (3201,'mobile_notification_error.wav',NULL,1);
INSERT INTO sound_files VALUES (3202,'mobile_notification_status.wav',NULL,1);
INSERT INTO sound_files VALUES (3203,'name_menu.wav',NULL,1);
INSERT INTO sound_files VALUES (3204,'name_play.wav',NULL,1);
INSERT INTO sound_files VALUES (3205,'name_record.wav',NULL,1);
INSERT INTO sound_files VALUES (3206,'new_years_day.wav',NULL,1);
INSERT INTO sound_files VALUES (3207,'new_years_eve.wav',NULL,1);
INSERT INTO sound_files VALUES (3208,'newmessage.wav',NULL,1);
INSERT INTO sound_files VALUES (3209,'newmessages.wav',NULL,1);
INSERT INTO sound_files VALUES (3210,'next_greeting.wav',NULL,1);
INSERT INTO sound_files VALUES (3211,'next_message.wav',NULL,1);
INSERT INTO sound_files VALUES (3212,'nextmessage.wav',NULL,1);
INSERT INTO sound_files VALUES (3213,'no_more_messages.wav',NULL,1);
INSERT INTO sound_files VALUES (3214,'no_more_new_message.wav',NULL,1);
INSERT INTO sound_files VALUES (3215,'no_more_new_messages.wav',NULL,1);
INSERT INTO sound_files VALUES (3216,'no_more_saved_message.wav',NULL,1);
INSERT INTO sound_files VALUES (3217,'no_more_saved_messages.wav',NULL,1);
INSERT INTO sound_files VALUES (3218,'no_new_messages.wav',NULL,1);
INSERT INTO sound_files VALUES (3219,'no_saved_messages.wav',NULL,1);
INSERT INTO sound_files VALUES (3220,'nogreetingrecorded.wav',NULL,1);
INSERT INTO sound_files VALUES (3221,'nomatch.wav',NULL,1);
INSERT INTO sound_files VALUES (3222,'nonamerecorded.wav',NULL,1);
INSERT INTO sound_files VALUES (3223,'nonewmessages.wav',NULL,1);
INSERT INTO sound_files VALUES (3224,'nosavedmessages.wav',NULL,1);
INSERT INTO sound_files VALUES (3225,'notvalidextension.wav',NULL,1);
INSERT INTO sound_files VALUES (3226,'november.wav',NULL,1);
INSERT INTO sound_files VALUES (3227,'october.wav',NULL,1);
INSERT INTO sound_files VALUES (3228,'off.wav',NULL,1);
INSERT INTO sound_files VALUES (3229,'on.wav',NULL,1);
INSERT INTO sound_files VALUES (3230,'opening.wav',NULL,1);
INSERT INTO sound_files VALUES (3231,'options_manu.wav',NULL,1);
INSERT INTO sound_files VALUES (3232,'out_of_office_until.wav',NULL,1);
INSERT INTO sound_files VALUES (3233,'outside_normal_hours.wav',NULL,1);
INSERT INTO sound_files VALUES (3234,'password_change_menu.wav',NULL,1);
INSERT INTO sound_files VALUES (3235,'password_change_prompt.wav',NULL,1);
INSERT INTO sound_files VALUES (3236,'password_prompt.wav',NULL,1);
INSERT INTO sound_files VALUES (3237,'password_save_as.wav',NULL,1);
INSERT INTO sound_files VALUES (3238,'password_saved.wav',NULL,1);
INSERT INTO sound_files VALUES (3239,'passwordbad.wav',NULL,1);
INSERT INTO sound_files VALUES (3240,'passwordconfirm.wav',NULL,1);
INSERT INTO sound_files VALUES (3241,'passwordfail.wav',NULL,1);
INSERT INTO sound_files VALUES (3242,'passwordsaveas.wav',NULL,1);
INSERT INTO sound_files VALUES (3243,'passwordsuccess.wav',NULL,1);
INSERT INTO sound_files VALUES (3244,'please_hold_tansfer.wav',NULL,1);
INSERT INTO sound_files VALUES (3245,'pleasehold.wav',NULL,1);
INSERT INTO sound_files VALUES (3246,'pm.wav',NULL,1);
INSERT INTO sound_files VALUES (3247,'post_message_append.wav',NULL,1);
INSERT INTO sound_files VALUES (3248,'post_message_menu1.wav',NULL,1);
INSERT INTO sound_files VALUES (3249,'post_message_menu2.wav',NULL,1);
INSERT INTO sound_files VALUES (3250,'presidents_day.wav',NULL,1);
INSERT INTO sound_files VALUES (3251,'record_message_after_tone.wav',NULL,1);
INSERT INTO sound_files VALUES (3252,'repeatmessage.wav',NULL,1);
INSERT INTO sound_files VALUES (3253,'retrymessage.wav',NULL,1);
INSERT INTO sound_files VALUES (3254,'return_call.wav',NULL,1);
INSERT INTO sound_files VALUES (3255,'savedmessage.wav',NULL,1);
INSERT INTO sound_files VALUES (3256,'savedmessages.wav',NULL,1);
INSERT INTO sound_files VALUES (3257,'second.wav',NULL,1);
INSERT INTO sound_files VALUES (3258,'seconds.wav',NULL,1);
INSERT INTO sound_files VALUES (3259,'september.wav',NULL,1);
INSERT INTO sound_files VALUES (3260,'sound_file_3098.wav',NULL,1);
INSERT INTO sound_files VALUES (3261,'sound_file_3240.wav',NULL,1);
INSERT INTO sound_files VALUES (3262,'sound_file_3349.wav',NULL,1);
INSERT INTO sound_files VALUES (3263,'sound_file_3350.wav',NULL,1);
INSERT INTO sound_files VALUES (3264,'sound_file_3352.wav',NULL,1);
INSERT INTO sound_files VALUES (3265,'sound_file_3354.wav',NULL,1);
INSERT INTO sound_files VALUES (3266,'subnet_invalid.wav',NULL,1);
INSERT INTO sound_files VALUES (3267,'thanksgiving_holiday.wav',NULL,1);
INSERT INTO sound_files VALUES (3268,'today.wav',NULL,1);
INSERT INTO sound_files VALUES (3269,'user_main_menu.wav',NULL,1);
INSERT INTO sound_files VALUES (3270,'user_settings_menu.wav',NULL,1);
INSERT INTO sound_files VALUES (3271,'utut_done.wav',NULL,1);
INSERT INTO sound_files VALUES (3272,'utut_greet.wav',NULL,1);
INSERT INTO sound_files VALUES (3273,'utut_greet_menu.wav',NULL,1);
INSERT INTO sound_files VALUES (3274,'utut_intro.wav',NULL,1);
INSERT INTO sound_files VALUES (3275,'utut_name.wav',NULL,1);
INSERT INTO sound_files VALUES (3276,'utut_password.wav',NULL,1);
INSERT INTO sound_files VALUES (3277,'utut_password_conf.wav',NULL,1);
INSERT INTO sound_files VALUES (3278,'vacation_active.wav',NULL,1);
INSERT INTO sound_files VALUES (3279,'vacation_deactivated.wav',NULL,1);
INSERT INTO sound_files VALUES (3280,'vaction_set.wav',NULL,1);
INSERT INTO sound_files VALUES (3281,'veterans_day.wav',NULL,1);
INSERT INTO sound_files VALUES (3282,'yesterday.wav',NULL,1);
INSERT INTO sound_files VALUES (3283,'you_have.wav',NULL,1);
INSERT INTO sound_files VALUES (3284,'youentered.wav',NULL,1);
INSERT INTO sound_files VALUES (3285,'/var/spool/openums/o-matrix.net/prompts/sound_file_3285.wav','new sound',0);
INSERT INTO sound_files VALUES (3286,'/var/spool/openums/o-matrix.net/prompts/sound_file_3286.wav','new sound',0);

--
-- Table structure for table `sound_variables`
--

DROP TABLE IF EXISTS sound_variables;
CREATE TABLE sound_variables (
  sound_var_name varchar(40) NOT NULL default '',
  sound_var_file varchar(100) NOT NULL default '',
  custom_sound_flag tinyint(1) NOT NULL default '0',
  PRIMARY KEY  (sound_var_name)
) TYPE=MyISAM;

--
-- Dumping data for table `sound_variables`
--

INSERT INTO sound_variables VALUES ('DEFAULT_INVALID_SOUND','invalid.wav',0);
INSERT INTO sound_variables VALUES ('NO_NEW_MESSAGES','nonewmessages.wav',0);
INSERT INTO sound_variables VALUES ('NEW_MESSAGE','newmessage.wav',0);
INSERT INTO sound_variables VALUES ('NEW_MESSAGES','newmessages.wav',0);
INSERT INTO sound_variables VALUES ('NO_SAVED_MESSAGES','nosavedmessages.wav',0);
INSERT INTO sound_variables VALUES ('SAVED_MESSAGE','savedmessage.wav',0);
INSERT INTO sound_variables VALUES ('SAVED_MESSAGES','savedmessages.wav',0);

--
-- Table structure for table `vacations`
--

DROP TABLE IF EXISTS vacations;
CREATE TABLE vacations (
  extension smallint(6) NOT NULL default '0',
  begin_date date NOT NULL default '0000-00-00',
  dayback_date date NOT NULL default '0000-00-00',
  PRIMARY KEY  (extension)
) TYPE=MyISAM COMMENT='Vacation settings for a user.';

--
-- Dumping data for table `vacations`
--


--
-- Table structure for table `web_sessions`
--

DROP TABLE IF EXISTS web_sessions;
CREATE TABLE web_sessions (
  id varchar(32) NOT NULL default '',
  a_session text NOT NULL,
  UNIQUE KEY id (id)
) TYPE=MyISAM COMMENT='All the web_sessions get stored here. This is needed by the ';

--
-- Dumping data for table `web_sessions`
--


