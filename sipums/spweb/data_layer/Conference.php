<?  
require_once('Date/Span.php');
require_once('Date.php');
class Conference {
  // essential, must have
  var $username;
  var $domain;

  var $conferenceId;
  var $companyId;
  // these are PEAR Date objects
  var $conferenceDate;
  var $conferenceDateFormatted;
  var $beginTimeFormatted;
  var $beginTime;
  var $endTimeFormatted;
  var $endTime;

//  var $conferenceDate;
//  var $beginTime;
//  var $endTime;

  var $constraintFields;
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
    if ($this->conferenceId) { 
      $date_format = "if(c.conference_date=current_date(),'Today',date_format(c.conference_date,'%m-%d-%Y')) conference_date_formatted" ;
      $begin_time_format = " time_format(begin_time,'%l:%i %p') begin_time_formatted"; 
      $end_time_format = " time_format(end_time,'%l:%i %p') end_time_formatted"; 

      $q = "SELECT c.conference_id, c.company_id, conference_name, conference_date,begin_time, end_time,  "
         . " invitee_email, invitee_name,$date_format,$begin_time_format,$end_time_format "
         . " FROM conferences c, invitees i " 
         . " WHERE i.conference_id = c.conference_id "
         . " AND   i.owner_flag = 1 "
         . " AND c.conference_id = " . $this->conferenceId ;

      change_to_conference_db($this->db);
     // $log->log("QUERY = $q ");
      $res =  $res=$this->db->query($q);
      if (DB::isError($res) ) {
         $log->log("ERROR IN QUERY $q ");
      }
      $row = $res->fetchRow(DB_FETCHMODE_ASSOC);
      $res->free();
      change_to_default_db($this->db);
      $this->companyId = $row['company_id'] ;
      $this->conferenceName = $row['conference_name'] ;
      $this->conferenceDate = new Date(); 
      $this->conferenceDate->setDate($row['conference_date']);  
      $this->conferenceDateFormatted = $row['conference_date_formatted'];  
      $this->beginTimeFormatted = $row['begin_time_formatted'];  
      $this->endTimeFormatted = $row['end_time_formatted'];  
      $this->ownerName = $row['invitee_name'] ;

      list ($beginHour, $beginMinute ) = split(':',$row['begin_time']);
      list ($endHour, $endMinute ) = split(':',$row['end_time']);
      $this->beginTime = $this->conferenceDate; 
      $this->endTime   = $this->conferenceDate; 

      $this->beginTime->setHour($beginHour);
      $this->beginTime->setMinute($beginMinute);

      $this->endTime->setHour($endHour);
      $this->endTime->setMinute($endMinute);

      //$log->log("month = " . $this->conferenceDate->getMonth()  ); 
      //$log->log("day = " . $this->conferenceDate->getDay()  ); 
      //$log->log("year = " . $this->conferenceDate->getYear()  ); 

      //$log->log("Begin hour = " . $this->beginTime->getHour() ) ;
      //$log->log("Begin min = " . $this->beginTime->getMinute() ) ;

      //$log->log("End Hour = " . $this->endTime->getHour() ) ;
      //$log->log("End Min = " . $this->endTime->getMinute() ) ; 
    } 
  }  

  function getCompanyId() {
    global $log; 
    if ($this->domain) {
      change_to_conference_db($this->db);
      $q = "SELECT company_id FROM companies WHERE domain ='" . $this->domain . "' "; 
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
      $q = "SELECT max_concurrent, max_time_mins,  max_invitees  FROM companies WHERE domain ='" . $this->domain . "' ";
      $res =  $this->db->query($q);
      IF (dB::isError($res) ) {
         $log->log("ERROR IN QUERY $q ");
      }
      $log->log("q is $q");
      $row = $res->fetchRow(); 

      $this->constraintFields[max_concurrent] = $row[0] ;
      $this->constraintFields[max_time_mins] = $row[1] ;
      $this->constraintFields[max_invitees] = $row[2] ;
      $log->log("new max_time_mins -= " . $this->constraintFields[max_time_mins] ); 
      change_to_default_db($this->db);
                                                                                                                                               
      $this->companyId = $company_id;
  } 

  function isMaxConcurrent() {
    global $log; 
    if (!$this->companyId) { 
      $this->getCompanyId() ; 
    } 
    $sql_conference_date = date_to_sql($this->conferenceDate); 
    $sql_begin_time = time_to_sql($this->beginTime); 
    $sql_end_time = time_to_sql($this->endTime); 
    $q = "select count(*) FROM conferences WHERE conference_date = '$sql_conference_date' "
     . "  AND (( begin_time >= '$sql_begin_time' and end_time <= '$sql_end_time')  "
     . "  OR ( begin_time <= '$sql_begin_time' and end_time >= '$sql_end_time')  " 
     . "  OR ( begin_time > '$sql_begin_time' and begin_time < '$sql_end_time')  " 
     . "  OR ( end_time > '$sql_begin_time' and end_time < '$sql_end_time')  " 
     . " ) "; 

    $log->log("q= $q" ) ; 
    change_to_conference_db($this->db);
    $res =  $res=$this->db->query($q);
    if (DB::isError($res) ) {
         $log->log("ERROR IN QUERY $q " . $res->getMessage() ) ; 
    }
    $row = $res->fetchRow();
    $res->free();
    $concurrent = $row[0] ;
    $log->log("concurrent = $concurrent " ) ; 
    $log->log("Max concurrent = " . $this->constraintFields[max_concurrent] ) ; 
    change_to_default_db($this->db);
    if ($concurrent >= $this->constraintFields[max_concurrent]) { 
      return false  ; 
    } else {
      return true ;
    } 
  } 

  function isMaxTime(){

    global $log; 
    $ds = new Date_Span(); 
    $ds->setFromDateDiff($this->beginTime, $this->endTime) ; 
    $log->log("span = " . $ds->toMinutes()) ; 
    $log->log("maxItme_mine = " . $this->constraintFields[max_time_mins] ) ;   
    if ($ds->toMinutes() > $this->constraintFields[max_time_mins] ) {
      return false ; 
    } else {  
      return true; 
    }

  } 


  function create(&$error) {
    global $log; 
    // Make sure that everything is here
    if  (!($this->companyId) ) {
      $error = "No Company Id"; 
      return false ;
    } 
    if (!$this->conferenceName) { 
      $error = "No End Time."; 
      return false ;
    } 
    if (!$this->conferenceDate) { 
      $error = "No End Time."; 
      return false ;
    } 
    if (!$this->beginTime) { 
      $error = "No Start Time."; 
      return false ;
    } 
    if (!$this->endTime) { 
      $error = "No End Time."; 
      return false ;
    } 
    // change to conference db

    change_to_conference_db($this->db);
    $sql_conference_date = $this->conferenceDate->year . "-" . $this->conferenceDate->month 
           . "-" .  $this->conferenceDate->day ; 

    $sql_begin_time = $this->beginTime->hour 
           . ":" .  $this->beginTime->minute 
           . ":00"; 

    $sql_end_time = $this->endTime->hour . ":" .  $this->endTime->minute 
           . ":00"; 

    $q = "INSERT INTO  conferences (conference_id , company_id , conference_name, " 
     . "  conference_date , conference_number, begin_time , end_time ,  creator ) "
     . " VALUES (0, " . $this->companyId . ", " 
     . $this->db->quote($this->conferenceName) . "," 
     . "'$sql_conference_date'," 
     . "'3560078'," 
     . "'$sql_begin_time', " 
     . "'$sql_end_time', '$this->username' ) " ; 


     $res=$this->db->query($q);
     $ret = true ; 

     if (dB::isError($res) ) {
        $log->log("ERROR IN QUERY $q");
        $log->log("MEssage = " . $res->getMessage()) ; 
        $ret = false;
        $error = "Failed to create conference " . $res->getMessage() ; 
     }  else { 
        $q = "SELECT LAST_INSERT_ID() " ; 
        $res = $this->db->query($q) ; 
        $row = $res->fetchRow();
        $this->conferenceId = $row[0] ;
        $res->free(); 
     } 

     $log->log("insert is $q");  

     change_to_default_db($this->db);

     return $ret;    
  } 
  function sendNotifyCancel() { 
      ///
    global $log ; 
    if ($this->conferenceId){ 
      $q = "select invitee_email, invitee_name FROM invitees WHERE conference_id = " . $this->conferenceId; 
      $log->log("q = $q") ; 
      // conference db
      change_to_conference_db($this->db);

      $res=$this->db->query($q);

      while ($row = $res->fetchRow(DB_FETCHMODE_ASSOC)) { 
        if ($row[invitee_email]) { 
          $email_body = "Aloha $row[invitee_name], \n"
          . "   The conference '" . $this->conferenceName . "' has been cancelled by " . $this->ownerName . "\n"
          . '   Conference Date: '. $this->conferenceDateFormatted  . "\n"
          . '   Start Time : '. $this->beginTimeFormatted . " Hawaiian Standard Time\n"
          . "\n";
          $log->log("email_body $email_body"); 
          mail($row[invitee_email] , "Cancellation of " . $this->conferenceName,  $email_body,
             "From: kelepona@{$_SERVER['SERVER_NAME']}\r\n" .
             "X-Mailer: PHP/" . phpversion());
        } else {
          $log->log("$row[invitee_name] has no e-mail");
        } 
  
      } 
     $res->free();
     change_to_default_db($this->db);
       
    }
     return ;
  } 
  function cancel() {
     global $log ; 
     if ($this->conferenceId)  { 
       change_to_conference_db($this->db);

       $q1 = "DELETE FROM invitees WHERE conference_id = " . $this->conferenceId ; 
       $q2 = "DELETE FROM conferences WHERE conference_id = " . $this->conferenceId ; 
       $res=$this->db->query($q1);
       if (dB::isError($res) ) {
          $log->log("error running q1 $q1"); 
       } 
       $res=$this->db->query($q2);
       if (dB::isError($res) ) {
          $log->log("error running q2 $q2"); 
       } 

       change_to_default_db($this->db);
   
     } 

  } 


}

?>
