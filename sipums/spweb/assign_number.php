<?
/*
 * $Id: assign_number.php,v 1.1 2004/09/07 21:22:40 kenglish Exp $
 */

require 'prepend.php';
require 'Smarty.class.php';

require 'lib/nav.php';
#require "lib/wrappers.php";

put_headers();
function update_number(){
  global $log,$data,$_POST,$client_id; 
  $log->log("want to save number" . $_POST['phone_number'] ); 
  $log->log("for " . $client_id ); 
  if ($_POST['phone_number'] && $client_id) { 
    $data->save_client_number($client_id, $_POST['phone_number']);
  } else {
     $log->log("no phone_number or client_id=" . $_POST['phone_number'] . $client_id);
  } 

}

// get db connect 
$data = CData_Layer::create($errors) ;


// get the sess, auth and perm vars
page_open (array("sess" => "phplib_Session_Pre_Auth",
   "auth" => "phplib_Pre_Auth",
   "perm" => "phplib_Perm"));


## do this in every file after the page_open
$perm->check('SUPER');

if ($_POST[client_id]) {
  $client_id = $_POST[client_id];
} else {
  $client_id = $_GET[client_id]; 
}

if (!$client_id){
  header("Location: clients.php");
}

if ($_POST[save_number] ){
  update_number(); 
}


$header_smarty = get_smarty_header($data, $auth, $perm); 

$my_smarty = get_smarty(); 

$phone_numbers = $data->get_avail_numbers($client_id); 
$client_name = $data->get_client_name($client_id); 

$my_smarty->assign("phone_numbers",$phone_numbers); 
$my_smarty->assign("client_id",$client_id); 
$my_smarty->assign("client_name",$client_name); 

$footer_smarty = get_smarty(); 

$header_smarty->assign("clients_bg_flag",1); 
$header_smarty->display('app_header.tpl');
$my_smarty->display('assign_number.tpl');
$footer_smarty->display('app_footer.tpl');

// freeze the session 
page_close(); 
// please close the log
$log->close(); 
?>
