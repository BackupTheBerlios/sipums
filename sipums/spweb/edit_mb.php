<?
/*
 */

require 'prepend.php';
require 'Smarty.class.php';
require 'lib/nav.php';

put_headers();

// get db connect 
$data = CData_Layer::create($errors) ;

// get the sess, auth and perm vars
page_open (array("sess" => "phplib_Session_Pre_Auth",
   "auth" => "phplib_Pre_Auth",
   "perm" => "phplib_Perm"));

## do this in every file after the page_open
$perm->check('ADMIN');
do_debug("func=" . $_GET[func] );
if (!$FORM_VARS[ext] || !($_GET[func] || $_POST[func]) ) { 
  header("Location: mailboxes.php");
} 




if ($perm->have_perm('ADMIN')) {
  $no_require_old_password = 1; 
}

$header_smarty = get_smarty_header($data, $auth, $perm); 

$mb_smarty = get_smarty(); 
$data->init($adomain,$FORM_VARS[ext]); 

//Check persmissions 

if ($_POST[func]=="save_password") { 
  do_debug("tryingt so save_password");
  if (!$_POST[new_password]) { 
    $msg = "Passwords blank";
  }  elseif ($_POST[new_password] != $_POST[new_password_re]) {
    $msg = "Passwords do not match";
  }  elseif (!is_numeric($_POST[new_password])) {
    $msg = "Password must be numeric";
  } else { 
   $data->update_password($_POST[new_password]); 
    header("Location: mailboxes.php?msg=Password for mailbox $_POST[ext] changed");
    exit ;
  }
} 

if($_GET[func]=="delete_mailbox"){
    header("Location: mailboxes.php?msg=Mailbox $_GET[ext] deleted");
}

$footer_smarty = get_smarty(); 
$self = basename($_SERVER['PHP_SELF']) ;
$self = str_replace(".php","",$self); 
if ($_GET[func] == "change_password" || $_POST[func]=="save_password") { 
  // if they saved it
  $body_template = $self . "_" . "change_password" ; 
  $mb_smarty->assign('func',"save_password"); 
  $mb_smarty->assign('ext',$FORM_VARS[ext]); 
  $mb_smarty->assign('msg',$msg); 
} 



 
do_debug("ad domain = $adomain, self = $body_template" );


$mb_smarty->assign('extension',$FORM_VARS[ext]); 


$header_smarty->display('app_header.tpl');

$mb_smarty->display($body_template . ".tpl" );
$footer_smarty->display('app_footer.tpl');


// freeze the session 
page_close(); 
?>
