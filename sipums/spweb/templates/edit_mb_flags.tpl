<tr>
<td><img src="images/trans.gif" width="1" height="1"></td>
<td>
        <table border="1" bordercolor="#cccccc" cellpadding="0" cellspacing="0" width="100%" class="main">
        <tr>
        <td align="center" valign="top">
<!-- Required Indent -->

<form name=''  method='POST' action='' target='_self' onsubmit="return form_Validator(this)">   
<INPUT type='hidden' name='func' value='<!--{$func}-->'>
<INPUT type='hidden' name='ext' value="<!--{$ext}-->">
 <table border=0>
  <!--{if $vm_flags_msgs}-->
  <TR>
    <TD align=center><font style="color: red">
     <!--{foreach from=$vm_flags_msg item=msg}-->
         <!--{$msg}--><BR>
     <!--{/foreach}-->
      </font></td>
  </tr>
  <!--{/if}-->
                                                                                                                                               
  <tr>
     <Td colspan=2>
      <TABLE border=0> <tr>
         <Td>Active </Td>
         <TD><select name='active'>
            <option value='1' <!--{if $active eq "1"}-->SELECTED<!--{/if}-->  >Yes</option>
            <option value='0' <!--{if $active eq "0"}-->SELECTED<!--{/if}-->  >No</option>
          </select>
                                                                                                                                               
         </TD>
          <TD>Transfer</Td> <TD><select name='transfer'>
              <option value='1'  <!--{if $transfer eq "1"}-->SELECTED<!--{/if}--> >Yes</option>
              <option value='0'  <!--{if $transfer eq "0"}-->SELECTED<!--{/if}--> >No</option>
            </select>
          </TD>
      </tr><tr>
         <Td>Light MWI</Td>
                                                                                                                                               
         <TD><select name='mwi_flag'>
            <option value='1'  <!--{if $mwi_flag eq "1"}-->SELECTED<!--{/if}--> >Yes</option>
            <option value='0'  <!--{if $mwi_flag eq "0"}-->SELECTED<!--{/if}--> >No</option>
            </select>
         </TD>
         <Td>New User?</b></Td>
           <TD><select name='new_user_flag'>
              <option value='1'  <!--{if $new_user_flag eq "1"}-->SELECTED<!--{/if}--> >Yes</option>
                                                                                                                                               
              <option value='0'  <!--{if $new_user_flag eq "0"}-->SELECTED<!--{/if}--> >No</option>
              </select>
         </TD>
      </tr>
     </TABLE>
     </td></tr>
  <tr>
     <td align='center'> <INPUT TYPE=submit value='Apply'></td>
  </tr>
  </table>

</FORM>

<!-- Required Indent -->
                                                                                                                                               
        </td>
        </tr>
        </table>
</td>
<td><img src="images/trans.gif" width="1" height="1"></td>
</tr>

