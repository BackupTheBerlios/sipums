<?
/*
 * $Id: super.php,v 1.4 2004/08/12 00:03:25 kenglish Exp $
 */

class CData_Layer extends CDL_common{

  function get_users($domain){
    global $config,$log;
    switch($this->container_type){
    case 'sql':
       /* get num rows */		
       /* get users */
      if ($domain) { 
          $where = " WHERE domain = '$domain' "; 
      } 
      $q="select s.username,s.domain, s.first_name, s.last_name, s.phone, s.email_address, s.perm FROM ".$config->data_sql->table_subscriber." s ". 
         " $where order by s.domain,s.username ";

      $log->log("q -= $q");

	
             $res=$this->db->query($q);
             if (DB::isError($res)) {
               log_errors($res, $errors); 
               return false;
             }
             $out=array();
             while ($row=$res->fetchRow(DB_FETCHMODE_OBJECT)){
                $name=$row->last_name;
                if ($name) $name.=" "; 
                $name.=$row->first_name;
                $row->name=$name;
                $row->permission=$name;
	        $out[]=$row;
              }
              $res->free();
		
              return $out;
       case 'ldap':
         die('NOT IMPLEMENTED: '.__FILE__.":".__LINE__);
     }
  }
  function get_domains($include_count) { 
      $q="";
      if ($include_count) { 
         $q = "SELECT d.domain,count(s.username) user_count FROM domain d LEFT JOIN subscriber s ON (d.domain = s.domain) group by d.domain"; 
      } else { 
         $q = "SELECT domain FROM domain";  
      } 
      $res=$this->db->query($q);
      $out=array();
      while ($row=$res->fetchRow(DB_FETCHMODE_OBJECT) ) {
	        $out[]=$row;
      }
      $res->free();
		
      return $out;
  }

}

?>
