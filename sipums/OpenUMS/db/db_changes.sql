INSERT INTO aa_action_types (action_type,action_type_desc)
VALUES ('SPECLOGIN','Special Login for Users');

DELETE FROM menu WHERE menu_id = 602;
DELETE FROM menu_sounds WHERE menu_id = 602 ;
DELETE FROM menu_items WHERE menu_id = 602 ;

DELETE FROM menu WHERE menu_id = 603;
DELETE FROM menu_sounds WHERE menu_id = 603 ;
DELETE FROM menu_items WHERE menu_id = 603 ;


UPDATE `menu_items` 
SET `menu_item_title` = 'Press 5 to go the secret admin menu',
`menu_item_option` = '5',
`menu_item_action` = NULL WHERE `menu_item_id` = '7295' LIMIT 1 ;


INSERT INTO menu_items (menu_id, menu_item_title, menu_item_option, dest_menu_id)
VALUES (203,'Press 4 to go the secret record sound menu',4,228); 

UPDATE `menu_items` SET `dest_menu_id` = '203' WHERE `menu_item_id` = '7391' LIMIT 1 ;

UPDATE `menu_items` SET `dest_menu_id` = '244',
`menu_item_action` = NULL WHERE `menu_item_id` = '7430' ; 

UPDATE `menu_items` SET `dest_menu_id` = '244',
`menu_item_action` = NULL WHERE `menu_item_id` = '7337'

UPDATE `menu_items` 
SET `dest_menu_id` = '203' 
WHERE `menu_item_id` = '7394' ;
-- new  : 1/28/2004

DROP TABLE did_mapping ; 
CREATE TABLE did_mapping (
  client_number varchar(12) NOT NULL default '',
  menu_id int(11) NOT NULL default '0',
  PRIMARY KEY  (client_number)
) TYPE=MyISAM;
 show databases;



