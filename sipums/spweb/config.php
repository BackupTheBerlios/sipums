<?
/*
 * $Id: config.php,v 1.2 2004/08/03 09:14:40 kenglish Exp $
 */

/*****************************************************************************
 * 	                      DOMAIN DEPENDING VALUES                            *
 *****************************************************************************/
 
 /* In this section is values that can be changed in config of each domain. 
    Values below is only default values which is used only if isn't said in 
    domain dependend config file
  */
 
		/* ------------------------------------------------------------*/
		/*      basic local configuration options                      */
		/* ------------------------------------------------------------*/
		/* you need to align these values to your local server settings */

		/* serweb will send confirmation emails and SIP IMs -- what sender
		   address should it claim ?
		   should appear in them ?
		*/
		$config->mail_header_from="registrar@servpac.com";
		$config->web_contact="sip:daemon@servpac.com";

		/* info email address */
		$config->infomail = "info@servpac.com";

		/* email address for questions concerning registration */
		$config->regmail=	"registrar@servpac.com";

		
		/* content of html <title> tag */
		$config->html_title="SERVPAC SIP 1.0";

		/* user content of <head> tag. There can be some linked CSS or javascript or <meta> tags
		   for example CSS styles used in prolog.html
		      $this->html_headers[]='<link REL="StyleSheet" HREF="http://www.servpac.com/styles/my_styles.css" TYPE="text/css">';
		   or some javascript
		      $this->html_headers[]='<script language="JavaScript" src="http://www.servpac.com/js/main.js"></script>';
		   uncoment following lines if you want add something
		*/	
		$config->html_headers=array();
//		$config->html_headers[]="";
//		$config->html_headers[]="";
//		$config->html_headers[]="";

		/* DOCTYPE of html pages. The default value is 'strict' for XHTML 1.0 Strict. If your prolog.html and epilog.html
			is not coresponding with this, use 'transitional' for HTML 4.0 Transitional or empty string for none DOCTYPE  */		
		$config->html_doctype="strict";
		
		/* initial nummerical alias for new subscriber -- don't forget to
		   align your SER routing script to it !
		*/
		$config->first_alias_number=82000;


		/* ------------------------------------------------------------*/
		/* text														   */
		/* ------------------------------------------------------------*/
		/* human-readable text containing messages displayed to users
		   in web or sent by email; you may need to hire a lawyer ,
		   a word-smith, a diplomat or a translator to get it right :)
		*/


		/* text of password-reminder email */
		$config->forgot_pass_subj="your login information";
		$config->mail_forgot_pass="Hello,\n".
			"now you can access to your account at the folowing URL within 1 hour:\n".
			$config->root_uri.$config->root_path."user/my_account.php?#session#\n\n".
			"We recommend change your password after you login\n\n";

		/* text of confirmation email sent during account registration  */
		$config->register_subj="Your ".$config->domain." Registration";
		$config->mail_register=
			"Thank you for registering with ".$config->domain.".\n\n".
			"We are reserving the following SIP address for you: #sip_address#\n\n".
			"To finalize your registration please check the following URL within ".
			"24 hours:\n".
			$config->root_uri.$config->root_path."user/reg/confirmation.php?nr=#confirm#\n\n".
			"(If you confirm later you will have to re-register.)\n\n".
			"Windows Messenger users may look at additional configuration hints at\n".
			"http://www.iptel.org/phpBB/viewtopic.php?topic=11&forum=1&0\n";

		/* terms and conditions as they appear on the subscription webpage */
		$config->terms_and_conditions=
			"BY PRESSING THE 'I ACCEPT' BUTTON, YOU (HEREINAFTER THE 'USER') ARE ".
			"STATING THAT YOU AGREE TO ACCEPT AND BE BOUND BY ALL OF THE TERMS AND ".
			"CONDITIONS OF THIS AGREEMENT.  DO NOT PROCEED IF YOU ARE UNABLE TO AGREE".
			" TO THE TERMS AND CONDITIONS OF THIS AGREEMENT. THESE TERMS AND CONDITIONS ".
			"OF SERVICE FOR USE OF ".$config->domain." SIP SERVER (THE 'AGREEMENT')".
			" CONSTITUTE A LEGALLY BINDING CONTRACT BETWEEN ".$config->domain.
			" AND THE ENTITY THAT AGREES TO AND ACCEPTS THESE TERMS AND CONDITIONS. ".
			"ACCESS TO ".$config->domain."'s SESSION INITIATION PROTOCOL SERVER ".
			"('SIP SERVER') IS BEING PROVIDED ON AN 'AS IS' AND 'AS AVAILABLE' BASIS, ".
			"AND ".$config->domain." MAKES NO REPRESENTATIONS OR WARRANTIES OF ANY ".
			"KIND, WHETHER EXPRESS OR IMPLIED, WITH RESPECT TO USER'S ACCESS OF THE ".
			"SIP SERVER, INCLUDING BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, ".
			"NONINFRINGEMENT, TITLE OR FITNESS FOR A PARTICULAR PURPOSE. FURTHER, ".
			$config->domain." MAKES NO REPRESENTATIONS OR WARRANTIES THAT THE SIP ".
			"SERVER, OR USER'S ACCESS THERETO, WILL BE AVAILABLE AT ANY GIVEN TIME, ".
			"OR WILL BE FREE FROM ERRORS, DEFECTS, OMISSIONS, INACCURACIES, OR FAILURES".
			" OR DELAYS IN DELIVERY OF DATA. USER ASSUMES, AND ".$config->domain.
			" DISCLAIM, TOTAL RISK, RESPONSIBILITY, AND LIABILITY FOR USER'S ACCESS TO ".
			"AND USE OF THE SIP SERVER.\n\n".
			"Access to ".$config->domain." SIP Server is being provided on a ".
			"non-exclusive basis. User acknowledges and understands that ".
			$config->domain." SIP site is in a developmental stage and that ".
			$config->domain." makes no guarantees regarding the availability or ".
			"functionality thereof. User may not sublicense its access rights to the ".
			"SIP Server to any third party. \n\n".
			"USER AGREES TO INDEMNIFY, DEFEND AND HOLD iptel.org, ITS AFFILIATES, ".
			"DIRECTORS, OFFICERS, EMPLOYEES, AGENTS AND LICENSORS HARMLESS FROM AND ".
			"AGAINST ANY AND ALL CLAIMS, ACTIONS, EXPENSES, LOSSES, AND LIABILITIES ".
			"(INCLUDING COURTS COSTS AND REASONABLE ATTORNEYS' FEES), ".
			"ARISING FROM OR RELATING TO THIS AGREEMENT INCLUDING USER'S ACCESS TO ".
			"AND USE OF THE SIP SERVER TO THE MAXIMUM EXTENT PERMITTED BY APPLICABLE LAW,".
			" IN NO EVENT SHALL ".$config->domain." OR ANY OF ITS LICENSORS, BE LIABLE ".
			"FOR ANY INDIRECT, SPECIAL, PUNITIVE, EXEMPLARY, OR CONSEQUENTIAL DAMAGES, ".
			"ARISING OUT OF THE ACCESS TO OR USE OF OR INABILITY TO ACCESS OR USE THE ".
			"SIP SERVER, OR THAT RESULT FROM MISTAKES, OMISSIONS, INTERRUPTIONS, ".
			"DELETIONS OF FILES, ERRORS, DEFECTS, DELAYS IN TRANSMISSION OR OPERATION OR ".
			"ANY FAILURE OF PERFORMANCE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH ".
			"DAMAGES. \n\n".
			"If User commits, in ".$config->domain."'s  sole determination, a default ".
			"of these terms and conditions, ".$config->domain." may immediately ".
			"terminate User's access to the SIP Server. Furthermore, ".$config->domain.
			" reserves the right to discontinue offering access to the SIP Server at any ".
			"time. \n\n".

			"User may not assign its rights hereunder without the prior written ".
			"consent of ".$config->domain.". User agrees to comply with all laws, ".
			"regulations and other legal requirements that apply to these terms and ".
			"conditions.  \n\n".
			"If any provision of this Agreement is held to be unenforceable for any ".
			"reason, such provision shall be reformed only to the extent necessary to ".
			"comply with applicable laws, and the remainder shall remain in full force ".
			"and effect. \n\n".
			"Any failure of ".$config->domain." to enforce any provision of this ".
			"Agreement shall not constitute a waiver of any rights under such provision ".
			"or any other provision of this Agreement. \n\n".
			"USER ACKNOWLEDGES THAT IT HAS READ THIS AGREEMENT, UNDERSTANDS IT, AND ".
			"AGREES THAT IT IS THE COMPLETE AND EXCLUSIVE STATEMENT OF THE ENTIRE ".
			"AGREEMENT BETWEEN COMPANY AND ".$config->domain." WITH RESPECT TO THE ".
			"SUBJECT MATTER HEREIN, AND SUPERSEDES ALL PRIOR AND CONTEMPORANEOUS ".
			"PROPOSALS, DISCUSSIONS, AGREEMENTS, UNDERSTANDINGS, AND COMMUNICATIONS, ".
			"WHETHER WRITTEN OR ORAL AND MAY BE AMENDED ONLY IN A WRITING EXECUTED BY ".
			"BOTH USER AND ".$config->domain.". \n\n";
		

/*****************************************************************************
 * 	                     DOMAIN INDEPENDING VALUES                           *
 *****************************************************************************/

/* There are values common for all domains */

		/* this array contain list of config parameter which can be modified
		   by admins of particular domains */

		$config->domain_depend_config=array("mail_header_from", "web_contact", 
			"html_title", "html_doctype", "html_headers", "first_alias_number", 
			"infomail", "regmail", "forgot_pass_subj", "mail_forgot_pass", 
			"register_subj", "mail_register", "terms_and_conditions");

		/* ------------------------------------------------------------*/
		/* serweb appearance                                           */
		/* ------------------------------------------------------------*/

		/* which tabs should show in user's profile ? those set to false
		   by default are experimental features which have not been tested
		   yet
		*/

		/* user tabs definitions
			Ctab (enabled, name_of_tab, php_script)
		*/

		$config->user_tabs=array();
		$config->user_tabs[]=new Ctab (true, "my account", "my_account.php");
		$config->user_tabs[]=new Ctab (true, "phone book", "phonebook.php");
		$config->user_tabs[]=new Ctab (true, "missed calls", "missed_calls.php");
		$config->user_tabs[]=new Ctab (true, "accounting", "accounting.php");
		$config->user_tabs[]=new Ctab (true, "send IM", "send_im.php");
		$config->user_tabs[]=new Ctab (false, "notification subscription", "notification_subscription.php");
		$config->user_tabs[]=new Ctab (true, "message store", "message_store.php");
		$config->user_tabs[]=new Ctab (false, "voicemail", "voicemail.php");
		$config->user_tabs[]=new Ctab (true, "user preferences", "user_preferences.php");
		$config->user_tabs[]=new Ctab (false, "speed dial", "speed_dial.php");
		$config->user_tabs[]=new Ctab (false, "caller screening", "caller_screening.php");

		/* admin tabs definitions
			Ctab (enabled, name_of_tab, php_script)
		*/
		$config->admin_tabs=array();
		$config->admin_tabs[]=new Ctab (true, "users", "users.php");
		$config->admin_tabs[]=new Ctab (true, "admin privileges", "list_of_admins.php");
		$config->admin_tabs[]=new Ctab (true, "server monitoring", "ser_moni.php");
		$config->admin_tabs[]=new Ctab (true, "user preferences", "user_preferences.php");

		$config->num_of_showed_items=20; 	/* num of showed items in the list of users */
		$config->max_showed_rows=50;		/* maximum of showed items in "user find" */

		/* experimental/incomplete features turned off: voicemail
		   and set up a jabber account for each new SIP user too
		*/
		$config->show_voice_silo=false; /* show voice messages in silo too */
		$config->enable_dial_voicemail=false;
		$config->setup_jabber_account=false;

		$config->jserver = "localhost";   		# Jabber server hostname
		$config->jport = "5222";     			# Jabber server port
		$config->jcid  = 0;      				# Jabber communication ID

		# Jabber module database
		$config->jab_db_type="mysql";           # type of db host, enter "mysql" for MySQL or "pgsql" for PostgreSQL
		$config->jab_db_srv="localhost";        # database server
		$config->jab_db_port="";                # database port - leave empty for default
		$config->jab_db_usr="ser";              # database user
		$config->jab_db_pas="heslo";            # database user's password
		$config->jab_db_db="sip_jab";           # database name


		/* ------------------------------------------------------------*/
		/* Loging                                                      */
		/* ------------------------------------------------------------*/

		/* I think that loging is currently useful only for developers.
		   When you enable loging be sure if you have instaleld PEAR package
		   Log. See http://pear.php.net/manual/en/installation.getting.php 
		   for more information
		*/

		$config->enable_loging = false;
		$config->log_file = "/var/log/spweb.log";

		/* ------------------------------------------------------------*/
		/* Speed dial                                                  */
		/* ------------------------------------------------------------*/


		// string to which must start username from request uri in speed dial
		$config->speed_dial_initiation="11";


		/* ------------------------------------------------------------*/
		/* ACLs                                                        */
		/* ------------------------------------------------------------*/

		/* there may be SIP contacts which you wish to prevent from being added
		   through serweb to avoid loops, forwarding to unfriendly domains, etc.
		   use these REGexs  to specify which contacts you do not wish;
		   the first value includes banned REs, the second displays error message
		   displayed to users if they attempt to introduce a banned contact
		*/
		$config->denny_reg=array();
		$config->denny_reg[]=new CREG_list_item("iptel\.org$","local forwarding prohibited");
		$config->denny_reg[]=new CREG_list_item("gateway","gateway contacts prohibited");

		/* SER configuration script may check for group membership of users
		   identified using digest authentication; e.g., it may only allow
		   international calls to callers who are members of 'int' group;
		   this is a list of groups that serweb allows to set -- they need to
		   correspond to names of groups used in SER's membership checks
		*/
		$config->grp_values=array();
		$config->grp_values[]="ld";
		$config->grp_values[]="local";
		$config->grp_values[]="int";



		/* =========================================================== */
        /* ADVANCED SETTINGS                                           */
		/* =========================================================== */

		/* ------------------------------------------------------------*/
		/* applications (experimental)                                 */
		/* ------------------------------------------------------------*/

		/* subscribe-notify -- list of events to which a user can subscribe and
		   is then notified with an instant message, if they occur; experimental
		*/
		$config->sub_not=array();
		$config->sub_not[]=new Csub_not("sip:weather@iptel.org".
			";type=temperature;operator=lt;value=0","temperature is too low");
		$config->sub_not[]=new Csub_not("sip:weather@iptel.org".
			";type=wind;operator=gt;value=10","wind is too fast");
		$config->sub_not[]=new Csub_not("sip:weather@iptel.org;".
			"type=pressure;operator=lt;value=1000","pressure is too low");
		$config->sub_not[]=new Csub_not("sip:weather@iptel.org;type=metar",
			"send METAR data");

		/* metar wheather application */
		//this is an identificator in event table for sending METAR data
		$config->metar_event_uri="sip:weather@iptel.org;type=metar";
		//from header in sip message
		$config->metar_from_sip_uri="sip:daemon@iptel.org";
		// N/A message - is sended to user when we can't get his location or METAR data
		$config->metar_na_message="sorry we can't get your location or METAR data for you";


		/* ------------------------------------------------------------*/
		/*            configure FW/NAT detection applet                */
		/* ------------------------------------------------------------*/

		/* the applet is used to detect whether user is behind firewall or NAT 
		   to enable FW/NAT detection must be installed STUN server */

		// show test firewall/NAT button at my account tab
		$config->enable_test_firewall=false;

		//width of NAT detection applet
		$config->stun_applet_width=350;				
		//height of NAT detection applet
		$config->stun_applet_height=100;				
		//starting class of NAT detection applet
		$config->stun_class="STUNClientApplet.class"; 
		//jar archive with NAT detection applet - optional - you can comment 
		// it if you don't use jar archive
        $config->stun_archive="STUNClientApplet.jar";             

		/* applet parameters: */

		/* STUN server address - must be same as web server address because 
		   the java security manager allows only this one
		*/
		$config->stun_applet_param=array();
		$config->stun_applet_param[]=new Capplet_params("server", "www.iptel.org");

		/* STUN server port. The Default value is 1221 - optional - you can comment 
			it if you want use default value
		*/
		$config->stun_applet_param[]=new Capplet_params("port", 1221);
		/* destination port for the first probing attempt -- just set up a simple
		   tcp echo server there; we use the first TCP connection to determine
		   local IP address, which can't be learned from systems setting due to
	       security manager ; default is 5060
		*/
		$config->stun_applet_param[]=new Capplet_params("tcp_dummyport", 5061);

		/* Number of times to resend a STUN message to a STUN server. The 
			Default is 9 times - optional - you can comment it if you want 
			use default value
		*/
		// $config->stun_applet_param[]=new Capplet_params("retransmit", 9);

		/* Specify source port of UDP packet to be sent from. The Default value 
		   is 5000 - optional - you can comment it if you want use default value
		*/
		// $config->stun_applet_param[]=new Capplet_params("sourceport", 5000);



		/* ------------------------------------------------------------*/
		/*            configure server monitoring					   */
		/* ------------------------------------------------------------*/

		/* if you change this values, please delete all data from table	
		   "table_ser_mon_agg" and "table_ser_mon" by reason that the 
			aggregated data may be calculated bad if you don't do it
		*/

		/* length of marginal period in seconds */
		$config->ser_moni_marginal_period_length=60*5;   //5 minutes
		
		/* length of interval (in seconds) for which will data stored, 
		   data older then this interval will be deleted
		*/
		$config->ser_moni_aggregation_interval=60*15;	//15 minut

		/* ------------------------------------------------------------*/
		/*            click to dial                                    */
		/* ------------------------------------------------------------*/

		/* address of the final destination to which we want to transfer
		   initial CSeq and CallId */
		$config->ctd_target="sip:23@192.168.2.16";

		/* address of user wishing to initiate conversation */
		$config->ctd_uri="sip:44@192.168.2.16";
		
		/* from header for click-to-dial request */
		$config->ctd_from	=	"sip:controller@servpac.com";
		
		/* ------------------------------------------------------------*/
		/*            caller screening                                 */
		/* ------------------------------------------------------------*/

		/*
			this array describe how to dispose of draggers
			$config->calls_forwarding["screening"][]=new Ccall_fw(<action>, <param1>, <param2>, <label>)

			<action> is "reply" or "relay"
			"reply" have parameters status code and phrase (e.g. ("486", "busy") or ("603", "decline"))
			"relay" have only one parameter - address of server where to request forward
			<label> is string which is displayed to user
		*/
		$config->calls_forwarding=array();
		$config->calls_forwarding["screening"][]=new Ccall_fw("reply", "603", "decline", "decline");
		$config->calls_forwarding["screening"][]=new Ccall_fw("reply", "486", "busy", "reply you are busy");
		$config->calls_forwarding["screening"][]=new Ccall_fw("relay", "sip:voicemail@".$config->domain, null, "forward to voicemail");

		/* ------------------------------------------------------------*/
		/* Values you typically do NOT want to change unless you know  *
        /* well what you are doing                                     *
		/* ------------------------------------------------------------*/


		/* these are table names as reffered from script and via FIFO */
		$config->ul_table="location";
		$config->fifo_aliases_table="aliases";


		/* development value
		$config->reply_fifo_path="d:/temp/".$config->reply_fifo_filename; */	

		/* serweb version */
		$config->psignature="Web_interface_Karel_Kozlik-0.9";

		/* IM paging configuration */
		$config->charset="windows-1250";
		$config->im_length=1300;

		/* expiration times, priorities, etc. for usrloc/alias contacts */
		$config->new_alias_expires='567648000';
		$config->new_alias_q=1.00;
		$config->new_alias_callid="web_call_id@fox";
		$config->new_alias_cseq=1;
		$config->ul_priority="1.00";
		/* replication support ? (a new ser feature) */
		$config->ul_replication=1;

		/* seconds in which expires "get pass session" */
		$config->pre_uid_expires=3600;                
		/* is the sql database query for user authentication formed
		   with clear text password or a hashed one; the former is less
		   secure the latter works even if password hash is incorrect,
		   which sometimes happens, when it is calculated from an
		   incorrect domain during installation process
		*/
		$config->clear_text_pw=1;

		/* ------------------------------------------------------------*/
		/*            send daily missed calls by email                 */
		/* ------------------------------------------------------------*/
		
		/*
			name of attribute in user preferences for daily sending missed  
			calls to email, it's type should be boolean
		*/
		$config->up_send_daily_missed_calls="send_daily_missed_calls";
		
		/*
			subject and body of daily sended email with missed calls
		*/
		$config->send_daily_missed_calls_mail_subj="your missed calls";
		$config->send_daily_missed_calls_mail_body=" Hello, \n".
				"we are sending your missed calls";




		/* $config->realm, $config->domainname and $config->default_domain will be substituted by $config->domain */
                $config->domain = "o-matrix.com"; 
		$config->realm=$config->domainname=$config->default_domain=$config->domain;

                $config->debug = 1;
				
?>
