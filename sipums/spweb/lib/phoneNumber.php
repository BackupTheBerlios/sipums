<?
class PhoneNumber { 

  var $number;
  var $longDistanceFlag;

  function PhoneNumber($pNumber) {
    $this->number = $pNumber;
    $this->strip();
    $this->valid(); 
  } 


  function strip() {
     $num = str_replace("-","",$this->number);
     $this->number=$num;
  }

  function  valid() { 
    $ret=0;
    if (strlen($this->number) == 7) {
       $ret=1;
    } elseif (strlen($this->number) == 10) {
       $this->longDistanceFlag=1; 
       $ret= 1;
    } 
    do_debug("numb = $this->number ret=$ret");
    return $ret;
  }
  function isLongDistance() {
    return $this->longDistanceFlag ; 
  } 

}
?>
