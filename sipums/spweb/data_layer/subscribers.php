<?
/*
 * $Id: subscribers.php,v 1.11 2004/08/30 04:22:54 kenglish Exp $
 */

class CData_Layer extends CDL_common{

  function get_subscribers($domains){
    global $config;
    switch($this->container_type){
    case 'sql':
       /* get num rows */		
       /* get users */
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
      $q="select s.username, s.domain, s.first_name, s.last_name, s.phone, s.email_address, s.perm, s.mailbox, s.rpid  FROM ".$config->data_sql->table_subscriber." s ". 
         " $where order by s.domain,s.username ";

             $res=$this->db->query($q);
             if (DB::isError($res)) {
               log_errors($res, $errors); 
               return false;
             }
             $out=array();
             while ($row=$res->fetchRow(DB_FETCHMODE_ASSOC)){
                
                $row[caller_id] = $row[rpid]; 
                if ($row[caller_id]) { 
                   $row[caller_id] = rpid_to_caller_id($row[caller_id]); 
                } 
	        $out[]=$row;
                
             }
             $res->free();
		
              return $out;
       case 'ldap':
         die('NOT IMPLEMENTED: '.__FILE__.":".__LINE__);
     }
  }
}
?>
