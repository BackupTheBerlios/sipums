<?
/*
 */

require 'prepend.php';
require 'Smarty.class.php';
require 'lib/nav.php';
require_once 'data_layer/Invitee.php';
require_once 'data_layer/Conference.php';

function uninvite() {
  global $_POST, $log, $invitee,$conference_id; 
  if ($_POST[notifyUninvite] ) { 
    $invitee->sendUninvite(); 
  } 
  $invitee->remove(); 
  Header("Location: cdetails.php?conference_id=$conference_id");

}
function save_invitee() {
  global $log, $invitee; 
  $msgs = array();

  $invitee->inviteeName = $_POST[invitee_username] ; 
  $invitee->inviteeEmail = $_POST[invitee_email] ; 

  $invitee->inviteeName = $_POST[invitee_name] ; 
  $invitee->inviteeEmail = $_POST[invitee_email] ; 

  if($invitee->update()) { 
    $msgs[] = "Invitee Info Updated."; 
  } else {
    $msgs[] = "Invitee Info Update Failed."; 
  } 
  return $msgs; 
}

put_headers();

// get db connect 
if ($_POST[conference_id]) { 
  $conference_id = $_POST[conference_id]; 
  $invitee_id = $_POST[invitee_id]; 
}  else {
  $conference_id = $_GET[conference_id]; 
  $invitee_id = $_GET[invitee_id]; 

}
$data = CData_Layer::create($errors) ;
$invitee = new Invitee($data->db, $_GET[conference_id], $_GET[invitee_id] );
$invitee->get();

// get the sess, auth and perm vars
page_open (array("sess" => "phplib_Session_Pre_Auth",
   "auth" => "phplib_Pre_Auth",
   "perm" => "phplib_Perm"));


## do this in every file after the page_open
$perm->check('USER');

if ($perm->have_perm('SUPER'))  {
  change_domain();
}


//Check persmissions 
$qdomains = array();

if ($perm->have_perm('SUPER')){
  $qdomains[0] = 'ALL';
  global $adomain;
  if ($FORM_VARS[domain]) {
    $qdomains[0] = $FORM_VARS[domain];
  } elseif ($adomain) {
    $qdomains[0] = $adomain;
  } 
} elseif ($perm->have_perm('RESELLER') ) {
  ## HEre we'd query the reseller domains  $qdomain[] = $auth->
} elseif ($perm->have_perm('ADMIN') ) {
  $qdomains[] = $auth->auth[udomain];
}
if ($_POST[conference_id]) { 
  $conference_id = $_POST[conference_id] ; 
} elseif ($_GET[conference_id]) {
  $conference_id = $_GET[conference_id] ; 
}

if (!$data->is_conference_owner($conference_id,$auth->auth["uname"]) ) {
  #$log
   header('Location: conference.php');
}


$header_smarty = get_smarty_header($data, $auth, $perm); 
$smarty = get_smarty(); 

$log->log("save_invitee === " . $_POST[edit_invitee]  ); 
$log->log("uninvite === " . $_POST[uninvite]  ); 

if ($_POST[edit_invitee] ) {
   $msgs = save_invitee(); 
} elseif ($_POST[uninvite] ){
   $msgs = uninvite(); 

} 

if ($_POST[invitee_flag]) {
   $invitee_flag =$_POST[invitee_flag];
} else {
   $invitee_flag ='O'; 
}

$smarty->assign('msgs', $msgs);

$log->log("get_conference_ids " . $auth->auth["uname"] );
// $invitee_users = $data->get_invitee_users($auth->auth["udomain"] ) ; 
# #  $smarty->assign('user_conferences', $ids); 

$smarty->assign('conference_id', $conference_id); 
$smarty->assign('invitee_id', $invitee_id);
$smarty->assign('invitee_name', $invitee->inviteeName);
$smarty->assign('invitee_email', $invitee->inviteeEmail);

$footer_smarty = get_smarty(); 
$header_smarty->assign('conference_bg_flag',1);
$header_smarty->display('app_header.tpl');
$smarty->display('invitee_edit.tpl');
$footer_smarty->display('app_footer.tpl');

// freeze the session 
page_close(); 
?>
