<?
/*
 */

require 'prepend.php';
require 'Smarty.class.php';
require 'lib/nav.php';
require 'data_layer/Conference.php';

put_headers();


function delete_conference() {
  global $conference,$_POST,$log; 
  if ($_POST[notify_invitees]) {
     $log->log("want to send notif invitee");
    $conference->sendNotifyCancel();  
  } 
   $conference->cancel();  
  Header("Location: conference.php");
  exit; 
  

}

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


$header_smarty = get_smarty_header($data, $auth, $perm); 

$smarty = get_smarty(); 
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
  ## here we'd query the reseller domains  $qdomain[] = $auth->
} elseif ($perm->have_perm('ADMIN') ) {
  $qdomains[] = $auth->auth[udomain];
}

if ($_POST[conference_id]) {
  $conference_id=$_POST[conference_id];
} elseif($_GET[conference_id]) {
  $conference_id=$_GET[conference_id];
}else {
  Header("Location: conference.php");
  exit; 
}

$conference = new Conference($data->db, $auth->auth[uname],$auth->auth[udomain]);
$conference->conferenceId=$conference_id;
$conference->get(); // =$conference_id;

$log->log("rm_conf_flag = " . $_POST[rm_conf_flag]) ; 
$log->log("conference_id = " . $_POST[conference_id]) ; 
if ($_POST[rm_conf_flag]){
  delete_conference();  

}



$smarty->assign('conference_date', $conference->conferenceDateFormatted); 
$smarty->assign('conference_id', $conference->conferenceId); 
$smarty->assign('conference_name', $conference->conferenceName); 
$smarty->assign('begin_time', $conference->beginTimeFormatted); 
$smarty->assign('end_time', $conference->endTimeFormatted); 

$footer_smarty = get_smarty(); 
$header_smarty->assign('conference_bg_flag',1);
$header_smarty->display('app_header.tpl');
$smarty->display('cancel_conference.tpl');
$footer_smarty->display('app_footer.tpl');


// freeze the session 
page_close(); 
?>
