<?  

class Clients {
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
  function Clients(&$db,$username="",$domain="") { 
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
}

?>
