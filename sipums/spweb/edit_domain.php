<?
/*
 */

require 'prepend.php';
require 'Smarty.class.php';
require 'lib/nav.php';
require 'data_layer/SpDomain.php';
require 'data_layer/VmUser.php';

function save_domain() {
  global $_POST,$data,$spDomain, $perm,$log;

  if ($spDomain->domain) {
    $spDomain->dbFields[company_name] = $_POST[company_name]; 
    $spDomain->dbFields[company_number] = $_POST[company_number]; 
    $log->log("gonna updateBasic updateBasic " ); 
    if ($spDomain->updateBasic()) { 
      $log->log("did updateBasic " ); 
      header("Location: domains.php?msg=Company Info changed for " . $spDomain->domain );
      exit ;
    }  else {  
      $msg = "Failed to update password for mailbox.";
    } 
  } else {
      $msg = "No Domain to save.";
  } 
  return $msg; 
}

function get_domain_form(&$smarty,&$template_name,$msg){
  global $_POST, $_GET, $spDomain, $data, $perm, $self,$log;

  $template_name = $self . "_" . "domain" ; 
  $smarty->assign('func',"save_domain"); 
  $smarty->assign('domain',$spDomain->domain); 
  $smarty->assign('msg',$msg); 
   $smarty->assign('company_name',$spDomain->dbFields[company_name] ); 
  // $smarty->assign('company_number',$spDomain->dbFields[company_number] ); 
  $smarty->assign('company_number',$spDomain->dbFields[company_number] ); 

}

/*********************************************
** END FUNCTION DEFS, BEGIN CONTENT
**
**
**
*********************************************/

//


// get db connect 
$data = CData_Layer::create($errors) ;

// get the sess, auth and perm vars
page_open (array("sess" => "phplib_Session_Pre_Auth",
   "auth" => "phplib_Pre_Auth",
   "perm" => "phplib_Perm"));

// must be super to edit a domain
$perm->check('SUPER');

// check that parameters are here
if (!$FORM_VARS[domain] || !($_GET[func] || $_POST[func]) ) { 
  header("Location: domain.php");
} 

//  get the smarties
$header_smarty = get_smarty_header($data, $auth, $perm); 
$smarty = get_smarty(); 

if ($_POST[domain]) { 
   $domain  = $_POST[domain]; 
} elseif ($_GET[domain] )   {
   $domain  = $_GET[domain]; 
} else {
  header("Location: domain.php");
}

// get me! 
$self = basename($_SERVER['PHP_SELF']) ;
$self = str_replace(".php","",$self);
// create SpDomain
$log->log("SpDomain => $domain, $self" );

$spDomain = new SpDomain($data->db,$domain ); 
$spDomain->get(); 
// Save an submission
$log->log("trying so --$_POST[func]-- ");


if ($_POST[func]=="save_domain") { 
  $log->log("calling save_domain ");
  $msg = save_domain();
}  



// $data->init($FORM_VARS[ext], $adomain); 


put_headers();

$footer_smarty = get_smarty(); 
if ($_GET[func] == "edit_domain" || $_POST[func]=="save_domain") { 
  get_domain_form($smarty, $body_template,$msg); 
}  

$header_smarty->display('app_header.tpl');

$smarty->display($body_template . ".tpl" );
$footer_smarty->display('app_footer.tpl');


// freeze the session 
page_close(); 
?>
