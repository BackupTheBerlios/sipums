<?  
require_once 'data_layer/Conference.php';

class Invitee {
  // essential, must have
  var $username;
  var $domain;
  var $email;
  var $domain;

  var $inviteeId;
  var $conpanyId;
  var $conferenceId;
  var $inviteeEmail;
  var $ownerFlag;
  var $inviteeCode ;
  var $inviteeName;
  var $conferenceInviteeCount;
  var $companyMaxInvitee;

  var $db;

  // vm variables
  function Invitee(&$db,$conferenceId="",$inviteeId="") { 
    if ($db) { 
      $this->db = $db; 
    }  
    if ($inviteeId) { 
      $this->inviteeId = $inviteeId; 
    }  
    if ($conferenceId) { 
      $this->conferenceId = $conferenceId; 
    }  
    return ;
  } 

  // retrieves user's data from the database 
  function get() {
    global $log; 
    // all these must be present to do the query
    if ($this->conferenceId && $this->inviteeId) { 
       change_to_conference_db($this->db);
       $q = "SELECT invitee_id , company_id , conference_id , invitee_email, "
           . " owner_flag , invitee_code , invitee_username , invitee_name "
           . " FROM invitees WHERE invitee_id = ". $this->inviteeId; 
       $res=$this->db->query($q);
       if (DB::isError($res) ) {
          $log->log("ERROR IN QUERY $q ");
       } else { 
          $log->log("$q ");
          $row = $res->fetchRow();
          $this->companyId= $row[1] ;
          $this->inviteeEmail= $row[3] ;
          $this->ownerFlag= $row[4] ;
          $this->inviteeCode= $row[5] ;
          $this->username = $row[6] ;
          $this->inviteeName = $row[7] ;
          
       }  
       change_to_default_db($this->db);
    }  else {
      $log->log("Called invitee get with no inviteeId or conferenceId");
    } 
  }  
  function _make_seed() {
        list($usec, $sec) = explode(' ', microtime());
       return (float) $sec + ((float) $usec * 100000);
  }

  function generateInviteeCode() {
    global $log; 
    change_to_conference_db($this->db);
    srand($this->_make_seed());
    $exists = 1; 
    
    while ($exists) {  
      $randval = rand(100000,9999999);

      $q = "SELECT count(*)  FROM invitees WHERE invitee_code  ='" . $randval .  "' "; 

      $res=$this->db->query($q);
      if (DB::isError($res) ) { 
         $log->log("ERROR IN QUERY $q ");
      } 
      $row = $res->fetchRow();
      $count = $row[0] ; 
      if ($count ==0) { 
          $exists = 0;  
      } 

      $this->inviteeCode = $randval; 
    } 
    
   $log->log("inviteeCode is not " .  $this->inviteeCode  );
   change_to_default_db($this->db);
   return;
  } 
  function isMaxInvitee(){
    global $log; 
    if (!$this->companyId) { 
       $this->getCompanyId();       
    } 
    if (!$this->conferenceId) { 
       $log->log("called isMaxInvitee with no conferenceId set"); 
       $this->getCompanyId();       
    } 

    change_to_conference_db($this->db);
    $q =  'select com.max_invitees,count(*) ' 
       . ' FROM companies com, conferences con,invitees i  '
       . ' WHERE com.company_id = con.company_id ' 
       . ' AND con.conference_id = i.conference_id ' 
       . ' AND con.conference_id = ' . $this->conferenceId 
       . ' GROUP BY com.max_invitees,con.conference_id ' ; 
    
    $res = $this->db->query($q);
    if (DB::isError($res) ) {
       $log->log("ERROR IN QUERY $q ");
    }
    $row = $res->fetchRow();

    $this->companyMaxInvitee = $row[0] ;
    $this->conferenceInviteeCount = $row[1] ;

    change_to_default_db($this->db); 
    $log->log("companyMaxInvitee = " . $this->companyMaxInvitee); 
    $log->log("conferenceInviteeCount = " . $this->conferenceInviteeCount); 
    $log->log("bool = " . ($this->conferenceInviteeCount >= $this->companyMaxInvitee) ); 
    if ($this->conferenceInviteeCount >= $this->companyMaxInvitee) {
       return true; 
    }  else {
       return false; 
    }
     
    
  } 

  function create() { 
    global $log; 
    // $this->conferenceId='4001';
    if (!$this->conferenceId) {

       $log->log('create invite called with no conference id ' ); 

       return false; 
    } 
    if (!$this->companyId) { 
       $this->getCompanyId();       
    } 
    if ($this->ownerFlag != 1)  { 
        $this->ownerFlag = 0; 
    } 

    $log->log("create it" ); 
    $q =  'INSERT INTO invitees ( invitee_id , company_id , conference_id , invitee_email , owner_flag , invitee_code , invitee_username , invitee_name ) '  
        . ' VALUES ( 0, ' . $this->companyId . ', ' 
        . $this->conferenceId . ',' 
        . $this->db->quote($this->inviteeEmail) . ',' 
        . $this->ownerFlag . ',' 
        . $this->db->quote($this->inviteeCode) . ',' 
        . $this->db->quote($this->username) . ',' 
        . $this->db->quote($this->inviteeName) . ' ) ' ; 
    $log->log("q = $q " ); 

    change_to_conference_db($this->db);
    $res=$this->db->query($q);
    if (DB::isError($res) ) {
       $log->log("ERROR IN QUERY $q " . $res->getMessage() );
     }
    change_to_default_db($this->db);
  } 

  function sendNotify() { 
     global $log; 

     if ($this->inviteeEmail ) { 
       
        $conference = new Conference($this->db) ; 

        $conference->conferenceId = $this->conferenceId;
        $conference->get(); 

        $email_body = "Aloha $this->inviteeName, \n"
        . "   You have been inviteed to attend the conference '" . $conference->conferenceName . "' by " . $conference->ownerName . "\n"
        . '   Conference Date: '. $conference->conferenceDate->getMonth(). "-" . $conference->conferenceDate->getDay().'-' . $conference->conferenceDate->getYear() . "\n\n" 
        . 'Start Time : '. $conference->beginTime->getHour(). ":" . $conference->beginTime->getMinute() . "\n"
        . 'Your Conference Code : '. $this->inviteeCode . "\n"
        . "Call Matt to enter the conference becuase the rest doesn't work yet\n";
        mail($this->inviteeEmail, "Invitation to " . $conference->conferenceName,  $email_body,
           "From: kelepona@{$_SERVER['SERVER_NAME']}\r\n" .
           "X-Mailer: PHP/" . phpversion());

       $log->log("Email BODY :\n $email_body \n" );
         
     } else {
       $log->log("No InviteeEmai " );
       return false;  
     }
  } 

  function getCompanyId() {
    global $log;
    if ($this->conferenceId) {
      change_to_conference_db($this->db);
      $q = "SELECT company_id FROM conferences WHERE conference_id =" . $this->conferenceId ;
      $res =  $res=$this->db->query($q);
      if (DB::isError($res) ) {
         $log->log("ERROR IN QUERY $q ");
      }
      $row = $res->fetchRow();
      $company_id = $row[0] ;
      change_to_default_db($this->db);
 
      $this->companyId = $company_id;
 
      return $company_id;
    }
  }
  function getInfoFromUserName() {
     global $log ;
     if ($this->username)  { 
       $q = "SELECT concat(first_name,' ',last_name), email_address FROM subscriber WHERE username =" . $this->username ;
       $res =  $res=$this->db->query($q);
       if (DB::isError($res) ) {
           $log->log("ERROR IN QUERY $q ");
       }
       $row = $res->fetchRow();
       $this->inviteeName = $row[0] ;
       $this->inviteeEmail = $row[1] ;
       $res->free();

       if (!$this->inviteeEmail) {
         $log->log("Called getInfoFromUserName but found no Email, returning false");
         return false; 
       } else { 
         return true; 
       } 
    } else {
      $log->log("called getInfoFromUserName with no username set");
      return false; 
    } 
  } 

}
