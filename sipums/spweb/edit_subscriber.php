<?
/*
   edit_subscriber.php
 */

require 'prepend.php';
require 'Smarty.class.php';
require 'lib/nav.php';

require_once 'data_layer/SpUser.php';

function save_caller_id() {
  global $_POST, $_GET,  $data,$perm,$log,$spUser;

  // first check the permission, only super can update caller id
  $perm->check('SUPER');
  // Conditions to match the options for saving the caller_id settings
  if ($spUser->username) {
    if ($_POST[caller_id_setting] == "NO") {
      $success = $spUser->setCallerIdToUnknown();
    } elseif ($_POST[caller_id_setting] == "DID") {
      $success = $spUser->setCallerIdToDid();
    } elseif ($_POST[caller_id_setting] == "COMPANY")  {
      $success = $spUser->setCallerIdToCompany();
    }

    if ($success) {
      $log->log("caller_id update " . $spUser->username . $_POST[caller_id_setting]  );
      header("Location: subscribers.php");
    }  else {
      $log->log("FAILDED update " . $spUser->username . $_POST[caller_id_setting]  );
    }
  }

                                                                                                                                               
}

function save_perm() {
  global $_POST, $data, $perm,$log,$spUser;
  $perm->check('SUPER');
  $log->log("save_perm " . $_GET[edit_user] );

  if ($spUser->username) {
    if ($spUser->changePerm($_POST[new_perm]) ) { 
      $log->log("perm updated " . $spUser->username);
      header("Location: subscribers.php?msg=Permissions updated for " . $spUser->username);
    }  else { 
     return "Failed to update permission for $_POST[edit_user]";
    } 
  }
}


function get_caller_id_form(&$smarty,&$template_name,$msg) {
  
  global $_POST, $_GET,  $data, $perm,$log,$spUser;
  // first check the permission, only super can edit caller id
  $perm->check('SUPER');


  // get the name of this file and the function name
  $self = str_replace('.php','',basename($_SERVER['PHP_SELF'])) ;
  $template_name = $self . "_" . $_GET[func] . '.tpl'  ;

  // assign the basics 
  $smarty->assign('func',"save_called_id");
  $smarty->assign('edit_user',$spUser->sipAddress);
  $smarty->assign('edit_uname',$spUser->username);
  $smarty->assign('edit_udomain',$spUser->domain);
  $smarty->assign('msg',$msg);

  // get the user's caller_id
  $caller_id = $spUser->getCallerId();

                                                                                                                                               
  // get the user's caller_id
  $log->log($spUser->username .  " = $caller_id "); 
  if (preg_match("/unknown/" , $caller_id)) {
    $smarty->assign('caller_id_setting','NO');
  } elseif (preg_match("/" . $spUser->username ."/", $caller_id))  {
    $log->log("DID " . $spUser->username .  " = $caller_id "); 
    $smarty->assign('caller_id_setting','DID');
  }  else {
    $smarty->assign('caller_id_setting','COMPANY');
  }
  $log->log("CallerID = $caller_id");

  $smarty->assign('setting_options', array(
                    "NO"  => 'No Caller Id',
                    "DID" => "Use DID number (e.g. $edit_uname)",
                    "COMPANY" => "Use Company's main number "));
  return ;
}

function get_perm_form(&$smarty,&$template_name,$msg) {
  
  global $_POST, $_GET,  $data,$spUser,  $perm;
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
  $user_perm = $spUser->perm; 
  $smarty->assign('perm',$user_perm); 

  $smarty->assign('perm_options',array(
                     "USER" => "USER - Edit personal settings only" ,
                     "ADMIN" => "ADMIN - Limitted edit of user in their domain" ,
                     "RESELLER" => "RESELLER - Edit accounts they have resold" ,
                     "SUPER" => "SUPER - Edit everything" )); 
  return ;
}

$log->log("Putting Headers"); 

put_headers();

// get db connect 
$data = CData_Layer::create($errors) ;

$log->log("doing page open"); 
// get the sess, auth and perm vars
page_open (array("sess" => "phplib_Session_Pre_Auth",
   "auth" => "phplib_Pre_Auth",
   "perm" => "phplib_Perm"));
global $perm; 
## do this in every file after the page_open

$header_smarty = get_smarty_header($data, $auth, $perm); 

// If there's nothing to do, let's return

if ($_POST[edit_user] ) { 
  $edit_user = $_POST[edit_user] ; 
} else {
  $edit_user = $_GET[edit_user] ; 
}

list($edit_uname,$edit_udomain) = split('@',$edit_user);

if (!($edit_uname && $edit_udomain) || !($_GET[func] || $_POST[func]) ) {
  header("Location: subscribers.php");
}
$log->log("edit_uname, edit_udomain = ($edit_uname, $edit_udomain "); 

$spUser = new SpUser($data->db,$edit_uname, $edit_udomain );
$spUser->get();

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
