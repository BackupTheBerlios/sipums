<?php
/*
 * $Id: prepend.php,v 1.1 2004/08/01 20:06:13 kenglish Exp $
 */ 

$_SERWEB = array();
$_PHPLIB = array();

# Can't control your include path?
# Point this to your PHPLIB base directory. Use a trailing "/"!
$_SERWEB["serwebdir"]  = "";
$_PHPLIB["libdir"]  = "/usr/share/pear/phplib/";


#}

require($_SERWEB["serwebdir"] . "main_prepend.php");
require($_SERWEB["serwebdir"] . "load_phplib.php");

require("page_attributes.php");
if ($config->debug) { 
  $FDEBUG = fopen("/tmp/sp_web_debug.log","a+");
  do_debug("-----------------------\nbegin\n"); 
}
global $FORM_VARS ;
$FORM_VARS = array_merge($_POST,$_GET);


?>
