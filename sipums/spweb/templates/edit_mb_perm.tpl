<tr>
<td><img src="images/trans.gif" width="1" height="1"></td>
<td>
        <table border="1" bordercolor="#cccccc" cellpadding="0" cellspacing="0" width="100%" class="main">
        <tr>
        <td align="center" valign="top">
<!-- Required Indent -->

<form name=''  method='POST' action='' target='_self' >   
<INPUT type='hidden' name='func' value='<!--{$func}-->'>
<INPUT type='hidden' name='ext' value="<!--{$ext}-->">
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
        <td align="right">Extension:</td>
        <td align="left"><B><!--{$extension}--></b></td>
      </tr>
      <tr  style="cursor:default;">
        <td align="right">Permission:</td>
        <td align="left"><select name=perm>
	<!--{html_options values=$perm_options output=$perm_options selected=$perm}-->
         </select></td>
      </tr>
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

