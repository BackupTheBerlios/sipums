<?
/*
 * $Id: domains.php,v 1.1 2004/08/01 20:06:13 kenglish Exp $
 */

class CData_Layer extends CDL_common{

  function get_domains($include_count) { 
      $q="";
      if ($include_count) { 
         $q = "SELECT d.domain domain, d.voicemail_db, count(s.username) user_count FROM domain d LEFT JOIN subscriber s ON (d.domain = s.domain) group by d.domain,d.voicemail_db"; 
      } else { 
         $q = "SELECT domain, voicemail_db FROM domain";  
      } 
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