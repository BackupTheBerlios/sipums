<?
/*
 * $Id: assign_number.php,v 1.1 2004/09/07 21:22:40 kenglish Exp $
 */

class CData_Layer extends CDL_common{

  function get_avail_numbers($client_id) { 
      global $log; 
      $q = "SELECT username FROM subscriber WHERE client_id <> $client_id";
      $res=$this->db->query($q);
      $out=array();
      $log->log("sql = $q"); 
      while ($row=$res->fetchRow() ) {
          if (strlen($row[0]) ==7) { 
            $out[]=$row[0];
          }
      }
      $res->free();
      return $out;
  }
  function get_client_name($client_id){
      $q = "SELECT client_name FROM clients WHERE client_id=$client_id";
      $res=$this->db->query($q);
      if ($row=$res->fetchRow() ) {
          $out=$row[0];
      }
      $res->free();
      return $out;
  } 
  function save_client_number($client_id, $username){
      global $log; 
      $q = "UPDATE subscriber SET client_id=$client_id, username='$username' WHERE username='$username'";
      $log->log("sql = $q"); 
      $res=$this->db->query($q);
      if (DB::isError($res)) {
        $log->log("ERROR DOING  = $q"); 
      }
  }

}

?>
