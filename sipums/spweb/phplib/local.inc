<?php
/*
 * Session Management for PHP3
 *
 * Copyright (c) 1998-2000 NetUSE AG
 *                    Boris Erdmann, Kristian Koehntopp
 *
 * $Id: local.inc,v 1.2 2004/09/01 23:40:23 kenglish Exp $
 *
 */

class DB_phplib extends DB_Sql {
  var $Host;
  var $Database;
  var $User;
  var $Password;

  function DB_phplib(){
  	global $config;
	$this->Host     = $config->data_sql->db_host;
	$this->Database = $config->data_sql->db_name;
	$this->User     = $config->data_sql->db_user;
	$this->Password = $config->data_sql->db_pass;
  }
}


##
## Session needs to use a storage container (ct).
## Select exactly one of the following and set $that_class
## in Example_Session appropriately.
##

class phplib_CT_Sql extends CT_Sql {
  var $database_class = "DB_phplib";          ## Which database to connect...
  var $database_table = "active_sessions"; ## and find our session data in this table.
}

##
## main session class
##

class phplib_Session extends Session {
  var $classname = "phplib_Session";

  var $cookiename     = "";                ## defaults to classname
  var $magic          = "Hocuspocus";      ## ID seed
  var $mode           = "cookie";          ## We propagate session IDs with cookies
  var $fallback_mode  = "get";
  var $lifetime       = 0;                 ## 0 = do session cookies, else minutes
  var $that_class     = "phplib_CT_Sql";  ## name of data storage container class
  var $gc_probability = 5;
  var $allowcache     = "no";              ## "public", "private", or "no"
}

##
## modified session class used to login when user forgot password
##

class phplib_Session_Pre_Auth extends phplib_Session {

  function get_id($id = "") {
    global $HTTP_COOKIE_VARS, $HTTP_GET_VARS, $HTTP_POST_VARS, $QUERY_STRING;

	if ($this->mode=="cookie"){
		/*
		 * if is there cookie and get or post vars then seconds are preffered
		 */
	    if ( "" == $id ) {
          $id = isset($HTTP_GET_VARS[$this->name]) ?
                $HTTP_GET_VARS[$this->name] :
                ( isset($HTTP_POST_VARS[$this->name]) ?
                $HTTP_POST_VARS[$this->name] :
                "") ;
		}
	    if ( "" == $id ) {
          $id = isset($HTTP_COOKIE_VARS[$this->name]) ?
                $HTTP_COOKIE_VARS[$this->name] : "";
		}

		/* set the corect cookie */
	    if ( "" == $id && ( 0 == $this->lifetime )) {
          SetCookie($this->name, $id, 0, "/", $this->cookie_domain);
		}

	}//if

	parent::get_id($id);

  }
}

##
## default auth class
##

class phplib_Auth extends Auth {
  var $classname      = "phplib_Auth";

  var $lifetime       = 60;

//  var $database_class = "DB_phplib";
//  var $database_table;
  var $data;

  function phplib_Auth(){
//  	global $config;
//	$this->database_table = $config->table_subscriber;
	if (!$data = CData_Layer::create($errors)) die($errors[0]);
         $this->data=$data;
  }

  function auth_loginform() {
    global $sess;
    global $_PHPLIB;
	global $config;
	global $errors;

    include($_PHPLIB["libdir"] . "loginform.ihtml");
  }

  function auth_validatelogin() {
    global $config, $_POST, $errors;

    if(isset($_POST['username'])) {
      $this->auth["uname"]=$_POST['username'];        ## This provides access for "loginform.ihtml"
    }

    $uid = false;

	$username="";
	$password="";
	
	if (isset($_POST['username'])) $username=$_POST['username'];
	if (isset($_POST['password'])) $password=$_POST['password'];
	
	$p_uid = $this->data->check_passw_of_user($username, $config->domain, $password, $errors);
	if ($p_uid) $uid=$p_uid;

/*	if ($config->clear_text_pw){
	    $this->db->query(sprintf("select phplib_id ".
    	                         "        from %s ".
        	                     "       where username = '%s' ".
            	                 "         and password = '%s'".
								 "         and domain = '%s'",
                	          $this->database_table,
                    	      addslashes($username),
                        	  addslashes($password),
							  addslashes($config->realm)));
	}else{
		$ha1=md5($username.":".$config->realm.":".$password);

	    $this->db->query(sprintf("select phplib_id ".
    	                         "        from %s ".
        	                     "       where username = '%s' ".
								 "        and domain = '%s'".
            	                 "         and ha1 = '%s'",
                	          $this->database_table,
                    	      addslashes($username),
							  addslashes($config->realm),
                        	  addslashes($ha1)));
	}


    while($this->db->next_record()) {
      $uid = $this->db->f("phplib_id");
    }
*/
	$this->check_for_privileges();

    return $uid;
  }

  /*
  	method checks user permisions
  */
	function check_for_privileges(){
		global $config, $errors;

    if (false === $privilege = $this->data->get_privileges_of_user($this->auth["uname"], $this->auth["udomain"], 
        array('SUPER','RESELLER', 'ADMIN','USER'), $errors)) return false;

          switch ($privilege){
            case 'SUPER':
               $this->auth["perm"]="USER,ADMIN,RESELLER,SUPER";
	       break;

             case 'RESELLER':
                $this->auth["perm"]="USER,ADMIN,RESELLER";
                break;

             case 'ADMIN':
                $this->auth["perm"]="USER,ADMIN";
                break;
             case 'USER':
                $this->auth["perm"]="USER";
                break;

           }//switch



   } //function check_for_privileges()
}

class phplib_Pre_Auth extends phplib_Auth {
	var $classname = "phplib_Pre_Auth";

	function auth_preauth()	{
	    global $sess, $errors;
	    global $pre_uid, $pre_uid_expires;

		if (isset($pre_uid)){
			$sess->unregister('pre_uid');
			$sess->unregister('pre_uid_expires');

			if (isset($pre_uid_expires) and $pre_uid_expires<time()) return false;

			if (false === $row = $this->data->get_username_from_uid($pre_uid, $errors)) return false;

			$this->auth["uname"] = $row->username;
			$this->auth["udomain"] = $row->domain;
			$this->auth["client_id"] = $row->client_id;
                        $this->auth['admin_client_ids'] = $this->data->get_admin_client_ids($row->client_id); 
			$uid=$pre_uid;

/*
		    $this->db->query(sprintf("select username ".
		                             "        from %s ".
		                             "       where phplib_id = '%s' ",
		                          $this->database_table,
		                          addslashes($pre_uid)));

		    $uid=0;
		    while($this->db->next_record())	{
		      $this->auth["uname"] = $this->db->f("username");
			  $uid=$pre_uid;
		    }
*/
			$this->check_for_privileges();
			return $uid;
		}
		else{
			return false;
		}
	}
}


##
## default perm class
##

class phplib_Perm extends Perm {
  var $classname = "phplib_Perm";
  
   
  var $permissions = array(
                            "USER"      => 1,
		            "ADMIN"=> 2,
		            "RESELLER"=> 4,
		            "SUPER"=> 8
                          );

  function perm_invalid($does_have, $must_have) {
    global $perm, $auth, $sess;
    global $_PHPLIB;

    include($_PHPLIB["libdir"] . "perminvalid.ihtml");
  }
}

?>
