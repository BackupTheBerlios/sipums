<?
/*
 * $Id: edit_subscriber.php,v 1.6 2004/08/06 07:29:21 kenglish Exp $
 */

class CData_Layer extends CDL_common{

  var $extension; 
  var $uname; 
  var $udomain; 
  var $AREA_CODE = '808'; 

  function init($uname,$udomain) {
     $this->uname=$uname;
     $this->udomain=$udomain;
  }   
  function get_caller_id($edit_uname, $edit_udomain ) { 
    $q = "SELECT rpid FROM subscriber WHERE username = '$edit_uname' AND domain = '$edit_udomain'";
    $res = $this->db->query($q);
    if (DB::isError($res)) {
      do_debug("QUERY FAILED $q");
      do_debug("Error looking up by name");
      return 0;
    }
                                                                                                                                               
    $row = $res->fetchRow(DB_FETCHMODE_ORDERED);
    $res->free(); 
    $rpid = $row[0];
    $caller_id = rpid_to_caller_id($rpid); 
    return $caller_id;    
  } 


  function get_perm($edit_uname, $edit_udomain ) {
    $q = "SELECT perm FROM subscriber WHERE username = '$edit_uname' AND domain = '$edit_udomain'";
    $res = $this->db->query($q);
    if (DB::isError($res)) {
      do_debug("QUERY FAILED $q");
      do_debug("Error looking up by name");
      return 0;
    }
    $row = $res->fetchRow(DB_FETCHMODE_ORDERED);
    $res->free();
    $perm = $row[0];
    return $perm;
  }


  function save_perm($edit_uname, $edit_udomain,$new_perm ) {
    $q = "UPDATE subscriber SET perm = '$new_perm' WHERE username = '$edit_uname'
          AND domain = '$edit_udomain' ";
    $res=$this->db->query($q);   
    if (DB::isError($res)) { 
      do_debug("QUERY FAILED $q"); 
      return 0;   
    }  else {
      do_debug("did QUERY $q"); 
      return 1;   
    } 
  } 

  function set_caller_id_to_unknown($edit_uname, $edit_udomain ) {
    $q = "UPDATE subscriber SET rpid = '<sip:unknown@$edit_udomain>' WHERE username = '$edit_uname'
          AND domain = '$edit_udomain' ";
    $res=$this->db->query($q);   
    if (DB::isError($res)) { 
      do_debug("QUERY FAILED $q"); 
      return 0;   
    }  else {
      do_debug("did QUERY $q"); 
    } 
    return 1;   
  } 

  function set_caller_id_to_did($edit_uname, $edit_udomain ) {

    $this->db->quote($this->user_info[first_name]);   
    $q = "SELECT first_name, last_name FROM subscriber WHERE username = '$edit_uname' AND domain = '$edit_udomain'"; 
    $res = $this->db->query($q);   
    if (DB::isError($res)) { 
      do_debug("QUERY FAILED $q"); 
      do_debug("Error looking up name"); 
       return 0; 
    } 

    $row = $res->fetchRow(DB_FETCHMODE_ORDERED);  
    $first_name = $row[0]; 
    $last_name  = $row[1]; 

    if ($first_name && $last_name) { 
       $AREA_CODE = $this->AREA_CODE; 
       $caller_id = "\"$first_name $last_name\" <sip:$AREA_CODE$edit_uname@$edit_udomain>"; 
    }  else {
       $caller_id = "<sip:$edit_uname@$edit_udomain>"; 
    } 

    do_debug("caller_id = $caller_id"); 

    $q_caller_id = $this->db->quote($caller_id); 
    $q = "UPDATE subscriber SET rpid = $q_caller_id WHERE username = '$edit_uname'
          AND domain = '$edit_udomain' ";

    do_debug("QUERY =$q"); 
    $res=$this->db->query($q);   
    return 1; 
  } 
  function set_caller_id_to_company($edit_uname, $edit_udomain ) {
    $q = "SELECT company_name, company_number FROM domain WHERE domain = '$edit_udomain'"; 
    $res=$this->db->query($q);   
    if (DB::isError($res)) { 
      do_debug("QUERY FAILED $q"); 
      do_debug("Error looking up name"); 
      return 0; 
    } 

    $row = $res->fetchRow(DB_FETCHMODE_ORDERED);  
    $company_name = $row[0]; 
    $company_number  = $row[1]; 
    if ($company_name && $company_number) { 
       $AREA_CODE = $this->AREA_CODE; 
       $caller_id = "\"$company_name\" <sip:$AREA_CODE$company_number@$edit_udomain>"; 
       do_debug("caller_id = $caller_id"); 
    } else {
      return; 
    } 
    $q_caller_id = $this->db->quote($caller_id);
    $q = "UPDATE subscriber SET rpid = $q_caller_id WHERE username = '$edit_uname'
          AND domain = '$edit_udomain' ";

    do_debug("QUERY =$q"); 
    $res=$this->db->query($q);   
    return 1;
    

  } 
}
