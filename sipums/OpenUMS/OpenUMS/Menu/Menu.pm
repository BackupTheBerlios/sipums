package OpenUMS::Menu::Menu;

### $Id: Menu.pm,v 1.3 2004/07/31 21:51:15 kenglish Exp $
#
# Menu.pm
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

=pod
=head1 NAME
                                                                                                                             
OpenUMS::Menu::Menu - Master Control Class for Openums menu system
                                                                                                                             
=head1 SYNOPSIS
                                                                                                                             
  use OpenUMS::Menu::Menu;
  use OpenUMS::Common;
  use Telephony::CTPort;

  my $ctport = new Telephoney::CTPort($port); 
  my $dbh = OpenUMS::Common::get_dbh();
  my $menu = new OpenUMS::Menu::Menu($dbh, $ctport); 
  ## query the database for the latest menu structure...
  $menu->create_menu (); 
  ## RUN THAT BAD DOG 
  $menu->run_menu($extension_to, $caller_id ) ;     
                                                                                                                             
=head1 DESCRIPTION 

This module implements an Object-Oriented interface to Menu System for
the OpenUMS Voicemail System.
                                                                                                                             
=head1 AUTHOR
                                                                                                                             
Kevin English, kenglish@comtelhi.com
Matt Darnell , mdarnell@comtelhi.com
Dean Takemori, dtakemore@comtelhi.com
                                                                                                                             
=cut
                                                                                                                             



use strict ; 

use OpenUMS::Config ; 
use OpenUMS::Log;
use OpenUMS::Object::User ; 
use OpenUMS::Permissions ; 
use OpenUMS::DbUtils ; 
use OpenUMS::DbQuery ; 

use OpenUMS::Menu::MenuProcessor ; 
use OpenUMS::Menu::IntroMP ; 
use OpenUMS::Menu::ExtensionMP ; 
use OpenUMS::Menu::PasswordMP ; 
use OpenUMS::Menu::MessageMP ; 
use OpenUMS::Menu::AppendMsgMP ; 
use OpenUMS::Menu::AAGMP; 
use OpenUMS::Menu::RecMsgMP ; 
use OpenUMS::Menu::DbnmMP; 
use OpenUMS::Menu::DbnmResultMP ; 
use OpenUMS::Menu::InfoMP ; 
use OpenUMS::Menu::AdminMP ; 
use OpenUMS::Menu::UserSettingsMP ; 
use OpenUMS::Menu::PostRecMsgMP;
use OpenUMS::Menu::ForwardMessageMP;


#################################
## sub new
#################################
sub new {
  ## this your standard 'new', it intializes the hash and blesses it
  ## expected parametes:
  ##  $dbh = a valid database handle. Should already be connected to a database
  ## containing an instance of our standard voicemail database   
  ##  $ctport = a valid instance of the Telephony::CTPort object. 
  my $proto = shift;
  my $dbh = shift;
  my $ctport = shift;
  my $phone_sys = shift;

  my $ext_to = shift;
  my $ext_from = shift;

  my $class = ref($proto) || $proto;
  my $self = {}; ## self is a hash ref

  ## we add the parameters to the hash ref..
  $self->{DBH} = $dbh;
  $self->{CTPORT} = $ctport;
  $self->{PHONE_SYSTEM} = $phone_sys;
  $self->{MENU_OBJ} = undef; 
  $self->{EXTENSION_TO} = $ext_to ; 
  $self->{EXTENSION_FROM} = $ext_from ; 
  ## bless that puppy, ie, make it an object ref
  

  bless($self, $class);
  return $self;
}
#######################################################
## sub create_menu() ; 
## this sub queries the database and creates the MENU_OBJ
## the MENU_OBJ has all options, the menuProcessor and collectors 
## to reload changes to the menu made in the database 
#######################################################

sub create_menu {
  my $self = shift; 
  my $admin = shift; 
  my $dbh = $self->{DBH}; 
  my $ctport = $self->{CTPORT}; 

  my $sql = qq{SELECT menu_id , title , menu_type_code, max_attempts, permission_id, collect_time, 
                 param1, param2, param3, param4  
               FROM menu };
  if ($admin ) {
    
  } 

  my $sth = $dbh->prepare($sql);
  my $user = new OpenUMS::Object::User($dbh,$self->{EXTENSION_TO},$self->{EXTENSION_FROM} );  ## create a dummy user object...
  ## we need a ref to that user also
  $self->{USER} = $user ; 
  my $phone_sys =  $self->{PHONE_SYSTEM};

  $sth->execute();
  my $menuObj;

  while (my ($menu_id, $menu_title, $menu_type_code, 
             $max_attempts,$permission_id, $collect_time, $param1, $param2, $param3,
             $param4 ) = $sth->fetchrow_array() ) {
    $menuObj->{$menu_id}->{id} = $menu_id;  ## kind of redundatn but you'll see, it helps..
    $menuObj->{$menu_id}->{type} = $menu_type_code;
    $menuObj->{$menu_id}->{title} = $menu_title;
    $menuObj->{$menu_id}->{max_attempts} = $max_attempts;
    $menuObj->{$menu_id}->{permission_id} = $permission_id;
    $menuObj->{$menu_id}->{collect_time} = $collect_time;
    $menuObj->{$menu_id}->{param1} = $param1;
    $menuObj->{$menu_id}->{param2} = $param2;
    $menuObj->{$menu_id}->{param3} = $param3;
    $menuObj->{$menu_id}->{param4} = $param4;

    ## to create the menuProcessor, we look at the type. This essentially maps the
    ## database menu_type_code to the 

    ## current valid menu types:
    ## AAM BASIC DBNM DBNMRES EXT MSGS PASSWD RECMSG SETGET SETPLAY XFER
    ## custom menuProcessor for menu type:
    ##   AAM DBNMRES MSGS RECMSG SETGET SETPLAY XFER
    ## the rest are handle by the default, in 'else'

##    if ($menu_type_code eq 'AAM' ) {
 ##      ## this is an auto attendant  Menu...
##      $menuObj->{$menu_id}->{menuProcessor} = new OpenUMS::Menu::AutoAttendantMP($dbh, $ctport, $user, $phone_sys, 
##                                        $menu_id,$permission_id, $collect_time );
##      $menuObj->{$menu_id}->{menuProcessor}->aa_type($menu_type_code); 
##    } elsif ($menu_type_code eq 'AAG') { 
    if ($menu_type_code eq 'AAG') { 
      $menuObj->{$menu_id}->{menuProcessor} = new OpenUMS::Menu::AAGMP($dbh, $ctport, $user, $phone_sys, 
                                        $menu_id,$permission_id, $collect_time );
      $menuObj->{$menu_id}->{menuProcessor}->aa_type($menu_type_code); 
    } elsif ($menu_type_code eq 'APPENDMSG') { 

      $menuObj->{$menu_id}->{menuProcessor} = new OpenUMS::Menu::AppendMsgMP($dbh, $ctport, $user, $phone_sys, 
                                        $menu_id,$permission_id, $collect_time );
    } elsif ($menu_type_code eq 'DBNM') { 

      $menuObj->{$menu_id}->{menuProcessor} = 
          new OpenUMS::Menu::DbnmMP($dbh, $ctport,$user, $phone_sys, $menu_id,$permission_id, $collect_time ) ; 
      $menuObj->{$menu_id}->{menuProcessor}->dbnm_type($param1); 
    } elsif ($menu_type_code eq 'USERSET') {

      $menuObj->{$menu_id}->{menuProcessor} =
          new OpenUMS::Menu::UserSettingsMP($dbh, $ctport,$user, $phone_sys, $menu_id,$permission_id, $collect_time ) ;
      $menuObj->{$menu_id}->{menuProcessor}->setting_type($param1);

    } elsif ($menu_type_code eq 'DBNMRES') {
      $menuObj->{$menu_id}->{menuProcessor} =
          new OpenUMS::Menu::DbnmResultMP($dbh, $ctport,$user, $phone_sys, $menu_id,$permission_id, $collect_time ) ;
      $menuObj->{$menu_id}->{menuProcessor}->dbnm_type($param1);

    } elsif ($menu_type_code eq 'LOGIN') { 
      $menuObj->{$menu_id}->{menuProcessor} = 
          new OpenUMS::Menu::ExtensionMP($dbh, $ctport,$user,$phone_sys,$menu_id,$permission_id, $collect_time ) ; 

    } elsif ($menu_type_code eq 'MSGS') { 
      ## MSGS is for listening to messages...
      $menuObj->{$menu_id}->{menuProcessor} = new OpenUMS::Menu::MessageMP($dbh, $ctport, $user,$phone_sys, 
                                        $menu_id,$permission_id, $collect_time );
      ## this would be 'N' or 'S' for new or saved...
      $menuObj->{$menu_id}->{menuProcessor}->message_status_id($param1); 
   } elsif ($menu_type_code eq 'FWDMSG') {
      ## MSGS is for listening to messages...
      $menuObj->{$menu_id}->{menuProcessor} = new OpenUMS::Menu::ForwardMessageMP($dbh, $ctport, $user, $phone_sys,
                                        $menu_id,$permission_id, $collect_time );
      ## this would be 'N' or 'S' for new or saved...
      $menuObj->{$menu_id}->{menuProcessor}->menu_name($param1);
    } elsif ($menu_type_code eq 'PASSWD') { 
      $menuObj->{$menu_id}->{menuProcessor} = 

          new OpenUMS::Menu::PasswordMP($dbh, $ctport,$user, $phone_sys, $menu_id,$permission_id, $collect_time ) ; 

    } elsif ($menu_type_code eq 'RECMSG') {
       ## this is an to record a message for someone
      $menuObj->{$menu_id}->{menuProcessor} = new OpenUMS::Menu::RecMsgMP($dbh, $ctport, $user, $phone_sys,
                                        $menu_id,$permission_id, $collect_time );
      if (defined($param1) ) {
        ##
        $menuObj->{$menu_id}->{menuProcessor}->{EXTENSION_TO} = $param1
      }
    } elsif ($menu_type_code eq 'POSTRECMSG') {
       ## this is an to record a message for someone
      $menuObj->{$menu_id}->{menuProcessor} = new OpenUMS::Menu::PostRecMsgMP($dbh, $ctport, $user, $phone_sys,
   
                                        $menu_id,$permission_id, $collect_time );
       $menuObj->{$menu_id}->{menuProcessor}->post_opt($param1); 
    } elsif ($menu_type_code eq 'XFER') {
       ## this is an to transfer to an extension 
      $menuObj->{$menu_id}->{menuProcessor} = new OpenUMS::Menu::MenuProcessor($dbh, $ctport, $user, $phone_sys,
                                        $menu_id,$permission_id, $collect_time );
      if (defined($param1) ) {
        $menuObj->{$menu_id}->{menuProcessor}->{EXTENSION_TO} = $param1
      }

    } elsif ($menu_type_code eq 'UINTRO') { 
      $menuObj->{$menu_id}->{menuProcessor} = new OpenUMS::Menu::IntroMP($dbh, $ctport, $user, $phone_sys,
                                        $menu_id,$permission_id, $collect_time );
    } elsif ($menu_type_code eq 'UINFO') { 
      $menuObj->{$menu_id}->{menuProcessor} = new OpenUMS::Menu::InfoMP($dbh, $ctport, $user, $phone_sys, $menu_id,$permission_id, $collect_time );
      # $menuObj->{$menu_id}->{menuProcessor}->info_type($param1); 

    } elsif ($menu_type_code eq 'ADMIN') { 
      $menuObj->{$menu_id}->{menuProcessor} = new OpenUMS::Menu::AdminMP($dbh, $ctport, $user, $phone_sys, $menu_id,$permission_id, $collect_time );
      $menuObj->{$menu_id}->{menuProcessor}->setting_type($param1) ; 
      $menuObj->{$menu_id}->{menuProcessor}->sound_type($param2);
    } else { 
      $menuObj->{$menu_id}->{menuProcessor} = new OpenUMS::Menu::MenuProcessor($dbh, $ctport, $user , $phone_sys, 
                                        $menu_id,$permission_id, $collect_time );
    }

   ## end loop, go to the next record...
  }
  
  $sth->finish();
  ## add this menu to the 'self' object...
  $self->{MENU_OBJ} = $menuObj ; 
  ## now, install the permissions regime...
  my $perm  = new OpenUMS::Permissions($dbh); 
  $self->{PERMISSIONS} = $perm ; 

  return ;
}
##################################################
## sub run_menu 
##     runs the menu program, this is like the main
##################################################
sub run_menu {
  my $self = shift; 
  my $id = shift;
  my $extension_to = shift || undef  ; 
  my $caller_id = shift || undef  ; 
  $log->debug("run_menu called, Menu_id $id" );
  my $menuObj = $self->{MENU_OBJ} ;                                                                                                                             
  my $menu = $menuObj->{$id};

  if (!$menu || !$id) {
     return ;
  } 

  my $continue =  1; 
  my $attempts_count  = 1; 
  my $idles_count    = 1; 
  my $rotary_flag = 1; ## assume it's rotary...
  my $hung_up_flag = 0; ## assume it's rotary...
  

  while ( $continue ) {
    ## if they want out, let 'em leave
    $log->debug ("[Menu.pm] : menu_type_code:" . $menu->{type} . ",menu_id:" . $menu->{id}   );  
    if ($menu->{type} eq 'EXIT') {
       $rotary_flag = 0 ;
       last ;
    }  
    ## make a local copy of the menu's menuProcessor....

    my $menuProcessor =  $menu->{menuProcessor} ;
    ## set the exention_to, this will be needed for 
    ## transfers, record call and record message

    $menuProcessor->{EXTENSION_TO} = $extension_to if ($extension_to); 

    ## here we call the method to play the sound for this menu.... 
    ## it could do something or it could nothing, like for record call and
    ## and transfer, it does nothing

    ## handle the transfer 

    if ($menu->{type} eq 'XFER' ) {
        ## make this local, so it doesn't affecte anything
         my $local_ext_to = $extension_to ;
         if ($menu->{param1}){
             $local_ext_to = $menu->{param1} ;
         }
         $log->debug("USER SELECTED TRANSFER to $local_ext_to ");
         return $self->xfer_to_extension($local_ext_to);
    }

    $menuProcessor->init();
    ## play the sound.... 
    $menuProcessor->play_menu();
    ## make a copy of the menu's 

    ## Since we are using references, this collector could have been used earlier 
    ## and may have some old date in it. Thus we clear it
    $menuProcessor->clear() ; ## clear anything that might have been left from 

    ## set the exention_to, this will be needed for 
    ## record call and record message
    $menuProcessor->{EXTENSION_TO} = $extension_to if ($extension_to); 
    ## if extension_to is defined, undef it. 
    ## It should only hold over from the last menu
    if (defined($extension_to)) {
      $extension_to = undef ; 
    } 

    ## here the input from the user 
    $menuProcessor->get_input();
    ## check to see if they hung up during that input collect...
    my $valid ; 
    if ($menuProcessor->user_hung_up() ) {
      ## they hung up so let's get lost real fast....
      $log->debug("[Menu.pm] : User hung up") ; 
      $continue = 0 ; 
      $hung_up_flag = 1; 
    } else {  

       ## validate the input.... set the valid flag...
       $valid = $menuProcessor->validate_input();
       my $play_invalid = 0; ## this is used to determine if we will play the invalid or not..
       $log->debug("[Menu.pm] : validate_input... Valid = $valid no_input = " . $menuProcessor->no_input()) ; 

      if ($valid) {
         ## it's a valid input, so let's call menuProcessor and get the next action...
         my ($action, @params) = $menuProcessor->process() ; 
         if ($action eq 'NEXT' ) {
           ## if it's NEXT , we get the next menu....
           my $next_id = shift @params; 
           ## are they trying to leave... 
           if (!$next_id  || $self->is_exit($next_id) ) {
               $continue =0; 
           }  else {   
              ## are they not authorized...
              if ($self->is_user_authorized($next_id) ) { 
                 if (scalar(@params))  {
                   $extension_to =  shift @params; 
                 } 
      #           if ($menu->{menu_id} ne $next_id ) {
                 $attempts_count = 1; 
  #         }
  
                 $menu = $self->_get_next_menu($next_id);  
                 $rotary_flag = 0 ; 
                 next ; 
             } else {
                ## sort of pretend this didn't happen and just play_invalid....
                $play_invalid = 1; 
              } 
           }
         } elsif ($action eq 'RETCALL' ) { 
            if (scalar(@params))  {
               my $ext_from =  shift @params; 
               return $self->do_return_call($ext_from);
            } 
         }  
         if (!defined($menu) )  { 
           $log->debug("UNDEFINED MENU....."); 
           $continue = 0 ;
         } 
    
      } elsif ($menuProcessor->no_input() )  {
        $play_invalid = 0; 
        ## do nothing...
      }   else {
        ## they input something but it wasn't valid, let them know!
        $rotary_flag = 0 ; 
        $play_invalid = 1; 
      } 
  
      if ($play_invalid ) { 
        $log->debug("[Menu.pm] : gonna play_invalid \n" );
        $menuProcessor->play_invalid() ; 
      } 

      $attempts_count++;  
      if ($attempts_count > $menu->{max_attempts} ) { 
        $log->debug("[Menu.pm] : Max Attempts exceeded ...  "); 
        if ($menuProcessor->no_input() || !($valid) ) { 
          my ($action, $next_id) = $menuProcessor->process_default();    
          $log->debug("[Menu.pm] : Max Attempts exceeded no input, did process default.next_id = $next_id  "); 
          $menu = $self->_get_next_menu($next_id);  
          if (!defined($menu) ) { 
              $continue =0 ; 
          } 
        } else {
          $continue = 0; 
        } 
      } 
    }  ## end if user->hung_up
  }
  ## they are done...

  $log->debug("[Menu.pm] : Call done, rotary_flag = $rotary_flag ");
  $log->debug("Calling user->end_session ()  ");

  $self->{USER}->end_session(); 

# $my $saved = $self->{USER}->save_message() ;  ## doing this in  
#  $log->debug("[Menu.pm] : User save_message() = $saved");

  if ($rotary_flag && !($hung_up_flag) ) {
    $self->xfer_to_extension(); 
  } else { 
    if (!($hung_up_flag)) { 
      $self->{CTPORT}->play(PROMPT_PATH . "goodbye.wav"); 
      $self->{CTPORT}->on_hook(); 
    }
    $log->debug("call done");
  }
}

########################################################################
##  sub _get_next_menu
##    Gets a menuProcessor obj for the given Id
##############################################

sub _get_next_menu {
  ## this gets the hash for menu they will hear next...
  my $self = shift ; 
  my $next_id = shift;

  my $menuObj = $self->{MENU_OBJ} ; 
  my $menu = $menuObj->{$next_id};
  return $menu ;
}
########################################################################
##  sub xfer_to_extension ($ext)
##    Transfer to an extension
##############################################
sub xfer_to_extension {
  my $self =  shift;
  my $ext= shift;

#  my $ctport =  $self->{CTPORT} ;
#  my $dbh =  $self->{DBH} ;
                                                                                                                                               
  if (!$ext) { ## this means they sent 0 or it's not defined, we'll transfer to the operator...
      $log->err("transfer called with no extension, settting it to OPERATOR_EXTENSION");
     $ext = $main::GLOBAL_SETTINGS->get_var('OPERATOR_EXTENSION') ;
  } 

  ## let's look up and make sure it's a valid extension shoon....
  if (!OpenUMS::DbQuery::validate_mailbox($self->{DBH}, $ext) ) {
        $log->err("Tried to transfer to an invalid extenstion $ext, sending back to Auto Attendant");
        ## return to wherever they call from, we return 1 so they repeat
        ## the menu if there is one...
        my $menu_id = OpenUMS::DbQuery::get_action_menu_id($self->{DBH}, "auto_attendant");
        return $self->run_menu($menu_id);
   }
 

  ## does the user have transfer set to flag?
  if (!OpenUMS::DbQuery::get_user_xfer($self->{DBH}, $ext )) {
     ## this means the user wants every call to go straight to rec msg...
     my $menu_id = $self->get_rec_msg_menu_id();
     $log->debug("Transfer called but user $ext has transfer = No,record messsage menu_id = $menu_id ");
     return $self->run_menu($menu_id,$ext);
  }

  $log->debug("[Menu.pm] : transfering to $ext");
  ## play please hold...
  $self->{CTPORT}->play(PROMPT_PATH . "pleasehold.wov");
                                                                                                                                               
  $self->{CTPORT}->clear();
  $self->{STANDALONE} = undef ;
  
  
  ### $self->{CTPORT}->dial("&,$ext,");
  $self->{PHONE_SYSTEM}->do_transfer($ext);
                                                                                                                                               
#  $ctport->on_hook();
  $self->{CTPORT}->clear();
  return ;



}

########################################################################
##  sub xfer_to_extension_old($ext)
##    Transfer to an extension
##############################################

sub xfer_to_extension_old {

  my $self =  shift;
  my $ext= shift;

  my $ctport =  $self->{CTPORT} ;
  my $dbh =  $self->{DBH} ;


  if (!$ext) { ## this means they sent 0 or it's not defined, we'll transfer to the operator...
     $ext = $main::GLOBAL_SETTINGS->get_var('OPERATOR_EXTENSION') ;
  }
  else {
     ## let's look up and make sure it's a valid extension shoon....
     if (!OpenUMS::DbQuery::validate_mailbox($dbh, $ext) ) {
        $log->err("Tried to transfer to an invalid extenstion $ext");
        ## return to wherever they call from, we return 1 so they repeat
        ## the menu if there is one...
        return 0;
     }
  }
  $log->debug("[Menu.pm] : transfering to $ext");
  ## play please hold...
  $ctport->play(PROMPT_PATH . "pleasehold.vox");

  $ctport->clear();
  $self->{STANDALONE} = undef ;
  $ctport->dial("&,$ext,");
                                                                                                                                               
#  $ctport->on_hook();
  $ctport->clear();
  return ; ## this tells guy we're done...
  ## return to wherever they call from, we return 0 so they know not to repeat
  ## the menu ...
}

########################################################################
##  sub get_rec_msg_menu()
##    This returns the menu_id for the menu that will record a message
##############################################

sub get_rec_msg_menu_id {
  my $self = shift; 
  my $menuObj  =  $self->{MENU_OBJ} ; 
  foreach my $menu_id (reverse sort keys %{$menuObj} ) { 
     if  ($menuObj->{$menu_id}->{type} eq 'RECMSG') { 
        return $menu_id ; 
        $log->debug("[Menu.pm] : Called get_rec_msg_menu $menu_id $menuObj->{$menu_id}->{type} "); 
     } 
  } 
  return ; 
}

########################################################################
##  sub is_exit()
##   This returns 1 if the menu_type_code for the passed menu_id is 'EXIT'
##############################################

sub is_exit {
  my $self = shift; 
  my $menu_id = shift ; 
  my $menuObj  =  $self->{MENU_OBJ} ; 
  if ($menuObj->{$menu_id}->{type} eq 'EXIT') {
     return 1; 
  }  else {
     return 0 ; 
  } 
}

#################################
## sub is_user_authorized
#################################
sub is_user_authorized {
  my ($self,$next_menu_id)  = @_; 
  my $perm = $self->{PERMISSIONS}; 
  my $user = $self->{USER}; 
  my $menuObj  =  $self->{MENU_OBJ} ; 
  my $menu_perm_id = $menuObj->{$next_menu_id}->{permission_id} ; 
  if (!$next_menu_id) {
    ## huh? 
     return 0; 
  } 
  return $perm->is_authorized($menu_perm_id, $user->permission_id()) ; 
}

sub do_return_call {

  my ($self, $ext_from) = @_; 
  $log->debug("[Menu.pm] DOING RETURN CALL ... $ext_from ") ; 
  my $to_dial ; 
  my $area_code = AREA_CODE  ; 
  if (length($ext_from) ==  EXTENSION_LENGTH) { 
     $to_dial = $ext_from ; 
  } else {
    $to_dial = $ext_from ; 
    if ($to_dial =~ /^$area_code/) { 
       $to_dial =~ s/^$area_code//g;
     } 
     ## if it's still 10, then it must be long dist...
     if (length($to_dial) == 10) { 
       $to_dial = '1' . $to_dial; 
     } 
     $to_dial =  '9,' . $to_dial;
  } 
  my $ctport =  $self->{CTPORT} ;
  $log->debug("[Menu.pm] RETURNING CALL DIALING $to_dial ") ; 
  $ctport->dial("&,$to_dial,");


                                                                                                                                               
#  $ctport->on_hook();
  $ctport->clear();

  
  return ;

}

sub get_user {
  my ($self)  = shift; 
  return $self->{USER}; 
}
1;
