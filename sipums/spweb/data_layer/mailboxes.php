<?
/*
 * $Id: mailboxes.php,v 1.6 2004/08/12 00:03:25 kenglish Exp $
 */

class CData_Layer extends CDL_common{

  var $uname; 
  var $udomain; 
  var $mailbox; 
  function init($udomain) {
     $this->udomain=$udomain;
  }   


  function get_perm($mailbox) {
    global $log; 
    $voicemail_db = $this->get_voicemail_db($this->udomain); 
    $q = "SELECT permission_id FROM VM_Users WHERE extension = '$mailbox' "; 
    $res = $this->db->query($q);

    if (DB::isError($res)) {
      $log->log("QUERY FAILED $q");
      $log->log("Error looking up by name");
      return 0;
    }
    $row = $res->fetchRow(DB_FETCHMODE_ORDERED);
    $res->free();
    $perm = $row[0];

    $ser_db=$config->data_sql->db_name ;
    $this->change_db($ser_db);

    return $perm;
  }

  function save_perm($mailbox,$new_perm) {
    global $log; 
    if ($this->mailbox)  { 

       $q="UPDATE VM_Users SET permission_id = '$new_perm' WHERE "
          . " extension=  ". $mailbox;
       $res=$this->db->query($q);
       if (DB::isError($res)) {
         $log->log("QUERY FAILED $q " . $res->getMessage());
       } 

     } 
  }
  function get_mailboxes() {
    global $log; 
    if ($this->udomain)  { 
       $voicemail_db = $this->get_voicemail_db($this->udomain); 
       $log->log("CHANGING TO $voicemail_db "); 
       $this->change_db($voicemail_db); 

       // if (DB::isError($res)) {
       //   $log->log("QUERY FAILED $q " . $res->getMessage());
       // } else {

         $vm_info = array();
         $this->db->_db=$this->user_info[voicemail_db];
         $this->change_db($this->db->_db);

         $q = "SELECT extension, first_name, last_name, email_address, store_flag,
             email_delivery, email_server_address, email_type, email_user_name ,
             mobile_email_flag, mobile_email,vstore_email , 
             active, transfer, mwi_flag, new_user_flag,permission_id
             FROM VM_Users ORDER BY extension " ;

         $res=$this->db->query($q);
  
         $extensions =array(); 
         if (DB::isError($res)) {
           $log->log("QUERY FAILED $q " . $res->getMessage());
         } else {
          $out=array();
          while ($row = $res->fetchRow(DB_FETCHMODE_ASSOC)) { 
             // blank out the option as it is irrelevant what it's set to
            $extension = $row[extension]; 
            if ($extension == 0) {  
              continue; 
               
            }
            $extensions[]=$extension; 
            if ($row[store_flag] == 'E') { 
              $row[vstore_email]="";
            }  else {
              $row[email_delivery]="";
            } 
            $vm_info[$extension]  = $row ;
            $log->log("extension = $row[extension]");
          }
          $log->log("store_flag = " . $vm_info[store_flag]);
          $res->free();
        }

        global $config;

        $log->log("Changing back to " . $config->data_sql->db_name );

        $ser_db=$config->data_sql->db_name ; 
        $this->change_db($ser_db);
        $ext_list = implode(",", $extensions); 

        $q = "SELECT username, mailbox FROM subscriber WHERE domain = '" .$this->udomain . "' AND   mailbox in ($ext_list)"; 

        $res = $this->db->query($q);

        if (DB::isError($res)) {
           $log->log("QUERY FAILED $q " . $res->getMessage());
        } else {
          $out=array();
          while ($row = $res->fetchRow(DB_FETCHMODE_ASSOC) ) {  
            $log->log("$row[username] $row[mailbox] ");
            $vm_info[$row[mailbox]][did] = $row[username] ; 
            $vm_info[$row[mailbox]][user] = $row[username] . '@' .$this->udomain ; 
          }
          $res->free();
        } 
        return $vm_info;
     //  }

    }  else {
      $log->log("ERROR : get_mailboxes no domain to query " );

    }  
  } 

  function get_perm_options($uname) { 
    global $log; 
    if ($uname ){
       $q = "SELECT mailbox FROM subscriber WHERE  domain = '" . $this->udomain 
              . "' and subscriber = '" . $uname ."' " ;
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
           case "ADMIN":
              $perm_options[]='ADMIN';
              $perm_options[]='USER';
           case "USER":
              $perm_options[]='USER';
        }
        return $perm_options;
            
    } else {
      $log->log("ERROR : get_perm_options called with no uname " );

    }  
  } 

}
