package OpenUMS::Menu::ForwardMessageMP; 
### $Id: ForwardMessageMP.pm,v 1.3 2004/09/01 03:16:35 kenglish Exp $
#
# MessagePresenter.pm
#
# Plays messages and menu choices for caller.
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

use OpenUMS::Config; 
use OpenUMS::Log; 
use OpenUMS::Menu::MenuProcessor; 

use base ("OpenUMS::Menu::MenuProcessor");

use strict ; 


#################################
## sub message_status_id
#################################
sub menu_name {
  my $self = shift;
  if (@_) {
    $self->{MENU_NAME} = shift ;
  }
  return $self->{MENU_NAME} ;
}



#################################
## sub _play_menu ()
#################################
sub _play_menu () {
  ## this the most basic of basic plays....
  my $self = shift ; 
  my $ctport = $self->{CTPORT} ; 
  my $user = $self->{USER} ; 
  if ($self->menu_name eq 'DBNMRES') {
    my $ext_input = $self->{EXTENSION_TO} ;
    my $user = $self->{USER};
                                                                                                                                               
     my $sound  ;
     my $dbnm_spool  = $user->get_dbnm_spool($ext_input, 'BOTH' ) ;
     my $cur = $dbnm_spool->get_current();
     my ($sound_path, $sound_file,$extension) = ($cur->{name_wav_path}, $cur->{name_wav_file},$cur->{extension} ) ;

      $log->debug("[DbnmResultMP.pm] phone_keys=$ext_input sound=$sound_path$sound_file extension=$extension)\n");
      $sound .=  "$sound_path$sound_file " ;

     my $menuSounds = $self->{SOUNDS_ARRAY};
                                                                                                                                               
     $sound .=   OpenUMS::Common::get_prompt_sound(  $menuSounds->{M}->[0]->{sound_file})  ;
                                                                                                                                               
                                                                                                                                               
     if (defined($sound) ) {
       ## hey, it's gotta be there...
       $ctport->play($sound);
     }
     return ;
  } 
  return $self->SUPER::_play_menu(); 
} 

#################################
## sub play_invalid
#################################
sub play_invalid {
  my $self = shift ; 
  ## get the 2 objects...
  return $self->SUPER::play_invalid(); 
} 

#################################
## sub _get_input
#################################
sub _get_input {
  my $self = shift; 
  my $ctport = $self->{CTPORT}; 
  $log->debug("get_input , menu_name = " . $self->menu_name()); 
  if ($self->menu_name() eq 'FWD'){
     $self->{INPUT} = 'DEFAULT'; 
     return ;
  } elsif ($self->menu_name() eq 'GETFWDMB') { 
      if (!defined($self->{EXTENSIONS} )) {
           $self->get_active_extensions();
      }
      my $input = $self->get_var_len_input(3) ; 
      if ($self->is_valid_extension($input) ) { 
        $self->{INPUT} = 'EXT'; 
        $self->{EXTENSION_TO}  = $input ; 
        $log->debug("They entered a valid extension : " . $self->{INPUT} . " EXTENSION_TO " . $self->{EXTENSION_TO} ); 
      } else {
        $self->{INPUT} = $input; 
      } 
   } elsif ($self->menu_name() =~ /^RECCOM/)  {  
      my $user = $self->{USER}; 
      $user->create_temp_file();
      my ($file, $path) = $user->get_temp_file();
      $log->debug( "getting input for RECFILE $file $path");
      $ctport->clear();


      my $menuSounds = $self->{SOUNDS_ARRAY};
      my $sound;

      if ($menuSounds->{M}->[1]->{sound_file} ) {
         $sound .=   OpenUMS::Common::get_prompt_sound( $menuSounds->{M}->[1]->{sound_file})  ;
         $ctport->play($sound);
      }
      OpenUMS::Common::comtel_record($ctport,"$path$file",60,"*#", SILENCE_TIMEOUT );
   } elsif ($self->menu_name() eq 'DBNM') {
     ## for dial by name results...
     my $input = $ctport->collect(3,$main::CONF->get_var('COLLECT_TIME'));
     $self->{INPUT} = $input;
   } else {
      return  $self->SUPER::_get_input(); 
   }
} 
sub validate_input {
  my $self = shift ;
                                                                                                                                               

  if ($self->menu_name() eq 'FWD' || $self->menu_name() =~ /^RECCOM/) { 
    return  1 ;
  } elsif ($self->menu_name() eq 'DBNM') {

     my $input = $self->{INPUT}; 
     my $dbnm_ar = $self->get_dbnm_list();

     if (!$input) {
        return 0 ;
     }
     foreach my $pkey  (@{$dbnm_ar} ) {
       if ($pkey =~ /^$input/) {
          return 1;
       }
    }
  } else {
    return  $self->SUPER::validate_input(); 
  }
}


#################################
## sub process
#################################

sub process {
  my $self = shift;
  my $user = $self->{USER};

  my $input       = $self->{INPUT} ;
  my $menuOptions = $self->{MENU_OPTIONS} ;

  $log->debug("process : " . $self->{INPUT} . " EXTENSION_TO " . $self->{EXTENSION_TO} ); 

  if ($self->menu_name() eq 'GETFWDMB' ) {
    if (defined($menuOptions->{$input}->{item_action}) )  { 
       if ($self->{MENU_OPTIONS}->{$input}->{item_action} =~ /^ADDEXT/ ){
          $log->debug(" adding mailbox to forward object " ); 
          my $fwdObj = $user->get_forward_object(); 
          $fwdObj->add_mailbox( $self->{EXTENSION_TO} ) ; 
       } 
    }

  } elsif ( $self->menu_name() eq 'DBNMRES') {
     if (defined($menuOptions->{$input}->{item_action}) )  {
       my $dbnm_spool  = $user->get_dbnm_spool($self->{EXTENSION_TO}, 'BOTH') ;
       if ($self->{MENU_OPTIONS}->{$input}->{item_action} =~ /^ADDEXT/ ){
          my $cur =  $dbnm_spool->get_current();
          my $extension_to = $cur->{extension};
          $log->debug(" adding mailbox to forward object $extension_to " );
          my $fwdObj = $user->get_forward_object();
          $fwdObj->add_mailbox( $extension_to ) ;
       } elsif ($self->{MENU_OPTIONS}->{$input}->{item_action} eq 'NEXTNAME' ) {
         $dbnm_spool->next();
       }#  else {
        # my $cur =  $dbnm_spool->get_current();
        # $extension_to = $cur->{extension};
      # }
    }
  } elsif ($self->menu_name() eq 'FWD') {
      $log->debug("menu_name = FWD"); 
      my $fwdObj = $user->get_forward_object(); 
      $fwdObj->forward_message();   
#      $user->clear_temp_file();
      return ("NEXT", $menuOptions->{DEFAULT}->{dest_id} ) ; 
  } elsif ($self->menu_name() =~ /^RECCOM/ ) {
    $log->debug("menu_name = RECCOM"); 
    my $fwdObj = $user->get_forward_object(); 
    my ($file, $path) = $user->get_temp_file();
    if ( $self->menu_name() eq 'RECCOMEND') { 
        $log->debug("set_end_comment : $file, $path "); 
        $fwdObj->set_end_comment($file, $path); 
    } elsif ( $self->menu_name() eq 'RECCOMBEG' ) { 
        $log->debug("set_begin_comment : $file, $path "); 
        $fwdObj->set_begin_comment($file, $path); 
    } 
    return ("NEXT", $menuOptions->{DEFAULT}->{dest_id} ) ; 
  } elsif ($self->menu_name() eq 'DBNM')  {
    my $param2  = $self->{INPUT};
                                                                                                                                               
    $log->debug("[DbnmMP.pm] DbnmCollect -> ACTION = ..$param2.. \n");
 
    return ("NEXT", $menuOptions->{DEFAULT}->{dest_id},$param2) ;
  }  

  return  $self->SUPER::process(); 
} 
#################################
## sub get_dbnm_list
#################################
sub get_dbnm_list {
  my $self = shift;
  if (!defined($self->{DBNM_AR}) ) {
     $self->{DBNM_AR}  = OpenUMS::DbQuery::get_dbnm_list($self->{DBH},'BOTH');
     ## get the list from the db...
  }
  return  $self->{DBNM_AR};
}


1; 

