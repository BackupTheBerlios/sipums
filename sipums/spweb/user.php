<?
/*
 * $Id: user.php,v 1.12 2004/08/17 19:33:56 kenglish Exp $
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

if ($perm->have_perm('SUPER') || $perm->have_perm('RESELLER') ) {
  // we send them to the account page
  $log->log("he, redirect here...");
  header('Location: domains.php'); 
  exit ;
} elseif ($perm->have_perm('ADMIN') ) {
  // we send them to the account page
  $log->log("he, redirect here...");
  header('Location: subscribers.php'); 
  exit ;
} elseif ($perm->have_perm('USER')) {
  $log->log("he, redirect here...");
  header('Location: account.php'); 
  exit;

} 

  $log->log("No Redirect...");

## do this in every file after the page_open

$smarty = get_smarty_header($data, $auth, $perm); 
$smarty->display('app_header.tpl');

$smarty->display('app_footer.tpl');

// freeze the session 
page_close(); 
?>
