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
$perm->check('ADMIN');

if ($perm->have_perm('SUPER'))  {
  $log->log("calling change perm") ;
  change_domain();
}
$header_smarty = get_smarty_header($data, $auth, $perm); 

$subscribers_smarty = get_smarty(); 
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


$subscribers = $data->get_subscribers($qdomains); 

$subscribers_smarty->assign("subscribers",$subscribers); 
if ($perm->have_perm('SUPER')){
  $subscribers_smarty->assign("edit_caller_id",1);
  $subscribers_smarty->assign("edit_perm",1);
}

$footer_smarty = get_smarty(); 

$header_smarty->display('app_header.tpl');
$subscribers_smarty->display('subscribers.tpl');
$footer_smarty->display('app_footer.tpl');


// freeze the session 
page_close(); 
?>
