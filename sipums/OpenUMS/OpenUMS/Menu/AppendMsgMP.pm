package OpenUMS::Menu::AppendMsgMP; 
### $Id: AppendMsgMP.pm,v 1.2 2004/07/30 20:22:13 kenglish Exp $
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
## sub _play_menu ()
#################################
##sub _play_menu () {
##  ## this the most basic of basic plays....
##  my $self = shift ; 
##  my $ctport = $self->{CTPORT} ; 
##
##  $log->warning("OpenUMS::RecMsg called, menu_id = " . $self->{MENU_ID} ); 
##  if (!defined($self->{EXTENSION_TO}) ) { 
##    $log->warning("OpenUMS::RecMsgPresenter _play_menu called with no EXTENSION_TO"); 
##    ## trying to use the one on the user....
##    $self->{EXTENSION_TO}  = $self->{USER}->{EXTENSION_TO}  ; 
##    $log->warning("OpenUMS::RecMsgPresenter should've set " . $self->{USER}->{EXTENSION_TO} ); 
##   return ;
##  } 
##  
##  my $sound = OpenUMS::Greeting::get_greeting_sound($self->{DBH}, $self->{EXTENSION_TO} ); 
##
##  $log->info("Record Message, playing greeting $sound "); 
##  if (defined($sound) ) { 
##    ## hey, it's gotta be there...
##    $ctport->play($sound); 
##  } 
##  return ;
##} 

#################################
## sub _get_input
#################################
sub _get_input {
  my $self = shift ;
  my $ctport = $self->{CTPORT};
  my $ext_to  = $self->{EXTENSION_TO} ; 
  my $user = $self->{USER}; 

  my $input = $ctport->collect(1,0);
    
  if (defined($self->{MENU_OPTIONS}->{$input}) ) {  
     ## they wanna do something other than record the message...
    $self->{INPUT} = $input ; 
     return ;  
  } 
    

  my ($message_file,$message_path) =  OpenUMS::DbQuery::get_new_message_file_name ($ext_to, $ctport->{HANDLE}); 
  ## add '_append' at the end of the file:

  $message_file =~ s/\.wav$/_append.wav/; 
  $log->info("[AppendMsgMP.pm] Gonna record extra $message_file for extension $ext_to"); 
      
  my $menuSounds = $self->{SOUNDS_ARRAY};
  my $sound; 

  if ($menuSounds->{M}->[1]->{sound_file} ) {
     $sound .=    PROMPT_PATH . $menuSounds->{M}->[1]->{sound_file}  ;
  }

  my ($old_message_file,$old_message_path) =  $user->get_message_file(); 
  my $old_file_duration = OpenUMS::Common::file_duration($old_message_file, BASE_PATH . TEMP_PATH);
  my $new_timeout=  $main::GLOBAL_SETTINGS->get_var('MESSAGE_TIMEOUT') - $old_file_duration ; 
  $ctport->play($sound); 

  OpenUMS::Common::comtel_record($ctport, BASE_PATH . TEMP_PATH . $message_file, $new_timeout, RECORD_TERM_KEYS, SILENCE_TIMEOUT);

  $user->append_file($message_file); 
  
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

  if (defined($self->{MENU_OPTIONS}->{$input}) ) {  
     $next_id =  $self->{MENU_OPTIONS}->{$input}->{dest_id} ;
     $action  =  "NEXT"; 
     if ($self->{MENU_OPTIONS}->{$input}->{item_action} eq 'LOGIN' ) {
       $user->{EXTENSION_TO} = $self->{EXTENSION_TO} ; 
     }  
  }

  if (!$next_id) {
    ## otherwise send them to the post message thingie
         
    $action = "NEXT";
    $next_id =  OpenUMS::DbQuery::get_post_msg_menu_id($dbh);
  }
  $log->debug("[AppendMsgMP.pm] Processing done : action= $action next_id= $next_id ");
  return ($action, $next_id,$self->{EXTENSION_TO}) ;    

}
1;
