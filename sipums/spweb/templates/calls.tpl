<tr>
<td><img src="images/trans.gif" width="1" height="1"></td>
<td>
        <table border="1" bordercolor="#cccccc" cellpadding="0" cellspacing="0" width="100%" class="main">
        <tr>
        <td align="center" valign="top">
        <table>
        <TR>
           <TH>CALL TYPE</TH>
            <TH>DATE</TH>
            <TH>START</TH>
            <TH>END</TH>
            <TH>NUMBER</TH>
            <TH>ACCOUNT</TH>
            <TH>DURATION</TH>
            <TH>COST</TH>
            </tr>
        <!--{ foreach item=smdr from=$smdr_records}-->
          <TR>
           <TD><!--{$smdr.call_type}--></TD>
           <TD><!--{$smdr.date}--></TD>
           <TD><!--{$smdr.state_time}--></TD>
           <TD><!--{$smdr.end_time}--></TD>
           <TD><!--{$smdr.number}--></TD>
           <TD><!--{$smdr.account}--></TD>
           <TD><!--{$smdr.duration}--></TD>
           <TD align=right>$<!--{$smdr.cost}--></TD>
          </tr>
        <!--{/foreach}-->

       </table>

        </td>
        </tr>
        </table>
</td>
<td><img src="images/trans.gif" width="1" height="1"></td>
</tr>
                                                                                                                                               

