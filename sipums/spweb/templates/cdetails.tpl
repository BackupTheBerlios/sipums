<tr>
<td><img src="images/trans.gif" width="1" height="1"></td>
<td>
        <table border="0" bordercolor="#cccccc" cellpadding="0" cellspacing="0" width="100%" class="main">
        <tr>
        <td align="center" valign="top">
          <TABLE >
            <TR><TD valign='top'>
              <TABLE class="MTable">
                 <TR> <TD> Conference Name:</TD><TD> <B><!--{$conf.conference_name}--></b> </td></tr>
                 <TR><TD> Date :</TD><TD> <B><!--{$conf.conference_date}--></b> </td></td>
                 <tr> <TD> Begins :</TD><TD> <B><!--{$conf.begin_time}--></b> </td></tr>
                 <TR> <TD> Ends :</TD><TD> <B><!--{$conf.end_time}--> </b></td> </tr>
               </TABLE>
            </td><td valign=top>
               <CENTER>
               <TABLE class="MTable" valign=top> 
                 <TR><TD colspan=2><B>Invitees</b></tD></tr>
                 <TR><TD><B>Name</b></tD><tD><B>Email</b></tD><!--{if $conf.owner_flag}--><TD>&nbsp;</TD><!--{/if}--></tr>
                 <!--{foreach key=key item=item from=$conf.invitees}-->
                 <TR><TD><!--{$item.invitee_name}--></td><td><!--{$item.invitee_email}--></td>
                     <!--{if $conf.owner_flag}--><TD><a href="invitee_edit.php?conference_id=<!--{$conf.conference_id}-->&invitee_id=<!--{$item.invitee_id}-->">edit</a>
                    </TD><!--{/if}--> 
                            </tr>
                   <!--{/foreach}-->
                   <!--{if $conf.owner_flag}-->
                   <TR> <TD colspan=2 align=center>
                      <a href='invitee_add.php?conference_id=<!--{$conf.conference_id}-->'>Add an Invitee</a>
                     </td></tr>
                    <!--{/if}-->
                   
               </TABLE> </CENTER>
           </td></tr>
          </table>
        </td>
        </tr>
      </TABLE>
</td>
<td><img src="images/trans.gif" width="1" height="1"></td>
</tr>
                                                                                                                                               

