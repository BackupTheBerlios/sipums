<?
/*
 * $Id: new_conference.php,v 1.6 2004/08/20 20:48:08 kenglish Exp $
 */

class CData_Layer extends CDL_common{

  var $extension; 
  var $udomain; 

  var $uname; 
  var $mailbox; 

  function get_conference_name($domain) { 
    global $config,$log ; 

    if ($domain)  { 
       change_to_conference_db($this->db); 
       $q="SELECT count(*),com.company_name FROM companies com,conferences con " 
         . " WHERE com.domain='$domain' " 
         . " AND com.company_id = con.company_id GROUP BY com.company_name"; 

       $res=$this->db->query($q);
       if (DB::isError($res)) {
         $log->log("QUERY FAILED $q " . $res->getMessage());
       } 

       $row  = $res->fetchRow() ; 
       $count = $row[0] ; 
       $company_name = $row[1]; 
       $res->free(); 

       if (!$count) {
          $q = "SELECT company_name FROM companies WHERE domain='$domain' "  ; 
          $res=$this->db->query($q);
          $row = $res->fetchRow() ;
          $company_name = $row[0];
          $count  =0; 
       } 
       $count++;
       $conf_name = "$company_name Conference #$count" ; 
       $log->log("count = $count $conf_name "); 
  
       change_to_default_db($this->db);
       return $conf_name ; 
    } 
  }
}
?>
