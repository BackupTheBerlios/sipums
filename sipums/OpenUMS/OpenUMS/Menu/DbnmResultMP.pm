package OpenUMS::Menu::DbnmResultMP; 
### $Id: DbnmResultMP.pm,v 1.3 2004/09/01 03:16:35 kenglish Exp $
#
# DbnmResultMP.pm
#
# Plays dbnm and menu choices for caller.
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
use strict;

## this is the skeleton pacakge for the VmProc
use OpenUMS::Config; 
use OpenUMS::Log; 
use OpenUMS::Object::DbnmSpool; 
use OpenUMS::Menu::MenuProcessor; 

use base ("OpenUMS::Menu::MenuProcessor");


#################################
## sub _play_menu ()
#################################
sub _play_menu () {
  ## this the most basic of basic plays....
  my $self = shift ; 
  my $ctport = $self->{CTPORT} ; 
  my $ext_input = $self->{EXTENSION_TO} ; 
  my $user = $self->{USER}; 

  my $sound  ; 
  my $dbnm_spool  = $user->get_dbnm_spool($ext_input, $self->dbnm_type() ) ; 
  my $cur = $dbnm_spool->get_current(); 
  my ($sound_path, $sound_file,$extension) = ($cur->{name_wav_path}, $cur->{name_wav_file},$cur->{extension} ) ; 

#  if (!$cur->{HEARD} ) { 
    $log->debug("[DbnmResultMP.pm] phone_keys=$ext_input sound=$sound_path$sound_file extension=$extension)\n"); 
    $sound .=  "$sound_path$sound_file " ; 
#    $cur->{HEARD} = 1; 
#  } 

  my $menuSounds = $self->{SOUNDS_ARRAY}; 

  $sound .=   OpenUMS::Common::get_prompt_sound(  $menuSounds->{M}->[0]->{sound_file})  ; 


  if (defined($sound) ) { 
    ## hey, it's gotta be there...
    $ctport->play($sound); 
  } 
  return ;
} 

#################################
## sub clear
#################################
sub clear {
  ## this clears out all variable except the ctport and dbh var
  my $self = shift  ;
  $self->{INPUT} = undef ;
  $self->{LOST_CALL_FLAG} = undef ;
#  $self->{EXTENSION_TO} = undef ;
}

#################################
## sub process
#################################

sub process {
  my $self = shift;
  my $input = $self->{INPUT} ; 
  my $user = $self->{USER} ;
  ## get the spool...

  my $dbnm_spool  = $user->get_dbnm_spool($self->{EXTENSION_TO}, $self->dbnm_type() ) ;
  my $cur = $dbnm_spool->get_current();
  my ($sound_path, $sound_file,$extension) = ($cur->{name_wav_path}, $cur->{name_wav_file},$cur->{extension} ) ;

  $log->debug("[DbnmResultMP.pm] Processing, extension = $extension)\n"); 

  my ($action, $next_id); 
  ## only one option here.....

  $action = "NEXT";
  $next_id =  $self->{MENU_OPTIONS}->{$input}->{dest_id} ;

  my $extension_to = undef;
  if ($self->{MENU_OPTIONS}->{$input}->{item_action} eq 'NEXTNAME' ) {
    $dbnm_spool->next(); 
  }  else {
    my $cur =  $dbnm_spool->get_current(); 
    $extension_to = $cur->{extension}; 
  } 
  return ($action, $next_id,$extension_to ) ;    

}

#################################
## sub dbnm_type
#################################
sub dbnm_type {
  my $self = shift;
  if (@_) {
     $self->{DBNM_TYPE} = shift ;
  }
  return $self->{DBNM_TYPE};
}
1; 
