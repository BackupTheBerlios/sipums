#
# Copyright (C) 2003 Comtel
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

package OpenUMS::SipUmsMwi;

=pod
=head1 NAME

Telephony::CTPort - Computer Telephony programming in Perl

=head1 SYNOPSIS

use OpenUMS::Mwi;

=head1 DESCRIPTION

This module implements an Object-Oriented interface to control Computer
Telephony (CT) card ports using Perl.  It is part of a client/server
library for rapid CT application development using Perl.

=head1 AUTHOR

Kevin English, support@comtel.com

Dean Kramer, support@voicetronix.com.au

=cut

##  some people hate restrictions, i don't, declare everything with 'my'

use strict;
## libaries we're using

use OpenUMS::Config;
use OpenUMS::Log;
my $DEBUG = 1;




#################################
## sub update_mwis($$)
#################################
sub update_mwis($$)
{
  my ($dbh,$user_mailboxes) = @_;
  #my $log = &OpenUMS::Log::new();
  $log->debug("They called update_mwis"); 
  ## populate for new users...
  populate($dbh); 
  ## these are all the guys we turn it on for...
  
  my $data = get_data($dbh) ; 
  my @exts = sort keys %{$data} ; 
  foreach my $ext (@exts ) { 
     $log->debug("$ext, doing send mwi  " . $data->{$ext}->{action}  ); 
     send_mwi($user_mailboxes->{$ext}, $data->{$ext}->{action},$data->{$ext}->{new_message_count}, $data->{$ext}->{saved_message_count}  );
     save($dbh,$ext,$data->{$ext}->{new_message_count});
  } 

  if (scalar(@exts ) ) { 
     $log->debug(scalar(@exts )  . " Mwis processed\n"); 
  }  else {
     $log->debug("NO Mwi to process\n"); 
  } 
} 


#################################
## sub get_data
#################################
sub get_data {
  my $dbh = shift;
  ## everyone with new messages....
  my @to_light ;
  
#  my $sql = qq{SELECT u.extension, count(*) FROM VM_Users u INNER JOIN VM_Messages m on (u.extension = m.extension_to) 
#     WHERE u.mwi_flag = 1 GROUP BY u.extension} ; 
#
#  my $sth = $dbh->prepare($sql ); ##"SELECT count(*) FROM VM_Messages WHERE extension_to = ? AND message_status_id = 'N'");
#  $sth->execute();
#  while (my ($ext,$count) = , $last_visit_uts) = $sth->fetchrow_array() ) {
#   
#   
#  return ; 
  ### old way
  my $sql = qq{select q.extension , last_new_message_count, unix_timestamp(last_sent) last_sent, 
           unix_timestamp(u.last_visit) last_visit
            FROM VM_Users u INNER JOIN mwi_status q on (u.extension = q.extension) 
            WHERE u.mwi_flag = 1 AND u.store_flag ='V' AND NOT u.vstore_email = 'S'};

   my $sth  = $dbh->prepare($sql);
   $sth->execute();
                                                                                                                                               
   my $sth_new = $dbh->prepare("SELECT count(*) FROM VM_Messages WHERE extension_to = ? AND message_status_id = 'N'");

   my $sth_saved = $dbh->prepare("SELECT count(*) FROM VM_Messages WHERE extension_to = ? AND message_status_id = 'S'");

   my $data;
   while (my ($ext,$last_new_msg_count, $last_sent_uts, $last_visit_uts) = $sth->fetchrow_array() ) {

                                                                                                                                               
      $sth_new->execute($ext);
      my $new_msg_count = $sth_new->fetchrow();
      $sth_new->finish();

      $sth_saved->execute($ext);
      my $saved_msg_count = $sth_saved->fetchrow();
      $sth_saved->finish();

      $log->debug("in SipUmsMwi->get_data() $ext last_new_msg_count=$last_new_msg_count new_msg_count=$new_msg_count"); 

      ## if they have no new messages and they had new messages before, we turn it off...
      if (!$new_msg_count && $last_new_msg_count) {
          $data->{$ext}->{saved_message_count} = $saved_msg_count ; 
          $data->{$ext}->{new_message_count} = $new_msg_count ; 
          $data->{$ext}->{action}  = 'D'; ## deactivate
      }
                                                                                                                                               
      ## if they had no new messages and they have new messages now, we turn it off...
     if (!$last_new_msg_count && $new_msg_count) {
          $data->{$ext}->{saved_message_count} = $saved_msg_count ; 
          $data->{$ext}->{new_message_count} = $new_msg_count ; 
          $data->{$ext}->{action} = 'A'; ## activate
      }
      
      ## if they have more new messages now than they had before, we turn it on
     if ($new_msg_count > $last_new_msg_count) {
          $data->{$ext}->{saved_message_count} = $saved_msg_count ; 
          $data->{$ext}->{new_message_count} = $new_msg_count ; 
          $data->{$ext}->{action} = 'A'; ## activate
      }

      my $last_visit_flag =  ($last_visit_uts > $last_sent_uts ); 

      ## if they logged in and still have new messages
      if ($last_visit_flag && $new_msg_count) {
          $data->{$ext}->{saved_message_count} = $saved_msg_count ; 
          $data->{$ext}->{new_message_count} = $new_msg_count ; 
          $data->{$ext}->{action} = 'A'; ## activate
      }

   }
   $sql = qq{select extension, unix_timestamp(last_visit) last_visit ,
              max(unix_timestamp(m.message_created)) last_message,count(*) count
               FROM VM_Users u INNER JOIN  VM_Messages m on (u.extension = m.extension_to)
               WHERE m.message_status_id ='N'
               GROUP BY extension, unix_timestamp(last_visit) };
   $sth  = $dbh->prepare($sql);
   $sth->execute();


#   while (my ($ext,$last_visit_uts, $last_msg_uts,$new_message_count) = $sth->fetchrow_array() ) {
#      $log->debug("$ext--> $new_message_count");
#      if ($last_msg_uts > $last_visit_uts) { 
#          $data->{$ext}->{action} = 'A'; ## activate
#      } 
#   } 
  

   return $data ;
}

#################################
## sub send_mwi
#################################
#sub send_mwi {
#  my $ctport = shift;
#  my $ext = shift ;
#  my $mwi_action  = shift ;  # aciton should be A or D
#  my $flash ; 
#  if ($mwi_action eq 'A') {
#    $flash =  ",#" . $ext . "01" ; 
#  }  else { 
#    $flash =  ",#" . $ext . "00" ; 
#  } 
#  $ctport->on_hook();
#  $ctport->clear();
#  sleep(2);
#  $ctport->off_hook();
#  $log->debug("sending MWI flash $flash"); 
#  $ctport->dial($flash);
#  $ctport->on_hook();
#
#  return ; 
#}


#################################
## sub populate($)
#################################
sub populate($) {
  my $dbh = shift ; 
  ## this gets any new users and makes a record for them in the table..
  my $sql = qq{ SELECT u.extension
    FROM VM_Users u LEFT JOIN  mwi_status q
    ON (u.extension = q.extension)  
    WHERE q.extension IS NULL AND u.extension <> 0} ; 
  my $sth = $dbh->prepare($sql) ; 
  $sth->execute();
  while (my ($ext) = $sth->fetchrow_array() ) { 
     my $ins = qq{INSERT INTO mwi_status (extension)
      VALUES ($ext) }; 
     $dbh->do($ins); 
     
  } 
  $sth->finish();
} 


#################################
## sub save
#################################
sub save {
  my ($dbh,$ext,$new_message_count) = @_;
  if (!$new_message_count) {
    $new_message_count = 0; 
  } 
   my $sql = qq{UPDATE mwi_status SET last_sent = NOW()  , 
    last_new_message_count = $new_message_count 
    WHERE  extension = $ext }; 
  # $log->debug("update mwi_status $ext  $new_message_count   ");
  $dbh->do($sql); 
  return 
} 
#################################
## sub send_mwi
#################################
sub send_mwi {
  my ($ser_user, $mwi_action,$new_count, $saved_count) = @_;
  my $flash; 

  $saved_count = "0" if (!$saved_count); 
  $new_count = "0" if (!$new_count); 

  $log->log("send_mwi : $ser_user, $mwi_action,$new_count, $saved_count ");

  if ($mwi_action eq 'A') {
     $flash =  "yes" ; 
  }  else {
     $flash =  "no"; 
  }

#  $log->debug("send_mwi :: ser_user = $ser_user flash = $flash action=$mwi_action ");


  # my $resp = (int(rand(10000)) + 1) .  ".fifo";
  # my $FIFO = "/tmp/$resp";

  # my $val = `mkfifo -m 666 $FIFO`;
                                                                                                                                               
  my $handle = new File::Temp(UNLINK => 1, SUFFIX => '.fifo');
  my $cmd_file = $handle->filename;
                                                                                                                                               
  my $mwi_fifo_cmd = qq(:t_uac_dlg:hh
NOTIFY
sip:$ser_user
.
From:sip:sipums\@servpac.com
To:sip:$ser_user
Event: message-summary
Content-Type: application/simple-message-summary
                                                                                                                                               
Messages-Waiting: $flash
Voicemail: $new_count/$saved_count
.
                                                                                                                                               
);


   print $handle "$mwi_fifo_cmd";
   autoflush $handle 1; 
   my $cmd = "cat $cmd_file > /tmp/ser_fifo "; 

   my $ret = `$cmd`; 

   close($handle); 
  

}

sub get_user_mailboxes($$) {
  my ($dbh,$db_name) = @_; ##  = OpenUMS::Common::get_dbh("ser") ;
                                                                                                                                               
  my $sql = qq{SELECT s.mailbox, s.username,s.domain,  c.voicemail_db
FROM subscriber s, clients c
WHERE s.client_id = c.client_id
AND c.voicemail_db = '$db_name'
AND mailbox IS NOT NULL
AND mailbox <> 0} ; 
                                                                                                                                               
                                                                                                                                               
  my $sth = $dbh->prepare($sql);
  $sth->execute();
  my %hash;

  while (my ($mailbox, $username,$domain) = $sth->fetchrow_array() ) {
    $hash{$mailbox} = "$username\@$domain";
  }
  $log->debug("get_user_mailboxes(  "  . $db_name . ") == " . scalar(keys %hash) . " mailboxes  " );
    
  
  return \%hash; ## $ary_ref;
}
1; 
