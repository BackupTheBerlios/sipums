<?  
class SpDomain {
  // must have
  var $domain;
  // db 
  var $db; 
  var $dbFields; 
  // vm variables
   
  function SpDomain(&$db,$domain="") { 
     if ($db) {
         $this->db=$db;
     }
     if ($domain) {
         $this->domain=$domain;
     }
     return ;
   } 
   // retrieves user's data from the database 
   function get(){ 
     global $log;
     // all these must be present to do the query
     if ($this->domain) {
        
        $q = "SELECT voicemail_db , company_name , company_number " 
         . " FROM domain  WHERE domain = '" . $this->domain  . "' "; 

         $res = $this->db->query($q);

         $log->log("DONE : $q",LOG_ERR);
         if (DB::isError($res)) {
           $log->log("FAILED QUERY : $q",LOG_ERR);
           return false;
         }
        $this->dbFields = $res->fetchRow(DB_FETCHMODE_ASSOC) ;
        $res->free();
        return true; 
     } else {
         $log->log("SpDomain->get called with invalid data  " .$this->domain ,LOG_ERR);
         return false;
     }  
   }

   function updateBasic() {
     global $log;

     if ($this->db && $this->domain) {
       $q = "UPDATE domain SET " .
            " company_name = " . $this->db->quote($this->dbFields[company_name] ) .
            ", company_number = " . $this->db->quote($this->dbFields[company_number] ) .
            " WHERE domain = '" . $this->domain . "'" ; 

       $log->log("updating SpDomain->save $q ",LOG_ERR);
       $res = $this->db->query($q);

       if (DB::isError($res)) {
         $log->log("FAILED TO SpDomain->updateBasic : $q",LOG_ERR);
         return false;
       }
       return true;
     } else {
       $log->log("SpDomain->save called with blank fields: $this->mailbox ",LOG_ERR);
       return false;
     }
   } 

}
