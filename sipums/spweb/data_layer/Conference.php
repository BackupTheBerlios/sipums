<?  
require_once('Date/Span.php');
require_once('Date.php');
class Conference {
  // essential, must have
  var $username;
  var $domain;

  var $conferenceId;
  var $companyId;
  var $conferenceDate;
  var $beginTime;
  var $endTime;

//  var $conferenceDate;
//  var $beginTime;
//  var $endTime;

  var $dbFields;
  var $db;

  // vm variables
  function Conference(&$db,$username="",$domain="") { 
    if ($db) { 
       $this->db = $db; 
    }  
    if ($username) { 
       $this->username=$username; 
    }  
    if ($domain) { 
       $this->domain=$domain; 
    }  
    return ;

  } 

  // retrieves user's data from the database 
  function get() {
    global $log; 
    // all these must be present to do the query
    if ($this->conference_id) { 
    } 
  }  

  function getCompanyId() {
    global $log; 
    if ($this->domain) {
      change_to_conference_db($this->db);
      $q = "SELECT company_id FROM companies WHERE domain ='" . $this->domain . "' "; 
      $res =  $res=$this->db->query($q);
      if (DB::isError($db) ) { 
         $log->log("ERROR IN QUERY $q ");
      } 
      $row = $res->fetchRow();
      $company_id = $row[0] ; 
      change_to_default_db($this->db);

      $this->companyId = $company_id; 

      return $company_id; 
    } 
  } 
  function isPastDate() {
    global $log; 
    // get the unix timestamps
    $now_uts =  mktime(); 
    list($conf_mon, $conf_day, $conf_year) =  split("-",$this->dbFields[conference_date] ) ; 
    $log->log("$conf_mon, $conf_day,$conf_year  "); 
    $conference_uts = mktime(23,59,59,$conf_mon,$conf_day,$conf_year) ; 
    $log->log("now = $now_uts, conference_uts = $conference_uts "); 
    if ($conference_uts < $now_uts ) {
      return true ; 
    }  else {
      return false ; 
    } 
  } 
  function loadConstraints () { 
    global $log; 
    if (!$this->companyId) { 
      $this->getCompanyId() ; 
    } 
      change_to_conference_db($this->db);
      $q = "SELECT max_concurrent, max_time_mins,  max_invite FROM companies WHERE domain ='" . $this->domain . "' ";
      $res =  $res=$this->db->query($q);
      IF (dB::isError($db) ) {
         $log->log("ERROR IN QUERY $q ");
      }
      $log->log("q is $q");
      $row = $res->fetchRow(); 

      $this->dbFields[max_concurrent] = $row[0] ;
      $this->dbFields[max_time_mins] = $row[1] ;
      $this->dbFields[max_invite] = $row[2] ;
      $log->log("new max_time_mins -= " . $this->dbFields[max_time_mins] ); 
      change_to_default_db($this->db);
                                                                                                                                               
      $this->companyId = $company_id;
  } 
  function isMaxConcurrent() {
    global $log; 
    if (!$this->companyId) { 
      $this->getCompanyId() ; 
    } 
    $log->log("creating ds");
    $ds = new Date_Span();

   
    return true ; 
   
  } 
  function isMaxTime(){
    global $log; 
    $ds = new Date_Span(); 
    $ds->setFromDateDiff($this->beginTime, $this->endTime) ; 
    $log->log("span = " . $ds->toMinutes()) ; 
    $log->log("maxItme_mine = " . $this->dbFields[max_time_mins] ) ;   
    if ($ds->toMinutes() > $this->dbFields[max_time_mins] ) {
      return false ; 
    } else {  
      return true; 
    }
  } 
  function create() {
    // $q = "INSERT INTO  
    
   
  } 


}

?>
