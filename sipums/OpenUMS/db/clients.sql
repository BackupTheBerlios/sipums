--
-- Table structure for table `clients`
--
 
CREATE TABLE clients (
  client_id int(10) unsigned NOT NULL auto_increment,
  client_name varchar(100) NOT NULL default '',
  reseller_flag tinyint(1) NOT NULL default '0',
  reseller_client_id int(10) default NULL,
  client_website varchar(200) default NULL,
  company_logo_image varchar(100) default NULL,
  voicemail_db varchar(40) NOT NULL default 'vm_corp_servpac_com',
  client_main_number varchar(15) default NULL,
  PRIMARY KEY  (client_id)
) TYPE=MyISAM;
 
--
-- Dumping data for table `clients`
--
 
INSERT INTO clients VALUES (770000,'Servpac Inc.',1,NULL,'www.servpac.com','','vm_corp_servpac_com',NULL);

