
<!--{if $show_admin_row}-->
<!-- Adminstrators only row -->
<tr>
<td><img src="images/trans.gif" width="1" height="1"></td>
<td>
	<table border="0" cellpadding="0" cellspacing="0" width="100%">

	<tr><td colspan="3"><img src="images/trans.gif" width="1" height="7"></td></tr>

	<tr><td width="100%">
            
             <form name='UserSelectForm'  method='GET' action='<!--{$action}-->' target='_self' >
                <input type='hidden' name='gfunc' value='change_edit_user'> 
		<table border="0" cellpadding="0" cellspacing="0"><tr>
		<td><b>USER  :</b></td>
		<td>&nbsp;&nbsp;&nbsp;&nbsp;</td>
		<td><select name='edit_user'  onchange="document.UserSelectForm.submit();">
                   <!--{html_options values=$edit_users selected=$edit_user output=$edit_users}-->
                   </select>
               </td>
             </form>
	</tr></table>

	<tr>
	<td colspan="3"><img src="images/trans.gif" width="1" height="8"></td>
	</tr>

	<tr>
	<td colspan="3" background="images/dash.gif"><img src="images/trans.gif" width="1" height="1"></td>
	</tr>

	<tr><td colspan="3"><img src="images/trans.gif" width="1" height="7"></td></tr>

		</table>
</td>
<td><img src="images/trans.gif" width="1" height="1"></td>
</tr>

<!-- END ADMINSTRATOR only row -->
<!--{/if}-->
<!-- Required Indent -->
<tr>
<td><img src="images/trans.gif" width="1" height="1"></td>
<td>
        <table border="1" bordercolor="#cccccc" cellpadding="0" cellspacing="0" width="100%" class="main">
        <tr>
        <td align="center" valign="top">
<!-- Required Indent -->
                                                                                                                                               


<table border="0" cellpadding="0" cellspacing="0" width="100%">

<input type="hidden" name="prefs" value="1">
<input type="hidden" name="simple" value="1">
<tr><td>

<table border="1" bordercolor="#cccccc" cellpadding="8" cellspacing="0" width="100%" class="mainnb">
<tr>

<!-- A1 -->

<td bgcolor="#EEEEEE" width="55%" valign="top" onmouseover="this.className='highlightOn'" onmouseout="this.className='highlightOff'">
<b>Call Settings:</b><br/>Here you may modify how calls get routed.<br /><br /><center><table class="mainnb">

<form name=''  method='POST' action='' target='_self' onsubmit="return form_Validator(this)">
<input type='hidden' name='func' value='update_call_opts'> 
<TABLE>
<TR>
  <TH><BR></tH>
  <TH>
  Change Your Call Settings 
  </tH>

  <TR>
    <TD valign='top'>
     <input type='radio' name='call_opt' id='call_opt' value='default' <!--{if $call_opt eq "default"}-->CHECKED<!--{/if}--> > 
    </td>
    <TD align=left><B>DEFAULT</b>: Ring my desk, if I don't answer go to voicemail </td>
  </TR>
  <TR>
    <TD valign='top'>
     <input type='radio' name='call_opt' id='call_opt' value='dnd' <!--{if $call_opt eq "dnd"}-->CHECKED<!--{/if}--> > 
    </td>
    <TD align=left><B>DND</b>: All calls will be forwarded to voicemail</td>
  </TR>
  <TR>
    <TD valign='top'>
      <input type='radio' name='call_opt' id='call_opt' value='fwd' <!--{if $call_opt eq "fwd"}-->CHECKED<!--{/if}--> > 
    </td>
    <TD align=left><B>FWD</b>: Forward all calls to the following number: <BR>

      <input name='fwd_number' id='fwd_number' value="<!--{$fwd_number}-->" type='text' maxlength='128' size='20'>    </td>
  </TR>
  <TR>
    <TD valign='top'>
     <input type='radio' name='call_opt' id='call_opt' value='rb' <!--{if $call_opt eq "rb"}-->CHECKED<!--{/if}-->> 
    </td>
    <TD align=left><B>RB</b>: Ring both my desk number and the following number: <BR>
     <input name='rb_number' id='rb_number' value="<!--{$rb_number}-->" type='text' maxlength='128' size='20'>    </td>

  </TR>
  <TR>
    <TD valign='top'>
     <input type='radio' name='call_opt' id='call_opt' value='fmfm'  <!--{if $call_opt eq "fmfm"}-->CHECKED<!--{/if}--> > 
    </td>
    <TD align=left><B>FMFM</b>: Find Me Follow me, ring my desk number, if no answer ring the following number: <BR>
     <input name='fmfm_number' id='fmfm_number' value="<!--{$fmfm_number}-->" type='text' maxlength='128' size='20'>    </td>
  </TR>

  <TR>
    <TD colspan=2 valign='top' align=center>
      <input type="submit" value="Apply">
    </TD>
  </TR>
  </table>
  </form>
</td>
<!-- B1 -->
<td bgcolor="#EEEEEE"  valign="top" onmouseover="this.className='highlightOn'" onmouseout="this.className='highlightOff'">
<form name=''  method='POST' action='' target='_self' onsubmit="return form_Validator(this)">
<input type='hidden' name='func' value='update_user_vm'> 
<b>User Information </b><br />
  <TABLE>
  <!--{if $user_info_msgs}-->
  <TR>
    <TD colspan=2 align=center><font style="color: red">
     <!--{foreach from=$user_info_msgs item=msg}--> 
         <!--{$msg}--><BR>
     <!--{/foreach}-->
      </font></td>
  </tr>
  <!--{/if}-->
  <TR>
    <TD>First Name&nbsp;&nbsp; </td>
    <TD><INPUT name='first_name' value='<!--{$first_name}-->'></TD>
  </tr>

  <TR>
    <TD>Last Name&nbsp;&nbsp; </td>
    <TD><INPUT name='last_name' value='<!--{$last_name}-->'></TD>
  </tr>
  <TR>
    <TD>E-mail Address &nbsp;&nbsp; </td>
    <TD><INPUT name='email_address' value='<!--{$email_address}-->' ></TD>
  </tr>
  <TR>
    <TD>Voicemail Mailbox &nbsp;&nbsp; </td>
    <TD><!--{if $edit_mailbox}-->
       <INPUT name='mailbox' value='<!--{$mailbox}-->' >
        
        <!--{else}-->
           <b><!--{$mailbox}--></b>
        <!--{/if}-->
     </TD>
    
  </tr>
  <TR>
    <TD colspan=2><b>Reset Voicemail Password (Numbers only)</b> </td>
  </tr>
  <TR>
    <TD>New VM Password&nbsp;&nbsp; </td>
    <TD><INPUT type='password' name='vm_password' value='' ></TD>
  </tr>
  <TR>
    <TD>Re-type VM Password&nbsp;&nbsp; </td>
    <TD><INPUT type='password' name='vm_password_re' value='' ></TD>
  </tr>
  <TR>
    <TD colspan=2><b>Reset SpWeb Password (Numbers only)</b> </td>
  </tr>
  <TR>
    <TD>New SpWeb Password&nbsp;&nbsp; </td>
    <TD><INPUT type='password' name='spweb_password' value='' ></TD>
  </tr>
  <TR>
    <TD>Re-type SpWeb Password&nbsp;&nbsp; </td>
    <TD><INPUT type='password' name='spweb_password_re' value='' ></TD>
  </tr>


<!--  <TR>
    <TD colspan=2 valign='top' align=center>
    <BR>
    </td>
  </tr>
-->

  <TR>
    <TD colspan=2 valign='top' align=center>
     <BR>
      <input type="submit" value="Apply">
    </TD>
  </TR>
  </TABLE>
  </FORM>
</td>

</tr><tr>
<!-- A2 -->
<td bgcolor="#EEEEEE" width="55%" valign="top" onmouseover="this.className='highlightOn'" onmouseout="this.className='highlightOff'">
<form name=''  method='POST' action='' target='_self' onsubmit="return form_Validator(this)">
<input type='hidden' name='func' value='update_um'>
<b>Unified Messaging Settings</b><br />
  <table>
  <tr>

     <Td colspan=2><b>Message Storage Options</b></Td>
  </tr>
  <!--{if $user_um_msg}-->
  <TR>
    <TD colspan=2 ><font style="color: red"><!--{$user_um_msg}--> </font></td>
  </tr>
  <!--{/if}-->
  <tr>
     <Td colspan=2><i><input type='radio' name='store_flag' value='V' <!--{if $store_flag eq 'V'}-->CHECKED<!--{/if}-->>
        Use Voicemail Store. </I></Td>
  
  </tr><tr>
  <!-- N-->
   <Td>E-mail Option</b></Td>
   <TD><select name='vstore_email'>
          <!--{html_options options=$vstore_email_options selected=$vstore_email}-->
        </select>
      </TD>
  </tr><tr>
     <Td colspan=2><i><input type='radio' name='store_flag' value='E' <!--{if $store_flag eq 'E'}-->CHECKED<!--{/if}--> >
      Use E-mail Store. </I></Td>
    </tr><tr>
   <Td>Email Interface Option</b></Td>

   <TD><select name='email_delivery'>
          <!--{html_options options=$email_delivery_options selected=$email_delivery}-->
        </select>
      <!-- I -->
      </TD>
  </tr><tr>
     <Td>E-mail Server Address</b></Td>

   <TD><INPUT TYPE='TEXT' NAME="email_server_address" value="<!--{$email_server_address}-->" size=30>  </TD>
  </tr><tr>
     <Td>E-mail User Name</b></Td>
     <TD><INPUT TYPE='TEXT' NAME="email_user_name" value="<!--{$email_user_name}-->" size=30>  </TD>

  </tr><tr>
     <Td>Mobile E-mail </b></Td>
     <TD><INPUT TYPE='TEXT' NAME="mobile_email" value="<!--{$mobile_email}-->" size=30>  </TD>
  </tr><tr>
     <Td>Mobile E-mail Flag </b></Td>
     <TD><SELECT NAME='mobile_email_flag'> 
         <OPTION VALUE='1' <!--{if $mobile_email_flag eq "1"}-->SELECTED<!--{/if}-->  >On</option>
         <OPTION VALUE='0' <!--{if $mobile_email_flag eq "0"}-->SELECTED<!--{/if}--> >Off</option>
        </SELECT></TD>
  </tr><tr>
     <Td>E-mail Password </b></Td>
     <TD><INPUT TYPE='PASSWORD' NAME="email_password" value="" size=30>  </TD>
  </tr><tr>
     <Td>Retype E-mail Password </b></Td>
     <TD><INPUT TYPE='PASSWORD' NAME="email_password_re" value="" size=30>  </TD>
  </tr><tr>
    <TD colspan=2 valign='top' align=center>
      <input type="submit" value="Apply">
    </TD>
  </TR>
</table>
</td>
</form>

<!-- B2 -->
<form name=''  method='POST' action='' target='_self' onsubmit="return form_Validator(this)">
  <input type='hidden' name='func' value='update_vm_flags'>
<td bgcolor="#EEEEEE"  valign="top" onmouseover="this.className='highlightOn'" onmouseout="this.className='highlightOff'">
<b>Voicemail Settings</b><br />

  <table>
  <tr>
     <Td colspan=2>
     <TABLE> <tr> 
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
      </tr><!-- <tr>
         <Td>Auto Login</Td>
         <TD><select name='auto_login_flag'>
            <option value='1' >Yes</option>
            <option value='0' >No</option>
  
            </select>
         </TD>
         <Td>Auto New Messages?</Td>
         <TD><select name='auto_new_messages_flag'>
            <option value='1' >Yes</option>
            <option value='0' >No</option>
            </select>
            </td>
      </tr> 
      -->
     </table>
     </td></tr>
  <tr>
     <TD>
      <BR>
     </td>
  </tr>
  <tr>
     <td align='center'><INPUT TYPE=submit value='Apply'></td>
  </tr>
  </table>
  
</td>

<!-- A2 -->


</tr>
</table></td></tr></form></table>


<!-- Required Indent -->

        </td>
        </tr>
        </table>
</td>
<td><img src="images/trans.gif" width="1" height="1"></td>
</tr>
                                                                                                                                               

