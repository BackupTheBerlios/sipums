<?
/*
 */

require 'prepend.php';
require 'Smarty.class.php';
require 'lib/nav.php';
require 'data_layer/SpUser.php';
require 'data_layer/Conference.php';
require 'data_layer/Invitee.php';
require_once 'Date.php';
require_once 'Date/Calc.php';


function create_conference() {
  global $log, $spUser,$_POST,$data; 
  $msgs = array(); 
  // check the title
  if (!$_POST[conference_name] ) { 
    $msgs[] = "Conference must have a title";
    return $msgs  ; 
  } 

  // validate the date ... 
  if (($conference_uts = strtotime($_POST[conference_date]))===false )  { 
    $msgs[] = "Conference date is an Invalid date.";
    return $msgs  ; 
  } 
  list ($m,$d,$y) = split('-',$_POST[conference_date]);

  // Make date objects...
  $confDate = new Date(); 
  $confDate->setMonth($m); 
  $confDate->setYear($y); 
  $confDate->setDay($d); 
  $confDate->setHour(0); 
  $confDate->setMinute(0); 
  $confDate->setSecond(0); 
  $beginTime = $confDate; 
  $endTime = $confDate; 

  list ($beginHour,$beginMinute) = split(':', $_POST[begin_time] ); 
  list ($endHour,$endMinute) = split(':', $_POST[end_time] ); 

  $beginTime->setHour($beginHour); 
  $beginTime->setMinute($beginMinute); 
  $endTime->setHour($endHour); 
  $endTime->setMinute($endMinute); 

  // see if it's the past
  if ($beginTime->isPast() ){ 
    $msgs[] = "Conference date is in the Past.";
    return $msgs ; 
  }   

  // Make sure the end time is not less than the begin time
  if (Date::compare($endTime, $beginTime) != 1     ){ 
    $msgs[] = "Start time must be before end time.";
    return $msgs ; 
  }   
  
  // create a new Conference object

  $conference = new Conference($data->db, $spUser->username,$spUser->domain); 

  // get the user's company Id and load the companies constraints
  $conference->getCompanyId(); 
  $conference->loadConstraints() ; 
  // set the date objects.
  $conference->conferenceDate = $confDate; 
  $conference->conferenceDate = $confDate; 
  $conference->beginTime = $beginTime; 
  $conference->endTime = $endTime; 
  $conference->conferenceName = $_POST[conference_name] ; 

  // Is the conference too long
  if (!$conference->isMaxTime()) {
    $msgs[] = "Your conference exceeds the maximum amount of minutes.";
    return $msgs  ; 
  } 
  
  // Are there other conferences scheduled for this time.
  if (!$conference->isMaxConcurrent()) {
    $msgs[] = "Your company has other conferences scheduled for this time.";
    return $msgs  ; 
  } 
  $error = "nay!"; 
  if ($conference->create($error) ) { 
    $msgs[] = "Conference created id = " . $conference->conferenceId;
    Header("Location: conference.php?msg=Conference created ") ;
  } else {
    $msgs[] = "Failed to create conference. ";
     $msgs[] = "$error";
  } 
  $owner = new Invitee($data->db, $conference->conferenceId);
  $owner->domain = $spUser->domain;
  $owner->username = $spUser->username;
  $owner->companyId = $conference->companyId; 
  $owner->inviteeEmail = $spUser->dbFields[email_address] ; 
  $owner->ownerFlag =  1; 
  $owner->inviteeName = $spUser->dbFields[first_name] . " " . $spUser->dbFields[last_name] ; 
  // genereate that unique code
  $owner->generateInviteeCode();   
  $owner->create();   
  $owner->sendNotify();   
  
  return $msgs  ; 


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

$spUser = new spUser($data->db,$auth->auth[uname], $auth->auth[udomain]); 
$spUser->get();

if ($_POST[create_conference] ){
   $msgs = create_conference(); 
} 



$val = mktime(0,0,0,01,01,2004); 
$interval = 15;  // in minutes
$numer_of_intervals = (24*60)/$interval;  

$times = array();

for ($i=0;$i< $numer_of_intervals; $i++) {
  $new_time = $val + ($interval*$i*60) ; 
  $new_time_ampm = date("H:i",$new_time); 
  $new_time_disp = date("g:i a",$new_time); 
  $times[$new_time_ampm] =  $new_time_disp  ; 
}


// get variables from form if there was an error
if ($_POST[conference_name] ){
  $conference_name = $_POST[conference_name]; 
} else {
  $conference_name = $data->get_conference_name($spUser->domain); 

}
if ($_POST[conference_date] ) {
  $conference_date = $_POST[conference_date]; 
} else {
  $conference_date = date("n-j-Y"); 

}

$date = new Date();
if ($_POST[begin_time] ){ 
  $begin_time = $_POST[begin_time]; 
} else { 
  // default value

  $begin_time = $date->getHour() .  ":00";
  $log->log("begin time = $begin_time ");
}

if ($_POST[end_time] ){ 
  $end_time = $_POST[end_time]; 
} else { 
  // default value
 
  $end_time = ($date->getHour() +1) . ":00"; 
}


$footer_smarty = get_smarty(); 
$header_smarty->assign('include_js_datepicker',1); 
$header_smarty->assign('conference_bg_flag',1); 
$header_smarty->display('app_header.tpl');
$smarty->assign('conference_name',$conference_name); 
$smarty->assign('conference_date',$conference_date); 
$smarty->assign( 'msgs', $msgs ); 
$smarty->assign('owner',$spUser->username); 
$smarty->assign('owner_name',$spUser->dbFields[first_name] . " " . $spUser->dbFields[last_name]); 
$smarty->assign('times',$times ); 
$smarty->assign('begin_time',$begin_time ); 
$smarty->assign('end_time',$end_time ); 
$smarty->display('new_conference.tpl');
$footer_smarty->display('app_footer.tpl');


// freeze the session 
page_close(); 
?>
