<?  
class SpUser {
  // essential, must have
  var $username;
  var $domain;
  var $mailbox;
  var $AREA_CODE = "808";

  var $perm;

  var $sipAddress ;
  var $voicemailDbName;
  // database fields 
  var $dbFields;
  var $db;

  // vm variables
  function SpUser(&$db,$username="",$domain="",$mailbox=""){
   $this->dbFields = array();
   if ($db) { 
       $this->db = $db; 
   }  
   if ($username) { 
       $this->username=$username; 
   }  
   if ($domain) { 
       $this->domain=$domain; 
   }  
   if ($mailbox) { 
       $this->mailbox=$mailbox; 
   }  
   return ;
  } 

  function getMyWhere() {
    $where = " username = " . $this->db->quote($this->username); 
    if ($this->domain) {  
            $where .= " AND  domain = " . $this->db->quote($this->domain) ;
    } 
  
    return $where;
  } 
   
  // retrieves user's data from the database 
  function get() {
    global $log; 
    // all these must be present to do the query
    if ($this->username && $this->db && $this->domain) { 
       $q = "SELECT s.domain domain, first_name,  last_name, " . 
            "  email_address, perm, mailbox,rpid, " . 
            " d.voicemail_db, d.company_name, d.company_number " . 
            " FROM subscriber s, domain d" . 
            " WHERE username = " . $this->db->quote($this->username) . 
            " AND s.domain = " . $this->db->quote($this->domain) ; 

       $res = $this->db->query($q);
       if (DB::isError($res)) {
         $log->log("FAILED QUERY : $q",LOG_ERR);
         return false;
       }
       $this->dbFields = $res->fetchRow(DB_FETCHMODE_ASSOC) ;
       $this->domain = $this->dbFields[domain]; 

        $res->free();
        // set the important fields here:
        $this->voicemailDbName = $this->dbFields[voicemail_db]; 
        $this->mailbox = $this->dbFields[mailbox]; 
        $this->perm = $this->dbFields[perm]; 
        $this->sipAddress = $this->username . '@' . $this->domain; 
    
        return true; 
    }  else {
       $log->log("SpUser->get called with blank fields: $this->username, $this->domain",LOG_ERR); 
       return false;
    } 
  }  
 
  function updateBasic() { 
    // this updates first_name, last_name, email_address
    global $log; 
    if ($this->username && $this->db && $this->domain) { 
       $q = "UPDATE subscriber SET " . 
            " first_name = " . $this->db->quote($this->dbFields[first_name] ) . 
            ", last_name = " . $this->db->quote($this->dbFields[last_name] ) . 
            ", email_address = " . $this->db->quote($this->dbFields[email_address]) . 
            " WHERE " . $this->getMyWhere() ;//  username = " . $this->db->quote($this->username) . 
            // " AND  domain = " . $this->db->quote($this->domain) ; 

       $res = $this->db->query($q);
       if (DB::isError($res)) {
         $log->log("FAILED TO updateBasic : $q",LOG_ERR);
         return false;
       }
       $log->log("updateBasic : $q",LOG_ERR);
       return true; 
    } else { 
       $log->log("SpUser->save called with blank fields: $this->username, $this->domain",LOG_ERR); 
       return false;
    } 
      
  } 
  function removeMailbox() { 
      global $log; 
      if ($this->username && $this->db && $this->domain) {
         $q = "UPDATE subscriber SET " 
            . " mailbox = null " 
            . " WHERE ". $this->getMyWHere() ;
         $res = $this->db->query($q);

         if (DB::isError($res)) {
           $log->log("FAILED TO remove Mailbox : $q",LOG_ERR);
           return false;
         }
         $log->log("updateMailbox : $q",LOG_ERR);
         return true;
      } 
      return false ; 
  } 
  function updateMailbox() { 
     global $log;
      if ($this->username && $this->db && $this->domain && $this->mailbox) {
       $q = "UPDATE subscriber SET " .
            " mailbox = " . $this->db->quote($this->mailbox) .
            " WHERE ". $this->getMyWHere() ; 

       $res = $this->db->query($q);
       if (DB::isError($res)) {
         $log->log("FAILED TO updateMailbox : $q",LOG_ERR);
         return false;
       }
       $log->log("updateMailbox : $q",LOG_ERR);
       return true;
    } else {
       $log->log("SpUser->save called with blank fields: $this->username, $this->domain",LOG_ERR);
       return false;
    }

  } 
  function changePerm($new_perm) { 
    global $log; 
    if ($this->username && $this->db && $this->domain) { 
      // make sure it's a valid permission
      if (preg_match("/SUPER|ADMIN|RESELLER|USER/",$new_perm) ) {
         $q = "UPDATE subscriber SET perm = '$new_perm' WHERE " . $this->getMyWhere();  
         $res = $this->db->query($q);
         if (DB::isError($res)) {
           $log->log("FAILED TO updateBasic : $q",LOG_ERR);
           return false;
         }
         $log->log("SpUser->changePerm Succeeded $new_perm: $this->username, $this->domain",LOG_ERR);
         return true  ;

      } else {
          $log->log("SpUser->changePerm tried to change to invalid permission $new_perm: $this->username, $this->domain",LOG_ERR); 
      } 
    } else { 
       $log->log("SpUser->changePerm called with blank fields: $this->username, $this->domain",LOG_ERR); 
       return false;
    } 
  } 
  function updateSpPassword($new_password) { 
    global $log; 
    if ($this->username && $this->db && $this->domain) { 
       $q = "UPDATE subscriber SET web_password  = PASSWORD('$new_password') WHERE " . $this->getMyWhere() ;
       $res = $this->db->query($q);
       if (DB::isError($res)) {
          $log->log("FAILED TO updateBasic : $q",LOG_ERR);
          return false;
       }
       $log->log("SpUser->updateSpPassword Succeeded $this->username, $this->domain",LOG_ERR);
       return true  ;
    } else { 
       $log->log("SpUser->updateSpPassword called with blank fields: $this->username, $this->domain",LOG_ERR); 
       return false;
    } 
  } 


  function get_perm($edit_uname, $edit_udomain ) {
    global $log ; 
    $q = "SELECT perm FROM subscriber WHERE username = '$edit_uname' AND domain = '$edit_udomain'";
    $res = $this->db->query($q);
    if (DB::isError($res)) {
      $log->log("QUERY FAILED $q");
      $log->log("Error looking up by name");
      return false;
    }
    $row = $res->fetchRow(DB_FETCHMODE_ORDERED);
    $res->free();
    $perm = $row[0];
    return $perm;
  }


  function save_perm($edit_uname, $edit_udomain,$new_perm ) {
    global $log ; 
    $q = "UPDATE subscriber SET perm = '$new_perm' WHERE username = '$edit_uname'
          AND domain = '$edit_udomain' ";
    $res=$this->db->query($q);   
    if (DB::isError($res)) { 
      $log->log("QUERY FAILED $q"); 
      return 0;   
    }  else {
      $log->log("did QUERY $q"); 
      return 1;   
    } 
  } 

  function setCallerIdToUnknown() {
    global $log; 
    if ($this->username) { 
      $q = "UPDATE subscriber SET rpid = '<sip:unknown@$" . $this->domain . ">' " . 
        " WHERE " . $this->getMyWhere() ; 

      $res=$this->db->query($q);   
      if (DB::isError($res)) { 
        $log->log("QUERY FAILED $q"); 
        return false;   
      }  else {
        return true;   
      } 
    } else { 
      $log->log("ERROR called setCallerIdToUnknown with no username"); 
      return false ;   
    } 
  } 

  function setCallerIdToDid() {
    global $log; 
    if ($this->username) { 
      //   $q = "SELECT first_name, last_name FROM subscriber WHERE " . $this->getMyWhere(); 
      // $res = $this->db->query($q);   
      //  if (DB::isError($res)) { 
      //  $log->log("QUERY FAILED $q"); 
      //   return false; 
      //  } 

      // $row = $res->fetchRow(DB_FETCHMODE_ORDERED);  
      $first_name = $this->dbFields[first_name]; 
      $last_name  =  $this->dbFields[last_name]; 
      $username = $this->username; 
      $domain  =  $this->domain; 
  
      if ($first_name && $last_name) { 
         $AREA_CODE = $this->AREA_CODE; 
         $caller_id = "\"$first_name $last_name\" <sip:$this->AREA_CODE$username@$domain>"; 
      }  else {
         $caller_id = "<sip:$username@$domain>"; 
      } 

      $log->log("setCallerIdToDid, saving caller_id = $caller_id"); 

      $q_caller_id = $this->db->quote($caller_id); 
      $q = "UPDATE subscriber SET rpid = $q_caller_id WHERE  " . $this->getMyWhere(); 
      $res=$this->db->query($q);   
      if(DB::isError($res) ) { 
        $log->log("query failed $q"); 
        return false ; 
      }  else { 
        return true; 
      } 
    } else {
       return false; 
    }  
  } 
  function setCallerIdToCompany() {
    global $log; 
    if ($this->username && $this->domain ) { 
      $q = "SELECT company_name, company_number FROM domain WHERE domain = '" . $this->domain ."' "; 
      $res=$this->db->query($q);   
      if (DB::isError($res)) { 
          $log->log("QUERY FAILED $q"); 
          $log->log("Error looking up company name"); 
          return false; 
      } 
      $row = $res->fetchRow(DB_FETCHMODE_ORDERED);  
      $company_name = $row[0]; 
      $company_number  = $row[1]; 
      if ($company_name && $company_number) { 
            $AREA_CODE = $this->AREA_CODE; 
            $caller_id = "\"$company_name\" <sip:" . $this->AREA_CODE . "$company_number@$edit_udomain>"; 
            $log->log("caller_id = $caller_id"); 
      } else {
          return false ; 
      } 
      $q_caller_id = $this->db->quote($caller_id);
      $q = "UPDATE subscriber SET rpid = $q_caller_id WHERE " . $this->getMyWhere(); 

      $log->debug("UPDATE IS  $q"); 
      $res=$this->db->query($q);   
      if(DB::isError($res) ) {
         $log->log("query failed $q");
         return false ;
      }  else {
         return true;
      }
    } else {
       $log->debug("setCallerIdToCompany with no username and domain"); 
       return false; 
    } 
  } 

  function getCallerId() {
    // $q = "SELECT rpid FROM subscriber WHERE username = '$edit_uname' AND domain = '$edit_udomain'";
    if (!$this->dbFields[rpid] ) { 
       $this->get();
    } 
    $rpid = $this->dbFields[rpid] ;
    $caller_id = rpid_to_caller_id($rpid);
    return $caller_id;
  }

}

?>
