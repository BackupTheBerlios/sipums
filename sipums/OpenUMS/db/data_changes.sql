
UPDATE menu_items 
SET menu_item_title = 'Press 5 to go the secret admin menu',
menu_item_option = '5',
menu_item_action = NULL WHERE menu_item_id = '7295' ;


INSERT INTO menu_items (menu_id, menu_item_title, menu_item_option, dest_menu_id)
VALUES (203,'Press 4 to go the secret record sound menu',4,228); 

UPDATE menu_items SET dest_menu_id = '203' WHERE menu_item_id = '7391';

UPDATE menu_items SET dest_menu_id = '244',
menu_item_action = NULL WHERE menu_item_id = '7430' ; 

UPDATE menu_items SET dest_menu_id = '244',
menu_item_action = NULL WHERE menu_item_id = '7337'; 

UPDATE menu_items 
SET dest_menu_id = '203' 
WHERE menu_item_id = '7394' ;


-- new 2/4/2005
INSERT INTO menu ( 
    menu_id , title , menu_type_code , max_attempts , permission_id , collect_time , param1 , param2 , param3 , param4 
)
VALUES (
    '9', 'Goto Previous Menu', 'GOPREV', '1', 'ANON', NULL , NULL , NULL , NULL , NULL
);
-- 2/14/2004

ALTER TABLE clients ADD client_domain VARCHAR( 240 ) AFTER client_name ;
ALTER TABLE clients ADD INDEX ( client_domain ) ;



