### $Id: SipUmsMwi.pm,v 1.2 2004/07/31 20:27:05 kenglish Exp $
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
  ## populate for new users...
  populate($dbh); 
  ## these are all the guys we turn it on for...
  
  my $data = get_data($dbh) ; 
  my @exts = sort keys %{$data} ; 
  foreach my $ext (@exts ) { 
     send_mwi($user_mailboxes->{$ext}, $data->{$ext}->{action} );
     save($dbh,$ext,$data->{$ext}->{new_message_count});
  } 
  if (scalar(@exts ) ) { 
     $log->debug(scalar(@exts )  . " Mwis processed\n"); 
  }  else {
     $log->debug("NO  Mwi to process\n"); 
  } 
} 


#################################
## sub get_data
#################################
sub get_data {
  my $dbh = shift;
  ## everyone with new messages....
   my @to_light ;
  
   my $sql = qq{select q.extension , last_new_message_count, unix_timestamp(last_sent) last_sent, 
           unix_timestamp(u.last_visit) last_visit
            FROM VM_Users u INNER JOIN mwi_status q on (u.extension = q.extension) 
            WHERE u.mwi_flag = 1 AND u.store_flag ='V' AND NOT u.vstore_email = 'S'};

   my $sth  = $dbh->prepare($sql);
   $sth->execute();
                                                                                                                                               
   my $sth2 = $dbh->prepare("SELECT count(*) FROM VM_Messages WHERE extension_to = ? AND message_status_id = 'N'");
   my %data;
                                                                                                                                               
   my $data;
                                                                                                                                               
   while (my ($ext,$last_new_msg_count, $last_sent_uts, $last_visit_uts) = $sth->fetchrow_array() ) {
                                                                                                                                               
      $sth2->execute($ext);
      my $new_msg_count = $sth2->fetchrow();
      $sth2->finish();
                                                                                                                                               
      ## if they have no new messages and they had new messages before, we turn it off...
      if (!$new_msg_count && $last_new_msg_count) {
          $data->{$ext}->{new_message_count} = $new_msg_count ; 
          $data->{$ext}->{action}  = 'D'; ## deactivate
      }
                                                                                                                                               
      ## if they had no new messages and they have new messages now, we turn it off...
     if (!$last_new_msg_count && $new_msg_count) {
          $data->{$ext}->{new_message_count} = $new_msg_count ; 
          $data->{$ext}->{action} = 'A'; ## activate
      }
      my $last_visit_flag =  ($last_visit_uts > $last_sent_uts ); 

      ## if they logged in and still have new messages
      if ($last_visit_flag && $new_msg_count) {
          $data->{$ext}->{new_message_count} = $new_msg_count ; 
          $data->{$ext}->{action} = 'A'; ## activate
      }

   }
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
  $dbh->do($sql); 
  return 
} 
#################################
## sub send_mwi
#################################
sub send_mwi {
  my ($ser_user, $mwi_action) = @_;
  my $flash; 

  if ($mwi_action eq 'A') {
     $flash =  "yes" ; 
  }  else {
     $flash =  "no"; 
  }

  $log->debug("send_mwi :: ser_user = $ser_user flash = $flash action=$mwi_action ");
  return ;

  my $resp = (int(rand(10000)) + 1) .  ".fifo";
  my $FIFO = "/tmp/$resp";

  my $val = `mkfifo -m 666 $FIFO`;
                                                                                                                                               
  my $handle = new File::Temp(UNLINK => 1, SUFFIX => '.fifo');
  my $cmd_file = $handle->filename;
                                                                                                                                               
  my $mwi_fifo_cmd = qq(:t_uac_dlg:$resp
NOTIFY
sip:$ser_user
.
From:sipums\@o-matrix.org
To:$ser_user
Event: message-summary
Content-Type: application/simple-message-summary
                                                                                                                                               
Messages-Waiting: $mwi_action
Voicemail: 2/5
.
                                                                                                                                               
);
  ## my $val = `cat $cmd_file >/tmp/ser_fifo`;
  

}

1; 
