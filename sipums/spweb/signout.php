<?

require "prepend.php";

page_open (array("sess" => "phplib_Session_Pre_Auth",
   "auth" => "phplib_Pre_Auth",
   "perm" => "phplib_Perm"));

do_debug("auth logout uname = " . $auth->auth["uname"] );

$sess->unregister("auth");
unset($auth->auth["uname"]);
$auth->unauth($nobody == "" ? $this->nobody : $nobody);

Header("Location: ".$sess->url("index.php"));
?>
