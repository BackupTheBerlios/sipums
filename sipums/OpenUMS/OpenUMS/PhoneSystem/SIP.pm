package OpenUMS::PhoneSystem::SIP ; 
### $Id: SIP.pm,v 1.6 2004/08/03 21:27:08 kenglish Exp $
#
# SIP.pm
#
## this will be a template for functions that 
#
# Copyright (C) 2003 Integrated Comtel Inc.
#
# This library is free software; you can redistribute it and/or modify it
# under the terms of the GNU Lesser General Public License as published by the
# Free Software Foundation; either version 2.1 of the license, or (at your
# option) any later version.
#
# This library is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public License for more
# details.
#
# You should have received a copy of the GNU Lesser General Public License
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
use strict ; 
use OpenUMS::PhoneSystem::PhoneSystemBase;
use OpenUMS::Log;
use OpenUMS::DbQuery;
use OpenUMS::Config;
use File::Temp;

use base ("OpenUMS::PhoneSystem::PhoneSystemBase"); 

#################################
## sub is_hangup
#################################
sub is_hangup {
 my ($self, $input)  = @_ ;


 if ($Telephony::SemsIvr::CALLER_HUNG_UP) { 
   return 1 ; 
 } else {
   return 0; 

 } 


}

sub hangup_occurred {
  my $self = shift; 
  ## for sip, it's not that much different
  return $self->is_hangup(); 
}


#################################
## sub send_mwi_on
#################################

sub send_mwi_on {
 my ($user) = @_;  

 my $mwi_fifo_cmd = qq(:t_uac_dlg:hh
NOTIFY
sip:$user
.
From:sipums\@o-matrix.org
To:$user
Event: message-summary
Content-Type: application/simple-message-summary
                                                                                                                                               
Messages-Waiting: yes
Voicemail: 2/5
.

);

}

#################################
## sub do_xfer
#################################
sub do_xfer { 
   my ($self, $ext)  = @_ ;
                                                                                                                             
   my $ctport = $self->{CTPORT};

   $ctport->dial("&,$ext,");
   $ctport->clear();
}

#################################
## sub do_transfer
#################################
sub do_transfer {
  my ($self, $ext) = @_; 
  if (!$ext) { 
     $log->error("CANNOT XFER, no ext") ;
     return ;
  } 

  my $voicemail_db = $main::GLOBAL_SETTINGS->get_var('VOICEMAIL_DB'); 

  if (!$voicemail_db) { 
     $log->error("CANNOT XFER, no voicemail_db") ;
     return ;
  } 

  my $dbh_ser = OpenUMS::Common::get_dbh(SER_DB_NAME); 
  my $sql = "SELECT  s.username, d.domain, d.voicemail_db,s.mailbox
      FROM subscriber s, domain d
      WHERE d.domain = s.domain
        AND d.voicemail_db = '$voicemail_db'
        AND mailbox = $ext" ; 

  $log->debug("$voicemail_db : $sql "); 
  my ($username,$domain) = $dbh_ser->selectrow_array($sql);
  $log->debug("$username,$domain");   
  if ($username && $domain) { 
    my $sip_user = "<sip:$username\@$domain>"; 
    $log->debug("calling ivr::redirect($sip_user)");   

    ivr::redirect($sip_user); 
  }  else {
    $log->error("TRANSFER COULD NOT FIND USERNAME FOR $ext");   
  } 

  $dbh_ser->disconnect(); 

} 



1; 
