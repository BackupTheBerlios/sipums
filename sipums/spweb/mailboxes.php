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

$header_smarty = get_smarty_header($data, $auth, $perm); 

$mb_smarty = get_smarty(); 
//Check persmissions 

$qdomains = array();

if ($perm->have_perm('SUPER')){
  $qdomains[0] = 'ALL';
  #$mb_smarty->assign(edit_permission) = get_smarty(); 
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

$footer_smarty = get_smarty(); 
do_debug("ad domain = $adomain");
$data->init($adomain); 
$mbs = $data->get_mailboxes($adomain); 
$mb_smarty->assign('mailboxes',$mbs); 
$mb_smarty->assign('domain',$adomain); 
$mb_smarty->assign('mailbox_msg',$_GET[msg]); 


$header_smarty->display('app_header.tpl');

$mb_smarty->display('mailboxes.tpl');
$footer_smarty->display('app_footer.tpl');


// freeze the session 
page_close(); 
?>
