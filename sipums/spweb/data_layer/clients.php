<?
/*
 * $Id: clients.php,v 1.1 2004/08/30 04:22:54 kenglish Exp $
 */

class CData_Layer extends CDL_common{

  function get_clients() { 
      global $log; 
      $q = "select c.client_id client_id ,c.client_name client_name,  r.client_id reseller_client_id, r.client_name reseller_client_name
FROM clients c LEFT OUTER JOIN clients r ON (r.client_id = c.reseller_client_id)";
      $res=$this->db->query($q);
      $out=array();
      $log->log("sql = $q"); 
      while ($row=$res->fetchRow(DB_FETCHMODE_ASSOC ) ) {
          $out[]=$row;
          $log->log($row['client_id'] . " = client_id "); 
          
      }
      $res->free();
      return $out;
  }

}

?>
