package OpenUMS::Menu::DbnmMP;

### $Id: DbnmMP.pm,v 1.2 2004/09/01 03:16:35 kenglish Exp $
#
# DbnmCollector.pm
#
# Dial by name Menu Collector
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
use strict ; 

use OpenUMS::Config; 
## this is the skeleton pacakge for all input processing classes...
use OpenUMS::Log;
use OpenUMS::Menu::MenuProcessor ;
use OpenUMS::DbUtils;

use base ("OpenUMS::Menu::MenuProcessor");



#################################
## sub _get_input
#################################
sub _get_input { 

  my $self = shift ; 
  my $ctport = $self->{CTPORT}; 
  my $input ; 
  if (!defined($self->{EXTENSIONS} )) { 
     $self->get_active_extensions(); 
  } 

  ## phone mode here dood...
  $input = $ctport->collect(3,$self->{COLLECT_TIME} );
  $self->{INPUT} = $input; 
}


#################################
## sub validate_input
#################################
sub validate_input {
  my $self = shift ; 
  my $input = $self->{INPUT} ; 

  my $dbnm_ar = $self->get_dbnm_list(); 
  if (!$input) { 
    return 0 ; 
  } 
  foreach my $pkey  (@{$dbnm_ar} ) { 
    if ($pkey =~ /^$input/) { 
       return 1; 
    }         
  } 
  return 0 ;  
} 


#################################
## sub process
#################################
sub process {

  my $self = shift;
  my $input = $self->{INPUT} ; 

  my $action = "NEXT"; 
  my $next_id =  $self->{MENU_OPTIONS}->{DEFAULT}->{dest_id} ; 
  my $param2  = $self->{INPUT};

  $log->debug("[DbnmMP.pm] DbnmCollect -> ACTION = $action, NEXT_ID = $next_id ..$param2.. \n"); 
  return ($action, $next_id,$param2) ;    
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


#################################
## sub get_dbnm_list
#################################
sub get_dbnm_list {
  my $self = shift; 
  if (!defined($self->{DBNM_AR}) ) { 
     $self->{DBNM_AR}  = OpenUMS::DbQuery::get_dbnm_list($self->{DBH},$self->dbnm_type() ); 
     ## get the list from the db...
  } 
  return  $self->{DBNM_AR}; 
} 


#################################
## sub is_valid_keys
#################################
sub is_valid_keys {
  my $self = shift ; 
  my $input = shift ; 
} 

#################################
## sub get_active_extensions
#################################
sub get_active_extensions {
  my $self = shift  ;
  if (defined($self->{EXTENSIONS}) ) {
    ## if it's there, use the cached one...
    return $self->{EXTENSIONS};
  } else {
    ## if it's there, use the cached one...
    $self->{EXTENSIONS} = OpenUMS::DbQuery::get_active_extensions($self->{DBH});
    $self->{MAX_EXT_LENGTH} = OpenUMS::DbQuery::get_max_ext_length($self->{DBH});
    ## now we figure out what the max length is...
    return $self->{EXTENSIONS};
  }
}


1;
