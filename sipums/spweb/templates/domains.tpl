<tr>
<td><img src="images/trans.gif" width="1" height="1"></td>
<td>
        <table border="1" bordercolor="#cccccc" cellpadding="0" cellspacing="0" width="100%" class="main">
        <tr>
        <td align="center" valign="top">
<!-- Required Indent -->


  <table border="0" cellpadding="2" cellspacing="0" width="100%" class="MTable">
      <tr bgcolor="#cccccc" style="cursor:default;">
        <th align="left">Domain</td>
        <th align="left">Line Count</td>
        <th align="left">Voicemail DB </td>
        <th align="left">Company Name</td>
        <th align="left">Main Number</td>
        <th align="left" >&nbsp;</td>
      </tr>
   <!--{foreach name=domains item=domain from=$domains}-->
      <tr onmouseover="this.style.backgroundColor='#C7D5EB';" onmouseout="this.style.backgroundColor='';"  style="cursor:default;">
        <td nowrap="nowrap">
             <span style="overflow:hidden;text-overflow:ellipsis;">
              <a href="subscribers.php?domain=<!--{$domain.domain}-->&change_domain=1"><!--{$domain.domain}--></a>
             </span>
        </td>
        <td nowrap="nowrap">
             <span style="overflow:hidden;text-overflow:ellipsis;">
              <a href="subscribers.php?domain=<!--{$domain.domain}-->&change_domain=1"><!--{$domain.user_count}--></a>
             </span>
        </td>
        <td nowrap="nowrap">
            <span style="overflow:hidden;text-overflow:ellipsis;">
              <!--{if !$domain.voicemail_db}-->  
                     NO VOICEMAIL SETUP  
              <!--{/if}-->  
              <!--<a href="edit_domain.php?domain=<!--{$domain.domain}-->&change_domain=1">-->
              <!--{$domain.voicemail_db}--> <!--</a>-->
            </span>

        </td>
        <td nowrap="nowrap">
            <span style="overflow:hidden;text-overflow:ellipsis;">
              <!--{$domain.company_name}--> 
            </span>
        </td>
        <td nowrap="nowrap">
            <span style="overflow:hidden;text-overflow:ellipsis;">
              <!--{$domain.company_number}--> 
            </span>
        </td>
        <td nowrap="nowrap">&nbsp;</td>
      </TR>
   <!--{/foreach}-->
     
  </table>

<!-- Required Indent -->
                                                                                                                                               
        </td>
        </tr>
        </table>
</td>
<td><img src="images/trans.gif" width="1" height="1"></td>
</tr>

