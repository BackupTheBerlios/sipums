-- MySQL dump 9.10
--
-- Host: localhost    Database: ser
-- ------------------------------------------------------
-- Server version	4.0.18-log

--
-- Table structure for table `acc`
--

CREATE TABLE acc (
  sip_from varchar(128) NOT NULL default '',
  sip_to varchar(128) NOT NULL default '',
  sip_status varchar(128) NOT NULL default '',
  sip_method varchar(16) NOT NULL default '',
  i_uri varchar(128) NOT NULL default '',
  o_uri varchar(128) NOT NULL default '',
  from_uri varchar(128) NOT NULL default '',
  to_uri varchar(128) NOT NULL default '',
  sip_callid varchar(128) NOT NULL default '',
  username varchar(64) NOT NULL default '',
  domain varchar(128) NOT NULL default '',
  fromtag varchar(128) NOT NULL default '',
  totag varchar(128) NOT NULL default '',
  time datetime NOT NULL default '0000-00-00 00:00:00',
  timestamp timestamp(14) NOT NULL,
  KEY acc_user (username,domain),
  KEY sip_callid (sip_callid),
  KEY idx_timestamp (timestamp)
) TYPE=MyISAM;

--
-- Table structure for table `acc_sum_placeholder`
--

CREATE TABLE acc_sum_placeholder (
  placeholder_timestamp varchar(20) NOT NULL default ''
) TYPE=MyISAM;

--
-- Table structure for table `acc_summary`
--

CREATE TABLE acc_summary (
  acc_summary_id mediumint(8) unsigned NOT NULL auto_increment,
  sip_callid varchar(128) NOT NULL default '',
  sip_from varchar(128) NOT NULL default '',
  number_from varchar(10) default NULL,
  domain_from varchar(50) default NULL,
  name_from varchar(100) default NULL,
  sip_to varchar(128) NOT NULL default '',
  number_to varchar(10) default NULL,
  domain_to varchar(50) default NULL,
  name_to varchar(100) default NULL,
  ack_datetime datetime default NULL,
  bye_datetime datetime default NULL,
  duration_sec mediumint(8) default NULL,
  PRIMARY KEY  (acc_summary_id),
  UNIQUE KEY sip_callid (sip_callid)
) TYPE=MyISAM;

--
-- Table structure for table `active_sessions`
--

CREATE TABLE active_sessions (
  sid varchar(32) NOT NULL default '',
  name varchar(32) NOT NULL default '',
  val text,
  changed varchar(14) NOT NULL default '',
  PRIMARY KEY  (name,sid),
  KEY changed (changed)
) TYPE=MyISAM;

--
-- Table structure for table `admin_privileges`
--

CREATE TABLE admin_privileges (
  username varchar(64) NOT NULL default '',
  domain varchar(128) NOT NULL default '',
  priv_name varchar(64) NOT NULL default '',
  priv_value varchar(64) NOT NULL default '',
  PRIMARY KEY  (username,priv_name,priv_value,domain)
) TYPE=MyISAM;

--
-- Table structure for table `aliases`
--

CREATE TABLE aliases (
  username varchar(64) NOT NULL default '',
  domain varchar(128) NOT NULL default '',
  contact varchar(255) NOT NULL default '',
  expires datetime NOT NULL default '2020-05-28 21:32:15',
  q float(10,2) NOT NULL default '1.00',
  callid varchar(255) NOT NULL default 'Default-Call-ID',
  cseq int(11) NOT NULL default '42',
  last_modified timestamp(14) NOT NULL,
  replicate int(10) unsigned NOT NULL default '0',
  state tinyint(1) unsigned NOT NULL default '0',
  flags int(11) NOT NULL default '0',
  PRIMARY KEY  (username,domain,contact),
  KEY aliases_contact (contact)
) TYPE=MyISAM;

--
-- Table structure for table `calls_forwarding`
--

CREATE TABLE calls_forwarding (
  username varchar(64) NOT NULL default '',
  domain varchar(128) NOT NULL default '',
  uri_re varchar(128) NOT NULL default '',
  purpose varchar(32) NOT NULL default '',
  action varchar(32) NOT NULL default '',
  param1 varchar(128) default NULL,
  param2 varchar(128) default NULL,
  PRIMARY KEY  (username,domain,uri_re,purpose)
) TYPE=MyISAM;

--
-- Table structure for table `client_line_map`
--

CREATE TABLE client_line_map (
  client_id int(10) NOT NULL default '0',
  phone_number varchar(10) NOT NULL default '',
  PRIMARY KEY  (client_id,phone_number)
) TYPE=MyISAM;

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
  PRIMARY KEY  (client_id)
) TYPE=MyISAM;

--
-- Table structure for table `config`
--

CREATE TABLE config (
  attribute varchar(32) NOT NULL default '',
  value varchar(128) NOT NULL default '',
  username varchar(64) NOT NULL default '',
  domain varchar(128) NOT NULL default '',
  modified timestamp(14) NOT NULL
) TYPE=MyISAM;

--
-- Table structure for table `cpl`
--

CREATE TABLE cpl (
  user varchar(50) NOT NULL default '',
  cpl_xml blob,
  cpl_bin blob,
  PRIMARY KEY  (user),
  UNIQUE KEY user (user)
) TYPE=MyISAM;

--
-- Table structure for table `domain`
--

CREATE TABLE domain (
  domain varchar(128) NOT NULL default '',
  last_modified datetime NOT NULL default '0000-00-00 00:00:00',
  voicemail_db varchar(40) default NULL,
  company_name varchar(100) NOT NULL default '',
  company_number varchar(10) NOT NULL default '',
  PRIMARY KEY  (domain)
) TYPE=MyISAM;

--
-- Table structure for table `event`
--

CREATE TABLE event (
  id int(10) unsigned NOT NULL auto_increment,
  username varchar(64) NOT NULL default '',
  domain varchar(128) NOT NULL default '',
  uri varchar(255) NOT NULL default '',
  description varchar(255) NOT NULL default '',
  PRIMARY KEY  (id)
) TYPE=MyISAM;

--
-- Table structure for table `grp`
--

CREATE TABLE grp (
  username varchar(64) NOT NULL default '',
  domain varchar(128) NOT NULL default '',
  grp varchar(50) NOT NULL default '',
  last_modified datetime NOT NULL default '0000-00-00 00:00:00',
  PRIMARY KEY  (username,domain,grp)
) TYPE=MyISAM;

--
-- Table structure for table `k_calls`
--

CREATE TABLE k_calls (
  callid varchar(155) NOT NULL default '',
  caller_user varchar(12) NOT NULL default '',
  caller_domain varchar(50) NOT NULL default '',
  callee_user varchar(12) NOT NULL default '',
  callee_domain varchar(50) NOT NULL default '',
  PRIMARY KEY  (callid)
) TYPE=MyISAM;

--
-- Table structure for table `location`
--

CREATE TABLE location (
  username varchar(64) NOT NULL default '',
  domain varchar(128) NOT NULL default '',
  contact varchar(255) NOT NULL default '',
  expires datetime NOT NULL default '2020-05-28 21:32:15',
  q float(10,2) NOT NULL default '1.00',
  callid varchar(255) NOT NULL default 'Default-Call-ID',
  cseq int(11) NOT NULL default '42',
  last_modified timestamp(14) NOT NULL,
  replicate int(10) unsigned NOT NULL default '0',
  state tinyint(1) unsigned NOT NULL default '0',
  flags int(11) NOT NULL default '0',
  PRIMARY KEY  (username,domain,contact)
) TYPE=MyISAM;

--
-- Table structure for table `misc_acc`
--

CREATE TABLE misc_acc (
  sip_from varchar(128) NOT NULL default '',
  sip_to varchar(128) NOT NULL default '',
  sip_status varchar(128) NOT NULL default '',
  sip_method varchar(16) NOT NULL default '',
  i_uri varchar(128) NOT NULL default '',
  o_uri varchar(128) NOT NULL default '',
  from_uri varchar(128) NOT NULL default '',
  to_uri varchar(128) NOT NULL default '',
  sip_callid varchar(128) NOT NULL default '',
  username varchar(64) NOT NULL default '',
  domain varchar(128) NOT NULL default '',
  fromtag varchar(128) NOT NULL default '',
  totag varchar(128) NOT NULL default '',
  time datetime NOT NULL default '0000-00-00 00:00:00',
  timestamp timestamp(14) NOT NULL,
  KEY acc_user (username,domain),
  KEY sip_callid (sip_callid)
) TYPE=MyISAM;

--
-- Table structure for table `missed_calls`
--

CREATE TABLE missed_calls (
  sip_from varchar(128) NOT NULL default '',
  sip_to varchar(128) NOT NULL default '',
  sip_status varchar(128) NOT NULL default '',
  sip_method varchar(16) NOT NULL default '',
  i_uri varchar(128) NOT NULL default '',
  o_uri varchar(128) NOT NULL default '',
  from_uri varchar(128) NOT NULL default '',
  to_uri varchar(128) NOT NULL default '',
  sip_callid varchar(128) NOT NULL default '',
  username varchar(64) NOT NULL default '',
  domain varchar(128) NOT NULL default '',
  fromtag varchar(128) NOT NULL default '',
  totag varchar(128) NOT NULL default '',
  time datetime NOT NULL default '0000-00-00 00:00:00',
  timestamp timestamp(14) NOT NULL,
  KEY mc_user (username,domain)
) TYPE=MyISAM;

--
-- Table structure for table `pending`
--

CREATE TABLE pending (
  phplib_id varchar(32) NOT NULL default '',
  username varchar(64) NOT NULL default '',
  domain varchar(128) NOT NULL default '',
  password varchar(25) NOT NULL default '',
  first_name varchar(25) NOT NULL default '',
  last_name varchar(45) NOT NULL default '',
  phone varchar(15) NOT NULL default '',
  email_address varchar(50) NOT NULL default '',
  datetime_created datetime NOT NULL default '0000-00-00 00:00:00',
  datetime_modified datetime NOT NULL default '0000-00-00 00:00:00',
  confirmation varchar(64) NOT NULL default '',
  flag char(1) NOT NULL default 'o',
  sendnotification varchar(50) NOT NULL default '',
  greeting varchar(50) NOT NULL default '',
  ha1 varchar(128) NOT NULL default '',
  ha1b varchar(128) NOT NULL default '',
  allow_find char(1) NOT NULL default '0',
  timezone varchar(128) default NULL,
  rpid varchar(128) default NULL,
  PRIMARY KEY  (username,domain),
  UNIQUE KEY phplib_id (phplib_id),
  KEY user_2 (username)
) TYPE=MyISAM;

--
-- Table structure for table `permission`
--

CREATE TABLE permission (
  perm_level smallint(4) NOT NULL default '0',
  perm_name varchar(10) NOT NULL default '',
  perm_descr varchar(200) default NULL,
  PRIMARY KEY  (perm_level)
) TYPE=MyISAM;

--
-- Table structure for table `phonebook`
--

CREATE TABLE phonebook (
  id int(10) unsigned NOT NULL auto_increment,
  username varchar(64) NOT NULL default '',
  domain varchar(128) NOT NULL default '',
  fname varchar(32) NOT NULL default '',
  lname varchar(32) NOT NULL default '',
  sip_uri varchar(128) NOT NULL default '',
  PRIMARY KEY  (id)
) TYPE=MyISAM;

--
-- Table structure for table `preferences`
--

CREATE TABLE preferences (
  username varchar(64) NOT NULL default '',
  domain varchar(128) NOT NULL default '',
  attribute varchar(50) NOT NULL default '',
  value varchar(100) NOT NULL default '',
  PRIMARY KEY  (username,domain,attribute)
) TYPE=MyISAM;

--
-- Table structure for table `preferences_types`
--

CREATE TABLE preferences_types (
  att_name varchar(50) NOT NULL default '',
  att_rich_type varchar(32) NOT NULL default 'string',
  att_raw_type int(11) unsigned NOT NULL default '2',
  att_type_spec text,
  default_value varchar(100) NOT NULL default '',
  PRIMARY KEY  (att_name)
) TYPE=MyISAM;

--
-- Table structure for table `reseller_info`
--

CREATE TABLE reseller_info (
  reseller_client_id int(10) unsigned NOT NULL default '0',
  logo_file varchar(50) NOT NULL default '',
  PRIMARY KEY  (reseller_client_id)
) TYPE=MyISAM;

--
-- Table structure for table `reserved`
--

CREATE TABLE reserved (
  username char(64) NOT NULL default '',
  UNIQUE KEY user2 (username)
) TYPE=MyISAM;

--
-- Table structure for table `server_monitoring`
--

CREATE TABLE server_monitoring (
  time datetime NOT NULL default '0000-00-00 00:00:00',
  id int(10) unsigned NOT NULL default '0',
  param varchar(32) NOT NULL default '',
  value int(10) NOT NULL default '0',
  increment int(10) NOT NULL default '0',
  PRIMARY KEY  (id,param)
) TYPE=MyISAM;

--
-- Table structure for table `server_monitoring_agg`
--

CREATE TABLE server_monitoring_agg (
  param varchar(32) NOT NULL default '',
  s_value int(10) NOT NULL default '0',
  s_increment int(10) NOT NULL default '0',
  last_aggregated_increment int(10) NOT NULL default '0',
  av float NOT NULL default '0',
  mv int(10) NOT NULL default '0',
  ad float NOT NULL default '0',
  lv int(10) NOT NULL default '0',
  min_val int(10) NOT NULL default '0',
  max_val int(10) NOT NULL default '0',
  min_inc int(10) NOT NULL default '0',
  max_inc int(10) NOT NULL default '0',
  lastupdate datetime NOT NULL default '0000-00-00 00:00:00',
  PRIMARY KEY  (param)
) TYPE=MyISAM;

--
-- Table structure for table `silo`
--

CREATE TABLE silo (
  mid int(11) NOT NULL auto_increment,
  src_addr varchar(255) NOT NULL default '',
  dst_addr varchar(255) NOT NULL default '',
  r_uri varchar(255) NOT NULL default '',
  inc_time int(11) NOT NULL default '0',
  exp_time int(11) NOT NULL default '0',
  ctype varchar(32) NOT NULL default 'text/plain',
  body blob NOT NULL,
  PRIMARY KEY  (mid)
) TYPE=MyISAM;

--
-- Table structure for table `speed_dial`
--

CREATE TABLE speed_dial (
  username varchar(64) NOT NULL default '',
  domain varchar(128) NOT NULL default '',
  username_from_req_uri varchar(128) NOT NULL default '',
  domain_from_req_uri varchar(128) NOT NULL default '',
  new_request_uri varchar(128) NOT NULL default '',
  PRIMARY KEY  (username,domain,domain_from_req_uri,username_from_req_uri)
) TYPE=MyISAM;

--
-- Table structure for table `subscriber`
--

CREATE TABLE subscriber (
  phplib_id varchar(32) NOT NULL default '',
  username varchar(64) NOT NULL default '',
  domain varchar(128) NOT NULL default '',
  client_id int(10) unsigned NOT NULL default '0',
  password varchar(25) NOT NULL default '',
  first_name varchar(25) default '',
  last_name varchar(45) default '',
  phone varchar(15) default '',
  email_address varchar(50) default '',
  datetime_created datetime default '0000-00-00 00:00:00',
  datetime_modified datetime default '0000-00-00 00:00:00',
  confirmation varchar(64) default '',
  flag char(1) default 'o',
  sendnotification varchar(50) default '',
  greeting varchar(50) default '',
  ha1 varchar(128) default '',
  ha1b varchar(128) default '',
  allow_find char(1) default '0',
  timezone varchar(128) default NULL,
  rpid varchar(128) default NULL,
  perm varchar(10) default 'USER',
  web_password varchar(100) NOT NULL default '',
  mailbox int(5) default NULL,
  PRIMARY KEY  (username,domain),
  UNIQUE KEY phplib_id (phplib_id),
  KEY user_2 (username),
  KEY idx_login (username,web_password),
  KEY client_id (client_id)
) TYPE=MyISAM;

--
-- Table structure for table `trusted`
--

CREATE TABLE trusted (
  src_ip varchar(39) NOT NULL default '',
  proto varchar(4) NOT NULL default '',
  from_pattern varchar(64) NOT NULL default '',
  PRIMARY KEY  (src_ip,proto,from_pattern)
) TYPE=MyISAM;

--
-- Table structure for table `uri`
--

CREATE TABLE uri (
  username varchar(64) NOT NULL default '',
  domain varchar(128) NOT NULL default '',
  uri_user varchar(50) NOT NULL default '',
  last_modified datetime NOT NULL default '0000-00-00 00:00:00',
  PRIMARY KEY  (username,domain,uri_user)
) TYPE=MyISAM;

--
-- Table structure for table `user_mailbox_map`
--

CREATE TABLE user_mailbox_map (
  username varchar(64) NOT NULL default '',
  mailbox smallint(6) NOT NULL default '0',
  voicemail_db varchar(64) NOT NULL default '',
  domain varchar(128) NOT NULL default '',
  PRIMARY KEY  (username,mailbox,voicemail_db,domain)
) TYPE=MyISAM;

--
-- Table structure for table `version`
--

CREATE TABLE version (
  table_name varchar(64) NOT NULL default '',
  table_version smallint(5) NOT NULL default '0'
) TYPE=MyISAM;

