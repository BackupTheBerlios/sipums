<?
/*
 * $Id: dbs.php,v 1.1 2004/08/01 20:06:13 kenglish Exp $
 */

require 'prepend.php';
require 'Smarty.class.php';

require 'lib/nav.php';
#require "lib/wrappers.php";

put_headers();

// get db connect 
$data = CData_Layer::create($errors) ;

// get the sess, auth and perm vars
page_open (array("sess" => "phplib_Session_Pre_Auth",
   "auth" => "phplib_Pre_Auth",
   "perm" => "phplib_Perm"));

## do this in every file after the page_open
$perm->check('SUPER');
$header_smarty = get_smarty_header($data, $auth, $perm); 
$dbs_smarty = get_smarty(); 
$footer_smarty = get_smarty(); 

$dbs = $data->get_dbs();
$dbs_smarty->assign('dbs',$dbs);  

$header_smarty->display('app_header.tpl');
$dbs_smarty->display('dbs.tpl');
$footer_smarty->display('app_footer.tpl');


// freeze the session 
page_close(); 
?>
