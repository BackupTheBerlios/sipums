<html>
<head>
<title>SERVPAC SIP 1.0</title>
	<meta http-equiv="Content-Type" content="text/html; charset=windows-1250">
	<meta http-equiv="PRAGMA" content="no-cache"> 
	<meta http-equiv="Cache-control" content="no-cache">
	<meta http-equiv="Expires" content="Thu, 17 Jun 2004 22:33:04 GMT"> 

	<LINK REL="StyleSheet" HREF="style/styles.css" TYPE="text/css">

<script language="javascript">
	//DO NOT REMOVE!!! TABLE STRUCTURE WILL BE ALTERED
</script>
</head>

 
	

<form name=''  method='POST' action='' target='_self'><table width="100%"><tr><td align="center">
	<table border="0" width="200" class="imain">
		<tr>
			<td align="center">
				<img src="images/centuryc-logo.png" alt="Century Logo" >
			</td>
		</tr>
            		<tr>

		<td align="left">
			<table align="center" border="0" width="100%" class="imain">
<!--				<tr>
					<td align="right" width="30%">
						Domain:
					</td>
					<td align="left" width="*">

<select name=udomain>
<!--{html_options values=$udomain_values selected=$udomain_selected output=$udomain_output}-->
</select>

					</td>
				</tr>
-->
				<tr>
					<td align="right" width="30%">
						Username:
					</td>
					<td align="left" width="*">
						<input name='ulogin' id='ulogin' value="" type='text' maxlength='50' size='20' >					</td>

				</tr>
				<tr>
					<td align="right">
						Password:
					</td>
					<td align="left" width="*">
						<input name='passw' id='passw' value="" type='password' maxlength='25' size='20'> </Td>
				</tr>
<!--				<tr>

					<td>
						&nbsp;
					</td>
					<td align="right" width="30%" nowrap>
						<input type="checkbox" name="remember">Remember me
					</td>

				</tr>
-->
			</table>
		</td>

	</tr>
	<tr>
		<td align="center">
                        <input type='hidden' name='do_login' value='1'>                        <input name='okey' value='Login' type='submit'>		</td>
	</tr>
<!--
	<tr>
		<td align="center">

			<table align="center" border="0" width="100%" class="imain">

				<tr>
					<td align="left" width="50%">
						<a href="/customer.php?action=newuser">New User?</a>
					<td align="right" width="50%">
						<a href="/customer.php?action=lostpass">Lost password?</a>
					</td>
				</tr>
			</table>

		</td>
	</tr>
-->
	</table>
</td></tr></table>
<input type='hidden' name='do_login' value='1'></form><script language='javascript'>
<!--
function form_Validator(f) {
if (f.elements[1].value.length < 1) {
  alert("you must fill username");
  f.elements[1].focus();
  return(false);
}
}
//-->
</script></script>
</html>
