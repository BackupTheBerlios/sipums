<?
/*
 * $Id: domains.php,v 1.9 2004/08/17 19:33:56 kenglish Exp $
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

$domains_smarty = get_smarty(); 
$domains = $data->get_domains(1);

$domains_smarty->assign("domains",$domains); 

$footer_smarty = get_smarty(); 

$header_smarty->display('app_header.tpl');
$domains_smarty->display('domains.tpl');
$footer_smarty->display('app_footer.tpl');


// freeze the session 
page_close(); 
// please close the log
$log->close(); 
?>
