package OpenUMS::Menu::MessageMP; 
### $Id: MessageMP.pm,v 1.3 2004/08/11 03:32:27 kenglish Exp $
#
# MessagePresenter.pm
#
# Plays messages and menu choices for caller.
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

use OpenUMS::Config; 
use OpenUMS::Log; 
use OpenUMS::Menu::MenuProcessor; 

use base ("OpenUMS::Menu::MenuProcessor");

use strict ; 


#################################
## sub message_status_id
#################################
sub message_status_id {
  my $self = shift;

  ## this is the set...
  if (@_) {
    $self->{MESSAGE_STATUS_ID} = shift ;
    return ; 
  }

  my $status =  $self->{MESSAGE_STATUS_ID} ; 

  if ($status eq 'N' || ($status eq 'S') ) { 
     return $status ; 
  }  elsif ($status eq 'U') {
    ## this means we get it off the session... we need 
    my $user = $self->{USER}; 
    $log->debug("this is a session detect message menu... last_message_status_id = " .  $user->last_message_status_id() . 
    " VIRTUAL_MESSAGE_STATUS_ID =  " .   $self->{VIRTUAL_MESSAGE_STATUS_ID}   ); 
    if ($user->last_message_status_id() ) { 
      if ($self->{VIRTUAL_MESSAGE_STATUS_ID} eq $user->last_message_status_id()  ) {
         $log->debug("VIRTUAL_MESSAGE_STATUS_ID already set, returning that..." . $self->{VIRTUAL_MESSAGE_STATUS_ID} ); 
         ## the database values, the options and all should be loaded...
         return $self->{VIRTUAL_MESSAGE_STATUS_ID} ; 
      }  else {
        ## get the menu id for this schema
         $log->debug("Going to DB to retrieve menu setting for : " . $user->last_message_status_id()   ); 
        $self->{MENU_ID} = $self->get_message_status_menu_id($user->last_message_status_id()  );  
        ## force it to load the data...
        $self->_pre_data();
                                                                                                                                               
        $self->_get_data();
        $self->_get_data2();
        $self->_post_data();
        ## now set the virtual status id so we don't try to load it again....
        $self->{VIRTUAL_MESSAGE_STATUS_ID} = $user->last_message_status_id() ;   
      } 
    }
  
  }  
}



#################################
## sub _play_menu ()
#################################
sub _play_menu () {
  ## this the most basic of basic plays....
  my $self = shift ; 
  my $ctport = $self->{CTPORT} ; 
  my $user = $self->{USER} ; 

  my $sound  ; 
  
  my $status = $self->message_status_id() ; 


  my $message_spool  = $user->get_message_spool($self->message_status_id() ); 
  $log->debug("[MessageMP.pm] User's last_message_file is : = " . $user->last_message_file() ); 
 
  ## check to  see there are messages 
  my $event_var = $message_spool->get_last_action(); 
  if (! ($message_spool->size())  ) {
    $log->debug("[MessageMP.pm] Message Spool emtpy, status_id = " . $self->message_status_id() ); 
    if ($event_var) {
      my $var_ref = $self->get_sound_var_ref($event_var) ;

      if ($var_ref->{sound_file}) { 
        $sound .= OpenUMS::Common::get_prompt_sound( $var_ref->{sound_file}) ;
        $sound .= " " ; 
  
        $message_spool->set_last_action(undef);
      } 
    }

    if (!$event_var ) { 
      ## they just got here, didn't do nothing...
      my $var_ref = $self->get_sound_var_ref('NOMSG') ;
      $sound .= OpenUMS::Common::get_prompt_sound(  $var_ref->{sound_file}) . " "  ;
    } else {
      my $var_ref = $self->get_sound_var_ref('NOMOREMSG') ;
      $sound .= OpenUMS::Common::get_prompt_sound(  $var_ref->{sound_file}) . " "  ;
    } 

    if (defined($sound) ) { 
      ## hey, it's gotta be there...
      $ctport->play($sound); 
    } 
    return ; 
  } 

  my $msg_obj = $message_spool->get_current_message(); 
  my $msg_sound = $main::CONF->get_var('VM_PATH')  . $msg_obj->get_sound(); 


  if (!$msg_obj->heard()) { 
    $log->debug("[MessageMP.pm] Message not heard by user, msg_sound = $msg_sound\n"); 

    if ($event_var) { 
      my $var_ref = $self->get_sound_var_ref($event_var) ; 
      $sound .= OpenUMS::Common::get_prompt_sound($var_ref->{sound_file}) ; 
      $sound .= " " ; 
      $message_spool->set_last_action(undef); 
    } 
    ## set the user's last sound_file, this is required for when they go into the forward message...
    $user->last_message_file($msg_obj->get_sound_file() ); 
    $user->last_message_status_id($self->message_status_id() ); 
    $sound .=  "$msg_sound "; 
  } 

  if (defined($event_var) && ($event_var eq 'TDSMSG')) {
    $sound .=  $message_spool->get_current_tds_sound() . " "; 
    $message_spool->set_last_action(undef);
  } 
  

  my $menuSounds = $self->{SOUNDS_ARRAY}; 

  $sound .=   OpenUMS::Common::get_prompt_sound($menuSounds->{M}->[0]->{sound_file})  ; 

  if (!$msg_obj->heard()) {
    $msg_obj->play_started(); 
  }
  if (defined($sound) ) { 
    ## hey, it's gotta be there...
    $ctport->play($sound); 
  } 
  return ;
} 

#################################
## sub play_invalid
#################################
sub play_invalid {
  my $self = shift ; 
  ## get the 2 objects...
  my $ctport = $self->{CTPORT}; 
  my $menuSounds = $self->{SOUNDS_ARRAY}; 
  my $invalid_sound  = $menuSounds->{I}->[0]->{sound_file};
  if ($invalid_sound) { 
      $ctport->play(OpenUMS::Common::get_prompt_sound($invalid_sound) ) ; 
  } 
  return ;
} 

#################################
## sub _get_input
#################################
sub _get_input {
  my $self = shift ; 
  my $user = $self->{USER}; 
  my $message_spool  = $user->get_message_spool($self->message_status_id() ); 
  ## fool it here, if they don't have  messages we just exit...

  if (!( $message_spool->size()) ) {
    my $input =  $self->get_item_action_input('EXITMSG') ; 
    $self->{INPUT} = $input ; 
    $log->debug("[MessageMP.pm] Message Spool empty, exiting messages") ; 
  } else {
    ## otherwise, we call the default...
    my $msg_obj = $message_spool->get_current_message();
    $msg_obj->play_stopped();
    $msg_obj->mark_heard(); 
    $self->SUPER::_get_input(); 
  } 

} 


#################################
## sub process
#################################
sub process {
  my $self = shift;
  my $input = $self->{INPUT} ; 
  my $user = $self->{USER} ;
  my $message_spool  = $user->get_message_spool($self->message_status_id() );
  my ($action, $next_id); 
  ## only one option here.....
  $self->{RESET_ATTEMPTS} = 1;  
  if ($self->{MENU_OPTIONS}->{$input}->{item_action} eq 'REWMSG') {
    $log->debug("[MessageMP.pm] User selected REWMSG (rewind)"); 
    my $msg_obj = $message_spool->get_current_message();
    $msg_obj->rewind();
    #$message_spool->set_last_action('REWMSG') ;
    $action = "NEXT";
    $next_id =  $self->{MENU_OPTIONS}->{$input}->{dest_id} ;
  } elsif ($self->{MENU_OPTIONS}->{$input}->{item_action} eq 'FFMSG')  {
    $log->debug("[MessageMP.pm] User selected FFMSG (fast forward)"); 
    my $msg_obj = $message_spool->get_current_message();
    $msg_obj->fast_forward();
    #$message_spool->set_last_action('REWMSG') ;
    $action = "NEXT";
    $next_id =  $self->{MENU_OPTIONS}->{$input}->{dest_id} ;
  } elsif ($self->{MENU_OPTIONS}->{$input}->{item_action} eq 'DELMSG') {
    $log->debug("[MessageMP.pm] User selected DELMSG (delete)"); 
    $message_spool->delete_current_message() ; 
    $message_spool->set_last_action('DELMSG') ; 
    $action = "NEXT";
    $next_id =  $self->{MENU_OPTIONS}->{$input}->{dest_id} ;
  } elsif ($self->{MENU_OPTIONS}->{$input}->{item_action} eq 'SAVEMSG') { 
    $log->debug("[MessageMP.pm] User selected SAVEMSG (save)"); 
    $message_spool->save_current_message() ; 
    $message_spool->set_last_action('SAVEMSG') ; 
    $action = "NEXT";
    $next_id =  $self->{MENU_OPTIONS}->{$input}->{dest_id} ;
  }  elsif ($self->{MENU_OPTIONS}->{$input}->{item_action} eq 'REPMSG') {
    $log->debug("[MessageMP.pm] User selected REPMSG (repeat)"); 
    my $msg_obj = $message_spool->get_current_message() ; 
    $msg_obj->repeat() ; 
    $action = "NEXT";
    $next_id =  $self->{MENU_OPTIONS}->{$input}->{dest_id} ;
  }  elsif ($self->{MENU_OPTIONS}->{$input}->{item_action} eq 'TDSMSG') {
    $log->debug("[MessageMP.pm] User selected TDSMSG (time-date-stamp)"); 
    $message_spool->set_last_action('TDSMSG') ; 
    $action = "NEXT";
    $next_id =  $self->{MENU_OPTIONS}->{$input}->{dest_id} ;
  } elsif ($self->{MENU_OPTIONS}->{$input}->{item_action} eq 'EXITMSG' ) {
    $log->debug("[MessageMP.pm] User selected EXITMSG (exit messages), we delete the message spool."); 
    $user->delete_message_spool( $self->message_status_id() ) ;  
    $action = "NEXT";
    $next_id =  $self->{MENU_OPTIONS}->{$input}->{dest_id} ;
  } elsif ($self->{MENU_OPTIONS}->{$input}->{item_action} eq 'NEWMSG') {
    $log->debug("[MessageMP.pm] User selected NEWMSG (mark new)."); 
    $message_spool->mark_new_current_message() ;
    $message_spool->set_last_action('NEWMSG') ;
    $action = "NEXT";
    $next_id =  $self->{MENU_OPTIONS}->{$input}->{dest_id} ;
 } elsif ($self->{MENU_OPTIONS}->{$input}->{item_action} eq 'RETCALL') {
    $log->debug("[MessageMP.pm] User selected RETCALL ."); 
    $action = "RETCALL";
    my $msgObj = $message_spool->get_current_message(); 
    my $ext_from = $msgObj->get_extension_from();  
    $next_id = $ext_from; 
 } else {
    $action = "NEXT";
    $next_id =  $self->{MENU_OPTIONS}->{$input}->{dest_id} ;
 } 
  return ($action, $next_id) ;    
}
sub get_message_status_menu_id {
  my $self = shift ;
  my $message_status_id = shift ; 
  my $dbh = $self->{DBH}; 
  my $sql = qq{SELECT menu_id FROM menu WHERE menu_type_code = 'MSGS' and param1 = ? }; 
  my $sth = $dbh->prepare($sql);
  $sth->execute($message_status_id ) ; 
  my $menu_id = $sth->fetchrow();
  $sth->finish();
  $log->debug ("get_message_status_menu_id menu_id = $menu_id "); 
  return $menu_id ; 

}
1;
