<tr>
<td><img src="images/trans.gif" width="1" height="1"></td>
<td>
        <table border="1" bordercolor="#cccccc" cellpadding="0" cellspacing="0" width="100%" class="main">
        <tr>
        <td align="center" valign="top">
           
          <form name='me'  method='POST' action='' target='_self' >
            <input type='hidden' name='edit_invitee' value='1'>
            <input type='hidden' name='conference_id' value='<!--{$conference_id}-->' >
            <input type='hidden' name='invitee_id' value='<!--{$invitee_id}-->' >

          <table border=1 cellpadding="2" cellspacing="0"> 
          <TR><TD bgcolor="#EEEEEE" align=center>    

            <TABLE>  
            <TR><TD align=center colspan=2><a href='cdetails.php?conference_id=<!--{$conference_id}-->'>Return to Conference Details</a></b></td></tr>
            <TR>
                <TD colspan=2 align=center><font style="color: red">
                 <!--{foreach from=$msgs item=msg}-->
                   <!--{$msg}--><BR>
                 <!--{/foreach}-->
                 </font></td>
            </tr>
            <TR><TD align=center colspan=2><B>Change Invitee Info</b></td></tr>
            </tr>
            <tr>
                <td>Invitee Name</td> 
                <td><Input name='invitee_name' value='<!--{$invitee_name}-->' > </td> 
            </tr>
            <tr>
                <td>Invitee E-mail</td> 
                <td><Input name='invitee_email' value='<!--{$invitee_email}-->'> </td> 
            </tr>
            <TR>
                 <td align='center' colspan=2><INPUT TYPE=submit value='Save Changes'></td>
            </TR>
            </form>
            </table>
          </td></tr>
          <TR><TD align=center>    

            <TABLE>  

            <form action='resend_email.php' method='GET'>
            <input type='hidden' name='conference_id' value='<!--{$conference_id}-->' >
            <input type='hidden' name='invitee_id' value='<!--{$invitee_id}-->' >
            <TR><TD align=center ><BR></td></tr>

            <TR><TD align=center ><B>Resend Invite E-mail</b></td></tr>
            <TR>
                 <td align='center' colspan=2><INPUT TYPE=submit value='Click to Re-Send E-mail'><BR><BR></td>
            </TR>
            <TR><TD align=center ><BR></td></tr>
            </form>
            </table>
          </td></tr>
          <TR><TD bgcolor="#EEEEEE">    
            <TABLE>  
            
            <form name='me'  method='POST' action='' target='_self' >
            <input type='hidden' name='uninvite' value='1' >
            <input type='hidden' name='conference_id' value='<!--{$conference_id}-->' >
            <input type='hidden' name='invitee_id' value='<!--{$invitee_id}-->' >

            <TR><TD align=center ><BR></td></tr>
            <TR><TD align=center ><B>Uninvite Invitee (this may be construed as rude)</b></td></tr>
            <TR><TD align=center >
                <input type='checkbox' name='notifyUninvite' value=1' CHECKED> Notify user they have been uninviteed.</b>
                </td></tr>
            <TR>
                 <td align='center' ><INPUT TYPE=submit value='Click to Uninvite Invitee'><BR></td>
            </TR>
            <TR><TD align=center ><BR></td></tr>
            <TR><TD align=center ><a href='cdetails.php?conference_id=<!--{$conference_id}-->'>Return to Conference Details</a></b></td></tr>

           </form>
            </table>
          </td></tr>
          </table>
         

        </td>
        </tr>
        </table>
</td>
<td><img src="images/trans.gif" width="1" height="1"></td>
</tr>
                                                                                                                                               

