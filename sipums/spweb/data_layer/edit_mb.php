<?
/*
 * $Id: edit_mb.php,v 1.7 2004/08/12 20:32:38 kenglish Exp $
 */

class CData_Layer extends CDL_common{

  var $extension; 
  var $udomain; 

  var $uname; 
  var $mailbox; 

  function init($mailbox,$udomain) {
     $this->mailbox=$mailbox;
     $this->udomain=$udomain;
  }   

  function get_perm_options($uname) { 
    global $log; 
    if ($uname ){
       $q = "SELECT mailbox FROM subscriber WHERE domain = '" . $this->udomain 
              . "' and username = '" . $uname ."' " ;
        $res = $this->db->query($q);
        if (DB::isError($res)) {
           $log->log("QUERY FAILED $q " . $res->getMessage());
           return ;
        }
        $row = $res->fetchRow(DB_FETCHMODE_ORDERED); 
        $user_mailbox = $row[0]; 
        $res->free();
        $perm = $this->get_perm($user_mailbox) ; 
        $perm_options = array();
        switch($perm) {
           case "SUPER":
              $perm_options[]='SUPER';
              $perm_options[]='ADMIN';
              $perm_options[]='USER';
              break; 
           case "ADMIN":
              $perm_options[]='ADMIN';
              $perm_options[]='USER';
              break; 
           case "USER":
              $perm_options[]='USER';
              break; 
        }
        return $perm_options;
            
    } else {
      $log->log("ERROR : get_perm_options called with no uname " );

    }  
  } 


/*  function update_password($new_password) {
      global $log; 

    ## this checks that the password is all numbers and is not blank
    if ($this->extension && $new_password && is_numeric($new_password) )  { 
       if (!$this->user_info[voicemail_db]) {
         $this->get_voicemail_db($this->udomain);     
       } 

       $this->db->_db=$this->user_info[voicemail_db];
       $this->change_db($this->db->_db);

       $q = "UPDATE VM_Users SET password = PASSWORD('$new_password') WHERE extension = " .$this->extension; 
       $res=$this->db->query($q);
       if (DB::isError($res)) {
         $log->log("UPDATE FAILED $q " . $res->getMessage());
         return 0; 
       }  
         $log->log("UPDATE $q succeeded");
      
        $res->free();

        global $config;
        $log->log("Changing back to " . $config->data_sql->db_name );


        $this->db->_db=$config->data_sql->db_name ; 
        $this->change_db($this->db->_db);
        $ext_list = implode(",", $extensions); 

    } else {
      $log->log("ERROR : failed to update password for " . $this->extension . " to $new_password " );
    }  
  }

  function get_perm($mailbox) {
    global $config,$log ; 
    
    $voicemail_db = $this->get_voicemail_db($this->udomain); 
    $this->change_db($voicemail_db ); 
     $log->log("changed to $voicemail_db for " . $this->udomain ); 

    $q = "SELECT permission_id FROM VM_Users WHERE extension = '" . $this->mailbox ."' "; 
    $res = $this->db->query($q);

    if (DB::isError($res)) {
      $log->log("QUERY FAILED $q");
      $log->log("Error looking up by name");
    } else { 
      $row = $res->fetchRow(DB_FETCHMODE_ORDERED);
      $res->free();
      $perm = $row[0];
    }
    $ser_db=$config->data_sql->db_name ;
    $this->change_db($ser_db);

    return $perm;
  }

  function save_perm($new_perm) {
    global $config,$log ; 
    if ($this->mailbox)  { 
       $voicemail_db = $this->get_voicemail_db($this->udomain); 
       $this->change_db($voicemail_db ); 
       $q="UPDATE VM_Users SET permission_id = '$new_perm' WHERE "
          . " extension=  ". $this->mailbox;
       $res=$this->db->query($q);
       if (DB::isError($res)) {
         $log->log("QUERY FAILED $q " . $res->getMessage());
       } 
       $ser_db=$config->data_sql->db_name ;
       $this->change_db($ser_db);

     } else {
         $log->log("save_perm called, no mailbox FAILED " ); 
     } 
  }
**/
}
?>
