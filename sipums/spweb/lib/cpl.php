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
  
    //   do_debug("get_dnd_xml $this->uname, $this->udomain");
    $xmlstr = <<<XML
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE cpl PUBLIC '-//IETF//DTD RFCxxxx CPL 1.0//EN' 'cpl.dtd'>
<!-- (call_setting=dnd) -->
<cpl>
  <incoming>
    <location url="sip:voicemail+$this->uname@$this->udomain">
     <proxy /> </location>
  </incoming>
 </cpl>
XML;
    return $xmlstr ; 
  }

  function _get_forward_xml($forward_number)  { 
  
    ///      do_debug("_get_forward $this->uname, $this->udomain $forward_number");
  $xmlstr = <<<XML
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE cpl PUBLIC '-//IETF//DTD RFCxxxx CPL 1.0//EN' 'cpl.dtd'>
<!-- (call_setting=fwd) -->
<cpl> 
  <incoming> 
    <location url="sip:$forward_number@$this->udomain">
    <redirect /> </location> 
  </incoming>
</cpl>
XML;
    return $xmlstr ; 
 
  }
  function _get_ring_both_xml($rb_number)  {
    ///      do_debug("_get_ring_both_xml $this->uname, $this->udomain $rb_number");
      $xmlstr = <<<XML
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE cpl PUBLIC '-//IETF//DTD RFCxxxx CPL 1.0//EN' 'cpl.dtd'>
<!-- (call_setting=rb) -->
<cpl>
   <incoming>
     <location url="sip:$rb_number@$this->udomain" priority="0.0">
       <lookup source="registration"> 
         <success> <proxy /> </success>
         <notfound> <proxy /> </notfound> 
         <failure> <proxy /> </failure>
       </lookup> 
     </location> 
</incoming> </cpl>
XML;
   return $xmlstr ; 

  }
  function _get_find_me_follow_me_xml($fmfm_number) {
    ///      do_debug("_get_find_me_follow_me_xml $this->uname, $this->udomain $rb_number");

      $xmlstr = <<<XML
<?xml version="1.0" encoding="UTF-8"?>
                                                                                                                                               
<!DOCTYPE cpl PUBLIC '-//IETF//DTD RFCxxxx CPL 1.0//EN' 'cpl.dtd'>
<!-- (call_setting=fmfm) -->
                                                                                                                                               
<cpl>
  <subaction id="call-out">
    <location url="sip:$fmfm_number@$this->udomain" clear="yes">
      <proxy />
    </location>
  </subaction>
  <incoming>
    <lookup source="registration">
      <success>
        <proxy>
          <noanswer>
            <sub ref="call-out" />
          </noanswer>
          <default>
            <sub ref="call-out" />
          </default>
        </proxy>
      </success>
      <notfound>
        <sub ref="call-out" />
      </notfound>
      <failure />
    </lookup>
  </incoming>
</cpl>

XML;
   return $xmlstr ; 
  
  } 
  
  function set_dnd() {

    $xml = $this->_get_dnd_xml($this->uname, $this->udomain); 
    ///      do_debug("set_dnd xm $xml");
    return $this->_load_cpl($xml);

  }

  /**************************** 
  ** function set_forward
  **  RETURNS:  Set this user to forward
  **  DESCRIPTION: This funciton sets user's phone to forward to the given number the cpl throught the fifo
  *****************************/
  function set_forward($forward_number){
    $xml = $this->_get_forward_xml($forward_number); 
    ///      do_debug("set_forward xml $xml");
    return $this->_load_cpl($xml);
  }
  /****************************
  ** function set_find_me_follow_me
  **  RETURNS:  Set this user to find me follow me
  **  DESCRIPTION: This funciton sets user's phone to find me follow me
  *****************************/
  function set_find_me_follow_me($fmfm_number){
    $xml = $this->_get_find_me_follow_me_xml($fmfm_number);
    ///      do_debug("set_find_me_follow_me xml $xml");
    return $this->_load_cpl($xml);
  }

  
  /****************************
  ** function set_ring_both
  **  DESCRIPTION::  Set this user to ring both his regular number and the number
  *****************************/

  function set_ring_both($rb_number){
    $xml = $this->_get_ring_both_xml($rb_number);
    ///      do_debug("set_ring_both xml $xml");
    return $this->_load_cpl($xml);
  }

  /**************************** 
  ** function _load_cpl
  **  RETURNS: Status: Error from fifo loader
  **  DESCRIPTION: This private funciton loads the cpl throught the fifo
  *****************************/
  function _load_cpl($xml) {
     
    $tmpfilename="cpl_".rand() . ".xml";
    $tmppath="/tmp/".$tmpfilename;
    $CPL_FILE=fopen($tmppath,"w");
    fwrite($CPL_FILE,$xml);
    fclose($CPL_FILE);
          do_debug("wrote to $tmppath");

    global $config; 
    $fifo_cmd=":LOAD_CPL:" . $config->reply_fifo_filename ."\n$this->uname@$this->udomain\n$tmppath\n\n";
          do_debug("writing to fifo:--\n$fifo_cmd---");

    write2fifo($fifo_cmd, $errors, $status);
    @unlink($tmppath); 
          do_debug("wrote to fifo  $status:$error");

    return "$status";
  } 
  function _cpl_get() {
    global $config; 
    if (!$this->uname || !$this->udomain) { 
        return ;
    }  
    $fifo_cmd=":GET_CPL:" . $config->reply_fifo_filename .  "\n$this->uname@$this->udomain\n\n";
          do_debug("writing to fifo:--\n$fifo_cmd---\n");

    $data = write2fifo($fifo_cmd, $errors, $status);

    do_debug("wrote to fifo $status:$error\n");
    do_debug("data = $data\n ");
    
    return "$data";
  }
  function get_cpl() {
    $xml = $this->_cpl_get();
    // do_debug("getting call setting $xml ");
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
             break ; 
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
    $str = 'call_setting='; 
    if (!$xml) { 
       return "default";
    }
    // do_debug( "xml $xml ");
    $data = strstr($xml, 'call_setting=');
    // do_debug( "data =$data");
    if (!$data) return ;
    $func = str_replace($str,"", $data); 
    $func = str_replace($str,"", $data); 
    $i=0; 
    // do_debug( "substr=" . substr($func,$i,1)."\n");
    while (substr($func,$i,1) !=")" ) { 
       do_debug(substr($func,$i,1)); 
       $i++; 
    } 
    $func = substr($func,0,$i); 
    // do_debug("func=$func" ); 
    return $func ; 
  } 

  function remove_cpl() {
    ## you never know if we may need another step 
     return $this->_remove_cpl(); 
  } 
  function _remove_cpl()  {
    do_debug("call _remove_cpl");
                                                                                                                                               
    global $config;
    $fifo_cmd=":REMOVE_CPL:" . $config->reply_fifo_filename ."\n$this->uname@$this->udomain\n\n";
    do_debug("writing to fifo:--\n$fifo_cmd---");

    write2fifo($fifo_cmd, $errors, $status);
    do_debug("wrote to fifo  $status:$error");

  } 

}

?>
