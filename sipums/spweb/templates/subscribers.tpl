<tr>
<td><img src="images/trans.gif" width="1" height="1"></td>
<td>
        <table border="1" bordercolor="#cccccc" cellpadding="0" cellspacing="0" width="100%" class="main">
        <tr>
        <td align="center" valign="top">
<!-- Required Indent -->
  

<table border="0" cellpadding="2" cellspacing="0" width="100%" class="MTable">
    
      <tr bgcolor="#cccccc" style="cursor:default;">
        <th align="left">User</td>
        <th align="left">Domain</td>
        <th align="left" >Caller ID</td>
        <th align="left">Name</td>
        <th align="left">Voicemail Mailbox</td>
        <th align="left" >Email</td>
        <th align="left" >Permission</td>
      </tr>
   <!--{foreach name=subscibers item=subscriber from=$subscribers}-->
      <tr onmouseover="this.style.backgroundColor='#C7D5EB';" onmouseout="this.style.backgroundColor='';"  style="cursor:default;">
        <td nowrap="nowrap">
             <span style="overflow:hidden;text-overflow:ellipsis;">
               <a href="account.php?gfunc=change_edit_user&edit_user=<!--{$subscriber.username}-->@<!--{$subscriber.domain}-->"> <!--{$subscriber.username}--></a>
             </span>
        </td>
        <td nowrap="nowrap">
             <span style="overflow:hidden;text-overflow:ellipsis;">
              <!--{$subscriber.domain}-->
             </span>
        </td>
        <td nowrap="nowrap">
             <span style="overflow:hidden;text-overflow:ellipsis;">
              <!--{if $edit_caller_id}-->
                <a href="edit_subscriber.php?func=caller_id&edit_user=<!--{$subscriber.username}-->@<!--{$subscriber.domain}-->">
                 <!--{$subscriber.caller_id|default:"Set Caller Id"}-->
                </a>
              <!--{else}-->
                 <!--{$subscriber.caller_id|default:"&nbsp;"}-->
              <!--{/if}-->
                
      
              
              </a>
             </span>
        </td>
        <td nowrap="nowrap">
             <span style="overflow:hidden;text-overflow:ellipsis;">
              <!--{$subscriber.first_name}--> <!--{$subscriber.last_name}-->
              <!--{if !$subscriber.first_name && !$subscriber.last_name}-->
                   &nbsp;
              <!--{/if}-->
             </span>
        </td>
        <td nowrap="nowrap">
             <span style="overflow:hidden;text-overflow:ellipsis;">
              <!--{$subscriber.mailbox}--> 
              <!--{if !$subscriber.mailbox}-->
                   No Mailbox
              <!--{/if}-->
             </span>
        </td>

        <td nowrap="nowrap">
             <span style="overflow:hidden;text-overflow:ellipsis;">
              <!--{$subscriber.email_address}-->
              <!--{if !$subscriber.email_address}-->
                   &nbsp;
              <!--{/if}-->
             </span>
        </td>
        <td nowrap="nowrap">
             <span style="overflow:hidden;text-overflow:ellipsis;">
             <!--{$subscriber.perm}-->
             </span>
        </td>
      </tr>
   <!--{/foreach}-->
     
  </table>
<!-- Required Indent -->
        </td>
        </tr>
        </table>
</td>
<td><img src="images/trans.gif" width="1" height="1"></td>
</tr>

