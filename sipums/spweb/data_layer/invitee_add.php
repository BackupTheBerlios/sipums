<?
/*
 * $Id: invitee_add.php,v 1.1 2004/08/30 04:22:54 kenglish Exp $
 */

class CData_Layer extends CDL_common{

  function get_invitee_users($domain) { 
    global $config,$log ; 

    if ($domain)  { 
       $q=" select username, concat(first_name,' ',last_name) name "
        . " FROM subscriber where domain='$domain' ORDER BY first_name " ; 

       $res=$this->db->query($q);
       if (DB::isError($res)) {
         $log->log("QUERY FAILED $q " . $res->getMessage());
       } 

       $data  = array(); 
       while ($row  = $res->fetchRow() ) { 
           $data[$row[0]] = "$row[1] ($row[0])";  
       } 
       $res->free(); 
       return $data ; 
    } 
  }

  function is_conference_owner($conference_id, $username) {
    global $log; 
    $log->log("is_conference_owner $conference_id, $username "); 

    if ($conference_id && $username){ 
      change_to_conference_db($this->db);

      $q=" select owner_flag FROM invitees WHERE conference_id=$conference_id AND invitee_username='$username'";
      $res=$this->db->query($q);

      if (DB::isError($res)) {
        $log->log("QUERY FAILED $q " . $res->getMessage());
      }
      $owner_flag = FALSE;

      $row = $res->fetchRow() ; 
      if ($row[0]) { 
        $owner_flag = TRUE;
      }

      $res->free();
      change_to_default_db($this->db);
      return $owner_flag; 
    }
  }  

}
?>
