<?
/*
 */

require 'prepend.php';
require 'Smarty.class.php';
require 'lib/nav.php';
require 'data_layer/VmUser.php';

function delete_mailbox () { 
  global $_POST, $vmUser,$DELETE_KEYWORD,$log  ; 
  $log->log($_POST[do_delete] . " == $DELETE_KEYWORD "); 

  if ($_POST[do_delete] == $DELETE_KEYWORD){ 
    if($vmUser->delete()) { 
       header("Location: mailboxes.php?msg=Mailbox $_POST[ext] deleted");
       exit;
     } else {
        return "delete mailbox failed"; 
     }
  } else {  
    header("Location: mailboxes.php?msg=Delete mailbox cancelled");
    exit;
  } 
   
    
} 
function save_password() {
  global $_POST,$data,$vmUser,  $perm;
  if (!$_POST[new_password]) {
    $msg = "Passwords blank";
  }  elseif ($_POST[new_password] != $_POST[new_password_re]) {
    $msg = "Passwords do not match";
  }  elseif (!is_numeric($_POST[new_password])) {
    $msg = "Password must be numeric";
  } else {
    if ($vmUser->updatePassword($_POST[new_password])) { 
      header("Location: mailboxes.php?msg=Password for mailbox $_POST[ext] changed");
      exit ;
    }  else {  
      $msg = "Failed to update password for mailbox.";
    } 
  }
  return $msg; 
}
function save_perm() {
  global $_POST,$data,$vmUser, $perm;

  if (!$_POST[perm]) {
    $msg = "Passwords blank";
  }  elseif ($_POST[perm] ==  "SUPER" && !$perm->have_perm('SUPER')) { 
    $msg = "Invalid Permission";
  }  elseif ($_POST[perm] ==  "ADMIN" && !$perm->have_perm('ADMIN')) { 
    $msg = "Invalid Permission";
  } else {
   $vmUser->savePerm($_POST[perm]);
    header("Location: mailboxes.php?msg=Permssion changed $_POST[ext] ");
    exit ;
  }
  return $msg; 
                                                                                                                                               
}
function save_flags(){

  global $_POST, $vmUser, $log;
  $log->log("func === update_vm_flags...",LOG_DEBUG );
  $vmUser->dbFields[active] = $_POST[active] ;
  $vmUser->dbFields[transfer] = $_POST[transfer] ;
  $vmUser->dbFields[new_user_flag] = $_POST[new_user_flag] ;
  $vmUser->dbFields[mwi_flag] = $_POST[mwi_flag] ;
                                                                                                                                               
  if ($vmUser->updateVmFlags()) {
    header("Location: mailboxes.php?msg=Voicemail flags updated for $_POST[ext] ");
  }  else {
    return "Failed to update voicemail flags."  ;
  }
  return $vm_msgs;
}

function get_delete_conf_form(&$smarty,&$template_name,$msg){
  global $_POST, $_GET, $vmUser, $data, $perm, $self;
  global $DELETE_KEYWORD; 
  $template_name = $self . "_" . "delete_conf" ; 
  $smarty->assign('func',"delete_mailbox_final"); 
  $smarty->assign('delete_keyword',"Delete"); 
  $smarty->assign('ext',$vmUser->mailbox); 
   
}

function get_change_password_form(&$smarty,&$template_name,$msg){
  global $_POST, $_GET, $vmUser, $data, $perm, $self;

  $template_name = $self . "_" . "change_password" ; 
  $smarty->assign('func',"save_password"); 
  $smarty->assign('ext',$vmUser->mailbox); 
  $smarty->assign('msg',$msg); 

}

function get_edit_perm_form(&$smarty,&$template_name,$msg) {
  global $_POST, $_GET,$log,  $data, $perm, $self,$auth,$vmUser;

  $template_name = $self . "_" . "perm" ; 
  $vm_perm_options = array(); 
  $log->log("checking perm");
  if ($perm->have_perm('SUPER') ) {
     $log->log("he's super");
     $vm_perm_options[] = "SUPER" ; 
     $vm_perm_options[] = "ADMIN" ; 
     $vm_perm_options[] = "USER" ; 
  } elseif ( $perm->have_perm('ADMIN') ) { 
     $log->log("he's addmin");
     $vm_perm_options[] = "ADMIN" ; 
     $vm_perm_options[] = "USER" ; 
  } 

  
  $smarty->assign('func',"save_perm"); 
  $smarty->assign('perm_options',$vm_perm_options); 
  $smarty->assign('perm',$vm_perm_options) ; 
  
  $smarty->assign('ext',$_GET[ext]); 
  $smarty->assign('msg',$msg); 
}
function get_edit_flags_form(&$smarty,&$template_name,$msg) {
  global $_POST, $_GET,$log,  $data, $perm, $self,$auth,$vmUser;
  $template_name = $self . "_" . "flags" ; 
  $smarty->assign('func',"save_flags"); 
  $smarty->assign('ext',$vmUser->mailbox);
  $smarty->assign('msg',$msg);

  $smarty->assign('active',$vmUser->dbFields[active]);
  $smarty->assign('transfer',$vmUser->dbFields[transfer]);
  $smarty->assign('new_user_flag',$vmUser->dbFields[new_user_flag]);
  $smarty->assign('mwi_flag',$vmUser->dbFields[mwi_flag]);

  return ;

}

$DELETE_KEYWORD = "Delete" ; 
put_headers();

// get db connect 
$data = CData_Layer::create($errors) ;

// get the sess, auth and perm vars
page_open (array("sess" => "phplib_Session_Pre_Auth",
   "auth" => "phplib_Pre_Auth",
   "perm" => "phplib_Perm"));

// do this in every file after the page_open
$perm->check('ADMIN');

$log->log("func=" . $_GET[func] );

if (!$FORM_VARS[ext] || !($_GET[func] || $_POST[func]) ) { 
  header("Location: mailboxes.php");
} 

if ($perm->have_perm('ADMIN')) {
  $no_require_old_password = 1; 
}

$header_smarty = get_smarty_header($data, $auth, $perm); 
$mb_smarty = get_smarty(); 
if ($_POST[ext]) { 
  $mailbox = $_POST[ext]; 
} else {
  $mailbox = $_GET[ext]; 
}

$log->log("maibox is $mailbox");

$log->log("ad domain = $adomain, self = $body_template" );
$vmUser = new vmUser($data->db,null, $adomain, $mailbox ); 
$vmUser->get(); 

// $data->init($FORM_VARS[ext], $adomain); 

//Check persmissions 

if ($_POST[func]=="save_password") { 
  $msg = save_password();
  $log->log("trying so save_password");
}  elseif ($_POST[func]=="save_perm"){
  $msg = save_perm();
  $log->log("trying so save_password");
}  elseif ($_POST[func]=="save_flags"){
  $msg = save_flags();
  $log->log("trying so save_password");

} elseif($_POST[func]=="delete_mailbox_final"){
   $msg = delete_mailbox(); 
}


$footer_smarty = get_smarty(); 
$self = basename($_SERVER['PHP_SELF']) ;
$self = str_replace(".php","",$self); 
if ($_GET[func] == "change_password" || $_POST[func]=="save_password") { 
  // if they saved it
  get_change_password_form($mb_smarty, $body_template,$msg); 
}  elseif ($_GET[func] =='edit_perm'){
  get_edit_perm_form($mb_smarty, $body_template,$msg); 
}  elseif ($_GET[func] =='edit_flags'){
  get_edit_flags_form($mb_smarty, $body_template,$msg); 
} elseif ($_GET[func] == 'delete_mailbox' || $_POST[func]=="delete_mailbox_final"){
  get_delete_conf_form($mb_smarty, $body_template,$msg); 

}





$mb_smarty->assign('extension',$FORM_VARS[ext]); 


$header_smarty->display('app_header.tpl');

$mb_smarty->display($body_template . ".tpl" );
$footer_smarty->display('app_footer.tpl');


// freeze the session 
page_close(); 
?>
