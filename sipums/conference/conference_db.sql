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

INSERT INTO companies (company_id, company_name, domain, max_concurrent, max_time_mins, max_invitees) VALUES (4001,'O Matrix Net','o-matrix.net',3,600,4);
INSERT INTO companies (company_id, company_name, domain, max_concurrent, max_time_mins, max_invitees) VALUES (4002,'O Matrix Org','o-matrix.org',4,600,5);
INSERT INTO companies (company_id, company_name, domain, max_concurrent, max_time_mins, max_invitees) VALUES (4003,'O Matrix Com','o-matrix.com',4,600,5);

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

INSERT INTO conferences (conference_id, company_id, conference_name, conference_date, conference_number, conferenc_room_number, begin_time, end_time, creator) VALUES (1,4001,'O Matrix Net Conference #1','2004-08-19','3560079','','11:00:00','12:00:00','3560074');
INSERT INTO conferences (conference_id, company_id, conference_name, conference_date, conference_number, conferenc_room_number, begin_time, end_time, creator) VALUES (2,4001,'O Matrix Net Conference #2','2004-08-20','3560079','','12:00:00','13:00:00','netAdmin');
INSERT INTO conferences (conference_id, company_id, conference_name, conference_date, conference_number, conferenc_room_number, begin_time, end_time, creator) VALUES (300001,4001,'O Matrix Net Conference #3','2004-08-23','3560078','','10:00:00','11:00:00','3560074');
INSERT INTO conferences (conference_id, company_id, conference_name, conference_date, conference_number, conferenc_room_number, begin_time, end_time, creator) VALUES (300002,4003,'O Matrix Com Conference #1','2004-08-20','3560078','','14:00:00','15:00:00','super');
INSERT INTO conferences (conference_id, company_id, conference_name, conference_date, conference_number, conferenc_room_number, begin_time, end_time, creator) VALUES (300003,4001,'O Matrix Net Conference #4','2004-08-20','3560078','','15:00:00','16:00:00','netAdmin');

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

INSERT INTO invitees (invitee_id, company_id, conference_id, invitee_email, owner_flag, invitee_code, invitee_username, invitee_name) VALUES (1,4001,1,'kenglish_hi@yahoo.com',1,'3287728','3560074','Kevin English');
INSERT INTO invitees (invitee_id, company_id, conference_id, invitee_email, owner_flag, invitee_code, invitee_username, invitee_name) VALUES (2,4001,1,'mdarnell@comtelhi.com',0,'9884874','3560075','Matt Darnell');
INSERT INTO invitees (invitee_id, company_id, conference_id, invitee_email, owner_flag, invitee_code, invitee_username, invitee_name) VALUES (3,4001,1,'richardzheng@yahoo.com',0,'5932220','3560073','Richard Zheng');
INSERT INTO invitees (invitee_id, company_id, conference_id, invitee_email, owner_flag, invitee_code, invitee_username, invitee_name) VALUES (4,4001,2,'',1,'6620431','netAdmin','o-matrix.net Administrator');
INSERT INTO invitees (invitee_id, company_id, conference_id, invitee_email, owner_flag, invitee_code, invitee_username, invitee_name) VALUES (5,4001,2,'mdarnell@comtelhi.com',0,'5551163','3560075','Matt Darnell');
INSERT INTO invitees (invitee_id, company_id, conference_id, invitee_email, owner_flag, invitee_code, invitee_username, invitee_name) VALUES (6,4001,2,'kenglish_hi@yahoo.com',0,'8214040','3560074','Kevin English');
INSERT INTO invitees (invitee_id, company_id, conference_id, invitee_email, owner_flag, invitee_code, invitee_username, invitee_name) VALUES (7,4001,3,'kenglish_hi@yahoo.com',1,'6126924','3560074','Kevin English');
INSERT INTO invitees (invitee_id, company_id, conference_id, invitee_email, owner_flag, invitee_code, invitee_username, invitee_name) VALUES (8,4001,3,'mattdarnell@yahoo.com',0,'1634438','3560075','Matt Darnell');
INSERT INTO invitees (invitee_id, company_id, conference_id, invitee_email, owner_flag, invitee_code, invitee_username, invitee_name) VALUES (9,4001,3,'richardzheng@yahoo.com',0,'5288110','3560073','Richard Zheng');
INSERT INTO invitees (invitee_id, company_id, conference_id, invitee_email, owner_flag, invitee_code, invitee_username, invitee_name) VALUES (10,4003,300002,'kevin@x5dev.com',1,'5461033','super','Initial Admin');
INSERT INTO invitees (invitee_id, company_id, conference_id, invitee_email, owner_flag, invitee_code, invitee_username, invitee_name) VALUES (11,4001,300003,'',1,'2344996','netAdmin','o-matrix.net Administrator');
INSERT INTO invitees (invitee_id, company_id, conference_id, invitee_email, owner_flag, invitee_code, invitee_username, invitee_name) VALUES (12,4001,300003,'matthewjohndarnell@yahoo.com',0,'5435128','3560075','Matt Darnell');
INSERT INTO invitees (invitee_id, company_id, conference_id, invitee_email, owner_flag, invitee_code, invitee_username, invitee_name) VALUES (13,4001,300003,'richardzheng@yahoo.com',0,'4777223','3560073','Richard Zheng');
INSERT INTO invitees (invitee_id, company_id, conference_id, invitee_email, owner_flag, invitee_code, invitee_username, invitee_name) VALUES (14,4001,300003,'kenglish_hi@yahoo.com',0,'2126856','3560074','Kevin English');

