<?
/*
 * $Id: main_prepend.php,v 1.1 2004/08/01 20:06:13 kenglish Exp $
 */ 

//require class defintions
require_once ($_SERWEB["serwebdir"] . "class_definitions.php");

//require paths configuration
require_once ($_SERWEB["serwebdir"] . "config_paths.php");

//set $config->domain
require_once ($_SERWEB["serwebdir"] . "set_domain.php");

//require domain depending config
//require_once ($_SERWEB["serwebdir"] . "config_domain.php");
//$domain_config=new CDomain_config();

//TO DO: load language

//require sql access configuration and table names
//require_once ($_SERWEB["serwebdir"] . "config_sql.php");
require_once ($_SERWEB["serwebdir"] . "config_data_layer.php");

//require other configuration
require_once ($_SERWEB["serwebdir"] . "config.php");

//if config.developer is present, replace default config by developer config
if (file_exists($_SERWEB["serwebdir"] . "config.developer.php")){
	require_once ($_SERWEB["serwebdir"] . "config.developer.php");
}

//activate domain depending config
//$domain_config->activate_domain_config();
//////////////////unset($domain_config);

//require PEAR DB
require_once 'DB.php';

//create log instance
if ($config->enable_loging){
	require_once 'Log.php';
	$serwebLog  = &Log::singleton('file', $config->log_file, 'serweb', array(), PEAR_LOG_INFO);
}
else{
	$serwebLog  = NULL;
}


//require functions
require_once ($_SERWEB["serwebdir"] . "lib/functions.php");

//require functions for work with data store
//require_once ($_SERWEB["serwebdir"] . "sql_and_fifo_functions.php");

require_once ($_SERWEB["serwebdir"] . "data_layer.php");
if (file_exists($_SERWEB["serwebdir"] . "data_layer/".basename($_SERVER['PHP_SELF']))){
	REQUIRE_ONce ($_SERWEB["serwebdir"] . "data_layer/".basename($_SERVER['PHP_SELF']));
}else{
	require_once ($_SERWEB["serwebdir"] . "data_layer/__std_data_layer.php");
}

//require page layout
require_once ($_SERWEB["serwebdir"] . "page.php");

?>
