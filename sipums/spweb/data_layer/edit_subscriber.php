<?
/*
 * $Id: edit_subscriber.php,v 1.15 2004/08/20 20:48:08 kenglish Exp $
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
