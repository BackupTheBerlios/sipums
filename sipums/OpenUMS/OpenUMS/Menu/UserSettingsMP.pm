package OpenUMS::Menu::UserSettingsMP ; 
### $Id: UserSettingsMP.pm,v 1.1 2004/07/20 02:52:15 richardz Exp $
#
# UserSettingsMP.pm
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
 
  my $self = shift ; 
  my $ctport = $self->{CTPORT} ; 
   ## if there's no setting type or it's GETPASSWD, we just do default behavior...
  if (!$self->setting_type()  || $self->setting_type() eq 'GETPASSWD') { 
    return $self->SUPER::_play_menu();
  } 
  my $user = $self->{USER} ; 

  my $menuSounds = $self->{SOUNDS_ARRAY};
  my $sound  ; 
  $sound .=   PROMPT_PATH . $menuSounds->{M}->[0]->{sound_file}  ;
  if ($self->setting_type() =~ /^PLAY/ ) {
     ## what's the variable to play....
     my $msound = $menuSounds->{M}->[1] ;  
     if ($self->setting_type() eq 'PLAYGREET') {
       my ($temp_file, $temp_path) = $user->get_temp_file('RECGREET'); 
       if ($temp_file) {  
          $sound =  "$temp_path$temp_file"; 
       } else { 
          my ($greeting_file, $greeting_path) = $user->get_greeting();
          $log->debug("[UserSetting.pm] Got greeting: $greeting_path$greeting_file"); 
          if ($greeting_file) { 
             $sound .=  " " .  $greeting_path . $greeting_file ; 
          }  else {
             $sound =   PROMPT_PATH . "nogreetingrecorded.vox" 
          } 
       } 
     }  elsif ($self->setting_type eq 'PLAYNAME')  {
       my ($temp_file, $temp_path) = $user->get_temp_file('RECNAME');
       if ($temp_file) {
          $sound =  "$temp_path$temp_file";
       } else {

          my ($name_file, $name_path) = $user->get_name();
          $log->debug("[UserSetting.pm] Got name: $name_path$name_file"); 
          if ($name_file) { 
             $sound .=  " " .  $name_path . $name_file ;
          }  else {
             $sound =   PROMPT_PATH . "nonamerecorded.vox" 
          } 
       }
    }
  }  elsif ($self->setting_type() =~ /^CONF/) {
     my $i =1;
     my @to_play_sounds;
                                                                                                                             
     while (defined($menuSounds->{M}->[$i] )  ) {
          my $msound = $menuSounds->{M}->[$i];
          if ($msound->{sound_file}) {
            push @to_play_sounds,PROMPT_PATH . $msound->{sound_file} ;
          }
                                                                                                                             
          if ($msound->{var_name} eq 'NEW_PASSWORD') {
             my $sound = OpenUMS::Common::ext_sound_gen($user->new_password() );
             push @to_play_sounds,  $sound;
          }
        $i++;
     }
     ## now put them all together...
     if (scalar(@to_play_sounds) ) {
        $sound .=   " " . join (" ", @to_play_sounds );
     }
 
  } elsif ($self->setting_type() =~ /^MOBILESTAT/) {
    if ($user->get_value('mobile_email_flag')  ) { 
      $sound .= " " . PROMPT_PATH . "activated.vox";   
    }  else {
      $sound .= " " . PROMPT_PATH . "deactivated.vox";   
    } 
  } 

  if (defined($sound) ) { 
    ## hey, it's gotta be there...
    $ctport->play($sound); 
  } 
  return ;
} 

#################################
## sub setting_type
#################################
sub setting_type {
  my $self = shift;
  if (@_ ) { 
    $self->{SETTING_TYPE}  = shift ; 
  } 
  return $self->{SETTING_TYPE}; 
}


#################################
## sub _get_input
#################################
sub _get_input {
  my $self = shift ;
  my $ctport = $self->{CTPORT};
  my $input ;
  ## if there's no setting type or it's the CONF menu, we just do default behavior...
  if (!$self->setting_type() || ($self->setting_type() eq 'CONFPASSWD') ||
      $self->setting_type() eq  'MOBILEDEACT' || $self->setting_type() eq  'MOBILEACT') { 
    return $self->SUPER::_get_input();
  } 
  
  if ( ($self->setting_type() eq 'MOBILESTAT') ) { 
    return ;   
  } 
  if ($self->setting_type() eq  'GETPASSWD' ) {
    $input = $self->get_var_len_input() ;
    $self->{INPUT} = $input;
    return;
  } elsif ($self->setting_type() =~ /^PLAYGREET/) {
      return ;  
  } elsif ($self->setting_type() =~ /^REC/) {
      my $user = $self->{USER}; 
      $user->create_temp_file($self->setting_type());
      my ($file, $path) = $user->get_temp_file($self->setting_type());
      $log->debug( "[UserSetting.pm] getting input for " . $self->setting_type() . " temp is : $file $path");
      $ctport->clear();
      OpenUMS::Common::comtel_record($ctport, "$path$file",60,"*#",SILENCE_TIMEOUT);
      return ;  
  } 
}

#################################
## sub validate_input
#################################
sub validate_input {
  my $self = shift ; 
 
  my $input = $self->{INPUT} ; 
  ## if there's no setting type or it's the CONF menu, we just do default behavior...
  if (!$self->setting_type() || 
     ($self->setting_type() eq 'CONFPASSWD') || 
      ($self->setting_type() eq  'MOBILEDEACT') || ($self->setting_type() eq  'MOBILEACT') )  { 
    return $self->SUPER::validate_input();
  } 
  if ( ($self->setting_type() eq 'MOBILESTAT') ) { 
    return 1;   
  } 
  ## play and record just return, ie we don't validate 
  if ($self->setting_type =~ /^PLAY|^REC/) {
     return 1;
  } elsif ($self->setting_type =~ /^GETPASSWD/) {
     ## check that the password is not too long or too short
     if ((length($input) < MIN_PASSWORD_LENGTH)   || (length($input) > MAX_PASSWORD_LENGTH ) ) { 
        return 0;
     }  else {
        return 1;
     }
  } 

}


#################################
## sub process
#################################
sub process {
  my $self = shift;
  my $input = $self->{INPUT} ; 

  if (!OpenUMS::Common::is_phone_input($input) && $self->{MENU_OPTIONS}->{DEFAULT}->{item_action}) {
    $log->debug("[UserSettingMP.pm] NO input but there a default action, setting input to DEFAULT"); 
     $input = 'DEFAULT' ; 
  } 

  my $user = $self->{USER}; 


  ## get the item_action & next_id 
  my $action ;
  my $item_action = $self->{MENU_OPTIONS}->{$input}->{item_action} ; 
  my $next_id = $self->{MENU_OPTIONS}->{$input}->{dest_id} ; 
  
  ## if there is no defined setting_type (menu.param1) and  there is no item_action (like save or play)
  ## we return default
  if (!$self->setting_type() && !($item_action)) { 
    return $self->SUPER::process();
  } 

   ## sort of the same condition for CONFPASSWD but i wanna keep it separate :~)
  if ($self->setting_type() =~ /^CONFPASSWD/ && !($item_action) ) {
    return $self->SUPER::process();
  } 

   ## sort of the same condition for MOBILEDEACT & MOBILEACT but i wanna keep it separate :~)
  if ( ( $self->setting_type() eq  'MOBILEDEACT' || $self->setting_type() eq  'MOBILEACT') 
      && !($item_action) ) {
    return $self->SUPER::process();
  } 

  ## Are they trying to save a setting 
  if ($item_action =~ /^SAVE/) { 
    
     if ($item_action eq 'SAVEPASSWD') { 
        ## save the password
        $log->debug("[UserSetting.pm] Saving new password ");
        $user->save_new_password();
        my $ctport = $self->{CTPORT} ; 
        $ctport->play(PROMPT_PATH . "password_saved.vox");
     } elsif ($item_action eq 'SAVEMOBILE') { 
   
       my $ctport = $self->{CTPORT} ; 
       if ($self->setting_type() eq  'MOBILEDEACT') {
         ## they are trying to deactivate it...
           $user->save_mobile_email_flag(0);         
           $ctport->play(PROMPT_PATH . "mobile_notification_deactivated.vox");
       } else {
         ## they are tryingt to activate it.
        if ($user->get_value('mobile_email')) { 
           $user->save_mobile_email_flag(1);         
           $ctport->play(PROMPT_PATH . "mobile_notification_activated.vox");
          ## make sure they have mobile e-mail defined...
        } else {
           $ctport->play(PROMPT_PATH . "mobile_notification_error.vox");
        } 
         
       } 
     } else {
        if ($item_action eq 'SAVEGREET') { 
            $log->debug("[UserSetting.pm] SAVING GREETING FOR  USER " . $user->extension());
            $user->save_greeting(); 
            my $ctport = $self->{CTPORT} ; 
            $ctport->play(PROMPT_PATH . "greeting_activate.vox");
        } elsif ($item_action eq 'SAVENAME') {
            $log->debug("[UserSetting.pm] SAVING NAME FOR  USER " . $user->extension());
            $user->save_name();
#           my $ctport = $self->{CTPORT} ;
#           $ctport->play(PROMPT_PATH . "greeting_activate.vox");
        }
        $user->clear_temp_file(); 
     } 
     $action = "NEXT";
     return ($action, $next_id) ;    
  } elsif ($item_action =~ /^CANCEL/) {
	$log->debug("[UserSetting.pm] Action cancelled .... clearing temp file...");
        $user->clear_temp_file(); 
     $action = "NEXT";
     return ($action, $next_id) ;    

  }

  if ($self->setting_type() =~ /^MOBILESTAT/) {
     $next_id = OpenUMS::DbQuery::get_mobile_menu_id($self->{DBH},$user->get_value('mobile_email_flag') ) ;  
     $action = "NEXT";
     return ($action, $next_id) ;    
  } 

  ##  for the any type of play or record , we just return  the DEFAULT
  ## since there is really nothing to process...
  if ($self->setting_type() =~ /^PLAY|^REC/ ) {
     $next_id = $self->{MENU_OPTIONS}->{DEFAULT}->{dest_id} ; 
     $action = "NEXT";
     return ($action, $next_id) ;    
  } 

  if ($self->setting_type() =~ /^GETPASSWD/) {
     $log->normal("User entered a new password: $input");
     $user->new_password($input);
     $action = "NEXT";
     $next_id =  $self->{MENU_OPTIONS}->{'DEFAULT'}->{dest_id} ;
     return ($action, $next_id) ;    
  } 

}
  
1; 
