<html>
<head>
<title>SpWeb :: Servpac's VoIP Configuration Manager</title>
	<LINK REL="StyleSheet" HREF="style/styles.css" TYPE="text/css">

<script language="javascript">
	//DO NOT REMOVE!!! TABLE STRUCTURE WILL BE ALTERED
</script>
</head>
<body bgcolor="#ffffff" topmargin="0" leftmargin="0" marginwidth="0" marginheight="0">
<table border="0" cellpadding="0" cellspacing="0" width="100%">
<tr>
<td><img src="images/trans.gif" width="27" height="1"></td>
<td width="100%"><img src="images/trans.gif" width="716" height="1"></td>
<td><img src="images/trans.gif" width="27" height="1"></td>
</tr>

<tr>
<td><img src="images/trans.gif" width="1" height="1"></td>
<td>
	<table border="0" cellpadding="0" cellspacing="0" width="100%">
	<tr>
	<td><img src="images/phoneworld.jpg" border="0"></a></td>
	<td align="right"><a href="http://www.servpac.com/"><img src="images/servpac.png" border="0"></a></td>
	</tr>
	</table>
</td>
<td><img src="images/trans.gif" width="1" height="1"></td>

</tr>

<tr>
<td><img src="images/trans.gif" width="1" height="1"></td>
<td>
	<table border="1" bordercolor="#cccccc" cellpadding="6" cellspacing="0" width="100%" class="main">
	<tr>
        <!--{if $admin_domain}-->
	  <td align="center" nowrap <!--{if $thispage eq "domains.php"}--> bgcolor="#eeeeee" <!--{/if}-->><a href="domains.php">Domains</a></td>
        <!--{/if}-->
        <!--{if $admin_reseller}-->
	  <td align="center" nowrap <!--{if $thispage eq "resellers.php"}--> bgcolor="#eeeeee" <!--{/if}-->><a href="resellers.php">Resellers</a></td>
        <!--{/if}-->
        
        <!--{if $admin_subscribers}-->
	<td align="center" nowrap <!--{if $thispage eq "subscribers.php"}--> bgcolor="#eeeeee" <!--{/if}--> ><a href="subscribers.php">Lines</a></td>
	<td align="center" nowrap <!--{if $thispage eq "mailboxes.php"}--> bgcolor="#eeeeee" <!--{/if}--> ><a href="mailboxes.php">Mailboxes</a></td>

        <!--{/if}-->
	<td align="center" nowrap <!--{if $thispage eq "account.php"}--> bgcolor="#eeeeee" <!--{/if}-->><a href="account.php">Account Settings</a></td>
	<td align="center" nowrap <!--{if $thispage eq "calls.php"}--> bgcolor="#eeeeee" <!--{/if}-->><a href="calls.php">Call Logs</a></td>
        <!--{if $admin_voicemail}-->
	<td align="center" nowrap <!--{if $thispage eq "voicemail.php"}--> bgcolor="#eeeeee" <!--{/if}--> ><a href="voicemail.php">Voicemail</a></td>
        <!--{/if}-->
	<td align="right" nowrap><a href="conference.php">Kelepona Conference</a></td>
	<td align="right" nowrap><b><a href="signout.php">Sign Out</a></b></td>

	</tr>
	</table>
</td>
<td><img src="images/trans.gif" width="1" height="1"></td>
</tr>

<tr>
<td><img src="images/trans.gif" width="1" height="1"></td>
<td>
	<table border="0" cellpadding="0" cellspacing="0" width="100%">

	<tr><td colspan="3"><img src="images/trans.gif" width="1" height="7"></td></tr>

	<tr><td width="33%">
		<table border="0" cellpadding="0" cellspacing="0"><tr>
		<td><b>Domain:</b></td>
		<td>&nbsp;</td>
		<td>
                <!--{if $admin_domain}-->
		<form name="DomainSelectForm" action="<!--{$thispage}-->" method="post">
			<select class="main" name="domain" onchange="document.DomainSelectForm.submit();">
                        <!--{html_options values=$udomain_values selected=$udomain_selected output=$udomain_output}-->
			</select>
			<input type="hidden" name="change_domain" value="1">
                </form>
                <!--{else}-->
                  <!--{$udomain}-->
                <!--{/if}-->
		</td>
	</tr></table>
	<td width="34%" align="center" nowrap>
		<b>Logged in as: </b><!--{$uname}--></td>

	<td width="33%" nowrap>&nbsp;</td>
	</td></tr>

	<tr>
	<td colspan="3"><img src="images/trans.gif" width="1" height="8"></td>
	</tr>

	<tr>
	<td colspan="3" background="images/dash.gif"><img src="images/trans.gif" width="1" height="1"></td>
	</tr>

	<tr><td colspan="3"><img src="images/trans.gif" width="1" height="7"></td></tr>
		</table>
</td>
<td><img src="images/trans.gif" width="1" height="1"></td>
</tr>


<!-- start stuff here -->
