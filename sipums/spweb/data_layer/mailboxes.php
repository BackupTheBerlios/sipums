<?
/*
 * $Id: mailboxes.php,v 1.1 2004/08/01 20:06:13 kenglish Exp $
 */

class CData_Layer extends CDL_common{

  var $uname; 
  var $udomain; 
  function init($udomain) {
     $this->udomain=$udomain;
  }   

  function get_mailboxes() {
    if ($this->udomain)  { 
       if (!$this->user_info[voicemail_db]) {
         $this->get_voicemail_db($this->udomain);     
       } 

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
         do_debug("QUERY FAILED $q " . $res->getMessage());
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
           do_debug("extension = $row[extension]");
        }
        do_debug("store_flag = " . $vm_info[store_flag]);
        $res->free();
      }

      global $config;
      do_debug("Changing back to " . $config->data_sql->db_name );


      $this->db->_db=$config->data_sql->db_name ; 
      $this->change_db($this->db->_db);
      $ext_list = implode(",", $extensions); 

      $q = "SELECT username, mailbox FROM subscriber WHERE domain = '" .$this->udomain . "' AND   mailbox in ($ext_list)"; 

      $res = $this->db->query($q);

      if (DB::isError($res)) {
         do_debug("QUERY FAILED $q " . $res->getMessage());
      } else {
        $out=array();
        while ($row = $res->fetchRow(DB_FETCHMODE_ASSOC) ) {  
          do_debug("$row[username] $row[mailbox] ");
          $vm_info[$row[mailbox]][did] = $row[username] ; 
          $vm_info[$row[mailbox]][user] = $row[username] . '@' .$this->udomain ; 
        }
        $res->free();
      } 
      

      return $vm_info;
    } else {
      do_debug("ERROR : get_mailboxes no domain to query " );
    }  

  }
}
