  <table border="0" cellpadding="2" cellspacing="0" width="100%" class="MTable">
    
      <tr bgcolor="#cccccc" style="cursor:default;">
        <th align="left">User</td>
        <th align="left">Domain</td>
        <th align="left">Name</td>
        <th align="left" >Email</td>
        <th align="left" >Permission</td>
      </tr>
   <!--{foreach name=subscibers item=subscriber from=$subscribers}-->
      <tr onmouseover="this.style.backgroundColor='#C7D5EB';" onmouseout="this.style.backgroundColor='';"  style="cursor:default;">
        <td nowrap="nowrap">
             <span style="overflow:hidden;text-overflow:ellipsis;">
              <!-- <a href="subscribers.php?domain="> --><!--{$subscriber.username}-->
             </span>
        </td>
        <td nowrap="nowrap">
             <span style="overflow:hidden;text-overflow:ellipsis;">

              <!--{$subscriber.domain}-->
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
