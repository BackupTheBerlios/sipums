<?
/*
 * $Id: resellers.php,v 1.1 2004/08/30 04:22:54 kenglish Exp $
 */

class CData_Layer extends CDL_common{

  function get_resellers() { 
      global $log; 
      $q = "select r.client_id client_id , "
          . " r.client_name client_name , "
          . " count(c.client_id) client_count" 
          . " FROM clients r , clients c " 
          . " WHERE r.reseller_client_id IS NULL " 
          . " AND r.client_id = c.reseller_client_id "
          . " GROUP BY r.client_id, r.client_name"; 

      $res=$this->db->query($q);
      $out=array();
      $log->log("sql = $q"); 
      while ($row=$res->fetchRow(DB_FETCHMODE_ASSOC ) ) {
          $out[]=$row;
          $log->log($row['client_count'] . " = client_count "); 
          
      }
      $res->free();
      return $out;
  }

}

?>
