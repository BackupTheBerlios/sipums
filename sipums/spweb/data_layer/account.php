<?
/*
 * $Id: account.php,v 1.8 2004/08/11 03:31:02 kenglish Exp $
 */

class CData_Layer extends CDL_common{

  var $uname; var $udomain; 

  function init($uname, $udomain) {
     $this->uname=$uname;$this->udomain=$udomain;
  }   

  function mailbox_exists ($mailbox) {
    global $log; 
    if (!$mailbox) { 
      return false; 
    } 
    $voicemail_db = get_voicemail_db($this->db, $this->udomain);
    change_db($this->db, $voicemail_db);
    $q = "SELECT count(extension) " . 
         " FROM VM_Users  WHERE extension = " . $mailbox;
                                                                                                                                               
     $res = $this->db->query($q);
                                                                                                                                               
     if (DB::isError($res)) {
          $log->log("FAILED QUERY : $q",LOG_ERR);
          change_to_default_db($this->db);
           
          return false;
     }
     $row =  $res->fetchRow(DB_FETCHMODE_ORDERED) ;
     $res->free();
     change_to_default_db($this->db);

     $count = $row[0]; 
     if ($count == 1)  {
       return true; 
     } else {
       return false; 
     } 
  } 


  function get_edit_users($domains) { 
    global $log; 
    $q="";

    if (empty($domains)) {
          return ;
    }  else {
      if ($domains[0] != 'ALL' ) {
        $where = " WHERE s.domain " ;
        if (count($domains) == 1 ) {
           $where  .=  " = '$domains[0]' ";
        } else {
          $where  .=  " in (" . implode($domains) . ")  ";
        }
      }
    }

    $q = "SELECT concat(s.username,'@',s.domain) edit_user FROM subscriber s 
          $where order by s.domain,s.username"; 
    $res= $this->db->query($q);
    $log->log("get_edit_users = $q ");
    $out=array();
    while ($row=$res->fetchRow(DB_FETCHMODE_ORDERED) ) {
      $out[]=$row[0];
    }
    $res->free();
    return $out;
  }

/****  
function get_user_info() {
  global $log; 
    

    $log->log("get_user_info $this->uname $this->udomain");

    if ($this->uname and $this->udomain) { 
      $q = "SELECT first_name, last_name, email_address,mailbox  " 
         . " FROM subscriber " 
         . " WHERE username = '$this->uname' AND domain ='$this->udomain' "; 

      $log->log("get_user_info $q");
      $res=$this->db->query($q);

      $row=$res->fetchRow(DB_FETCHMODE_ASSOC) ;
      $res->free();

      $this->user_info = $row; 

      $log->log("got user info ". $this->user_info[mailbox] ); 

      return $this->user_info; 
    }  else {
       $log->log("get_user_info no USER SPECIFIED--$this->uname ----$this->udomain");
    }
    
    
  } 


  function update_user_info ($p_user_info,&$error) {
    global $log; 
    $this->user_info = $p_user_info; 
    foreach ($p_user_info as $key => $value){
       $log->log("user_info $key;$value"); 
    } 

          // $this->update_mailbox() ;
    $log->log("CALLED update_user_info "); 
    if ($this->uname and $this->udomain) {  
       $first_name = $this->db->quote($this->user_info[first_name]);
       $last_name = $this->db->quote($this->user_info[last_name]);
       $email_address = $this->db->quote($this->user_info[email_address]);
       $mailbox = $this->db->quote($this->user_info[mailbox]);

       $q = "UPDATE subscriber " 
          . " SET first_name =$first_name,  "
          . " last_name = $last_name , "
          . " email_address = $email_address " ; 
      if ($this->user_info[spweb_password] ) {
        $q .= ", web_password = PASSWORD('" . $this->user_info[spweb_password] ."') " ; 
      } 
      $q .= " WHERE username ='$this->uname' AND domain = '$this->udomain'  ";
      $log->log("update is $q");
      $res = $this->db->query($q);  
      if (DB::isError($res)) {
         $log->log("FAILED QUERY : $q");
         $errors  = "Failed to update user info";     
         return false;
      }

    } else {
      $log->log("NO USER SPECIFIED");
    } 
    return true;




  } 
**/

/**  function get_voicemail_db() {
    global $log; 
    if ($this->udomain ) {
      $q = "SELECT voicemail_db FROM domain WHERE domain='$this->udomain' " ; 
      $res=$this->db->query($q);
      if (DB::isError($res)) {
           $log->log("FAILED QUERY : $q");
      } 
      $log->log("QUERY : $q");
      $out=array();
      while ($row=$res->fetchRow(DB_FETCHMODE_ORDERED) ) {
         $out[]=$row[0];
      }
      $res->free();
      $this->user_info[voicemail_db] = $out[0];
      return $out[voicemail_db];
    } else {
      $log->log("get_voicemail_db : udomain not set ");
      return 0; 
    } 
  }

  function get_vm_info() {
    global $log; 
    if (!$this->user_info[voicemail_db]) {
      $this->get_voicemail_db($this->udomain);     
    } 
    $vm_info = array();
    $log->log("get_vm_info() changing database to " . $this->user_info[voicemail_db]);

    $this->db->_db=$this->user_info[voicemail_db];
    $this->change_db($this->db->_db);
    if (!$this->user_info[mailbox] ) { 
       return false; 
    } 

   $q = "SELECT extension,first_name,last_name,email_address,store_flag,
         email_delivery, email_server_address, email_type, email_user_name ,
         mobile_email_flag, mobile_email,vstore_email , 
         active, transfer, mwi_flag, new_user_flag
         FROM VM_Users WHERE extension = " . $this->user_info[mailbox] ;

   $res=$this->db->query($q);
                                                                                                                                               
     if (DB::isError($res)) {
           $log->log("QUERY FAILED $q " . $res->getMessage());
     } else {
      
       $out=array();
       $row = $res->fetchRow(DB_FETCHMODE_ASSOC);
                                                                                                                                               
       if ($row[extension] ) {
         $vm_info  = $row ;
       }
        
       $log->log("QUERY $q");
       $log->log("store_flag = " . $vm_info[store_flag]);
       $res->free();
     }


    global $config;
    $log->log("Changeing back to " . $config->data_sql->db_name );

    $this->db->_db=$config->data_sql->db_name ; 
    $this->change_db($this->db->_db);
    $log->log("changed db : " . $this->db->_db); 

**/
/** $res = $this->db->query("SELECT count(*) from domain");
    if (DB::isError($res)) {
            $log->log("QUERY FAILED $q " . $res->getMessage());
     } else {
       $row=$res->fetchRow(DB_FETCHMODE_ORDERED);
       $log->log("row = $row[0]");
     }
**/
/** 

    $this->vm_info = $vm_info ; 
    return $vm_info;
  } 

**/

/** 
   function update_mailbox() {
    global $log; 
    if ($this->user_info[mailbox]) {
       $log->log("update_mailbox() $this->user_info[mailbox] ");
       if (!$this->user_info[voicemail_db]) {
          $this->get_voicemail_db($this->udomain);
       }
       $first_name = $this->db->quote($this->user_info[first_name] ) ; 
       $last_name = $this->db->quote($this->user_info[last_name] ) ; 

       if ($this->user_info[email_address] ) { 
         $email_address = $this->db->quote($this->user_info[email_address] ) ; 
       }
       $vm_password = $this->user_info[vm_password]  ; 

       $q = "UPDATE VM_Users  SET first_name = $first_name, last_name=$last_name";
       if (is_numeric($vm_password) ) {
           $q .=", password = PASSWORD('$vm_password') ";
       }

       if ($email_address ) {
           $q .=", email_address = $email_address ";
       }
       
       $q .= " WHERE extension = " . $this->user_info[mailbox]  ;
       $res=$this->db->_db=$this->voicemail_db; 
       $this->change_db($this->db->_db) ; 
       $res=$this->db->query($q);
       if (DB::isError($res)) {
           $log->log("FAILED QUERY : $q");
        }

       $log->log("Changeing back to " . $config->data_sql->db_name ); 
       global $config; 
       $res=$this->db->_db=$config->data_sql->db_name;
       $this->change_db($this->db->_db) ; 

    } else {
      $log->log("update_mailbox failed, no mailbox specified");
    }

  } 
**/
/**
  function update_um($vm_info) {
    global $log; 
    if ($vm_info[extension]) { 
      $q  = "UPDATE VM_Users set store_flag ='$vm_info[store_flag]',
      vstore_email = '$vm_info[vstore_email]',
      email_delivery ='$vm_info[email_delivery]' ,
      email_server_address ='$vm_info[email_server_address]',
      email_user_name ='$vm_info[email_user_name]',
      mobile_email_flag ='$vm_info[mobile_email_flag]' ,
      mobile_email='$vm_info[mobile_email]' 
      WHERE  extension = " . $vm_info[extension]; 

     if (!$this->user_info[voicemail_db]) {
        $log->log("update_um calling get_voicemail_db");
        $this->get_voicemail_db($this->udomain);
     }

     $res=$this->db->_db=$this->user_info[voicemail_db]; 
     $this->change_db($this->db->_db) ; 
     $res=$this->db->query($q);

     if (DB::isError($res)) {
           $log->log("FAILED QUERY : $q");
     }
     global $config; 
     $res=$this->db->_db=$config->data_sql->db_name;
     $this->change_db($this->db->_db) ; 
   } else {
        $log->log("ERRROR: Tried to update_um with no extension ");
   } 
  }
  function update_vm_flags($vm_info) { 
    global $log; 
    if ($vm_info[extension]) {
      $q  = "UPDATE VM_Users SET 
      active = '$vm_info[active]',
      transfer ='$vm_info[transfer]' ,
      new_user_flag ='$vm_info[new_user_flag]',
      mwi_flag ='$vm_info[mwi_flag]'
      WHERE  extension = " . $vm_info[extension];
                                                                                                                                               
     if (!$this->user_info[voicemail_db]) {
        $this->get_voicemail_db($this->udomain);
     }
                                                                                                                                               
     $res=$this->db->_db=$this->user_info[voicemail_db];
     $this->change_db($this->db->_db) ;
     $res=$this->db->query($q);
                                                                                                                                               
     if (DB::isError($res)) {
         $log->log("FAILED QUERY : $q " . $res->getMessage() );
     }
     global $config;
     $res=$this->db->_db=$config->data_sql->db_name;
     $this->change_db($this->db->_db) ;
   } else {
           $log->log("ERRROR: Tried to update_um with no extension ");
   }

  } 
**/
  
/**  function update_voicemail($user_info) {
     global $log; 
    $log->log("called update_voicemail");  
  
    $upd = "UPDATE VM_Users  SET first_name = '$user_info[first_name]', last_name='$user_info[last_name]'";
    if (is_numeric($user_info[password]) ) { 
        $upd .=", password = PASSWORD('$user_info[password]') "; 
    } 
    $upd .= " WHERE extension = $user_info[extension] " ; 
    $log->log("UPDATE  $upd "); 

    $res=$this->db->_db="voicemail";
    if ($this->db->connect("voicemail",true) ) { 
       $res=$this->db->query($upd);
    }
    $res=$this->db->_db="ser";
  } 
**/

}

?>
