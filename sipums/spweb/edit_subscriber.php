<?
/*
   edit_subscriber.php
 */

require 'prepend.php';
require 'Smarty.class.php';
require 'lib/nav.php';

function save_caller_id() {
  global $_POST, $_GET,  $data,$perm;

  // first check the permission, only super can update caller id
  $perm->check('SUPER');
  // Conditions to match the options for saving the caller_id settings
  if ($_POST[edit_uname] && $_POST[edit_udomain]) {
    if ($_POST[caller_id_setting] == "NO") {
      $success = $data->set_caller_id_to_unknown($_POST[edit_uname], $_POST[edit_udomain]);
    } elseif ($_POST[caller_id_setting] == "DID") {
      $success = $data->set_caller_id_to_did($_POST[edit_uname], $_POST[edit_udomain]);
    } elseif ($_POST[caller_id_setting] == "COMPANY")  {
      $success = $data->set_caller_id_to_company($_POST[edit_uname], $_POST[edit_udomain]);
    }

    if ($success) {
      do_debug("caller_id update " . $_GET[edit_user] );
      header("Location: subscribers.php");
    }  else {
      do_debug("Failed to set caller id for $_GET[edit_user]" );
    }
  }

                                                                                                                                               
}

function save_perm() {
  global $_POST, $data, $perm;
  $perm->check('SUPER');
  do_debug("save_perm " . $_GET[edit_user] );

  if ($_POST[edit_uname] && $_POST[edit_udomain]) {
    $success = $data->save_perm($_POST[edit_uname],$_POST[edit_udomain],$_POST[perm]); 
  }

  if ($success) {
      do_debug("perm updated " . $_GET[edit_user] );
      header("Location: subscribers.php?msg=Permissions updated for " . $_POST[edit_uname]);
  }  else {
     return "Failed to update permission for $_POST[edit_user]";
  }
  
}

function get_caller_id_form(&$smarty,&$template_name,$msg) {
  
  global $_POST, $_GET,  $data, $perm;
  // first check the permission, only super can edit caller id
  $perm->check('SUPER');

  // get the name of this file and the function name
  $self = str_replace('.php','',basename($_SERVER['PHP_SELF'])) ;
  $template_name = $self . "_" . $_GET[func] . '.tpl'  ;

  // assign the basics 
  list($edit_uname,$edit_udomain) = split('@',$_GET[edit_user]);
  $smarty->assign('func',"save_called_id");
  $smarty->assign('edit_user',$_GET[edit_user]);
  $smarty->assign('edit_uname',$edit_uname);
  $smarty->assign('edit_udomain',$edit_udomain );
  $smarty->assign('msg',$msg);

  // get the user's caller_id
  $caller_id = $data->get_caller_id($edit_uname,$edit_udomain);
                                                                                                                                               
  // get the user's caller_id
  if (strstr($caller_id,"unknown")) {
    $smarty->assign('caller_id_setting','NO');
  }
  elseif (strrpos($caller_id, $edit_uname) !== FALSE)  {
    $smarty->assign('caller_id_setting','DID');
  }  else {
    $smarty->assign('caller_id_setting','COMPANY');
  }
  do_debug("CallerID = $caller_id");

  $smarty->assign('setting_options', array(
                    "NO"  => 'No Caller Id',
                    "DID" => "Use DID number (e.g. $edit_uname)",
                    "COMPANY" => "Use Company's main number "));
  return ;
}

function get_perm_form(&$smarty,&$template_name,$msg) {
  
  global $_POST, $_GET,  $data, $perm;
  // first check the permission, only super can edit permissions 
  $perm->check('SUPER');

  // get the name of this file and the function name
  $self = str_replace('.php','',basename($_SERVER['PHP_SELF'])) ;
  $template_name = $self . "_" . $_GET[func] . '.tpl'  ;

  // assign the basics 
  list($edit_uname,$edit_udomain) = split('@',$_GET[edit_user]);
  $smarty->assign('func','save_perm');
  $smarty->assign('edit_user',$_GET[edit_user]);
  $smarty->assign('edit_uname',$edit_uname);
  $smarty->assign('edit_udomain',$edit_udomain );
  $smarty->assign('msg',$msg);

  // get the user's caller_id
  $user_perm = $data->get_perm($edit_uname,$edit_udomain);
  $smarty->assign('perm',$user_perm); 

  $smarty->assign('perm_options',array(
                     "USER" => "USER - Edit personal settings only" ,
                     "ADMIN" => "ADMIN - Limitted edit of user in their domain" ,
                     "RESELLER" => "RESELLER - Edit accounts they have resold" ,
                     "SUPER" => "SUPER - Edit everything" )); 
  return ;
}


put_headers();

// get db connect 
$data = CData_Layer::create($errors) ;


// get the sess, auth and perm vars
page_open (array("sess" => "phplib_Session_Pre_Auth",
   "auth" => "phplib_Pre_Auth",
   "perm" => "phplib_Perm"));


## do this in every file after the page_open
$perm->check('ADMIN');

$header_smarty = get_smarty_header($data, $auth, $perm); 

// If there's nothing to do, let's return

if (!($_GET[edit_user] || $_POST[edit_user]) || !($_GET[func] || $_POST[func]) ) {
  header("Location: subscribers.php");
}


// these process the form, save data, etc
if ($_POST[func] == 'save_called_id') { 
  $msg = save_caller_id() ;
}
elseif ($_POST[func] == 'save_perm') { 
  $msg = save_perm() ;
}

$main_smarty = get_smarty(); 
$main_template;

// these do the presentention, query the db, etc
if ($_GET[func] == "caller_id" || $_POST[func] == 'save_called_id') {
  // if they saved it
   get_caller_id_form(&$main_smarty,$main_template,$msg);  
} elseif ($_GET[func] == "perm" || $_POST[func] == 'save_perm') {
   get_perm_form(&$main_smarty,$main_template,$msg);  
}

$footer_smarty = get_smarty(); 
$header_smarty->display('app_header.tpl');
$main_smarty->display($main_template);
$footer_smarty->display('app_footer.tpl');
page_close(); 
?>
