<tr>
<td><img src="images/trans.gif" width="1" height="1"></td>
<td>
        <table border="1" bordercolor="#cccccc" cellpadding="0" cellspacing="0" width="100%" class="main">
        <tr>
        <td align="center" valign="top">
            <form name='me'  method='POST' action='' target='_self' >
            <INPUT TYPE='hidden' name='create_conference' value=1>
            <table cellpadding="2" cellspacing="0" class="MTable" > 
            <TR>
                <TD colspan=2 align=center><font style="color: red">
                 <!--{foreach from=$msgs item=msg}-->
                   <!--{$msg}--><BR>
                 <!--{/foreach}-->
                 </font></td>
            </tr>
            <tr>
                <td>Conference Owner </td> 
                <td><!--{$owner}--> </td> 
            </tr>
            <tr>
                <td>Owner Name</td> 
                <td><!--{$owner_name}--> </td> 
            <tr>
                <td>Conference Title </td> 
                <td><input type="text" name="conference_name" value="<!--{$conference_name}-->" size=30></Td>
                   
             </tr>
            <tr>
                <td>Conference Date </td> 
                <td><input type="text" name="conference_date" id="conference_date" value="<!--{$conference_date}-->" maxlength="10" size="10">
                   <a href="javascript:NewCal('conference_date','mmddyyyy')"><img src="images/cal.gif" width="16" height="16" border="0" alt="Pick a date"></a></td> 
             </tr>
             <TR>
                <td>Start Time:</td>
                <td><select name="begin_time">
                      <!--{html_options options=$times selected=$begin_time}-->
                    </select>
                </td>
             </TR>
             <TR>
                <td>End Time:</td>
                <td><select name="end_time">
                      <!--{html_options options=$times selected=$end_time}-->
                    </select>
                </td>
             </TR>
             <TR>
                 <td align='center' colspan=2><INPUT TYPE=submit value='Create Conference'></td>
             </TR>
            </table>
            </table>
   
           </form>
        </td>
        </tr>
        </table>
</td>
<td><img src="images/trans.gif" width="1" height="1"></td>
</tr>
                                                                                                                                               

