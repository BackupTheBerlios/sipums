<?
/*
 * $Id: edit_mb.php,v 1.1 2004/08/01 20:06:13 kenglish Exp $
 */

class CData_Layer extends CDL_common{

  var $extension; 
  var $udomain; 

  function init($extension,$udomain) {
     $this->extension=$extension;
     $this->udomain=$udomain;
  }   

  function update_password($new_password) {

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
         do_debug("UPDATE FAILED $q " . $res->getMessage());
         return 0; 
       }  
         do_debug("UPDATE $q succeeded");
      
        $res->free();

        global $config;
        do_debug("Changing back to " . $config->data_sql->db_name );


        $this->db->_db=$config->data_sql->db_name ; 
        $this->change_db($this->db->_db);
        $ext_list = implode(",", $extensions); 

    } else {
      do_debug("ERROR : failed to update password for " . $this->extension . " to $new_password " );
    }  
  }
}
