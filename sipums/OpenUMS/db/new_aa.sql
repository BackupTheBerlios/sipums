
DROP TABLE IF EXISTS auto_attendant;
CREATE TABLE auto_attendant (
  aa_dayofweek tinyint(3) unsigned NOT NULL default '0',
  aa_start_hour tinyint(3) unsigned NOT NULL default '0',
  aa_start_minute tinyint(3) unsigned NOT NULL default '0',
  menu_sound varchar(100) NOT NULL default 'aa_default.wav',
  PRIMARY KEY  (aa_dayofweek,aa_start_hour,aa_start_minute)
) TYPE=MyISAM COMMENT='Holds configuration for main auto attendant greeting. Tells ';

--
-- Dumping data for table `auto_attendant`
--

INSERT INTO auto_attendant (aa_dayofweek, aa_start_hour, aa_start_minute, menu_sound) VALUES (1,0,0,'aa_default_night.wav');
INSERT INTO auto_attendant (aa_dayofweek, aa_start_hour, aa_start_minute, menu_sound) VALUES (2,0,0,'aa_default_night.wav');
INSERT INTO auto_attendant (aa_dayofweek, aa_start_hour, aa_start_minute, menu_sound) VALUES (2,8,0,'aa_default.wav');
INSERT INTO auto_attendant (aa_dayofweek, aa_start_hour, aa_start_minute, menu_sound) VALUES (2,17,0,'aa_default_night.wav');
INSERT INTO auto_attendant (aa_dayofweek, aa_start_hour, aa_start_minute, menu_sound) VALUES (3,0,0,'aa_default_night.wav');
INSERT INTO auto_attendant (aa_dayofweek, aa_start_hour, aa_start_minute, menu_sound) VALUES (3,8,0,'aa_default.wav');
INSERT INTO auto_attendant (aa_dayofweek, aa_start_hour, aa_start_minute, menu_sound) VALUES (3,17,0,'aa_default_night.wav');
INSERT INTO auto_attendant (aa_dayofweek, aa_start_hour, aa_start_minute, menu_sound) VALUES (4,0,0,'aa_default_night.wav');
INSERT INTO auto_attendant (aa_dayofweek, aa_start_hour, aa_start_minute, menu_sound) VALUES (4,8,0,'aa_default.wav');
INSERT INTO auto_attendant (aa_dayofweek, aa_start_hour, aa_start_minute, menu_sound) VALUES (4,17,0,'aa_default_night.wav');
INSERT INTO auto_attendant (aa_dayofweek, aa_start_hour, aa_start_minute, menu_sound) VALUES (5,0,0,'aa_default_night.wav');
INSERT INTO auto_attendant (aa_dayofweek, aa_start_hour, aa_start_minute, menu_sound) VALUES (5,8,0,'aa_default.wav');
INSERT INTO auto_attendant (aa_dayofweek, aa_start_hour, aa_start_minute, menu_sound) VALUES (5,17,0,'aa_default_night.wav');
INSERT INTO auto_attendant (aa_dayofweek, aa_start_hour, aa_start_minute, menu_sound) VALUES (6,0,0,'aa_default_night.wav');
INSERT INTO auto_attendant (aa_dayofweek, aa_start_hour, aa_start_minute, menu_sound) VALUES (6,8,0,'aa_default.wav');
INSERT INTO auto_attendant (aa_dayofweek, aa_start_hour, aa_start_minute, menu_sound) VALUES (6,17,0,'aa_default_night.wav');
INSERT INTO auto_attendant (aa_dayofweek, aa_start_hour, aa_start_minute, menu_sound) VALUES (7,0,0,'aa_default_night.wav');


DROP TABLE IF EXISTS sound_variables;

CREATE TABLE sound_variables (
  sound_var_name VARCHAR( 40 ) NOT NULL ,
  sound_var_file VARCHAR( 100 ) NOT NULL ,
  custom_sound_flag TINYINT( 1 ) DEFAULT '0' NOT NULL ,
  PRIMARY KEY ( sound_var_name )
);

INSERT INTO sound_variables (sound_var_name, sound_var_file, custom_sound_flag) 
VALUES ('DEFAULT_INVALID_SOUND','invalid.wav',0); 
INSERT INTO sound_variables (sound_var_name, sound_var_file, custom_sound_flag) 
VALUES ('NO_NEW_MESSAGES','nonewmessages.wav',0); 
INSERT INTO sound_variables (sound_var_name, sound_var_file, custom_sound_flag) 
VALUES ('NEW_MESSAGE','newmessage.wav',0); 
INSERT INTO sound_variables (sound_var_name, sound_var_file, custom_sound_flag) 
VALUES ('NEW_MESSAGES','newmessages.wav',0); 

INSERT INTO sound_variables (sound_var_name, sound_var_file, custom_sound_flag) 
VALUES ('NO_SAVED_MESSAGES','nosavedmessages.wav',0); 
INSERT INTO sound_variables (sound_var_name, sound_var_file, custom_sound_flag) 
VALUES ('SAVED_MESSAGE','savedmessage.wav',0); 
INSERT INTO sound_variables (sound_var_name, sound_var_file, custom_sound_flag) 
VALUES ('SAVED_MESSAGES','savedmessages.wav',0); 

ALTER TABLE  holiday_sounds ADD COLUMN custom_sound_flag bool not null default 0; 
