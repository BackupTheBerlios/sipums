<?
/*
 */

require 'prepend.php';
require 'Smarty.class.php';
require 'lib/nav.php';
require "lib/cpl.php";
require "lib/phoneNumber.php";


// get db connect 
$data = CData_Layer::create($errors) ;

// get the sess, auth and perm vars
page_open (array("sess" => "phplib_Session_Pre_Auth",
   "auth" => "phplib_Pre_Auth",
   "perm" => "phplib_Perm"));

## do this in every file after the page_open
$perm->check('USER');

$header_smarty = get_smarty_header($data, $auth, $perm); 

$account_smarty = get_smarty(); 

$edit_uname = $auth->auth[uname]; 
$edit_udomain = $auth->auth[udomain]; 

// Check persmissions 
if ($perm->have_perm('ADMIN')){ 
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

$data->init($edit_uname, $edit_udomain);


$msg = array();
// CPL STUFF STARTS HERE
do_debug("func = $FORM_VARS[func]");
if ($FORM_VARS[func] == 'update_call_opts') { 
  if ($FORM_VARS[call_opt] == "default") {
 
    $cpl = new spCPL($edit_uname,$edit_udomain);  // create a CPL object
    $cpl->remove_cpl();
    $account_smarty->assign('call_opt','default');

  } if ($FORM_VARS[call_opt] == "dnd" ) {
    /// here we save the DNC CPL to the system
    $cpl = new spCPL($edit_uname,$edit_udomain);  // create a CPL object
    do_debug("call_pot is dndn");
    $msg[] = $cpl->set_dnd();
    $account_smarty->assign('call_opt','dnd');
  } elseif ($FORM_VARS[call_opt] == "fwd" ) {
    /// here we save the Forward Number to the system
                                                                                                                                               
    $pn = new PhoneNumber($FORM_VARS[fwd_number]);
                                                                                                                                               
    if ($pn->valid() && !($pn->isLongDistance())  ) {
      $cpl = new spCPL($edit_uname,$edit_udomain ) ;   // create a CPL object
      $msg[] = $cpl->set_forward($pn->number);
      $account_smarty->assign('call_opt','fwd');
      $account_smarty->assign('fwd_number', $FORM_VARS[fwd_number]); 
    } elseif (!$pn->valid())  {
      $msg[] = "Not a Valid Forward Number $FORM_VARS[fwd_number] ";
    } elseif($pn->isLongDistance()) {
      $msg[]= "Will not forward to long distance number";
    }
                                                                                                                                               
  } elseif ($FORM_VARS[call_opt] == "rb") {
    /// here we save the Ring Both Number to the system
    $pn = new PhoneNumber($FORM_VARS[rb_number] );
    if ($pn->valid() && !($pn->isLongDistance())  ) {
      $cpl = new spCPL($edit_uname,$edit_udomain);   // create a CPL object
      $msg[] = $cpl->set_ring_both($pn->number);
      $account_smarty->assign('call_opt','rb');
      $account_smarty->assign('rb_number', $FORM_VARS[rb_number]); 
    } elseif (!$pn->valid())  {
      $msg[] = "Not a Valid Ring Both Number";
    } elseif($pn->isLongDistance()) {
      $msg[]  = "Will not Ring Both  to long distance number";
    }
  }  elseif ($FORM_VARS[call_opt] == "fmfm") {
    /// here we save the Ring Both Number to the system
    $pn = new PhoneNumber($FORM_VARS[fmfm_number] );
    if ($pn->valid() && !($pn->isLongDistance())  ) {
      $cpl = new spCPL($edit_uname,$edit_udomain);  // create a CPL object
      $msg[] = $cpl->set_find_me_follow_me($pn->number);
      $account_smarty->assign('call_opt','fmfm');
      $account_smarty->assign('fmfm_number', $FORM_VARS[fmfm_number]); 
    } elseif (!$pn->valid())  {
      $msg[] = "Not a valid Find me follow me Number";
    } elseif($pn->isLongDistance()) {
      $msg[] = "Will not Ring Both  to long distance number";
    }
  }
} else {

  $cpl = new spCPL($edit_uname,$edit_udomain);  // create a CPL object
  $xml = $cpl->get_cpl();
  $msg = "";
    do_debug("call_setting = " . $cpl->call_setting );
  if ($cpl->call_setting ) {
    $account_smarty->assign('call_opt', $cpl->call_setting ); 
    if ($cpl->call_setting == 'fwd') {
       $account_smarty->assign('fwd_number', $cpl->forward_number) ;
    } elseif ($cpl->call_setting == 'rb') {
       $account_smarty->assign('rb_number', $cpl->ring_both_number) ;
     } elseif ($cpl->call_setting == 'fmfm') {
       $account_smarty->assign('fmfm_number', $cpl->fmfm_number) ;
     }
  }
                                                                                                                                               
}

do_debug("func is $FORM_VARS[func]");
if ($FORM_VARS[func] == 'update_user_vm') {

  do_debug("func is update_user_vm\n\n "); 
  $user_info = array();  

  $user_info[first_name] = $FORM_VARS[first_name];
  $user_info[last_name] = $FORM_VARS[last_name];
  $user_info[email_address] = $FORM_VARS[email_address];
  $user_info[mailbox] = $FORM_VARS[mailbox];
  $user_info_msgs =array(); 
  $do_update = 1; 

  // check vm_password
  if ($FORM_VARS[vm_password] ) { 
    if ($FORM_VARS[vm_password]  == $FORM_VARS[vm_password_re] ) { 
      if (is_numeric($FORM_VARS[vm_password] )  ) { 
          $user_info[vm_password] =  $FORM_VARS[vm_password_re] ;     
          $user_info_msgs[] = "Voicemail Password updated." ; 
       } else {
         $user_info_msgs[] = "Voicemail password must be numeric." ;
       } 
     }  else {
       $user_info_msgs[] = "Voicemail passwords do not match." ; 
       do_debug("passwords do not match\n\n "); 
    } 
  } 
  // same check for spweb_password
  if ($FORM_VARS[spweb_password] ) {
    if ($FORM_VARS[spweb_password] == $edit_uname){
         $user_info_msgs[] = "SpWeb Password can not be the same as your username/number." ;
    }  else  {
      if ($FORM_VARS[spweb_password]  == $FORM_VARS[spweb_password_re] ) {
         $user_info[spweb_password] =  $FORM_VARS[spweb_password_re] ;
         $user_info_msgs[] = "SpWeb Password updated." ;
      }  else {
         $user_info_msgs[] = "SpWeb passwords do not match." ;
         do_debug("passwords do not match\n\n ");
      }
    }


  }

  if ($do_update) { 
    foreach ($user_info as $key => $value){
      do_debug("user_info $key;$value");
     }
     $data->update_user_info($user_info); 
     $user_info_msgs[] = "User Info updated." ;
  }

  $account_smarty->assign('user_info_msgs', $user_info_msgs ); 
  
} else {
  $user_info = $data->get_user_info(); 
}

$vm_info = $data->get_vm_info($user_info[mailbox]);

if ($FORM_VARS[func] == 'update_um') {
  do_debug("here we update um settings..." ); 

  $vm_info[store_flag] = $FORM_VARS[store_flag] ; 
  $vm_info[vstore_email] = $FORM_VARS[vstore_email] ; 

  $vm_info[email_delivery] = $FORM_VARS[email_delivery] ; 
  $vm_info[email_user_name] = $FORM_VARS[email_user_name] ; 
  $vm_info[email_server_address] = $FORM_VARS[email_server_address] ; 
  $vm_info[mobile_email_flag] = $FORM_VARS[mobile_email_flag] ; 
  $vm_info[mobile_email] = $FORM_VARS[mobile_email] ; 
  if ($FORM_VARS[email_password] ) {
    if ($FORM_VARS[email_password]  == $FORM_VARS[email_password_re] ) {
       $vm_info[email_password] =  $FORM_VARS[email_password_re] ;
       $account_smarty->assign('user_um_msg', "Unified Messaging Info & Email Password updated." );
       $data->update_um($vm_info);  
    } else { 
       $account_smarty->assign('user_um_msg', "Email Paswords do not match." );
       do_debug("passwords do not match\n\n ");
    }
  }  else {
    $account_smarty->assign('user_um_msg', "Unified Messaging Info updated." );
    $data->update_um($vm_info);  
  }
  
  // update the unified messaging

}

if ($FORM_VARS[func] == 'update_vm_flags') {
  do_debug("func === update_vm_flags..." );
  $vm_info[active] = $FORM_VARS[active] ;
  $vm_info[transfer] = $FORM_VARS[transfer] ;
  $vm_info[new_user_flag] = $FORM_VARS[new_user_flag] ;
  $vm_info[mwi_flag] = $FORM_VARS[mwi_flag] ;
  $data->update_vm_flags($vm_info);  


}


/// HERE WE SET ALL THE VALUES IN THE TEMPLATE

if (!$vm_info[extension]) {
  do_debug("no extension");
  $account_smarty->assign('user_info_msg', "This User has no voicemail box. <BR>If a valid mailbox is entered, a new mailbox <BR>will be created for this user." ); 

} else {
  $account_smarty->assign('store_flag',$vm_info[store_flag]); 
  $account_smarty->assign('vstore_email',$vm_info[vstore_email]); 
  $account_smarty->assign('email_delivery',$vm_info[email_delivery]); 

  $account_smarty->assign('vstore_email_options', array(
                        'N'  => 'Do not send Voicemail over E-mail (Default)',
                        'C' => 'Send a copy of voicemail over e-mail',
                        'S' => 'Send a copy of voicemail over E-mail and delete it from the voicemail'));

  $account_smarty->assign('email_delivery_options', Array(
                        'I'  => "Deliver and store in IMAP folder 'INBOX Voicemail'",
                        'S' => 'Deliver and store in Main Inbox'));

  

  if ($vm_info[store_flag] == "V") {
    do_debug("setting  vstore_email = " . $vm_info[vstore_email]); 
    $account_smarty->assign('vstore_email',$vm_info[vstore_email]); 
  } elseif ($vm_info[store_flag] == "E" ) {
    $account_smarty->assign('email_delivery',$vm_info[email_delivery]); 
  } 
  $account_smarty->assign('email_server_address',$vm_info[email_server_address]); 
  $account_smarty->assign('email_user_name',$vm_info[email_user_name]); 
  $account_smarty->assign('mobile_email_flag',$vm_info[mobile_email_flag]); 
  $account_smarty->assign('mobile_email',$vm_info[mobile_email]); 
  $account_smarty->assign('active',$vm_info[active]); 
  $account_smarty->assign('transfer',$vm_info[transfer]); 
  $account_smarty->assign('new_user_flag',$vm_info[new_user_flag]); 
  $account_smarty->assign('mwi_flag',$vm_info[mwi_flag]); 
}
  
  $account_smarty->assign('first_name', $user_info[first_name] ) ;
  $account_smarty->assign('last_name', $user_info[last_name] ) ;
  $account_smarty->assign('email_address', $user_info[email_address] ) ;
  $account_smarty->assign('mailbox', $user_info[mailbox] ) ;
  $account_smarty->assign('action', 'account.php' ) ;




put_headers();

$footer_smarty = get_smarty();



$header_smarty->display('app_header.tpl');
$account_smarty->display('account.tpl');
$footer_smarty->display('app_footer.tpl');

// freeze the session 

page_close(); 


?>
