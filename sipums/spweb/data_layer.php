<?

class CDL_common{

  var $container_type;			//Type of data container 'sql' or 'ldap'
  var $db;						//PEAR DB object
  var $act_row=0, $num_rows=0;		//used when result returns too many rows
  var $showed_rows;					//how many rows from result display

  function CDL_common(){
    global $config;
    $this->container_type = &$config->data_container_type;
    $this->showed_rows = &$config->num_of_showed_items;
  }

/*
* static function
* Create a new DataLayer object and connect to the specified database.
*/
	
  function &create(&$errors){
     global $config;
     $obj = &new CData_Layer();

     if (!$db = $obj->connect_to_db($config->data_sql, $errors) ) { 
        return false;
     }
     $obj->db=$db;
     return $obj;
  }
  function connect_to_db($cfg, &$errors){
    global $config;

    $dsn = $cfg->db_type."://".
				$cfg->db_user.":".
				$cfg->db_pass."@".
				$cfg->db_host.
					(empty($cfg->db_port)?
						"":
						":".$cfg->db_port)."/".
				$cfg->db_name;
     $db = DB::connect($dsn,true);
     if (DB::isError($db)) {	
          do_debug($errors); 
         return false; 
     }
     return $db;
   }

	
   function set_num_rows($num_rows){
      $this->num_rows=$num_rows;
   }

   function get_num_rows(){
     return $this->num_rows;
   }

  function set_act_row($act_row){
     $this->act_row=$act_row;
  }

  function get_act_row(){
    return $this->act_row;
  }

  function get_showed_rows(){
    return $this->showed_rows;
  }

  function get_res_from(){
    return $this->get_act_row()+1;
  }
	
  function get_res_to(){
    global $config;
    return ((($this->get_act_row()+$this->get_showed_rows())<$this->get_num_rows())?
    ($this->get_act_row()+$this->get_showed_rows()):
    $this->get_num_rows());
  }
	
/***************************************************************************
 *
 *					Function for work with aliases
 *
 ***************************************************************************/
 
	 /*
	  *	get the max alias number 
	  */
	  
	 function get_alias_number(&$errors){
	 	global $config;

		switch($this->container_type){
		case 'sql':
			// abs() converts string to number
			$q="select max(abs(username)) from ".$config->data_sql->table_aliases." where domain='".$config->realm."' and username REGEXP \"^[0-9]+$\"";
			$res=$this->db->query($q);
			if (DB::isError($res)) {log_errors($res, $errors); return false;}
			$row=$res->fetchRow(DB_FETCHMODE_ORDERED);
			$res->free();
			$alias=is_null($row[0])?$config->first_alias_number:($row[0]+1);
			$alias=($alias<$config->first_alias_number)?$config->first_alias_number:$alias;
			return $alias;

		case 'ldap':
			die('NOT IMPLEMENTED: '.__FILE__.":".__LINE__);
		}
	}

	 /*
	  *	return array of aliases of user with $sip_uri
	  */

	function get_aliases($sip_uri, &$errors){
		global $config;
		
		switch($this->container_type){
		case 'sql':
			$q="select username, domain from ".$config->data_sql->table_aliases.
				" where lower(contact)=lower('".$sip_uri."') order by username";
			$res=$this->db->query($q);
			if (DB::isError($res)) {log_errors($res, $errors); false;}
		
			$out=array();
			while ($row = $res->fetchRow(DB_FETCHMODE_OBJECT)){
				$out[]=$row;
			}
			$res->free();
			return $out;

		case 'ldap':
			die('NOT IMPLEMENTED: '.__FILE__.":".__LINE__);
		}
	}
	
	 /*
	  *	add new alias
	  */
	
	function add_new_alias($sip_address, $alias, &$errors){
	 	global $config;
	
	    if ($config->ul_replication) $replication="0\n";
	    else $replication="";
	
		$ul_name=$alias."@".$config->default_domain."\n";
	
		/* construct FIFO command */
		$fifo_cmd=":ul_add:".$config->reply_fifo_filename."\n".
			$config->fifo_aliases_table."\n".	//table
			$ul_name.	//user
			$sip_address."\n".					//contact
			$config->new_alias_expires."\n".	//expires
			$config->new_alias_q."\n". 		//priority
			$replication."\n";
	
		$message=write2fifo($fifo_cmd, $errors, $status);
		if ($errors) return false;
		if (substr($status,0,1)!="2") {$errors[]=$status; return false; }
	
		return $message;

	}
	
/***************************************************************************
 *
 *					Function for work with sip users
 *
 ***************************************************************************/

	/*
	 *	check if user exists
	 */
	
	function is_user_exists($uname, $udomain, &$errors){
	 	global $config;
	
		switch($this->container_type){
		case 'sql':
			$q="select count(*) from ".$config->data_sql->table_subscriber.
				" where lower(username)=lower('$uname') and lower(domain)=lower('$udomain')";
			$res=$this->db->query($q);
			if (DB::isError($res)) {log_errors($res, $errors); return -1;}
		
			$row=$res->fetchRow(DB_FETCHMODE_ORDERED);
			$res->free();
			if ($row[0]) return true;
			
			$q="select count(*) from ".$config->data_sql->table_pending.
				" where lower(username)=lower('$uname') and lower(domain)=lower('$udomain')";
			$res=$this->db->query($q);
			if (DB::isError($res)) {log_errors($res, $errors); return -1;}
		
			$row=$res->fetchRow(DB_FETCHMODE_ORDERED);
			$res->free();
			if ($row[0]) return true;
			
			return false;

		case 'ldap':
			die('NOT IMPLEMENTED: '.__FILE__.":".__LINE__);
		}
	}
	
	 /*
	  *	add new user to table subscriber (or pending)
	  */
	
	function add_user_to_subscriber($uname, $domain, $passwd, $fname, $lname, $phone, $email, $timezone, $confirm, $table, &$errors){
	 	global $config;
		
		$ha1=md5($uname.":".$domain.":".$passwd);
		$ha1b=md5($uname."@".$config->domainname.":".$domain.":".$passwd);
	
		switch($this->container_type){
		case 'sql':
			$q="insert into ".$table." (username, password, first_name, last_name, phone, email_address, ".
					"datetime_created, datetime_modified, confirmation, ha1, ha1b, domain, phplib_id, timezone) ".
				"values ('$uname', '$passwd', '$fname', '$lname', '$phone', '$email', now(), now(), '$confirm', ".
					"'$ha1', '$ha1b','$domain', '".md5(uniqid('fvkiore'))."', '$timezone')";
		
			$res=$this->db->query($q);
			if (DB::isError($res)) {log_errors($res, $errors); return false;}
		
			return true;	

		case 'ldap':
			die('NOT IMPLEMENTED: '.__FILE__.":".__LINE__);
		}
	}
	
	 /*
	  *	set password for user
	  */
	
	function set_password_to_user($user_id, $passwd, &$errors){
		global $config;
		
		$ha1=md5($user_id.":".$config->realm.":".$passwd);
		$ha1b=md5($user_id."@".$config->domainname.":".$config->realm.":".$passwd);
	
		switch($this->container_type){
		case 'sql':
			$q="update ".$config->data_sql->table_subscriber." set password='$passwd', ha1='$ha1', ha1b='$ha1b' ".
				" where username='".$user_id."' and domain='".$config->realm."'";
		
			$res=$this->db->query($q);
			if (DB::isError($res)) {log_errors($res, $errors); return false;}
		
			return true;

		case 'ldap':
			die('NOT IMPLEMENTED: '.__FILE__.":".__LINE__);
		}
	}
	
	 /*
	  *	delete sip user
	  */
	
	function dele_sip_user ($uname, $domain, &$errors){
	 	global $config;
	
		switch($this->container_type){
		case 'sql':
			$q="delete from ".$config->data_sql->table_aliases." where contact='sip:".$uname."@".$domain."'";
			$res=$this->db->query($q);
			if (DB::isError($res)) {log_errors($res, $errors); return false;}
		
			$q="delete from ".$config->data_sql->table_subscriber." where username='".$uname."' and domain='".$domain."'";
			$res=$this->db->query($q);
			if (DB::isError($res)) {log_errors($res, $errors); return false;}
//!!!!!!!!!!!!!!!!!!!!!!! doplnit ostatni tabulky		
			return true;

		case 'ldap':
			die('NOT IMPLEMENTED: '.__FILE__.":".__LINE__);
		}
	}
	
	 /*
	  * get name of currently logged user
	  */
	
	function get_user_name(&$errors){
		global $auth, $config;
	
		switch($this->container_type){
		case 'sql':
			$q="select first_name, last_name from ".$config->data_sql->table_subscriber.
				" where domain='".$config->realm."' and username='".$auth->auth["uname"]."'";
			$res=$this->db->query($q);
			if (DB::isError($res)) {log_errors($res, $errors); return false;}
			if (!$res->numRows()) return false;
			
			$row = $res->fetchRow(DB_FETCHMODE_OBJECT);
			$res->free();
		
			return $row->first_name." ".$row->last_name." &lt;".$auth->auth["uname"]."@".$config->realm."&gt;";

		case 'ldap':
			die('NOT IMPLEMENTED: '.__FILE__.":".__LINE__);
		}
	}
	
	
	 /*
	  * get starus of sip user
	  * return: "non-local", "unknown", "non-existent", "on line", "off line"
	  */
	
	function get_status($sip_uri, &$errors){
		global $config;
	
		$reg=new Creg;
		if (!eregi("^sip:([^@]+@)?".$reg->host, $sip_uri, $regs)) return "<div class=\"statusunknown\">non-local</div>";
	
		if (strtolower($regs[2])!=strtolower($config->default_domain)) return "<div class=\"statusunknown\">non-local</div>";
	
		$user=substr($regs[1],0,-1);
	
		switch($this->container_type){
		case 'sql':
			$q="select count(*) from ".$config->data_sql->table_subscriber.
				" where username='$user' and domain='$config->realm'";
			$res=$this->db->query($q);
			if (DB::isError($res)) {log_errors($res, $errors); return "<div class=\"statusunknown\">unknown</div>";}
			$row=$res->fetchRow(DB_FETCHMODE_ORDERED);
			$res->free();
			if (!$row[0]) return "<div class=\"statusunknown\">non-existent</div>";
			break;

		case 'ldap':
			die('NOT IMPLEMENTED: '.__FILE__.":".__LINE__);
		}
	
	
		$fifo_cmd=":ul_show_contact:".$config->reply_fifo_filename."\n".
		$config->ul_table."\n".		//table
		$user."@".$config->default_domain."\n\n";	//username
	
		$out=write2fifo($fifo_cmd, $errors, $status);
		if ($errors) return;
	
		if (substr($status,0,3)=="200") return "<div class=\"statusonline\">on line</div>";
		else return "<div class=\"statusoffline\">off line</div>";
	}
	

  function check_passw_of_user($user, $domain, $passw, &$errors){
    global $config;
    $q="SELECT phplib_id FROM ". $config->data_sql->table_subscriber.
       " WHERE username='".addslashes($user)."' AND web_password=PASSWORD('".addslashes($passw)."')" ;
    $res=$this->db->query($q);
    if (DB::isError($res)) {
      do_debug("LOGIN QUERY FAILED" . $res->getMessage()); 
      $errors[]="SYSTEM LOGIN FAILED"; 
      return false;
    }
    if (!$res->numRows()) {
      $errors[]="Bad username or password"; 
      return false;
    }
    $row = $res->fetchRow(DB_FETCHMODE_OBJECT);
    $res->free();
    return $row->phplib_id;
  }
  function create_php_lib_id ($user, $domain) {
     $new_phplib_id = md5(uniqid('fvkiore')); 
     $q = "UPDATE subscriber SET phplib_id = '$new_phplib_id' "
          . " WHERE username='$user' AND domain='$domain' "; 
     do_debug("Creating phplib_id $new_phplib_id  $q"); 
     $res=$this->db->query($q);
     if (DB::isError($res)) {
       do_debug("get_user_domain query $q: " . $res->getMessage());
       return false;
     } else {
       return $new_phplib_id ; 
     } 
  } 

  function get_user_domain($user) { 
     global $config;
     $q = "SELECT domain FROM " .  $config->data_sql->table_subscriber . 
        " WHERE username='".addslashes($user)."'";
     $res=$this->db->query($q);
     if (DB::isError($res)) {
       do_debug("get_user_domain query $q: " . $res->getMessage());
       return false;
     } 

     if (!$res->numRows()) {
       do_debug("No domain found for $uname query=$q"); 
       return false;
     }
     if ($res->numRows() !=1 ) {
       do_debug("NOOOOOOOOOOOOOOO, bad, more than one domain for user $uname "); 
       return false;
     }
     $row = $res->fetchRow(DB_FETCHMODE_ORDERED);
     $domain = $row[0];
     $res->free();
     return $domain;
  } 

  function get_privileges_of_user($user, $domain, $only_privileges, &$errors){
    global $config;

    // if $only_privileges is array, generate where phrase which select only this privileges

     $q="select perm 
         from ".$config->data_sql->table_subscriber ." 
         where username = '".$user."' 
         and domain = '".$domain."'"; 
      do_debug("privileg query $q");
      $res=$this->db->query($q);
      if (DB::isError($res)) {
         do_debug("error getting privs" . $res->getMessage() ); return false;
      }
      $out=array();
      $row=$res->fetchRow(DB_FETCHMODE_ORDERED);
      $priv=$row[0];
      $res->free();
      return $priv;
  }
	
	function get_username_from_uid($uid, &$errors){
		global $config;
		
		switch($this->container_type){
		case 'sql':
			$q="select username,domain from ". $config->data_sql->table_subscriber.
				" where phplib_id='".$uid."'";
			$res=$this->db->query($q);
			if (DB::isError($res)) {log_errors($res, $errors); return false;}
	
			$row = $res->fetchRow(DB_FETCHMODE_OBJECT);
			$res->free();
			
			return $row;
		case 'ldap':
		default:
			die('NOT IMPLEMENTED: '.__FUNCTION__."; container type: ".$this->container_type);
		}
	}

	function get_sip_user($user, $domain, &$errors){
		global $auth, $config;
	
		switch($this->container_type){
		case 'sql':
			$q="select phplib_id, email_address from ".$config->data_sql->table_subscriber.
				" where username='".$user."' and domain='".$domain."'";
			$res=$this->db->query($q);
			if (DB::isError($res)) {log_errors($res, $errors); return false;}
			if (!$res->numRows()) {$errors[]='Sorry, '.$user.' is not a registered username!'; return false;}

			$row = $res->fetchRow(DB_FETCHMODE_OBJECT);
			$res->free();

			return $row;

		case 'ldap':
			die('NOT IMPLEMENTED: '.__FILE__.":".__LINE__);
		}
	}
	
	
/***************************************************************************
 *
 *					Function for work with timezones
 *
 ***************************************************************************/
	
	 /*
	  * get list of timezones from zone.tab
	  */
	
	function get_time_zones(&$errors){
		global $config;
	
		@$fp=fopen($config->zonetab_file, "r");
		if (!$fp) {$errors[]="Cannot open zone.tab file"; return array();}
		
		while (!feof($fp)){
			$line=FgetS($fp, 512);
			if (substr($line,0,1)=="#") continue; //skip comments
			if (!$line) continue; //skip blank lines
			
			$line_a=explode("\t", $line);
			
			$line_a[2]=trim($line_a[2]);
			if ($line_a[2]) $out[]=$line_a[2];
		}
	
		fclose($fp);
		sort($out);
		return $out;
	}
	
	
	 /*
	  * set timezone to timezone of currently logged user
	  */
	
	function set_timezone(&$errors){
		global $config, $auth;
	
		switch($this->container_type){
		case 'sql':
			$q="select timezone from ".$config->data_sql->table_subscriber.
				" where domain='".$config->realm."' and username='".$auth->auth["uname"]."'";
			$res=$this->db->query($q);
			if (DB::isError($res)) {log_errors($res, $errors); return;}
			$row = $res->fetchRow(DB_FETCHMODE_OBJECT);
			$res->free();
		
			putenv("TZ=".$row->timezone); //set timezone	
			return;

		case 'ldap':
			die('NOT IMPLEMENTED: '.__FILE__.":".__LINE__);
		}
	}

/***************************************************************************
 *
 *					Function for work with net geo
 *
 ***************************************************************************/

	 /*
	  * get location of domainname in sip_adr
	  */
	
	function get_location($sip_adr, &$errors){
		global $config;
		static $reg;
		
		$reg = new Creg();
		
		$domainname=$reg->get_domainname($sip_adr);
		
		switch($this->container_type){
		case 'sql':
			$q="select location from ".$config->data_sql->table_netgeo_cache.
				" where domainname='".$domainname."'";
			$res=$this->db->query($q);
			/* if this query failed netgeo is probably not installed -- ignore */
			if (DB::isError($res)) {return "n/a";}
			$row = $res->fetchRow(DB_FETCHMODE_OBJECT);
			$res->free();
		
			if (!$row) return "n/a";
			return $row->location;

		case 'ldap':
			die('NOT IMPLEMENTED: '.__FILE__.":".__LINE__);
		}
	}
        function get_domain_options($auth, $perm){
          global $config;
          global $db;
          $q = "SELECT distinct domain FROM subscriber";
          $result = $res=$this->db->query($q); 

          $values = array();
          $outputs = array();
          
//          $values[] = "0";
//          $outputs[] = "Please Select your domain"; 

          while ($row = $res->fetchRow()){
             $values[] = $row[0]; 
             $outputs[]= $row[0];
          }
          $ret = array($values, $outputs); 

          return $ret;
        }

/***************************************************************************
 *
 *					Function for work with voicemail
 *
 ***************************************************************************/
  function get_voicemail_db($domain) {
    if ($domain ) {
      $q = "SELECT voicemail_db FROM domain WHERE domain='$domain' " ;
      $res=$this->db->query($q);
      if (DB::isError($res)) {
           do_debug("FAILED QUERY : $q");
      }

      do_debug("QUERY : $q");
      $out=array();

      while ($row=$res->fetchRow(DB_FETCHMODE_ORDERED) ) {
         $voicemail_db=$row[0];
         do_debug("voicemail_Db $voicemail_db");
      }
      $res->free();

      if ($this->user_info) { 
        $this->user_info[voicemail_db] = $voicemail_db; 
      }
      return $voicemail_db; 
    } else {
      do_debug("get_voicemail_db : udomain not set ");
      return 0;
    }
  }

   
  function change_db ($db_name) {
    do_debug("change db to $db_name");
    $this->db->_db = $db_name ;   
    if (!@mysql_select_db($db_name, $this->db->connection)) {
        do_debug("COULD NOT CHANGE DB TO $db_name");
        return ; 
    } else {
        do_debug("CHANGED DB TO " .$this->db->_db);
        return ;
    } 

    // if (!@mysql_select_db($dn_name, $this->db->connection)) {
    //    do_debug("COULD NOT CHANGE DB TO $db_name");
    // }
  }

		
}

?>
