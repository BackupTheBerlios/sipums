package OpenUMS::Menu::RecMsgMP; 
### $Id: RecMsgMP.pm,v 1.1 2004/07/20 02:52:15 richardz Exp $
#
# RecMsgMP.pm
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

## this is the skeleton pacakge for the VmProc

use strict ; 
use OpenUMS::Config; 
use OpenUMS::Log; 
use OpenUMS::Menu::MenuProcessor; 
use OpenUMS::Common; 
use OpenUMS::DbQuery; 
use OpenUMS::DbUtils; 
use OpenUMS::Greeting; 
use base ("OpenUMS::Menu::MenuProcessor");


#################################
## sub _pre_data
#################################
sub _pre_data {
  my $self = shift ;
  my $dbh = $self->{DBH};
  my $menu_id = OpenUMS::DbQuery::get_rec_msg_menu_id($dbh);
#  if (!defined($menu_id) ) {
#     $menu_id = OpenUMS::DbQuery::get_current_aa_menu_id($dbh);
#  }
  $self->{MENU_ID} = $menu_id;
  return 1;
}


#################################
## sub _play_menu ()
#################################
sub _play_menu () {
  ## this the most basic of basic plays....
  my $self = shift ; 
  my $ctport = $self->{CTPORT} ; 

  $log->warning("OpenUMS::RecMsg called, menu_id = " . $self->{MENU_ID} ); 
  if (!defined($self->{EXTENSION_TO}) ) { 
    $log->warning("OpenUMS::RecMsgPresenter _play_menu called with no EXTENSION_TO"); 
    ## trying to use the one on the user....
    $self->{EXTENSION_TO}  = $self->{USER}->{EXTENSION_TO}  ; 
    $log->warning("OpenUMS::RecMsgPresenter should've set " . $self->{USER}->{EXTENSION_TO} ); 
   return ;
  } 
  
  my $sound = OpenUMS::Greeting::get_greeting_sound($self->{DBH}, $self->{EXTENSION_TO} ); 

  $log->info("Record Message, playing greeting $sound "); 
  if (defined($sound) ) { 
    ## hey, it's gotta be there...
    $ctport->play($sound); 
  } 
  return ;
} 


#################################
## sub _get_input
#################################
sub _get_input {
  my $self = shift ;
  my $ctport = $self->{CTPORT};
  my $ext_to  = $self->{EXTENSION_TO} ; 
  my $user = $self->{USER}; 

  my $input = $ctport->collect(1,0);
  $self->{INPUT_COLLECTED} = $input ; 
    
  if (defined($self->{MENU_OPTIONS}->{$input}) ) {  
     ## they wanna do something other than record the message...
    $self->{INPUT} = $input ; 
     return ;  
  } 
    
    
  my ($message_file,$message_path) =  OpenUMS::DbQuery::get_new_message_file_name ($ext_to, $ctport->{HANDLE}); 
  $log->info("[RecMsgMP.pm] Gonna record $message_file for $ext_to"); 
    
  my $menuSounds = $self->{SOUNDS_ARRAY};
  my $sound; 

  if ($menuSounds->{M}->[0]->{sound_file} ) {
     $sound .=    PROMPT_PATH . $menuSounds->{M}->[0]->{sound_file}  ;
  }

  $ctport->play($sound); 
  my $deanret = OpenUMS::Common::comtel_record($ctport,BASE_PATH . TEMP_PATH . $message_file, 
       $main::GLOBAL_SETTINGS->get_var('MESSAGE_TIMEOUT'), RECORD_TERM_KEYS, SILENCE_TIMEOUT);

  $user->set_message_file($message_file,$message_path ); 
  
}


#################################
## sub validate_input
#################################
sub validate_input {
  my $self = shift ; 
  ## always 1
  return 1;  
}
#################################
## sub process
#################################

sub process {
  my $self = shift;
  my $input = $self->{INPUT} ; 
  my $dbh = $self->{DBH} ; 
  
  my ($action, $next_id); 
#  $action = "NEXT"; 
#  $next_id =  OpenUMS::DbQuery::get_post_msg_menu_id($dbh);
#  return ($action, $next_id) ;    
  my $user = $self->{USER}; 

  ## $self->save_message(); ## always try to save the message...

  $log->debug("[RecMsgMP.pm] Proccessing message input=$input " ); 
  if (defined($self->{MENU_OPTIONS}->{$input}) ) {  
     $next_id =  $self->{MENU_OPTIONS}->{$input}->{dest_id} ;
     $action  =  "NEXT"; 
     if ($self->{MENU_OPTIONS}->{$input}->{item_action} eq 'LOGIN' ) {
       $user->{EXTENSION_TO} = $self->{EXTENSION_TO} ; 
     }  
     if ($self->{MENU_OPTIONS}->{$input}->{item_action} eq 'CANCEL' ) {
       $user->{EXTENSION_TO} = undef; 
       return ($action, $next_id) ;    
     }  
  }

  if (!$next_id) {
    ## otherwise send them to the post message thingie
    $action = "NEXT";
    $next_id =  OpenUMS::DbQuery::get_post_msg_menu_id($dbh);
    $log->debug("[RecMsgMP.pm] No input, default action=$action next_menu_id=$next_id ");
  }

  return ($action, $next_id,$self->{EXTENSION_TO}) ;    

}

1;
