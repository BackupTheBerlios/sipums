<?
/*
 * $Id: edit_subscriber.php,v 1.16 2004/08/30 04:22:54 kenglish Exp $
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
}
