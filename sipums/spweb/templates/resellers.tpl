<tr>
<td><img src="images/trans.gif" width="1" height="1"></td>
<td>
        <table border="1" bordercolor="#cccccc" cellpadding="0" cellspacing="0" width="100%" class="main">
        <tr>
        <td align="center" valign="top">
<!-- Required Indent -->


  <table border="0" cellpadding="2" cellspacing="0" width="100%" class="MTable">
      <tr bgcolor="#cccccc" style="cursor:default;">
        <th align="left">Reseller Client Id</td>
        <th align="left">Company Name</td>
        <th align="left">Number of Customers</td>
      </tr>
   <!--{foreach name=reseller item=reseller from=$resellers}-->
      <tr onmouseover="this.style.backgroundColor='#C7D5EB';" onmouseout="this.style.backgroundColor='';"  style="cursor:default;">
        <td nowrap="nowrap">
             <span style="overflow:hidden;text-overflow:ellipsis;">
              <!--{$reseller.client_id}-->
             </span>
        </td>
        <td nowrap="nowrap">
             <span style="overflow:hidden;text-overflow:ellipsis;">
              <!--{$reseller.client_name}-->
             </span>
        </td>
        <td nowrap="nowrap">
            <!--{$reseller.client_count}--> 
            </span>
        </td>
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

