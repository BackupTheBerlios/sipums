<?
/*
 */

require 'prepend.php';
require 'Smarty.class.php';
require 'lib/nav.php';
require 'data_layer/Invitee.php';

function add_invitee() {
  global $log, $conference_id, $_POST,$data; 
  $msgs = array();

  if ($_POST[invitee_flag] =='C'){
    $msgs[] = "Company"; 
    $invitee = new Invitee($data->db,$_POST[conference_id]) ; 

    $invitee->username = $_POST[invitee_username] ; 

    if (!$invitee->getInfoFromUserName()  ) { 
      $msgs[] = "Could not find all Invitee info by username, please enter info by hand.";
      return $msgs;
    } 
    
  } elseif ($_POST[invitee_flag] =='O') {
    if (!$_POST[invitee_email] ) {
      $msgs[] = "No Invitee email"; 
      return $msgs; 
    } 
    $invitee = new Invitee($data->db,$_POST[conference_id]) ; 

    $invitee->inviteeName = $_POST[invitee_name] ; 
    $invitee->inviteeEmail = $_POST[invitee_email] ; 
    
  } 
  if ($invitee->isMaxInvitee()) {
     $msgs[] = "This Invitee is exceeds the maximum capacity of " . $invitee->companyMaxInvitee . " for your company.";
     return $msgs;
  }
  $invitee->generateInviteeCode();
  $invitee->create();
  $invitee->sendNotify();
  header("Location: cdetails.php?conference_id=$conference_id&func=view");

  return $msgs; 
}

put_headers();

// get db connect 
$data = CData_Layer::create($errors) ;


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
   header('Location: conference.php');
}


$header_smarty = get_smarty_header($data, $auth, $perm); 
$smarty = get_smarty(); 



if ($_POST[add_invitee] ) {
  $msgs = add_invitee(); 
} 

if ($_POST[invitee_flag]) {
   $invitee_flag =$_POST[invitee_flag];
} else {
   $invitee_flag ='O'; 
}

$smarty->assign('msgs', $msgs);

$log->log("get_conference_ids " . $auth->auth["uname"] );
$invitee_users = $data->get_invitee_users($auth->auth["udomain"] ) ; 
##$smarty->assign('user_conferences', $ids); 

$smarty->assign('conference_id', $conference_id); 
$smarty->assign('invitee_users', $invitee_users);
$smarty->assign('invitee_flag', $invitee_flag);
$smarty->assign('invitee_username', $_POST[invitee_username]);
$smarty->assign('invitee_name', $_POST[invitee_name]);
$smarty->assign('invitee_email', $_POST[invitee_email]);

$footer_smarty = get_smarty(); 
$header_smarty->assign('conference_bg_flag', 1 );
$header_smarty->display('app_header.tpl');
$smarty->display('invitee_add.tpl');
$footer_smarty->display('app_footer.tpl');


// freeze the session 
page_close(); 
?>
