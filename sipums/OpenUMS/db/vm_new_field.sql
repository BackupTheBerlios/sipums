ALTER TABLE sound_files ADD custom_sound_flag TINYINT( 1 ) DEFAULT '1' NOT NULL ;
update sound_files set custom_sound_flag = !(professional);

-- 1/15/2005
 ALTER TABLE VM_Messages ADD COLUMN purged_flag BOOL default 0;


CREATE TABLE aa_action_types (
  action_type varchar(10) NOT NULL default '',
  action_type_desc varchar(200) default NULL,
  PRIMARY KEY  (action_type)
) TYPE=MyISAM;


INSERT INTO aa_action_types (action_type,action_type_desc)
VALUES ('SPECLOGIN','Special Login for Users');



DELETE FROM menu WHERE menu_id = 602;
DELETE FROM menu_sounds WHERE menu_id = 602 ;
DELETE FROM menu_items WHERE menu_id = 602 ;

DELETE FROM menu WHERE menu_id = 603;
DELETE FROM menu_sounds WHERE menu_id = 603 ;
DELETE FROM menu_items WHERE menu_id = 603 ;
