<?php
/*
 * $Id: prepend.php,v 1.11 2004/08/17 19:33:56 kenglish Exp $
 */ 

require_once 'Log.php';
$conf = array('mode' => 0660, 'timeFormat' => '%X %x');
$log = &Log::singleton('file', '/tmp/spweb.log', 'spW', $conf, LOG_INFO);

$log->log("!!!+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-!!!",LOG_ERR);


$_SERWEB = array();
$_PHPLIB = array();

# Can't control your include path?
# Point this to your PHPLIB base directory. Use a trailing "/"!
$_SERWEB["serwebdir"]  = "";
$_PHPLIB["libdir"]  = "/usr/share/php/phplib/";


#}

require($_SERWEB["serwebdir"] . "main_prepend.php");
require($_SERWEB["serwebdir"] . "load_phplib.php");

require("page_attributes.php");
if ($config->debug) { 
  $FDEBUG = fopen("/tmp/sp_web_debug2.log","a+");
}

global $FORM_VARS ;
$FORM_VARS = array_merge($_POST,$_GET);


?>
