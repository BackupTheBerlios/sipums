
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

-- done 1/25/2004
