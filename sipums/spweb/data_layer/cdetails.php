<?
/*
 * $Id: cdetails.php,v 1.2 2004/08/19 01:55:57 kenglish Exp $
 */

class CData_Layer extends CDL_common{

  function get_conference_ids($uname) { 
    global $config,$log ; 

    change_to_conference_db($this->db); 

     $q= "SELECT c.conference_id,i.owner_flag, c.conference_date,c.conference_name, " 
      .  " c.begin_time,c.end_time " 
      .	 "  FROM conferences c, invitees i " 
      .	 " WHERE c.conference_id = i.conference_id "
      . " AND i.invitee_username = '$uname'" 
      . " AND c.conference_Date >= NOW() " ; 


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
  function get_user_conference($conf_id,$username) {
    global $log ; 

    $q = "SELECT c.conference_id, c.conference_name, "
         ." date_format(c.conference_date,'%m-%d-%Y') conference_date,"
         ." time_format(c.begin_time,'%l:%i %p' ) begin_time,"
         ." time_format(c.end_time,'%l:%i %p' ) end_time,"
         ." i.owner_flag, i.invitee_id, i.invitee_email, "
         ."  i.invitee_code, i.invitee_name,i.invitee_username  "
         ."  FROM conferences c, invitees i "
         ." WHERE c.conference_id = i.conference_id AND c.conference_id = $conf_id ";
    $log->log($q); 
    change_to_conference_db($this->db); 

    $res=$this->db->query($q);
    if (DB::isError($res)) {
       $log->log("QUERY FAILED $q " . $res->getMessage());
    }

    $data =array();
    $user_conf = array();
    $row= $res->fetchRow(DB_FETCHMODE_ASSOC) ;
    $user_conf['conference_id']=$conf_id;
    $user_conf['conference_name']=$row['conference_name'] ;
    $user_conf['conference_date']=$row['conference_date'] ;
    $user_conf['begin_time']=$row['begin_time'] ;
    $user_conf['end_time']=$row['end_time'] ;
     
    do {
       $user_conf["invitees"][] = $row; 
       if ($row["owner_flag"] && ( $row["invitee_username"] == $username ) ) { 
         $log->log("owner_flag found");
         $user_conf['owner_flag']=1;
       } 
       $log->log("invitee_email = " . $row['invitee_email']);
       $log->log("owner_flag = " . $row['owner_flag']);
    } while ($row= $res->fetchRow(DB_FETCHMODE_ASSOC) ); 
    change_to_default_db($this->db);
    return $user_conf ; 

   
       
  } 
}
?>
