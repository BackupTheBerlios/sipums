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
$perm->check('SUPER');

$header_smarty = get_smarty_header($data, $auth, $perm); 

//Check Paramaters

if (!$FORM_VARS[edit_user] || !($_GET[func] || $_POST[func]) ) {
  header("Location: subscribers.php");
}


if ($_POST[func] == 'save_called_id') { 
  do_debug("Save caller id here " . $_GET[edit_user] ); 
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

$main_smarty = get_smarty(); 
$self = str_replace('.php','',basename($_SERVER['PHP_SELF'])) ;

if ($_GET[func] == "caller_id" || $_POST[func] == 'save_called_id') {
  // if they saved it
  $main_template = $self . "_" . $_GET[func] . '.tpl'  ;
  $main_smarty->assign('func',"save_called_id");
  $main_smarty->assign('edit_user',$_GET[edit_user]);
  list($edit_uname,$edit_udomain) = split('@',$FORM_VARS[edit_user]);
  $main_smarty->assign('edit_uname',$edit_uname);
  $main_smarty->assign('edit_udomain',$edit_udomain );
  $main_smarty->assign('msg',$msg);
  $caller_id = $data->get_caller_id($edit_uname,$edit_udomain); 
  
  do_debug("caller_id = $caller_id " . strstr($caller_id,"unknown")  ); 
  if (strstr($caller_id,"unknown")) { 
    do_debug("should set to NO "); 
    $main_smarty->assign('caller_id_setting','NO');
  } 
  elseif (strrpos($caller_id, $edit_uname) !== FALSE)  { 
    $main_smarty->assign('caller_id_setting','DID');
  }  else {
    $main_smarty->assign('caller_id_setting','COMPANY');
  } 
}

list($edit_uname,$edit_udomain) = split('@',$_GET[edit_user]);

$self = basename($_SERVER['PHP_SELF']) ;
$self = str_replace(".php","",$self);

$footer_smarty = get_smarty(); 

$main_smarty->assign('edit_uname',$edit_uname);
$main_smarty->assign('edit_udomain',$edit_udomain);

$main_smarty->assign('setting_options', array(
			"NO"  => 'No Caller Id',
			"DID" => "Use DID number (e.g. $edit_uname)",
			"COMPANY" => "Use Company's main number "));

$header_smarty->display('app_header.tpl');
$main_smarty->display($main_template);
$footer_smarty->display('app_footer.tpl');


// freeze the session 
page_close(); 
?>
