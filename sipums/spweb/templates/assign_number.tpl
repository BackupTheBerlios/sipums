<tr>
<td><img src="images/trans.gif" width="1" height="1"></td>
<td>
        <table border="1" bordercolor="#cccccc" cellpadding="0" cellspacing="0" width="100%" class="main">
        <tr>
        <td align="center" valign="top">
<!-- Required Indent -->

<form name='me'  method='POST' action='' target='_self'>   
<INPUT type='hidden' name='client_id' value="<!--{$client_id}-->">
<INPUT type='hidden' name='save_number' value="1-->">
<center>
<table border="0" cellpadding="2" cellspacing="0" width="100%" class="MTable">
  <tr>
  <td>
  <center>
    <table border="1"  cellpadding="2" cellspacing="0" class="FTable">
      <tr  bgcolor="#cccccc" style="cursor:default;">
        <th align="center" colspan=2><font size="+1">Assing Number to Client</font></td>
      </tr>
      <!--{if $msg}--> 
      <tr  style="cursor:default;">
        <td align="center" colspan=2><font style="color: red"><!--{$msg}--></font></td>
      </tr>
      <!--{/if}--> 
      <tr  style="cursor:default;">
        <td align="right">Client :</td>
        <td align="left"><B><!--{$client_id}-->: <!--{$client_name}-->: </b></td>
      </tr>
      <tr  style="cursor:default;">
        <td align="right">Phone Number:</td>
        <td align="left"><SELECT NAME='phone_number'>
	<!--{html_options values=$phone_numbers output=$phone_numbers  selected=$phone_number}-->
                         </SELECT></td>
      </tr>
      <TR>
        <td align='center' colspan=2><INPUT TYPE=submit value='Save'></td> 
      </TR>
      <TR>
        <td align='center' colspan=2><a href='clients.php'>Return to Clients</a></td> 
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

