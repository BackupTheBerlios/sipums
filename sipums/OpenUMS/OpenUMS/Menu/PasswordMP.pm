package OpenUMS::Menu::PasswordMP;
### $Id: PasswordMP.pm,v 1.2 2004/09/01 03:16:35 kenglish Exp $
#
# PasswdCollector.pm
#
# Get the user's password.
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



use OpenUMS::Config; 
use OpenUMS::Log;

use OpenUMS::Menu::MenuProcessor; 
#use OpenUMS::Mwi; 

## this is the skeleton pacakge for the VmProc
use base ("OpenUMS::Menu::MenuProcessor");

use strict ; 



#################################
## sub _get_input
#################################
sub _get_input { 
  
  my $self = shift ; 
  my $ctport = $self->{CTPORT}; 
  my $input ; 
  my $user = $self->{USER}; 

#  $user->update_last_visit() ; 

  if (TEXT_MODE) {
    $input = <STDIN>;
    chop($input); 
  } else {
    ## phone mode here dood...
    $input = $self->get_var_len_input() ; 
  }  
  $self->{INPUT_COLLECTED} = $input;
  if (OpenUMS::Common::is_phone_input($input) ) {
    $self->{INPUT} = $input;
  }  else {
    $self->{INPUT} = undef;
  } 

  return ; 

}


#################################
## sub validate_input
#################################
sub validate_input {
  my $self = shift ; 

  my $input = $self->{INPUT} ; 
  my $menuOptions = $self->{MENU_OPTIONS} ; 
 
  ## here's where we set their extension...
  my $user = $self->{USER}; 

#  if (!$user ) { 
#  } 

  if (!$user->{EXTENSION} ) {
    $user->{EXTENSION} = $user->{EXTENSION_TO}; 
  } 
  my $authed = $user->login($input); 
  if ($authed) {
    return  1 ;
  } else {
    return 0; 
  }
} 


#################################
## sub process
#################################
sub process {
  my $self = shift;
  my $input = $self->{INPUT} ; 

  my $user = $self->{USER}; 

  my $action = "NEXT"; 
  ## only one option here.....
  my $next_id =  $self->{MENU_OPTIONS}->{'????'}->{dest_id} ; 

#  if ( $user->get_value("new_user_flag") eq '1' && $self->{MENU_OPTIONS}->{'UTUT'}->{dest_id} ) {
#     $next_id = $self->{MENU_OPTIONS}->{'UTUT'}->{dest_id} ;   
#  } 
  return ($action, $next_id) ;    
}
1;
