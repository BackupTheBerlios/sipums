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
$perm->check('USER');

if ($perm->have_perm('SUPER'))  {
  change_domain();
}


$header_smarty = get_smarty_header($data, $auth, $perm); 

$reports_smarty = get_smarty(); 
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

$smdr_records = array(); 

$smdr_record['call_type'] = "OUTBOUND";
$smdr_record['date'] = "2004-07-31";
$smdr_record['state_time'] = "16:45:03";
$smdr_record['end_time'] = "16:57:03";
$smdr_record['number'] = "619-555-1111";
$smdr_record['duration'] = "00:07:00";
$smdr_record['cost'] = "0.90";
$smdr_records[] = $smdr_record ; 


//-----------
$smdr_record['call_type'] = "INBOUND";
$smdr_record['date'] = "2004-07-30";
$smdr_record['state_time'] = "06:45:03";
$smdr_record['end_time'] = "07:57:03";
$smdr_record['number'] = "415-555-1212";
$smdr_record['duration'] = "01:07:00";
$smdr_record['cost'] = "0.00";
$smdr_records[] = $smdr_record ; 
//-----------
$smdr_record['call_type'] = "INBOUND";
$smdr_record['date'] = "2004-07-29";
$smdr_record['state_time'] = "12:05:03";
$smdr_record['end_time'] = "13:06:03";
$smdr_record['number'] = "555-2323";
$smdr_record['duration'] = "01:01:00";
$smdr_record['cost'] = "0.00";
$smdr_records[] = $smdr_record ; 
//-----------
$smdr_record['call_type'] = "OUTBOUND";
$smdr_record['date'] = "2004-07-29";
$smdr_record['state_time'] = "10:32:03";
$smdr_record['end_time'] = "10:33:00";
$smdr_record['number'] = "202-555-9999";
$smdr_record['duration'] = "01:01:00";
$smdr_record['cost'] = "10.90";
$smdr_records[] = $smdr_record ;
//-----------
$smdr_record['call_type'] = "OUTBOUND";
$smdr_record['date'] = "2004-07-27";
$smdr_record['state_time'] = "14:25:00";
$smdr_record['end_time'] = "14:35:00";
$smdr_record['number'] = "510-555-1898";
$smdr_record['duration'] = "00:05:00";
$smdr_record['cost'] = "0.90";
$smdr_records[] = $smdr_record ;
//-----------
$smdr_record['call_type'] = "INBOUND";
$smdr_record['date'] = "2004-07-27";
$smdr_record['state_time'] = "14:05:00";
$smdr_record['end_time'] = "14:00:00";
$smdr_record['number'] = "555-9111";
$smdr_record['duration'] = "00:05:00";
$smdr_record['cost'] = "0.00";
$smdr_records[] = $smdr_record ;
//-----------
$smdr_record['call_type'] = "INBOUND";
$smdr_record['date'] = "2004-07-27";
$smdr_record['state_time'] = "13:13:00";
$smdr_record['end_time'] = "13:15:00";
$smdr_record['number'] = "310-555-5555";
$smdr_record['duration'] = "00:02:00";
$smdr_record['cost'] = "0.00";
$smdr_records[] = $smdr_record ; 
//-----------
$smdr_record['call_type'] = "OUTBOUND";
$smdr_record['date'] = "2004-07-27";
$smdr_record['state_time'] = "12:47:00";
$smdr_record['end_time'] = "13:07:00";
$smdr_record['number'] = "714-555-8787";
$smdr_record['duration'] = "00:20:00";
$smdr_record['cost'] = "1.20";
$smdr_records[] = $smdr_record ;


$reports_smarty->assign('smdr_records',$smdr_records);
$footer_smarty = get_smarty(); 

$header_smarty->display('app_header.tpl');
$reports_smarty->display('calls.tpl');
$footer_smarty->display('app_footer.tpl');


// freeze the session 
page_close(); 
?>
