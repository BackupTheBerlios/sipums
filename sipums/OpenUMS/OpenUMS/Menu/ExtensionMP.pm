package OpenUMS::Menu::ExtensionMP ;
### $Id: ExtensionMP.pm,v 1.4 2004/12/15 03:11:43 kenglish Exp $
#
# ExtensionMP.pm
#
# Get the extension from the caller.
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

use OpenUMS::Config; 
use OpenUMS::Menu::MenuProcessor; 
use OpenUMS::Log; 
use OpenUMS::GlobalSettings; 

## this is the skeleton pacakge for the VmProc
use base ("OpenUMS::Menu::MenuProcessor");

#################################
## sub _get_input
#################################

sub _get_input { 
  my $self = shift ; 
  my $ctport = $self->{CTPORT}; 
  my $input ; 
  ## phone mode here dood...
  $input = $ctport->collect($main::CONF->get_var('EXTENSION_LENGTH'), $main::CONF->get_var('COLLECT_TIME') ,2);
  if ($input =~ /#$/ ) {
     chop ($input); 
  } 
  $log->debug("[ExtensionMP.pm] got $input COLLECT TIME WAS " .  $main::CONF->get_var('COLLECT_TIME') ); 
  $self->{INPUT_COLLECTED} = $input; 
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

  my $input = $self->{INPUT} ; 
  my $menuOptions = $self->{MENU_OPTIONS} ; 
 
  ## here's where we set their extension...
  my $user = $self->{USER}; 
   
  my $ext = $user->extension($input); 

  $log->debug("[ExtensionMP.pm] setting extension for user in ext=$ext");  

  if ($ext) {
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

  my $action = "NEXT"; 
  ## only one option here.....
  my $next_id =  $self->{MENU_OPTIONS}->{'???'}->{dest_id} ; 
  return ($action, $next_id) ;    
}
1;
