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

$log->log("get_conference_ids " . $auth->auth["uname"] );

$conference_data = $data->get_conference_summary($auth->auth["uname"],$perm->have_perm('ADMIN') ); 

//if (!empty($ids)) { 
//   $user_conf = $data->get_user_conferences($ids); 
//   $smarty->assign('user_conferences', $user_conf); 
//} 
  $smarty->assign('user_conferences', $conference_data); 
##$smarty->assign('user_conferences', $ids); 

$footer_smarty = get_smarty(); 
$header_smarty->assign('conference_bg_flag',1);
$header_smarty->display('app_header.tpl');
$smarty->display('conference.tpl');
$footer_smarty->display('app_footer.tpl');


// freeze the session 
page_close(); 
?>
