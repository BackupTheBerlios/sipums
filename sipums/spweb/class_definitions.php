<?
/*
 * $Id: class_definitions.php,v 1.1 2004/08/01 20:06:13 kenglish Exp $
 */

class Csub_not {
	var $uri, $desc;
	function Csub_not($uri, $desc){
		$this->uri=$uri;
		$this->desc=$desc;
	}
}

class CREG_list_item {
	var $reg, $label;
	function CREG_list_item($reg, $label){
		$this->reg=$reg;
		$this->label=$label;
	}
}

class Capplet_params {
	var $name, $value;
	function Capplet_params($name, $value){
		$this->name=$name;
		$this->value=$value;
	}
}

class Ctab{
	var $name, $page, $enabled;
	function Ctab($enabled, $name, $page){
		$this->name=$name;
		$this->page=$page;
		$this->enabled=$enabled;
	}
}


class Ccall_fw{
	var $action, $param1, $param2, $label;
	function Ccall_fw($action, $param1, $param2, $label){
		$this->action = $action;
		$this->param1 = $param1;
		$this->param2 = $param2;
		$this->label  = $label;
	}
	
	/*
		find object with $action, $param1, $param2 in $arr and return its label
	*/
	function get_label($arr, $action, $param1, $param2){
		if(is_array($arr)){
			foreach($arr as $row){
				if ($row->action == $action and
					$row->param1 == $param1 and
					$row->param2 == $param2)
					return $row->label;
			}
		}
		return $action.": ".$param1." ".$param2;
	}

	/*
		find object with $action, $param1, $param2 in $arr and return its key
	*/
	function get_key($arr, $action, $param1, $param2){
		if(is_array($arr)){
			foreach($arr as $key => $row){
				if ($row->action == $action and
					$row->param1 == $param1 and
					$row->param2 == $param2)
					return $key;
			}
		}
		return null;
	}

}

class Cconfig{
} 
 
?>
