-- MySQL dump 9.10
--
-- Host: localhost    Database: conference
-- ------------------------------------------------------
-- Server version	4.0.18-log

--
-- Table structure for table `companies`
--

DROP TABLE IF EXISTS companies;
CREATE TABLE companies (
  company_id int(11) NOT NULL auto_increment,
  company_name varchar(50) NOT NULL default '',
  domain varchar(50) NOT NULL default '',
  max_concurrent smallint(3) NOT NULL default '60',
  max_time_mins int(4) NOT NULL default '0',
  max_invitees smallint(4) NOT NULL default '0',
  PRIMARY KEY  (company_id)
) TYPE=MyISAM;

--
-- Dumping data for table `companies`
--

INSERT INTO companies VALUES (4001,'Test Company 1','o-company.net',3,600,4);
INSERT INTO companies VALUES (4002,'Test Company 2','o-company.org',4,600,5);
INSERT INTO companies VALUES (4003,'Test Company 3','o-company.com',4,600,5);

--
-- Table structure for table `conferences`
--

DROP TABLE IF EXISTS conferences;
CREATE TABLE conferences (
  conference_id int(11) NOT NULL auto_increment,
  company_id smallint(11) NOT NULL default '0',
  conference_name varchar(50) NOT NULL default '',
  conference_date date NOT NULL default '0000-00-00',
  conference_number varchar(10) NOT NULL default '',
  conferenc_room_number varchar(10) NOT NULL default '',
  begin_time time NOT NULL default '00:00:00',
  end_time time NOT NULL default '00:00:00',
  creator varchar(50) NOT NULL default '',
  PRIMARY KEY  (conference_id)
) TYPE=MyISAM;

--
-- Dumping data for table `conferences`
--


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
INSERT INTO global_settings VALUES ('MIN_MESSAGE_LENGTH','Shortest message allowed in seconds','1','INTEGER',0,900,'');
INSERT INTO global_settings VALUES ('RC_TIMEOUT','Maximum length of a recorded call in minutes','60','INTEGER',0,900,'');
INSERT INTO global_settings VALUES ('OPERATOR_EXTENSION','Operator extension','301','INTEGER',0,100000,'');
INSERT INTO global_settings VALUES ('REWIND_SECS','Number of Seconds rewind/fast forward will jump','5','INTEGER',1,25,'');
INSERT INTO global_settings VALUES ('INTERGRATION_WAIT','Time to wait for Intergration Digits','4','INTEGER',1,10,'');
INSERT INTO global_settings VALUES ('VOICEMAIL_DB','Voicemail Database','vm_ocompany_com','CHAR',0,100000,'');
INSERT INTO global_settings VALUES ('VM_PATH','Voicemail Directory','','CHAR',0,100000,'');

--
-- Table structure for table `invitees`
--

DROP TABLE IF EXISTS invitees;
CREATE TABLE invitees (
  invitee_id int(11) NOT NULL auto_increment,
  company_id int(11) NOT NULL default '0',
  conference_id int(11) NOT NULL default '0',
  invitee_email varchar(60) NOT NULL default '',
  owner_flag smallint(1) unsigned NOT NULL default '0',
  invitee_code varchar(10) NOT NULL default '',
  invitee_username varchar(50) default NULL,
  invitee_name varchar(100) NOT NULL default '',
  PRIMARY KEY  (invitee_id),
  KEY invitee_username (invitee_username)
) TYPE=MyISAM;

--
-- Dumping data for table `invitees`
--


