<?
/*
 * $Id: conference.php,v 1.4 2004/08/30 04:22:54 kenglish Exp $
 */

class CData_Layer extends CDL_common{

  function get_conference_ids($uname,$admin_flag) { 

  } 
  function get_conference_summary($uname,$admin_flag) { 
    global $config,$log ; 

    change_to_conference_db($this->db); 
    $date_format = "if(c.conference_date=current_date(),'Today',date_format(c.conference_date,'%m-%d-%Y'))" ; 
    $q= "SELECT c.conference_id, $date_format conference_date,c.conference_name, " 
      .  " c.begin_time,c.end_time,c.creator,c.conference_number, IF(c.creator='3560074',1,0) owner_flag,   count(*) invitee_count " 
      .	 "  FROM conferences c, invitees i " 
      .	 " WHERE c.conference_id = i.conference_id "
      . " AND c.conference_Date >= NOW() " ; 
     $log->log("admin flag = $admin_flag");  
     if (!$admin_flag) { 
        $q .= " AND i.invitee_username = '$uname'" ;
     } 
     $q .= "GROUP BY c.conference_id,c.conference_date,c.conference_name, c.begin_time,c.end_time,c.creator,c.conference_number "; 
     $log->log("QUERY IS $q " ); 


     $res=$this->db->query($q);
     if (DB::isError($res)) {
        $log->log("QUERY FAILED $q " . $res->getMessage());
     } 
     $data =array(); 

     while ($row= $res->fetchRow(DB_FETCHMODE_ASSOC) ) { 
        $data[] = $row ; 
        $log->log("conference_id=". $row[conference_id]  ); 
     } 
  
     change_to_default_db($this->db);
     return $data ; 
  } 

  function get_user_conferences($conf_ids) {
    global $log ; 
    $id_array = array(); 
    $id_to_index_map = array(); 
    for ($i = 0; $i < count($conf_ids); $i++) {
       $id_array[] = $conf_ids[$i][conference_id] ; 
       $id_to_index_map[$conf_ids[$i][conference_id]] = $i; 
       $log->log(" $i " . $conf_ids[$i][conference_id] ); 
    }
   #    for ($i  ( $conf_ids as $h) {
   #    }  

    $ids = implode(',',$id_array); 
    $q = "SELECT c.conference_id, i.invitee_id, i.invitee_email, i.invitee_code, i.invitee_name,i.invitee_username  FROM conferences c, invitees i WHERE c.conference_id = i.conference_id AND c.conference_id in ($ids) ";
    $log->log($q); 
    change_to_conference_db($this->db); 

    $res=$this->db->query($q);
    if (DB::isError($res)) {
       $log->log("QUERY FAILED $q " . $res->getMessage());
    }

    $data =array();

    while ($row= $res->fetchRow(DB_FETCHMODE_ASSOC) ) {
        $index = $id_to_index_map[$row[conference_id]] ; 
        $conf_ids[$index]["invitees"][] = $row; 
    }
    change_to_default_db($this->db);
    return $conf_ids ; 

   
       
  } 
}
?>
