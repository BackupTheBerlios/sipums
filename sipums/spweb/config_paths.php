<?
/*
 * $Id: config_paths.php,v 1.1 2004/08/01 20:06:13 kenglish Exp $
 */

		/* the web path bellow which serweb's "admin" and "user_interface" 
		   directories begin to spread; If set up to be in root (http://www/admin ...),
           set just "/" here. Set a specific path otherwise, e.g., "/iptel/html/". 
		   Don't forget trailing slash.  
			Hint: if path incorrect, image buttons do not show up
		*/
		$config->root_path="/sp/";

		/* roo uri of your server */
		$config->root_uri="http://".$_SERVER['SERVER_NAME'];

		/* where is your zone file on your server ? */
		$config->zonetab_file =   "/usr/share/zoneinfo/zone.tab";

		/* relative paths of serweb tree */
		$config->img_src_path =		$config->root_path."img/";
		$config->js_src_path =    	$config->root_path."js/";
		$config->style_src_path = 	$config->root_path."style/";
		//$config->user_pages_path = 	$config->root_path."user_interface/";
		//$config->admin_pages_path =	$config->root_path."admin/";
		//$config->domains_path =		$config->root_path."domains/";


		/* spool directory with voicemail messages */
		$config->voice_silo_dir = '/var/spool/voicemail/'; 

		/* directory with voicemail greetings */
		$config->greetings_spool_dir = '/var/greetings/';

		/* serweb talks to SER via FIFO -- this is FIFO's name,
		   it must have the same value as SER's fifo config param
		*/
		$config->fifo_server="/tmp/ser_fifo";

		/* values used for names of reply fifos -- they change radnomly 
		   this values shouldn't be changed unless you well know what are
		   you doing
		 */
		$config->reply_fifo_filename="webfifo_".rand();
		$config->reply_fifo_path="/tmp/".$config->reply_fifo_filename;
		

		/* names of HTML documents surrounding
		   serweb pages -- these may typically include banner, trailers,
		   and whatever else appropriate to your web design; make sure
		   the values point to existing files; the files should include
		   at least:
           prolog: <body> or <body><h1>, etc.
		   separator: may be empty, or </h1><hr> etc.
           epilog: </body>
		*/

		$config->html_prolog="prolog.html";
		$config->html_separator="separator.html";
		$config->html_epilog="epilog.html";
 
?>
