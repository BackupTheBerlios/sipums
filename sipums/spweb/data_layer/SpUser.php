<?  
class SpUser {
  // essential, must have
  var $username;
  var $domain;
  var $mailbox;

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
    $where = " username = " . $this->db->quote($this->username) .
            " AND  domain = " . $this->db->quote($this->domain) ;
    return $where;
  } 
   
  // retrieves user's data from the database 
  function get() {
    global $log; 
    // all these must be present to do the query
    if ($this->username && $this->db && $this->domain) { 
       $q = "SELECT first_name,  last_name, " . 
            "  email_address, perm, mailbox, " . 
            " d.voicemail_db, d.company_name, d.company_number " . 
            " FROM subscriber s, domain d" . 
            " WHERE s.username = '" . $this->username . "' "  .
            " AND  s.domain = '" . $this->domain . "' "  ; 

       $res = $this->db->query($q);
       if (DB::isError($res)) {
         $log->log("FAILED QUERY : $q",LOG_ERR);
         return false;
       }
        $this->dbFields = $res->fetchRow(DB_FETCHMODE_ASSOC) ;
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
            " WHERE username = " . $this->db->quote($this->username) . 
            " AND  domain = " . $this->db->quote($this->domain) ; 

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


}

?>
