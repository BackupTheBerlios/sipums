package OpenUMS::Menu::InfoMP ; 

### $Id: InfoMP.pm,v 1.2 2004/09/01 03:16:35 kenglish Exp $
#
# InfoMP.pm
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

use base ("OpenUMS::Menu::MenuProcessor");


#################################
## sub _get_input
#################################
sub _get_input { 
  my $self = shift ; 
  my $ctport = $self->{CTPORT}; 
  my $input ; 
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
  my $user = $self->{USER}; 

  my $action = "NEXT"; 
  ## only one option here.....
  ## only one option here.....
  if ($self->{MENU_OPTIONS}->{DEFAULT}->{item_action}  =~ /^UNSETNUF/ ) { 
     use OpenUMS::DbUtils; 
     $log->info("[InfoMP.pm] Unsetting new user flag for " . $user->extension() ); 
     OpenUMS::DbUtils::unset_new_user_flag($self->{DBH}, $user->extension()); 
  } 

  my $next_id =  $self->{MENU_OPTIONS}->{DEFAULT}->{dest_id} ;
  return ($action, $next_id) ;    
}

1;
