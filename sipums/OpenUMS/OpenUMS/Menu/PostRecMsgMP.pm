package OpenUMS::Menu::PostRecMsgMP; 
### $Id: PostRecMsgMP.pm,v 1.5 2004/09/08 22:32:05 kenglish Exp $
#
# RecMsgMP.pm
#
# Copyright (C) 2004 Servpac Inc. 
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
## sub _play_menu()
#################################
sub _play_menu() { 
  my $self = shift ;
  my $user = $self->{USER} ;
  my $ctport = $self->{CTPORT} ;

  my ($message_file,$message_path) = $user->get_message_file();
  my $sound ; 
  if ($self->post_opt() =~ /^PLAYMSG/) {
     $log->debug("[PostRecMsgMP.pm] message_file = $message_file, " . TEMP_PATH . $message_file);
     $sound = $main::CONF->get_var('VM_PATH') . TEMP_PATH . $message_file; 
  }  else {
     my $max_duration = $main::CONF->get_var('MESSAGE_TIMEOUT') ; 
     my $file_duration  = OpenUMS::Common::file_duration($message_file, $main::CONF->get_var('VM_PATH') . TEMP_PATH ) ; 

     my $menuSounds = $self->{SOUNDS_ARRAY};
     
     $log->debug("[PostRecMsgMP.pm]  file_duration = $file_duration, max_duration = $max_duration");
     if ($file_duration >= $max_duration ) { 
        $sound =  $menuSounds->{M}->[1]->{PROMPT_OBJ}->file()  ;
     } else {
        $sound =  $menuSounds->{M}->[0]->{PROMPT_OBJ}->file(); ##  OpenUMS::Common::get_prompt_sound( $menuSounds->{M}->[0]->{sound_file})  ;
     } 
  }
  $log->debug("[PostRecMsgMP] will play sound $sound");
  if (defined($sound) ) {
    ## hey, if there, let 'em hear it
    $ctport->play($sound);
  }
}
sub _get_input {
  my $self = shift ;
  if ($self->post_opt() =~ /^PLAYMSG/) {
     return 1;  
  }  else { 
     ## other wise, do the default

     return $self->SUPER::_get_input() ;
  }
}

#################################
## sub validate_input
#################################
sub validate_input {
  my $self = shift ;
  if ($self->post_opt() =~ /^PLAYMSG/) {
     $log->debug( "[PostRecMsgMP.pm] post op is " . $self->post_opt() ); 
    return 1;
  } else { 
    ## always 1
    ## matt wants a hack, here's a hack..
    my $user = $self->{USER} ;
    my ($message_file,$message_path) = $user->get_message_file();
    my $input = $self->{INPUT} ;

    my $valid = $self->SUPER::validate_input(); 
    if ($valid )  { 
       my $menuOptions =  $self->{MENU_OPTIONS} ;
       my $max_duration = $main::CONF->get_var('MESSAGE_TIMEOUT') ; 
       my $file_duration  = OpenUMS::Common::file_duration($message_file, $main::CONF->get_var('VM_PATH') . TEMP_PATH ) ; 

       if ($menuOptions->{$input}->{item_action} eq 'APPMSG' &&  $file_duration >= $max_duration){
          $valid = 0 ; 
       }       
    } 
    return $valid; 
  }
}

#################################
## sub process
#################################
sub process {
  my $self = shift ;
  my $input = $self->{INPUT} ;

  my $user = $self->{USER}; 
  my $action ;
  my $item_action = $self->{MENU_OPTIONS}->{$input}->{item_action} ;
  my $next_id = $self->{MENU_OPTIONS}->{$input}->{dest_id} ;
  
  if ($item_action =~ /^SAVEMSG/){ 
     $user->save_message();
     $log->debug("saved message, signalling delivermail"); 
     OpenUMS::Common::signal_delivermail() ;
  } elsif ($item_action =~ /^CANCELMSG/) { 
     $user->clear_message_file();
     $self->{CTPORT}->play(OpenUMS::Common::get_prompt_sound( "messagecanceled")); 
  } 
  if ($self->post_opt() =~ /^PLAYMSG/) {
     $next_id = $self->{MENU_OPTIONS}->{DEFAULT}->{dest_id} ;
  } 
  $action = 'NEXT'; 
  return ($action,$next_id, $self->{EXTENSION_TO} ) 
}

#################################
## sub post_opt
#################################
sub post_opt {
  my $self = shift; 
  if (@_) {
    $self->{POST_OPT} = shift ;
  } 
  return  $self->{POST_OPT} ; 
}


1;
