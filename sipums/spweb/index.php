<?
/*
 * $Id: index.php,v 1.16 2004/09/07 22:02:27 kenglish Exp $
 */

require "prepend.php";
require 'Smarty.class.php';
                                                                                                                                               
$data = CData_Layer::create($errors) ;
$smarty = new Smarty;
$smarty->left_delimiter = '<!--{';
$smarty->right_delimiter = '}-->';

$log->log("putting headers");
// put_headers();
$log->log("doing page open");
page_open (array("sess" => "phplib_Session"));
$log->log("Got back from page open");

do {
 $log->log("gonna do ");
  // This is where we do the login stuff!
  if (isset($_POST[do_login])){                                                               // Is there data to process?
    $log->log("do_login ");

    if ($sess->is_registered('auth')) $sess->unregister('auth');
    // list($temp_uname, $temp_udomain)  = extract_user_domain($_POST['ulogin'] ); 
    $temp_uname   = $_POST['ulogin'] ; 
    $temp_udomain = 'xxxxxx';
    $log->log($_POST['ulogin']  . " -- " . $temp_uname . " -- " .  $temp_udomain ); 
    if (false === $phplib_id = $data->check_passw_of_user($temp_uname, $temp_udomain, $_POST['passw'], $errors)) {
       $msg = "Could not login";
       break;
    }
    $temp_udomain = $data->get_user_domain($temp_uname); 
    if (!$phplib_id && $temp_udomain && $temp_uname) { 
       $log->log("they do not have a phplib id, let's make them one");  
       $phplib_id = $data->create_php_lib_id($temp_uname, $temp_udomain); 
    }  elseif ($phplib_id && $temp_udomain && $temp_uname) {
       $log->log("good login boy");  
    }  else {
       $msg = "Could not login";
       break;
    }

    $log->log( " register session variables phplib_id = $phplib_id ");
    $sess->register('pre_uid');
    $sess->register('uname');
    $sess->register('udomain');
    $sess->register('company_logo_image');

    $company_logo_image=$data->get_company_logo($temp_uname,$temp_udomain);

    $log->log( " got company_logo_image = $company_logo_image");

    $pre_uid=$phplib_id;
    $udomain=$temp_udomain;
    $adomain=$temp_udomain;
    $log->log( "session adomain = $adomain");
    $uname=$_POST['uname'];
    Header("Location: ".$sess->url("user.php?kvrk=".uniqID("")));
    page_close();
    exit;
  } 
} while (false);



#$udomain_values = $opts[0]; 
#$udomain_output = $opts[1]; 
#
#$smarty->assign("udomain_values", $udomain_values);
#$smarty->assign("udomain_output", $udomain_output);
#

$log->log("creating data layer");

$data = CData_Layer::create($errors) ; 
$msg ; 

$smarty->display('login.tpl');


