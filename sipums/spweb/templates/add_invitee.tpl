<tr>
<td><img src="images/trans.gif" width="1" height="1"></td>
<td>
        <table border="1" bordercolor="#cccccc" cellpadding="0" cellspacing="0" width="100%" class="main">
        <tr>
        <td align="center" valign="top">
            <form name='me'  method='POST' action='' target='_self' >
            <INPUT TYPE='hidden' name='add_invitee' value=1>
            <INPUT TYPE='hidden' name='conference_id' value='<!--{$conference_id}-->'>

            <table cellpadding="2" cellspacing="0" class="MTable" > 
            <TR>
                <TD colspan=2 align=center><font style="color: red">
                 <!--{foreach from=$msgs item=msg}-->
                   <!--{$msg}--><BR>
                 <!--{/foreach}-->
                 </font></td>
            </tr>
            <TR>
            <Td colspan=2><i><input type='radio' name='invitee_flag' value='C' <!--{if $invitee_flag eq 'C'}-->CHECKED<!--{/if}--> >
                 Company invitee. </I></Td>
            </tr>
            <TR>
            <Td>Invitee</td>
            <Td><SELECT name='invitee_username'>
                <!--{html_options options=$invitee_users selected=$invitee_username}-->
                </select></td>
            </tr>

            <TR>
            <Td colspan=2><i><input type='radio' name='invitee_flag' value='O' <!--{if $invitee_flag eq 'O'}-->CHECKED<!--{/if}--> >
                 Outside Company invitee. </I></Td>
            </tr>
            <tr>
                <td>Invitee Name</td> 
                <td><Input name='invitee_name' value='<!--{$invitee_name}-->'> </td> 
            </tr>
            <tr>
                <td>Invitee E-mail</td> 
                <td><Input name='invitee_email' value='<!--{$invitee_email}-->'> </td> 
            </tr>
            <TR>
                 <td align='center' colspan=2><INPUT TYPE=submit value='Add'></td>
             </TR>
            </table>
           </form>
        </td>
        </tr>
        </table>
</td>
<td><img src="images/trans.gif" width="1" height="1"></td>
</tr>
                                                                                                                                               

