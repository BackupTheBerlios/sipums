<tr>
<td><img src="images/trans.gif" width="1" height="1"></td>
<td>
        <table border="0" bordercolor="#cccccc" cellpadding="0" cellspacing="0" width="100%" class="main">
        <tr>
        <td align="left" valign="top">

<CENTER>
<TABLE  border="0" cellpadding="2" cellspacing="0" width="100%" class="MTable"   >  
<!--{if $mailbox_msg}-->
<TR>
  <TD colspan=15 align=center> 
    <font style="color: red"><!--{$mailbox_msg}--> </font>
  </td>
</tr>
<!--{/if}-->
<TR bgcolor="#cccccc"  style="cursor:default;">
   <Th>Ext</Th>
   <Th>DID</Th>
   <Th>Name</Th>
   <Th>Email</Th>
   <Th>Email UserName</Th>
   <Th>Storage</Th>
   <Th>ACT</Th>
   <Th>XFER</Th>
   <Th>MWI</Th>
   <Th>NU</Th>
   <Th>AL</Th>
   <Th>ANM</Th>
   <Th>Permission</Th>
   <Th>&nbsp;</Th>
   <Th>&nbsp;</Th>
   <Th>&nbsp;</Th>
</tr>
<!--{foreach from=$mailboxes item=mb}-->
<TR>
   <Td><!--{$mb.extension}--></Td>
   <Td><a href='account.php?gfunc=change_edit_user&edit_user=<!--{$mb.user}-->'><!--{$mb.did|default:"&nbsp;"}--></a> </Td>
   <Td><!--{if $mb.last_name}--><!--{$mb.last_name}-->, <!--{/if}--><!--{$mb.first_name}-->
       <!--{if !$mb.last_name && !$mb.last_name}-->&nbsp;<!--{/if}--> </Td>
   <Td><!--{$mb.email_address|default:"&nbsp;"}--> </Td>
   <Td><!--{$mb.email_user_name|default:"&nbsp;"}--> </Td>
   <TD><!--{$mb.store_flag}--> - <!--{$mb.email_delivery}--><!--{$mb.vstore_email}--></td>
   <Td><!--{if $mb.active}-->Y<!--{else}-->N<!--{/if}--></Td>
   <Td><!--{if $mb.transfer}-->Y<!--{else}-->N<!--{/if}--></Td>
   <Td><!--{if $mb.mwi_flag}-->Y<!--{else}-->N<!--{/if}--></Td>
   <Td><!--{if $mb.new_user_flag}-->Y<!--{else}-->N<!--{/if}--></Td>
   <Td><!--{if $mb.auto_login_flag}-->Y<!--{else}-->N<!--{/if}--></Td>
   <Td><!--{if $mb.auto_new_messages_flag}-->Y<!--{else}-->N<!--{/if}--></Td>
   <Td><a href="edit_mb.php?func=edit_perm&ext=<!--{$mb.extension}-->"><!--{$mb.permission_id}--></a></td>
   
   <Td><!--{if !$mb.user}--><a href='edit_mb.php?func=delete_mailbox&ext=<!--{$mb.extension}-->'>delete</a><!--{else}-->&nbsp;<!--{/if}--> </td>
   <Td><a href="edit_mb.php?func=change_password&ext=<!--{$mb.extension}-->">Reset Password</a></Td>
   <Td><a href="edit_mb.php?func=edit_flags&ext=<!--{$mb.extension}-->">Change Flags</a></Td>
</TR>
<!--{foreachelse}-->
<TR>
  <td>&nbsp;</td>
  <td>&nbsp;</td>
  <td colspan=8><center>No Stuff</center></td>
</TR>
<!--{/foreach}-->
</TABLE>
<TABLE> 
<TR><TH align=center colspan=2>To delete a mailbox, you must first remove it from the subscriber line.</tH></tr>

<TR><TH align=center colspan=2> Flags Legend</tH></tr>
<td valign=top align=right> Strorage: </td>
<td valign=top> V - Voicemail Store <BR>
     E - Email Store </td>
</tr><tr>
<td valign=top align=right> Email Store Flags: </td>
<td valign=top> I - Deliver and store in IMAP folder 'INBOX Voicemail'<BR>
     S - Deliver and store in Main Inbox</td>
</tr><tr>
<td valign=top align=right> Voicemail Store Flags: </td>
<td valign=top> N - No Email<BR>
     C - Send a copy of voicemail to Email<BR>
     S - Send a copy of voicemail to Email<BR> and delete from voicemail store</td>
</tr><tr>
<td valign=top align=right> Transfer (XFER) : </td>
<td valign=top> Y - Callers will be transfers to user's extension<BR>
     N - Callers will be sent directly to users voicemail</td>
</tr><tr>
<td valign=top align=right> Active (ACT) : </td>
<td valign=top> Y - User is Active<BR>
     N - User's Account has been disabled</td>
</tr><tr>
<td valign=top align=right> New User (NU) : </td>
<td valign=top> Y - User will be forced to complete the user <BR>setup tutorial next time they log in to <BR>their voicemail<BR>
     N - User is not a New User</td>
</tr><tr>
<td valign=top align=right> Message Waiting Light (MWI) : </td>
<td valign=top> Note: MWI only applies to users using voicemail store<BR>
     Y - Message waiting light will be lit for new messages<BR>
     N - No Message waiting light for this user</td>
</tr><tr>
<td valign=top align=right> Auto Login (AL) : </td>
<td valign=top> Y - User WILL NOT be prompted for password when logging in from their station<BR>
    N - User WILL prompted for password when logging in from their station<BR></td>
</tr><tr>
<td valign=top align=right> Auto New Messages (ANM) : </td>
<td valign=top> Y - User WILL be sent directly to their new messages when they login<BR>
    N - User will be played the intro and then the main menu<BR></td>
</tr>
                                                                                                                                               
                                                                                                                                               
</table>

</CENTER>

        </td>
        </tr>
        </table>
</td>
<td><img src="images/trans.gif" width="1" height="1"></td>
</tr>
                                                                                                                                               

