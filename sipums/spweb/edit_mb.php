<?
/*
 */

require 'prepend.php';
require 'Smarty.class.php';
require 'lib/nav.php';
function save_password() {
  global $_POST,$data, $perm;
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
  return $msg; 
}
function save_perm() {
  global $_POST,$data, $perm;

  if (!$_POST[perm]) {
    $msg = "Passwords blank";
  }  elseif ($_POST[perm] ==  "SUPER" && !$perm->have_perm('SUPER')) { 
    $msg = "Invalid Permission";
  }  elseif ($_POST[perm] ==  "ADMIN" && !$perm->have_perm('ADMIN')) { 
    $msg = "Invalid Permission";
  } else {
   $data->save_perm($_POST[perm]);
    header("Location: mailboxes.php?msg=Permssion changed $_POST[ext] ");
    exit ;
  }
  return $msg; 
                                                                                                                                               
}

function get_change_password_form(&$smarty,&$template_name,$msg){
  global $_POST, $_GET,  $data, $perm, $self;

  $template_name = $self . "_" . "change_password" ; 
  $smarty->assign('func',"save_password"); 
  $smarty->assign('ext',$FORM_VARS[ext]); 
  $smarty->assign('msg',$msg); 

}

function get_edit_perm_form(&$smarty,&$template_name,$msg) {
  global $_POST, $_GET,  $data, $perm, $self,$auth;

  $template_name = $self . "_" . "perm" ; 
  $vm_perm_options = array(); 
  do_debug("checking perm");
  if ($perm->have_perm('SUPER') ) {
     do_debug("he's super");
     $vm_perm_options[] = "SUPER" ; 
     $vm_perm_options[] = "ADMIN" ; 
     $vm_perm_options[] = "USER" ; 
  } elseif ( $perm->have_perm('ADMIN') ) { 
     do_debug("he's addmin");
     $vm_perm_options[] = "ADMIN" ; 
     $vm_perm_options[] = "USER" ; 
  } 

  
  $smarty->assign('func',"save_perm"); 
  $smarty->assign('perm_options',$vm_perm_options); 
  $smarty->assign('perm',$data->get_perm($FORM_VARS[ext]) ); 
  
  $smarty->assign('ext',$_GET[ext]); 
  $smarty->assign('msg',$msg); 
}

put_headers();

// get db connect 
$data = CData_Layer::create($errors) ;

// get the sess, auth and perm vars
page_open (array("sess" => "phplib_Session_Pre_Auth",
   "auth" => "phplib_Pre_Auth",
   "perm" => "phplib_Perm"));

// do this in every file after the page_open
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
$data->init($FORM_VARS[ext], $adomain); 

//Check persmissions 

if ($_POST[func]=="save_password") { 
  $msg = save_password();
  do_debug("trying so save_password");
}  elseif ($_POST[func]=="save_perm"){
  $msg = save_perm();
  do_debug("trying so save_password");
} elseif($_GET[func]=="delete_mailbox"){
    header("Location: mailboxes.php?msg=Mailbox $_GET[ext] deleted");
}


$footer_smarty = get_smarty(); 
$self = basename($_SERVER['PHP_SELF']) ;
$self = str_replace(".php","",$self); 
if ($_GET[func] == "change_password" || $_POST[func]=="save_password") { 
  // if they saved it
  get_change_password_form($mb_smarty, $body_template,$msg); 
}  elseif ($_GET[func] =='edit_perm'){
  get_edit_perm_form($mb_smarty, $body_template,$msg); 

}



 
do_debug("ad domain = $adomain, self = $body_template" );


$mb_smarty->assign('extension',$FORM_VARS[ext]); 


$header_smarty->display('app_header.tpl');

$mb_smarty->display($body_template . ".tpl" );
$footer_smarty->display('app_footer.tpl');


// freeze the session 
page_close(); 
?>
