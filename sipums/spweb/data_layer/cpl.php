<?

class spCpl { 

  var $uname, $udomain,$call_setting;

  /**************************** 
  ** function spCpl
  **  constructuor
  ****************************/
  function spCpl($pNumber, $pDomain) {
    $this->uname = $pNumber;
    $this->udomain = $pDomain;
  } 

  /**************************** 
  ** function get_dnd_xml
  **  Parameters: uname, domain
  **  Returns CPL xml for setting a number to forward to voiceimail
  **
  *****************************/
  function _get_dnd_xml () { 
  
    $xmlstr = <<<XML
<?xml version="1.0" encoding="UTF-8"?>
<!-- (call_setting=dnd) --> 
 
<!DOCTYPE cpl PUBLIC '-//IETF//DTD RFCxxxx CPL 1.0//EN' 'cpl.dtd'>
<cpl>
  <incoming>
    <location url="sip:ivr+$this->uname@$this->udomain">
      <proxy />
    </location>
  </incoming>
</cpl>
XML;
    return $xmlstr ; 
  }

  function _get_forward_xml($forward_number)  { 
  
  $xmlstr = <<<XML
<?xml version="1.0" encoding="UTF-8"?>
<!-- (call_setting=fwd) -->
 
<!DOCTYPE cpl PUBLIC '-//IETF//DTD RFCxxxx CPL 1.0//EN' 'cpl.dtd'>
<cpl>
  <subaction id="voicemail">
    <location url="sip:ivr+$this->uname@$this->udomain">
      <proxy />
    </location>
  </subaction>
  <incoming>
    <location url="sip:$forward_number@$this->udomain">
      <proxy>
        <failure />
        <default>
          <sub ref="voicemail" />
        </default>
      </proxy>
    </location>
  </incoming>
</cpl>
XML;
    return $xmlstr ; 
 
  }
  function _get_ring_both_xml($rb_number)  {
      $xmlstr = <<<XML

<?xml version="1.0" encoding="UTF-8"?>
<!-- (call_setting=rb) -->
 
<!DOCTYPE cpl PUBLIC '-//IETF//DTD RFCxxxx CPL 1.0//EN' 'cpl.dtd'>
<cpl>
  <subaction id="voicemail">
    <location url="sip:ivr+$this->uname@$this->udomain" clear="yes">
      <proxy />
    </location>
  </subaction>
  <subaction id="defaultproxy">
    <proxy>
      <failure />
      <default>
        <sub ref="voicemail" />
      </default>
    </proxy>
  </subaction>
  <incoming>
    <location url="sip:$rb_number@$this->udomain" priority="0.0">
      <lookup source="registration">
        <success>
          <sub ref="defaultproxy" />
        </success>
        <notfound>
          <sub ref="defaultproxy" />
        </notfound>
        <failure>
          <sub ref="defaultproxy" />
        </failure>
      </lookup>
    </location>
  </incoming>
</cpl>
XML;
   return $xmlstr ; 

  }
  function _get_find_me_follow_me_xml($fmfm_number) {
     global $log; 
    ///   $log->log("_get_find_me_follow_me_xml $this->uname, $this->udomain $rb_number");

      $xmlstr = <<<XML
<?xml version="1.0" encoding="UTF-8"?>
<!-- (call_setting=fmfm) -->
 
<!DOCTYPE cpl PUBLIC '-//IETF//DTD RFCxxxx CPL 1.0//EN' 'cpl.dtd'>
<CPL>
  <subaction id="voicemail">
    <location url="sip:ivr+$this->uname@$this->udomain" clear="yes">
      <proxy />
    </location>
  </subaction>
  <subaction id="defaultproxy">
    <proxy>
      <failure />
      <default>
        <location url="sip:$fmfm_number@$this->udomain" clear="yes">
          <proxy>
            <failure />
            <default>
              <sub ref="voicemail" />
            </default>
          </proxy>
        </location>
      </default>
    </proxy>
  </subaction>
  <incoming>
    <lookup source="registration">
      <success>
        <sub ref="defaultproxy" />
      </success>
      <notfound>
        <sub ref="defaultproxy" />
      </notfound>
      <failure>
        <sub ref="defaultproxy" />
      </failure>
    </lookup>
  </incoming>
</cpl>
XML;
   return $xmlstr ; 
  
  } 
  
  function set_dnd() {
    global $log; 
    $xml = $this->_get_dnd_xml($this->uname, $this->udomain); 
    ///      $log->log("set_dnd xm $xml");
    return $this->_load_cpl($xml);

  }

  /**************************** 
  ** function set_forward
  **  RETURNS:  Set this user to forward
  **  DESCRIPTION: This funciton sets user's phone to forward to the given number the cpl throught the fifo
  *****************************/
  function set_forward($forward_number){
    global $log; 
    $xml = $this->_get_forward_xml($forward_number); 
    ///      $log->log("set_forward xml $xml");
    return $this->_load_cpl($xml);
  }
  /****************************
  ** function set_find_me_follow_me
  **  RETURNS:  Set this user to find me follow me
  **  DESCRIPTION: This funciton sets user's phone to find me follow me
  *****************************/
  function set_find_me_follow_me($fmfm_number){
    global $log; 
    $xml = $this->_get_find_me_follow_me_xml($fmfm_number);
    ///      $log->log("set_find_me_follow_me xml $xml");
    return $this->_load_cpl($xml);
  }

  
  /****************************
  ** function set_ring_both
  **  DESCRIPTION::  Set this user to ring both his regular number and the number
  *****************************/

  function set_ring_both($rb_number){
    global $log;
    $xml = $this->_get_ring_both_xml($rb_number);
    $log->log("set_ring_both xml $xml");
    return $this->_load_cpl($xml);
  }

  /**************************** 
  ** function _load_cpl
  **  RETURNS: Status: Error from fifo loader
  **  DESCRIPTION: This private funciton loads the cpl throught the fifo
  *****************************/
  function _load_cpl($xml) {
     
    global $log;
    $tmpfilename="cpl_".rand() . ".xml";
    $tmppath="/tmp/".$tmpfilename;
    $CPL_FILE=fopen($tmppath,"w");
    fwrite($CPL_FILE,$xml);
    fclose($CPL_FILE);
          $log->log("wrote to $tmppath");

    global $config; 
    $fifo_cmd=":LOAD_CPL:" . $config->reply_fifo_filename ."\n$this->uname@$this->udomain\n$tmppath\n\n";
          $log->log("writing to fifo:--\n$fifo_cmd---");

    write2fifo($fifo_cmd, $errors, $status);
    @unlink($tmppath); 
    $log->log("wrote to fifo  $status:$error");

    if (preg_match("/OK/", $status)) { 
      return true ;
    } else { 
      return false ;
    } 
  } 
  function _cpl_get() {
    global $config,$log; 
    if (!$this->uname || !$this->udomain) { 
        return ;
    }  
    $fifo_cmd=":GET_CPL:" . $config->reply_fifo_filename .  "\n$this->uname@$this->udomain\n\n";
    $log->log("writing to fifo:--\n$fifo_cmd---\n");

    $data = write2fifo($fifo_cmd, $errors, $status);

    $log->log("wrote to fifo $status:$error\n");
    $log->log("data = $data\n ");
    
    return "$data";
  }
  function get_cpl() {
    global $log; 
    $xml = $this->_cpl_get();
    // $log->log("getting call setting $xml ");
    $this->call_setting = $this->get_call_setting($xml);
    if ($this->call_setting == 'fwd') {
       $this->get_forward_number($xml); 
    } elseif ($this->call_setting == 'rb') {
       $this->get_rb_number($xml); 
    }  elseif ($this->call_setting == 'fmfm') {
       $this->get_fmfm_number($xml); 
    } 
  }  
   function get_fmfm_number($xml) {
                                                                                                                                               
    $p = xml_parser_create();
    xml_parse_into_struct($p, $xml, $values, $tags);
    xml_parser_free($p);
    $fmfm_number ;
    foreach ($values as $key=>$val) {
      $isloc=0;
      foreach ($val as $key2=>$val2) {
         if ($key2 =="tag" && $val2 == "LOCATION"){
            $isloc =1;
            $fmfm_number =$val[attributes][URL];
            if (preg_match('/ivr/',$fmfm_number)) {
               $fmfm_number="";
            }  else {
               break ;
            }

             break ;
         }
      }
      if ($fmfm_number) break ;
                                                                                                                                               
    }
    $fmfm_number = str_replace ("sip:","",$fmfm_number);
    $pos = strpos($fmfm_number,'@');
    $fmfm_number = substr($fmfm_number,0,$pos);
    $this->fmfm_number= $fmfm_number ;
  }

  

  function get_rb_number($xml) {
      
    $p = xml_parser_create();
    xml_parse_into_struct($p, $xml, $values, $tags);
    xml_parser_free($p);
    $rb_number ; 
    foreach ($values as $key=>$val) {
      $isloc=0;
      foreach ($val as $key2=>$val2) {
         if ($key2 =="tag" && $val2 == "LOCATION"){
            $isloc =1;    
            $rb_number =$val[attributes][URL]; 
             break ; 
         } 
      }
      if ($rb_number) break ; 

    } 
    $rb_number = str_replace ("sip:","",$rb_number); 
    $pos = strpos($rb_number,'@');
    $rb_number = substr($rb_number,0,$pos); 
    $this->ring_both_number= $rb_number ; 
  } 

  function get_forward_number($xml) {
      
    $simple = "<para><note>simple note</note></para>";
    $p = xml_parser_create();
    xml_parse_into_struct($p, $xml, $values, $tags);
    xml_parser_free($p);
    $fwd_number ; 
    foreach ($values as $key=>$val) {
      $isloc=0;
      foreach ($val as $key2=>$val2) {
         if ($key2 =="tag" && $val2 == "LOCATION"){
            $isloc =1;    
             
            $fwd_number =$val[attributes][URL]; 
            if (preg_match('/ivr/',$fwd_number)) { 
               $fwd_number="";
            }  else { 
               break ; 
            }
             
         } 
      }
      if ($fwd_number) break ; 

    } 
    $fwd_number = str_replace ("sip:","",$fwd_number); 
    $pos = strpos($fwd_number,'@');
    $fwd_number = substr($fwd_number,0,$pos); 
    $this->forward_number = $fwd_number ; 
  } 

  function get_call_setting ($xml) {
    global $log; 
    $str = 'call_setting='; 
    if (!$xml) { 
       return "default";
    }
    // $log->log( "xml $xml ");
    $data = strstr($xml, 'call_setting=');
    // $log->log( "data =$data");
    if (!$data) return ;
    $func = str_replace($str,"", $data); 
    $func = str_replace($str,"", $data); 
    $i=0; 
    // $log->log( "substr=" . substr($func,$i,1)."\n");
    while (substr($func,$i,1) !=")" ) { 
       $log->log(substr($func,$i,1)); 
       $i++; 
    } 
    $func = substr($func,0,$i); 
    $log->log("func=$func" ); 
    return $func ; 
  } 

  function remove_cpl() {
    ## you never know if we may need another step 
     return $this->_remove_cpl(); 
  } 
  function _remove_cpl()  {
    global $log;  
    $log->log("call _remove_cpl");
                                                                                                                                               
    global $config, $log;
    $fifo_cmd=":REMOVE_CPL:" . $config->reply_fifo_filename ."\n$this->uname@$this->udomain\n\n";

    $log->log("writing to fifo:--\n$fifo_cmd--- ",LOG_DEBUG);

    write2fifo($fifo_cmd, $errors, $status);

    $log->log("wrote to fifo  $status:$error",LOG_DEBUG);
    if (preg_match("/OK/", $status)) {
      return true ;
    } else {
      return false ;
    }


  } 

}

?>
