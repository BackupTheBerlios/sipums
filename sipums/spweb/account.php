<?
/*
 */

require 'prepend.php';
require 'Smarty.class.php';
require_once 'lib/nav.php';
require_once "data_layer/cpl.php";
require_once "data_layer/SpUser.php";
require_once "data_layer/VmUser.php";
require_once "data_layer/phoneNumber.php";

function update_cpl(){
  global $_POST,$log; 
  global $edit_uname, $edit_udomain; 
  $log->log("update_cpl() $edit_uname, $edit_udomain");

  $msgs = array(); 
  if ($_POST[call_opt] == "default") {
    $cpl = new spCPL($edit_uname,$edit_udomain);  // create a CPL object
    if ($cpl->remove_cpl()) { 
      $msgs[] = "Call settings set to default"; 
    } else { 
      $msgs[] = "Save call settings failed"; 
    } 
  } elseif ($_POST[call_opt] == "dnd" ) {
    /// here we save the DNC CPL to the system
    $cpl = new spCPL($edit_uname,$edit_udomain);  // create a CPL object
    $log->log("call_pot is dndn");
   
    if ($cpl->set_dnd()) { 
      $msgs[] = "Call Settings Saved to DND"; 
    } else { 
      $msgs[] = "Save Call Settings failed"; 
    } 
  } elseif ($_POST[call_opt] == "fwd" ) {
    /// here we save the Forward Number to the system
                                                                                                                                               
    $pn = new PhoneNumber($_POST[fwd_number]);
                                                                                                                                               
    if ($pn->valid() && !($pn->isLongDistance())  ) {
       $cpl = new spCPL($edit_uname,$edit_udomain ) ;   // create a CPL object
       if ($cpl->set_forward($pn->number)) { 
         $msgs[] = "Calls will be forwared to " . $pn->number ; 
       } else {
         $msgs[] = "Save call settings failed"; 
       } 
    } elseif (!$pn->valid())  {
      $msgs[] = "Not a Valid Forward Number $_POST[fwd_number] ";
    } elseif($pn->isLongDistance()) {
      $msgs[]= "Will not forward to long distance number";
    }
  } elseif ($_POST[call_opt] == "rb") {
    /// here we save the Ring Both Number to the system
    $pn = new PhoneNumber($_POST[rb_number] );
    if ($pn->valid() && !($pn->isLongDistance())  ) {
      $cpl = new spCPL($edit_uname,$edit_udomain);   // create a CPL object
      if ($cpl->set_ring_both($pn->number)) {
         $msgs[] = "Ring Both number set to " . $pn->number ; 
      } else {
         $msgs[] = "Save call settings failed"; 
      } 
    } elseif (!$pn->valid())  {
      $msgs[] = "Not a Valid Ring Both Number";
    } elseif($pn->isLongDistance()) {
      $msgs[]  = "Will not Ring Both  to long distance number";
    }
  }  elseif ($_POST[call_opt] == "fmfm") {
    /// here we save the Ring Both Number to the system
    $pn = new PhoneNumber($_POST[fmfm_number] );
    if ($pn->valid() && !($pn->isLongDistance())  ) {
      $cpl = new spCPL($edit_uname,$edit_udomain);  // create a CPL object
      if($cpl->set_find_me_follow_me($pn->number)) {
         $msgs[] = "Find Me, Follow number set to " . $pn->number ; 
      } else {
         $msgs[] = "Save call settings failed"; 
      } 
    } elseif (!$pn->valid())  {
      $msgs[] = "Not a valid Find me follow me Number";
    } elseif($pn->isLongDistance()) {
      $msgs[] = "Will not Ring Both  to long distance number";
    }
  }
  $log->log("returning from update_cpl ");
  return $msgs; 

}
function update_user_info(){
  global $_POST,$log,$data; 
  global $spUser,$vmUser, $data; 

  // create the array of error messages
  $user_info_msgs =array(); 

  // save the old e-mail address, we'll check this almost last 
  
  
  $spUser->dbFields[first_name] = $_POST[first_name];
  $spUser->dbFields[last_name] = $_POST[last_name];
  $spUser->dbFields[email_address] = $_POST[email_address];
 
  $log->log("Calling updateBasics"); 
  // update name, email, etc
  if ($spUser->updateBasic()) { 
    $user_info_msgs[] = "Name, E-mail Updated." ;
    // if they have a mailbox, we gotta update that too...


  } else {
    $user_info_msgs[] = "Could not update Name, E-mail." ;
    return $user_info_msgs; 
  } 
  if ($vmUser) { 
       $vmUser->dbFields[first_name] = $_POST[first_name];
       $vmUser->dbFields[last_name] = $_POST[last_name];
       $vmUser->dbFields[email_address] = $_POST[email_address];
       if (!$vmUser->updateBasic())  {
         $user_info_msgs[] = "Failed to update voicemail info." ;
       }  
  }    
   
  // Are they changing the spweb_password?
  if ($_POST[spweb_password] ) {
    //  Can't be the same as their user name
    if ($_POST[spweb_password] == $edit_uname){
         $user_info_msgs[] = "SpWeb Password can not be the same as your username/number." ;
         return $user_info_msgs ; 
    }  else  {
      //  The 2 form fields must match
      if ($_POST[spweb_password]  == $_POST[spweb_password_re] ) {
         $spUser->updateSpPassword($_POST[spweb_password]); 
         $user_info_msgs[] = "SpWeb Password updated." ;
      }  else {
         $user_info_msgs[] = "SpWeb passwords do not match, did not update." ;
         $log->log("passwords do not match\n\n ");
         return $user_info_msgs; 
      }
    }
  }

  // Are they adding a new mailbox?
  if (!$_POST[old_mailbox] && $_POST[mailbox] ) { 
    // Don't let them create a mailbox that already exists
    if ($data->mailbox_exists($_POST[mailbox]) )  { 
       $user_info_msgs[] = "Could not create mailbox, it is already assigned to another user.";
    } else { 
      $log->log("HERE WE ADD A NEW MAILBOX ");
      // create a new VmUsers class
      $vmUser = new vmUser($data->db,	$spUser->username,$spUser->domain,$_POST[mailbox],$spUser->voicemailDbName); 
 
      // set the dbFields array to their basic info
      $vmUser->dbFields[first_name] = $_POST[first_name];
      $vmUser->dbFields[last_name] = $_POST[last_name];
      $vmUser->dbFields[email_address] = $_POST[email_address];
      // try to create the mailbox
      if ($vmUser->create() ) {  
         $user_info_msgs[] = "Created mailbox " . $vmUser->mailbox ;
         // we have to update the SpUser too
         $spUser->mailbox = $vmUser->mailbox; 
         $spUser->updateMailbox();
      } else { 
         $user_info_msgs[] = "Failed to create mailbox " . $vmUser->mailbox ;
         return $user_info_msgs ;
      } 
    }
  // Are they changing to a diff mailbox a new mailbox?
  } elseif($_POST[old_mailbox] != $_POST[mailbox] ) { 
     $log->log("HERE WE WOULD CHANGE THE MAILBOX");
      // Don't let them change to a  mailbox that already exists
     if ($data->mailbox_exists($_POST[mailbox]) )  { 
         $user_info_msgs[] = "Could not change user's mailbox to " . $_POST[mailbox] .".  It is already assigned to another user." ;
         $user_info_msgs[] = "Before assigning an old mailbox to a user, you must first delete it using the 'mailboxes' tab." ; 
         return $user_info_msgs;  
     }  else {
       // deactivate the old mailbox
       if ($vmUser->deactivate())  { 
         // do same step to create a mailbox
         $vmUser = new vmUser($data->db,   $spUser->username,$spUser->domain,$_POST[mailbox],$spUser->voicemailDbName);
         // do set the dbFields array to their basic info
         $vmUser->dbFields[first_name] = $_POST[first_name];
         $vmUser->dbFields[last_name] = $_POST[last_name];
         $vmUser->dbFields[email_address] = $_POST[email_address];
         // this does the magic
         if ($vmUser->create() ) {
            $user_info_msgs[] = "Created mailbox " . $vmUser->mailbox ;
           // we have to update the SpUser too
           $spUser->mailbox = $vmUser->mailbox;
           $spUser->updateMailbox();
         } else {
            $user_info_msgs[] = "Failed to create mailbox " . $vmUser->mailbox ;
            return $user_info_msgs ;
         }
       } else {
         $user_info_msgs[] = "Error deactivatint old mailbox " . $vmUser->mailbox ;
         return $user_info_msgs ;
       } 
     } 
  } 

  // Are they changing the vm_password?
  if ($_POST[vm_password] && $_POST[mailbox]) { 
    //  the 2 form fields must match
    if ($_POST[vm_password]  == $_POST[vm_password_re] ) { 
      //   a voicemail password must be numeric or else how are they gonna enter it on the phone
      if (is_numeric($_POST[vm_password] )  ) { 
          // 
          if ($vmUser->updatePassword($_POST[vm_password])) { 
            $user_info_msgs[] = "Voicemail password updated." ; 
          } else {
            $user_info_msgs[] = "Voicemail password update failed." ; 
            return $user_info_msgs; 
          } 
       } else {
         $user_info_msgs[] = "Voicemail password must be numeric (no *'s or #'s either)." ;
       } 
     }  else {
       $user_info_msgs[] = "Voicemail passwords do not match." ; 
    } 
  } 

  return $user_info_msgs ; 
}
function update_um(){
  // sorry about the globals...
  global $_POST,$log,$data; 
  global $spUser,$vmUser, $data; 
  $um_msgs =array(); 
  $log->log("Update um " ) ;
  if (!$vmUser) { 
     $log->log("Update um " ) ;
     $um_msgs[] = "Can not update Unified Messaging: NO MAILBOX";
  } else {
    $log->log("Setting DB fields..."); 

    // set the database fields
    $vmUser->dbFields[store_flag] = $_POST[store_flag] ; 

    $vmUser->dbFields[vstore_email] = $_POST[vstore_email] ; 
    $vmUser->dbFields[email_delivery] = $_POST[email_delivery] ; 
    $vmUser->dbFields[email_user_name] = $_POST[email_user_name] ; 
    $vmUser->dbFields[email_server_address] = $_POST[email_server_address] ; 
    $vmUser->dbFields[mobile_email_flag] = $_POST[mobile_email_flag] ; 
    $vmUser->dbFields[mobile_email] = $_POST[mobile_email] ; 

    if ($_POST[email_password] ) {
      if ($_POST[email_password]  == $_POST[email_password_re] ) {
         $vmUser->dbFields[email_password] =  $_POST[email_password_re] ;
         $um_msgs[] = "E-mail Password Changed."  ; 
      } else { 
         $um_msgs[] = "Could not update e-mail password: Passwords do not match."  ; 
      }
    } 
    $log->log("Calliend update called...",LOG_DEBUG ); 

    if ($vmUser->updateUm()) { 
        $um_msgs[] = "Unified Messaging Info updated."  ; 
    }  else {
        $um_msgs[] = "Failed to update Unified Messaging Info updated."  ; 
    }   
    return $um_msgs; 
  } 
  



}
function update_vm_flags(){
  global $_POST, $vmUser, $log; 
  $log->log("func === update_vm_flags...",LOG_DEBUG );
  $vmUser->dbFields[active] = $_POST[active] ;
  $vmUser->dbFields[transfer] = $_POST[transfer] ;
  $vmUser->dbFields[new_user_flag] = $_POST[new_user_flag] ;
  $vmUser->dbFields[mwi_flag] = $_POST[mwi_flag] ;

  if ($vmUser->updateVmFlags()) { 
    $vm_msgs[] = "Voicemail flags updated."  ; 
  }  else {
    $vm_msgs[] = "Failed to update voicemail flags."  ; 
  } 
  return $vm_msgs; 
}
function get_cpl_form(&$smarty,$msgs){

  global $log; 
  global $edit_uname, $edit_udomain; 

  $cpl = new spCPL($edit_uname,$edit_udomain);  // create a CPL object
  $xml = $cpl->get_cpl();

  $log->log("cpl seeting is " . $cpl->call_setting ); 
  if ($cpl->call_setting ) {
    $smarty->assign('call_opt', $cpl->call_setting ); 
    if ($cpl->call_setting == 'fwd') {
       $smarty->assign('fwd_number', $cpl->forward_number) ;
    } elseif ($cpl->call_setting == 'rb') {
       $smarty->assign('rb_number', $cpl->ring_both_number) ;
    } elseif ($cpl->call_setting == 'fmfm') {
       $smarty->assign('fmfm_number', $cpl->fmfm_number) ;
    }
  } else { 
    
  }
  if (is_array($msgs)) { 
    $smarty->assign('cpl_msgs', $msgs); 
  } 
}
function get_user_info_form(&$smarty,$msgs){
  global $spUser; 
  global $log; 
  $log->log("last_name " . $spUser->dbFields[last_name]  ); 
  $smarty->assign('user_info_msgs', $msgs ); 
  $smarty->assign('first_name', $spUser->dbFields[first_name] ) ;
  $smarty->assign('last_name', $spUser->dbFields[last_name] ) ;
  $smarty->assign('email_address', $spUser->dbFields[email_address] ) ;
  $smarty->assign('mailbox', $spUser->mailbox ) ;
  $smarty->assign('old_mailbox', $spUser->mailbox ) ;
}
function get_um_form(&$smarty, $msgs )  { 
  global $vmUser; 
  global $log; 
  $smarty->assign('vstore_email_options', array(
                       'N'  => 'Do not send Voicemail over E-mail (Default)',
                       'C' => 'Send a copy of voicemail over e-mail',
                        'S' => 'Send a copy of voicemail over E-mail and delete it from the voicemail'));
  $smarty->assign('email_delivery_options', Array(
                        'I'  => "Deliver and store in IMAP folder 'INBOX Voicemail'",
                        'S' => 'Deliver and store in Main Inbox'));

  if (!$vmUser) {
  $log->log("no extension");
    $smarty->assign('user_info_msg', "This User has no voicemail box. <BR>If a valid mailbox is entered, a new mailbox <BR>will be created for this user." ); 
    $smarty->assign('store_flag','V'); 
  } else {
    $log->log("store_flag  " . $vmUser->dbFields[store_flag] );
    $smarty->assign('store_flag',$vmUser->dbFields[store_flag]); 
    $smarty->assign('vstore_email',$vmUser->dbFields[vstore_email]); 
    $smarty->assign('email_delivery',$vmUser->dbFields[email_delivery]); 
    $log->log("email_deliver_options set " ); 

    if ($vm_info[store_flag] == "V") {
      $smarty->assign('vstore_email',$vmUser->dbFields[vstore_email]); 
    } elseif ($vm_info[store_flag] == "E" ) {
      $smarty->assign('email_delivery',$vmUser->dbFields[email_delivery]); 
    } 
    $smarty->assign('email_server_address',$vmUser->dbFields[email_server_address]); 
    $smarty->assign('email_user_name',$vmUser->dbFields[email_user_name]); 
    $smarty->assign('mobile_email_flag',$vmUser->dbFields[mobile_email_flag]); 
    $smarty->assign('mobile_email',$vmUser->dbFields[mobile_email]); 
    $smarty->assign('um_msgs',$msgs ); 
  }
}
function get_vm_flags_form(&$smarty, $msgs )  { 
  global $vmUser; 
  global $log; 
  if ($vmUser) { 
    $smarty->assign('vm_flags_msgs',$msgs); 
    $smarty->assign('active',$vmUser->dbFields[active]); 
    $smarty->assign('transfer',$vmUser->dbFields[transfer]); 
    $smarty->assign('new_user_flag',$vmUser->dbFields[new_user_flag]); 
    $smarty->assign('mwi_flag',$vmUser->dbFields[mwi_flag]); 
  }
}

/*********************************************
** END FUNCTION DEFS, BEGIN CONTENT
**
**
**
*********************************************/
// get db connect 
$data = CData_Layer::create($errors) ;

// get the sess, auth and perm vars
page_open (array("sess" => "phplib_Session_Pre_Auth",
   "auth" => "phplib_Pre_Auth",
   "perm" => "phplib_Perm"));
$perm->check('USER');
//get those smarties
$header_smarty = get_smarty_header($data, $auth, $perm); 
$account_smarty = get_smarty(); 

// get what user we are editing, default is himself...
$edit_uname = $auth->auth[uname]; 
$edit_udomain = $auth->auth[udomain]; 

// Check persmissions  and get the drop down of users  if the guy has permissions
if ($perm->have_perm('ADMIN')) { 
  // for admins and above
  $account_smarty->assign('show_admin_row',1);  
  $account_smarty->assign('edit_mailbox',1);  
  $qdomains = array();
  if ($perm->have_perm('SUPER')) {
    $qdomains[] = "ALL"; 
  } elseif ($perm->have_perm('RESELLER') ) {
    // get the reseller's domains here
    $qdomains[] = $auth->auth[udomain] ; 
  } else {
    //ADMIN
    $qdomains[] = $auth->auth[udomain] ; 
  } 

  $edit_users = $data->get_edit_users($qdomains);
  
  if ($FORM_VARS[gfunc] == 'change_edit_user') { 
     list($edit_uname,$edit_udomain) = split('@',$FORM_VARS[edit_user]); 
     do_debug("gonna change edit user to $edit_uname,$edit_udomain" ); 
     change_edit_user($edit_uname,$edit_udomain); 
  } else {
    global $gedit_uname; 
    global $gedit_udomain; 
    do_debug("Getting edit user off the session $gedit_uname,$gedit_udomain" ); 
    if ($gedit_uname && $gedit_udomain ) {
       do_debug("Getting edit user off the session $gedit_uname,$gedit_udomain" ); 
       $edit_uname   = $gedit_uname   ;
       $edit_udomain = $gedit_udomain ;
    } 
  } 
  $account_smarty->assign('edit_users',$edit_users);
  $account_smarty->assign('edit_user',"$edit_uname@$edit_udomain");
}

/* Initialize the object $data, $spUser and $vmUser 
    data =  helper database function
    spUser =  subscriber  table from ser database
    vmUser =  VM_Users table in OpenUms database
*/
$data->init($edit_uname, $edit_udomain);
$spUser = new SpUser($data->db,$edit_uname, $edit_udomain);
$spUser->get(); 
$log->log("POST func = $_POST[func]");

if ($spUser->mailbox) { 
  $vmUser = new VmUser($data->db,$spUser->username, $spUser->domain, $spUser->mailbox, $spUser->voicemail_db);
  $vmUser->get();
} else {
  $vmUser = null ;  
}


//  Are they updating, if so call the corresponding function
if ($_POST[func] == 'update_call_opts') { 
  $cpl_msgs = update_cpl(); 
} elseif ($_POST[func] == 'update_user_info'){
  $log->log("$_POST[func] is update_user_info"); 
  $user_info_msgs = update_user_info(); 
// um=Unified Messaged
} elseif ($_POST[func] == 'update_um'){
  $log->log("$_POST[func] is update_um"); 
  $um_msgs = update_um(); 
} elseif ($_POST[func] == 'update_vm_flags' ) {
  $log->log("$_POST[func] is update_um"); 
  $vm_flags_msgs = update_vm_flags(); 
} 

// we've got forms on this page, get them
get_cpl_form(      $account_smarty, $cpl_msgs ) ; 
get_user_info_form($account_smarty, $user_info_msgs ) ; 
get_um_form(       $account_smarty, $um_msgs ) ; 
get_vm_flags_form( $account_smarty, $user_info_msgs ) ; 


// set the action 
$account_smarty->assign('action', 'account.php' ) ;

// put the headers
put_headers();

$footer_smarty = get_smarty();
// print the templates
$header_smarty->display('app_header.tpl');
$account_smarty->display('account.tpl');
$footer_smarty->display('app_footer.tpl');

// freeze the session 

page_close(); 


?>
