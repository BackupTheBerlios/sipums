<tr>
<td><img src="images/trans.gif" width="1" height="1"></td>
<td>
        <table border="1" bordercolor="#cccccc" cellpadding="0" cellspacing="0" width="100%" class="main">
        <tr>
        <td align="center" valign="top">
<!-- Required Indent -->


  <table border="0" cellpadding="2" cellspacing="0" width="100%" class="MTable">
      <tr bgcolor="#cccccc" style="cursor:default;">
        <th align="left">Title</td>
        <th align="left">Date</td>
        <th align="left">Start Time</td>
        <th align="left">End Time</td>
        <!-- <th align="left">Phone Number</td> -->
        <th align="left">Attendees</td> 
        <th align="left">Creator</td>
        <th align="left" >&nbsp;</td>
        <th align="left" >&nbsp;</td>
      </tr>
     <!--{foreach name=user_conferences item=conf from=$user_conferences}-->
      <tr onmouseover="this.style.backgroundColor='#C7D5EB';" onmouseout="this.style.backgroundColor='';"  style="cursor:default;">
        <td nowrap="nowrap">
             <span style="overflow:hidden;text-overflow:ellipsis;">
              <a href="cdetails.php?conference_id=<!--{$conf.conference_id}-->"><!--{$conf.conference_name}--></a>
             </span>
        </td>
        <td nowrap="nowrap">
           <!--{ if $conf.owner_flag}-->
             <span style="overflow:hidden;text-overflow:ellipsis;">
              <a href="conf_edit.php?conference_id=<!--{$conf.conference_id}-->"><!--{$conf.conference_date}--></a>
             </span>
           <!--{else}-->
            <!--{$conf.conference_date}-->
           <!--{/if}-->
        </td>
        <td nowrap="nowrap">

           <!--{ if $conf.owner_flag}-->
            <span style="overflow:hidden;text-overflow:ellipsis;">
              <a href="conf_edit.php?conference_id=<!--{$conf.conference_id}-->"><!--{$conf.begin_time}--></a>
            </span>
           <!--{else}-->
             <!--{$conf.begin_time}-->
           <!--{/if}-->
                            

        </td>
        <td nowrap="nowrap">
           <!--{ if $conf.owner_flag}-->
            <span style="overflow:hidden;text-overflow:ellipsis;">
              <a href="conf_edit.php?conference_id=<!--{$conf.conference_id}-->&func=view"><!--{$conf.end_time}--></a>
            </span>
           <!--{else}-->
             <!--{$conf.end_time}-->
           <!--{/if}-->
        </td>
        <td nowrap="nowrap">
            <span style="overflow:hidden;text-overflow:ellipsis;">
              <a href="cdetails.php?conference_id=<!--{$conf.conference_id}-->&func=view"><!--{$conf.invitee_count|default:"&nbsp;"}--></a>
            </span>
        </td>

<!--        <td nowrap="nowrap">
            <span style="overflow:hidden;text-overflow:ellipsis;">
              <a href="cdetails.php?conference_id=<!--{$conf.conference_id}-->&func=view"><!--{$conf.conference_number}--></a>
            </span>

        </td>
-->
        <td nowrap="nowrap">
            <span style="overflow:hidden;text-overflow:ellipsis;">
              <a href="cdetails.php?conference_id=<!--{$conf.conference_id}-->&func=view"><!--{$conf.creator}--></a>
            </span>
        </td>
        <td nowrap="nowrap">
           <!--{ if $conf.owner_flag}-->
            <span style="overflow:hidden;text-overflow:ellipsis;">
              <a href="invitee_add.php?conference_id=<!--{$conf.conference_id}-->">Invite Someone</a>
            </SPAn>
           <!--{else}-->
             &nbsp;
           <!--{/if}-->
          
        </td>
        <td nowrap="nowrap">
           <!--{ if $conf.owner_flag}-->
            <span style="overflow:hidden;text-overflow:ellipsis;">
              <a href="cancel_conference.php?conference_id=<!--{$conf.conference_id}-->">Cancel</a>
            </SPAn>
           <!--{else}-->
             &nbsp;
           <!--{/if}-->
        </td>
      </TR>

   <!--{foreachelse}-->
   <tr><td colspan=8 align=center>No Conferences</td>
   <!--{/foreach}-->
   <tr><td colspan=8 align=center><BR></td>
   <tr><td colspan=8 align=center><a href='new_conference.php'>Create a new conference</a></td>
  </table>


<!-- Required Indent -->
                                                                                                                                               
        </td>
        </tr>
        </table>
</td>
<td><img src="images/trans.gif" width="1" height="1"></td>
</tr>

