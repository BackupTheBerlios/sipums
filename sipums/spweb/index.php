<?
/*
 * $Id: index.php,v 1.3 2004/08/03 09:14:40 kenglish Exp $
 */

require "prepend.php";
require 'Smarty.class.php';
                                                                                                                                               
$data = CData_Layer::create($errors) ;
$smarty = new Smarty;
$smarty->left_delimiter = '<!--{';
$smarty->right_delimiter = '}-->';

do_debug("putting headers");
// put_headers();
do_debug("doing page open");
page_open (array("sess" => "phplib_Session"));
do_debug("Got back from page open");

do {
 do_debug("gonna do ");
  // This is where we do the login stuff!
  if (isset($_POST[do_login])){                                                               // Is there data to process?
    do_debug("do_login ");

    if ($sess->is_registered('auth')) $sess->unregister('auth');
    // list($temp_uname, $temp_udomain)  = extract_user_domain($_POST['ulogin'] ); 
    $temp_uname   = $_POST['ulogin'] ; 
    $temp_udomain = 'xxxxxx';
    do_debug($_POST['ulogin']  . " -- " . $temp_uname . " -- " .  $temp_udomain ); 
    if (false === $phplib_id = $data->check_passw_of_user($temp_uname, $temp_udomain, $_POST['passw'], $errors)) {
       $msg = "Could not login";
       break;
    }
    $temp_udomain = $data->get_user_domain($temp_uname); 
                                                                                                                                               
    do_debug( " register session variables");
    $sess->register('pre_uid');
    $sess->register('uname');
    $sess->register('udomain');
    $sess->register("adomain");
    $pre_uid=$phplib_id;
    $udomain=$temp_udomain;
    $adomain=$temp_udomain;
    do_debug( "session adomain = $adomain");
    $uname=$_POST['uname'];
    Header("Location: ".$sess->url("user.php?kvrk=".uniqID("")));
    page_close();
    exit;
  } 
} while (false);


$opts = $data->get_domain_options(null,null);

$udomain_values = $opts[0]; 
$udomain_output = $opts[1]; 

$smarty->assign("udomain_values", $udomain_values);
$smarty->assign("udomain_output", $udomain_output);


do_debug("creating data layer");

$data = CData_Layer::create($errors) ; 
$msg ; 

$smarty->display('login.tpl');


