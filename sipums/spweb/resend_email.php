<?
/*
 */

require 'prepend.php';
require 'Smarty.class.php';
require 'lib/nav.php';
require_once 'data_layer/Invitee.php';
require_once 'data_layer/Conference.php';


$data = CData_Layer::create($errors) ;

$invitee = new Invitee($data->db, $_GET[conference_id], $_GET[invitee_id] ); 
$invitee->get();
$invitee->sendNotify();

put_headers();

header('Location: cdetails.php?conference_id='.$_GET[conference_id].'&func=view');
exit ;

// get db connect 


// get the sess, auth and perm vars
page_open (array("sess" => "phplib_Session_Pre_Auth",
   "auth" => "phplib_Pre_Auth",
   "perm" => "phplib_Perm"));


## do this in every file after the page_open
$perm->check('USER');

if ($perm->have_perm('SUPER'))  {
  change_domain();
}



// freeze the session 
page_close(); 
?>
