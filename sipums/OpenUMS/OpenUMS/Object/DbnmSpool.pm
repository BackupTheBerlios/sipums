package OpenUMS::Object::DbnmSpool; 
### $Id: DbnmSpool.pm,v 1.2 2004/09/01 03:16:35 kenglish Exp $
#
# MessageSpool.pm
#
# Modify/update/add/delete from list of new or saved messages.
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
use OpenUMS::Log;
use OpenUMS::Common;



#################################
## sub new
#################################
sub new {
  ## this your standard 'new', it intializes the hash and blesses it
  my $proto = shift;

  my $dbh = shift;
  my $user_ext_input = shift ; 
  my $dbnm_type = shift ; 

  my $class = ref($proto) || $proto;
  my $self = {}; ## self is a hash ref
  ## we'll add the parameters to the hash ref..
  $self->{DBH} = $dbh;
  $self->{USER_INPUT} = $user_ext_input;
  $self->{DBNM_TYPE} = $dbnm_type || 'BOTH' ;

  $self->{LIST} = undef;
  $self->{IS_LIST} = undef; ## this tells us if we need to query or not, if it's not definied, we do!

  bless($self, $class);
#  $self->_get_data(); 
  
  return $self;
}
#################################
## sub is_queried
#################################
sub is_queried {
  my $self = shift ;
  return $self->{IS_LIST}; 
}


#################################
## sub query
#################################
sub query {
  ## this the most basic of basic plays....
  my $self = shift ; 

  my $dbh = $self->{DBH} ; 

  $log->debug("quering for " . $self->{USER_INPUT} . ", " .  $self->{DBNM_TYPE} . "\n"); 
  
  ## this returns an array ref of hashref's with the following fields:
  ## extension, name_wav_file, name_wav_path
  $self->{LIST} = OpenUMS::DbQuery::get_by_name_phone_keys($self->{DBH}, $self->{USER_INPUT}, $self->{DBNM_TYPE} ); 

   
  $self->{NUM} = 0; 
  $self->{IS_LIST} = 1; 
  return ;
} 


#################################
## sub size
#################################
sub size  {
  my $self = shift ; 

  if (defined($self->{LIST})) { 
    return scalar(@{$self->{LIST} } ); 
  } else {
    return 0 ; 
  }
} 

#################################
## sub is_last
#################################
sub is_last {
  my $self = shift ;
  if ($self->{NUM} == ($self->size() ) ) {
    return 1; 
  } else {
    return 0 ; 
  }    
}


#################################
## sub next
#################################
sub next {
  my $self = shift ; 
  $self->{NUM} = $self->{NUM} + 1;  ## increment....
} 

#################################
## sub get_current
#################################
sub get_current {
  my $self = shift ; 
  if ($self->{NUM} >= $self->size())  {
    ## reset it, they are looping around again... 
    $self->{NUM} = 0; 
  } 

  my $msg_hr = $self->{LIST}->[$self->{NUM}]; 

  return $msg_hr ; 
} 
1;
