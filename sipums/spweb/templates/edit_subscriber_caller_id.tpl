<tr>
<td><img src="images/trans.gif" width="1" height="1"></td>
<td>
        <table border="1" bordercolor="#cccccc" cellpadding="0" cellspacing="0" width="100%" class="main">
        <tr>
        <td align="center" valign="top">
<!-- Required Indent -->

<form name=''  method='POST' action='' target='_self' onsubmit="return form_Validator(this)">   
<INPUT type='hidden' name='func' value='<!--{$func}-->'>
<INPUT type='hidden' name='edit_user' value="<!--{$edit_user}-->">
<INPUT type='hidden' name='edit_uname' value="<!--{$edit_uname}-->">
<INPUT type='hidden' name='edit_udomain' value="<!--{$edit_udomain}-->">
<center>
<table border="0" cellpadding="2" cellspacing="0" width="100%" class="MTable">
  <tr>
  <td>
  <center>
    <table border="1"  cellpadding="2" cellspacing="0" class="FTable">
      <tr  bgcolor="#cccccc" style="cursor:default;">
        <th align="center" colspan=2><font size="+1">Edit Caller Id Settings</font></td>
      </tr>
      <!--{if $msg}--> 
      <tr  style="cursor:default;">
        <td align="center" colspan=2><font style="color: red"><!--{$msg}--></font></td>
      </tr>
      <!--{/if}--> 
      <tr  style="cursor:default;">
        <td align="right">User:</td>
        <td align="left"><INPUT name='user' value='<!--{$edit_uname}-->'></td>
      </tr>
      <tr  style="cursor:default;">
        <td align="right">Domain:</td>
        <td align="left"><INPUT name='user' value='<!--{$edit_udomain}-->'></td>
      </tr>
      <tr  style="cursor:default;">
        <td align="right">Setting:</td>
        <td align="left"><select name=caller_id_setting>
	<!--{html_options options=$setting_options selected=$caller_id_setting}-->
         </select></td>
      </tr>
   <!--
      <TR>
        <td align='center' colspan=2><INPUT TYPE=checkbox name='apply_to_all' value=1> Check here to apply the same setting to all users in this domain</td> 
      </TR>
   --> 
      <TR>

        <td align='center' colspan=2><INPUT TYPE=submit value='Apply'></td> 
      </TR>
     </table>
    </td>
   </tr>
  </table>
</center>
</FORM>

<!-- Required Indent -->
                                                                                                                                               
        </td>
        </tr>
        </table>
</td>
<td><img src="images/trans.gif" width="1" height="1"></td>
</tr>

