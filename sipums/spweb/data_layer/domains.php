<?
/*
 * $Id: domains.php,v 1.3 2004/08/06 07:29:21 kenglish Exp $
 */

class CData_Layer extends CDL_common{

  function get_domains($include_count) { 
      $q="";
      if ($include_count) { 
         $q = "SELECT d.domain domain, d.voicemail_db, d.company_name, d.company_number, count(s.username) user_count FROM domain d LEFT JOIN subscriber s ON (d.domain = s.domain) group by d.domain,d.voicemail_db,d.company_name, d.company_number"; 
      } else { 
         $q = "SELECT domain, voicemail_db FROM domain";  
  
      } 
      do_debug("sql  - $q") ; 
      $res=$this->db->query($q);
      $out=array();
      while ($row=$res->fetchRow(DB_FETCHMODE_ASSOC ) ) {
	        $out[]=$row;
      }
      $res->free();
		
      return $out;
  }

}

?>
