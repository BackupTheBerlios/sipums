<tr>
<td><img src="images/trans.gif" width="1" height="1"></td>
<td>
        <table border="1" bordercolor="#cccccc" cellpadding="0" cellspacing="0" width="100%" class="main">
        <tr>
        <td align="center" valign="top">
<!-- Required Indent -->

<form name=''  method='POST' action='' target='_self' onsubmit="return form_Validator(this)">   
<INPUT type='hidden' name='func' value='<!--{$func}-->'>
<INPUT type='hidden' name='ext' value="<!--{$ext}-->">
  <table border="0" cellpadding="2" cellspacing="0" class="MTable">
      <!--{if $msg}--> 
      <tr  style="cursor:default;">

        <td align="center" colspan=2><font style="color: red"><!--{$msg}--></font></td>
      </tr>
      <!--{/if}--> 
      <tr  style="cursor:default;">
        <td align="right">Extension:</td>
        <td align="left"><!--{$extension}--></td>
      </tr>
      <!--{if $no_require_old_password}-->
      <tr  style="cursor:default;">
        <td align="right">Old Password:</td>
        <td align="left"><INPUT NAME='old_password'></td>
      </tr>
      <!--{/if}-->
      <tr  style="cursor:default;">
        <td align="right">New Password:</td>
        <td align="left"><INPUT NAME='new_password'></td>
      </tr>
      <tr  style="cursor:default;">
        <td align="right">Re-type New Password:</td>
        <td align="left"><INPUT NAME='new_password_re' ></td>
      </tr>
      <TR>
        <td align='center' colspan=2><INPUT TYPE=submit value='Apply'></td> 
      </TR>

  </table>
</FORM>

<!-- Required Indent -->
                                                                                                                                               
        </td>
        </tr>
        </table>
</td>
<td><img src="images/trans.gif" width="1" height="1"></td>
</tr>

