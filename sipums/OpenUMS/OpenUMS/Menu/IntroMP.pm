package OpenUMS::Menu::IntroMP ; 

### $Id: IntroMP.pm,v 1.5 2004/08/13 19:32:47 kenglish Exp $
#
# .pm
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
use base ("OpenUMS::Menu::MenuProcessor");



#################################
## sub _play_menu ()
#################################
sub _play_menu () {

  ## this the most basic of basic plays....
  my $self = shift ; 
  my $ctport = $self->{CTPORT} ; 
  my $user = $self->{USER}; 
  if ($user->jump_to_menu_id() )  {
     return ;
  } 
  $log->debug("Jumpt to menu_id is " .  $user->jump_to_menu_id() ); 
  #  $user->update_last_visit() ;
  ## here we check to see if they came from auto_login...
  # if (!($user->extension) && OpenUMS::DbQuery::is_auto_login($self->{DBH},$self->{EXTENSION_TO}) )   { 
  #    $log->debug("[IntroMP.pm] user is using auto_login, getting info"); 
  #    $user->auto_login($self->{EXTENSION_TO}) ; 
  #  }

  my $menuSounds = $self->{SOUNDS_ARRAY};
  my $sound = undef; 
  $log->debug("[IntroMP.pm] : user permission_id is " . $user->permission_id() ) ; 
  my @to_play_sounds; 
#  if ($user->get_value('store_flag') eq 'E') { 
#    $ctport->play(OpenUMS::Common::get_prompt_sound("accessing_messages"));
#  }


  my $new_message_count = $user->new_message_count(); 
  my $saved_message_count = $user->saved_message_count(); 
  $log->normal("[IntroMP.pm] Playing Intro to user at ext " . $user->extension() . 
     ", new = $new_message_count , saved = $saved_message_count "); 

#  if ($new_message_count > 0 ) { 
#    OpenUMS::Mwi::mwi_extension_on($self->{DBH},$user->{EXTENSION});
#  } 

  foreach my $msound ( @{$menuSounds->{M} } ) {
    if ($msound->{sound_file}) { 
      push @to_play_sounds,OpenUMS::Common::get_prompt_sound($msound->{sound_file}) ;
    } 
    if (defined($msound->{var_name} ) ) { 
      if  ($msound->{var_name} eq 'NAME') {
        my ($name_wav_file , $name_wav_path) = OpenUMS::DbQuery::get_name_file($self->{DBH}, $user->extension);
        if ($name_wav_file ) { 
          push @to_play_sounds, $main::CONF->get_var('VM_PATH') . "$name_wav_path$name_wav_file"; 
        } 
      } 
      elsif ($msound->{var_name} eq 'NEW_MESSAGE_COUNT' ) {
        if ($new_message_count > 0 ) { 
          my $sound = OpenUMS::Common::count_sound_gen($new_message_count); 
          push @to_play_sounds,  $sound; 
        } 
      }  
      elsif ($msound->{var_name} eq 'NEW_MESSAGE_SOUND' ) {
        if (!$new_message_count) { 
          push @to_play_sounds, OpenUMS::Common::get_prompt_sound(  "nonewmessages") ; 
        } elsif ($new_message_count ==1 )  { 
         ## singular...
          push @to_play_sounds, OpenUMS::Common::get_prompt_sound(  "newmessage") ; 
        } else  {
          push @to_play_sounds, OpenUMS::Common::get_prompt_sound( "newmessages") ; 
        } 
      }
      elsif ($msound->{var_name} eq 'SAVED_MESSAGE_COUNT' ) {
        if ($saved_message_count > 0 ) { 
          my $sound = OpenUMS::Common::count_sound_gen($saved_message_count); 
          push @to_play_sounds,  $sound; 
        } 
      } elsif ($msound->{var_name} eq 'SAVED_MESSAGE_SOUND' ) { 
        if (!$saved_message_count) {
          push @to_play_sounds, OpenUMS::Common::get_prompt_sound( "nosavedmessages") ;
        } elsif ($saved_message_count ==1 )  {
         ## singular...
          push @to_play_sounds, OpenUMS::Common::get_prompt_sound( "savedmessage") ;
        } else  {
          push @to_play_sounds, OpenUMS::Common::get_prompt_sound(  "savedmessages") ;
        }
      } 
    }
  } 
  $sound = join (" ", @to_play_sounds ); 

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
  my $input ; 

  my $user = $self->{USER}; 

  if ($user->jump_to_menu_id() )  {
     return ;
  } 


  if (TEXT_MODE) {
    $input = <STDIN>;
    chop($input); 
  } else {
    ## phone mode here dood...
    $input = $ctport->collect(1, 1);
  }  

  if (OpenUMS::Common::is_phone_input($input) ) { 
    $self->{INPUT} = $input; 
  }  else {
    $self->{INPUT} = undef; 
  } 
}


#################################
## sub validate_input
#################################
sub validate_input {
  my $self = shift ; 

  return 1 ; 
} 


#################################
## sub process
#################################
sub process {
  my $self = shift;
  my $input = $self->{INPUT} ; 

  my $action = "NEXT"; 
  ## only one option here.....
  ## only one option here.....
  my $next_id; 
  my $user = $self->{USER}; 
  if ($user->jump_to_menu_id() )  {

     $next_id  =  $user->jump_to_menu_id(); 
     ## then clear it..
     $user->clear_jump_to_menu_id(); 
  } else {  
     $next_id =  $self->{MENU_OPTIONS}->{$input}->{dest_id} ;
  }
  if (!$next_id ) {
     $next_id =  $self->{MENU_OPTIONS}->{DEFAULT}->{dest_id} ;
  }

  return ($action, $next_id) ;    
}

1;
