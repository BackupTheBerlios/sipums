<?  
class VmUser {
  // must have
  var $username;
  var $domain;
  var $mailbox;
  var $voicemail_db;
  var $permission_id;
  // db 
  var $db; 
  var $dbFields; 
  // vm variables
   
  function VmUser(&$db,$username="",$domain="",$mailbox="",$voicemail_db="") { 
     if ($db) {
         $this->db=$db;
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
   // retrieves user's data from the database 
   function get(){ 
     global $log;
     
     // all these must be present to do the query
     if ($this->mailbox && $this->domain) {
        if (!$this->voicemail_db ) { 
          $this->voicemail_db = get_voicemail_db($this->db, $this->domain); 
        } 

        change_db($this->db, $this->voicemail_db); 
        
        $q = "SELECT extension , permission_id , active , first_name , ". 
         " last_name , mi , store_flag , transfer , mwi_flag , call_out_number , " . 
         " new_user_flag , phone_keys_first_name , phone_keys_last_name , " . 
         " personal_operator_extension , email_delivery , email_server_address , ".
         " email_address , email_user_name , email_password , email_type , " . 
         " name_wav_path , name_wav_file , mobile_email , mobile_email_flag , "  .
         " last_visit , vstore_email , auto_login_flag , auto_new_messages_flag " .  
         " FROM VM_Users  WHERE extension = " . $this->mailbox; 

         $res = $this->db->query($q);

         if (DB::isError($res)) {
           $log->log("FAILED QUERY : $q",LOG_ERR);
           return false;
         }
        $this->dbFields = $res->fetchRow(DB_FETCHMODE_ASSOC) ;
        $log->log("store flag = : " . $this->dbFields[store_flag] ,LOG_ERR);
        
        $this->permission_id  = $this->dbFields[permission_id]; 
        $res->free();

        change_to_default_db($this->db); 

        return true; 
     } else {
         $log->log("VmUser->get called with invalid data  $this->mailbox ",LOG_ERR);
         return false;
     }  
   }
   function create() {
      global $log; 
     if ($this->mailbox && $this->db && $this->domain) {

        if (!$this->voicemail_db ) { 
          $this->voicemail_db = get_voicemail_db($this->db, $this->domain); 
        } 
       $cmd = "perl /usr/local/openums/addvmuser " .
              $this->mailbox . " \"" .
              $this->dbFields[first_name]. "\" \"" .$this->dbFields[last_name] . "\" " . $this->voicemail_db  ;
 
       $output = `$cmd` ;
 
       $log->log("\ndid $cmd: $output ");
       if (preg_match("/Success/", $output) ) {
          $log->log("ADD VM USER SUCCESS"); 
          return true ;
       } else {
          $log->log("ADD VM USER FAILED"); 
          return false;
       }

     }  else {
       $log->log("VmUser->create called with blank fields: $this->mailbox ",LOG_ERR);
       return false;
     } 
    
   } 

   function updateBasic() {
     global $log;
     if ($this->mailbox && $this->db && $this->domain) {
       $q = "UPDATE VM_Users SET " .
            " first_name = " . $this->db->quote($this->dbFields[first_name] ) .
            ", last_name = " . $this->db->quote($this->dbFields[last_name] ) .
            ", mi = " . $this->db->quote($this->dbFields[mi] ) .
            ", email_address = " . $this->db->quote($this->dbFields[email_address]) .
            " WHERE extension = " . $this->mailbox; 
        if (!$this->voicemail_db ) { 
          $this->voicemail_db = get_voicemail_db($this->db, $this->domain); 
        } 
       change_db($this->db, $this->voicemail_db); 
                                                                                                                                               
       $res = $this->db->query($q);
       if (DB::isError($res)) {
         $log->log("FAILED TO VmUser->updateBasic : $q",LOG_ERR);
         return false;
       }

       change_to_default_db($this->db); 

       return true;
     } else {
       $log->log("VmUser->save called with blank fields: $this->mailbox ",LOG_ERR);
       return false;
     }
   } 
   function updatePassword($new_password) {
     global $log;
     if ($this->mailbox && $this->db && $this->domain) {

        if (!$this->voicemail_db ) {
          $this->voicemail_db = get_voicemail_db($this->db, $this->domain);
        }
       change_db($this->db, $this->voicemail_db);
       $q = "UPDATE VM_Users SET " .
            " password = Password('$new_password') " .
            " WHERE extension = " . $this->mailbox;
       $res = $this->db->query($q);
       if (DB::isError($res)) {
         $log->log("FAILED TO VmUser->updatePassword : $q",LOG_ERR);
         return false;
       }

       change_to_default_db($this->db);
       return true;
     } else {
       $log->log("VmUser->updatePassword called with blank fields: $this->mailbox ",LOG_ERR);
       return false;
     }
   }

   function deactivate() {
    global $log;
    if ($this->mailbox && $this->db && $this->domain) { 
      if (!$this->voicemail_db ) {
          $this->voicemail_db = get_voicemail_db($this->db, $this->domain);
       }

       change_db($this->db, $this->voicemail_db);

       $q = "UPDATE VM_Users SET " .
            " active = 0  " .
            " WHERE extension = " . $this->mailbox;

       $res = $this->db->query($q);
       if (DB::isError($res)) {
         $log->log("FAILED TO VmUser->deactivate : $q",LOG_ERR);
         return false;
       }

       change_to_default_db($this->db);
       return true;
        
 
    }  else { 
       $log->log("VmUser->deactivate called with blank fields: $this->mailbox ",LOG_ERR);
       return false;
    } 
   } 
   function updateUm() {
     global $log;
     if ($this->mailbox) {
        if (!$this->voicemail_db ) {
          $this->voicemail_db = get_voicemail_db($this->db, $this->domain);
       }

       $log->log("updateUM changing db");
       change_db($this->db, $this->voicemail_db);

       $q  = "UPDATE VM_Users SET store_flag ='" . $this->dbFields[store_flag] .  "', "  . 
       " vstore_email = '". $this->dbFields[vstore_email] . "', " . 
       " email_delivery ='" . $this->dbFields[email_delivery] . "' , " . 
       " email_server_address ='" . $this->dbFields[email_server_address] ."', "  .
       " email_user_name ='" . $this->dbFields[email_user_name] ."', " . 
       " mobile_email_flag ='" . $this->dbFields[mobile_email_flag] ."' , " . 
       " mobile_email='" . $this->dbFields[mobile_email] ."' " . 
       " WHERE  extension = " . $this->mailbox ; 

       $log->log("DOING UPDATE: $q");
       $res=$this->db->query($q);

       if (DB::isError($res)) {
          $log->log("FAILED QUERY : $q");
       }
       change_to_default_db($this->db);
       return true;

    } else {
      $log->log("ERRROR: Tried to update_um with no extension ");
      return false ; 
    }
  }
  function updateVmFlags() {
     global $log;
     if ($this->mailbox) {
        if (!$this->voicemail_db ) {
          $this->voicemail_db = get_voicemail_db($this->db, $this->domain);
       }
                                                                                                                                               
       $log->log("updateUM changing db");
       change_db($this->db, $this->voicemail_db);

       $q  = "UPDATE VM_Users SET " . 
        " active =  " . $this->db->quote($this->dbFields[active] ) . 
        ", transfer =  " . $this->db->quote($this->dbFields[transfer] ) . 
        ", new_user_flag =  " . $this->db->quote($this->dbFields[new_user_flag] ) . 
        ", mwi_flag =  " . $this->db->quote($this->dbFields[mwi_flag] ) . 
        " WHERE  extension = " . $this->mailbox;
       $res=$this->db->query($q);

       if (DB::isError($res)) {
          $log->log("FAILED QUERY : $q");
       }


       change_to_default_db($this->db);
       return true;
    } else {
      $log->log("ERRROR: Tried to updateVmFlags with no extension ");
    } 


  } 

}
?>
