package OpenUMS::Menu::AutoAttendantMP; 
### $Id: AutoAttendantMP.pm,v 1.3 2004/09/01 03:16:35 kenglish Exp $
#
# AAGMP.pm
#
# Generic/general subs for playing messages/prompts.
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
use strict;

use OpenUMS::Config;
use OpenUMS::Log;
use OpenUMS::Menu::MenuProcessor;
use OpenUMS::GlobalSettings;

use base ("OpenUMS::Menu::MenuProcessor");




sub play_invalid {
  ## this is executed if they user enters an invalid option

  my $self = shift ; 

  ## get the local objects...
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
  my $ctport = $self->{CTPORT}; 
  my $input ; 
  if (!defined($self->{EXTENSIONS} )) { 
     $self->get_active_extensions(); 
  } 


    ## phone mode here dood...
    $log->debug("GS Collect Time is:  " . $main::CONF->get_var('COLLECT_TIME')  ); 
    $input = $ctport->collect(1,$main::CONF->get_var('COLLECT_TIME') );
    $log->debug("AA input = $input  "); 
    $log->debug("Collected  TIME was:  " . $main::CONF->get_var('COLLECT_TIME')  ); 

    ## if they are using the direct ??? to transfer to extension...
    if ( defined($self->{MENU_OPTIONS}->{EXT}) && ($input =~ /[1-9]/) ) { 
      my $is_ext_intro = $self->is_ext_intro($input) ; 
      if ($is_ext_intro) {
        my $input2 = $ctport->collect(($self->{MAX_EXT_LENGTH} - 1),3); 
        if ($input2) {
           $input .= $input2;
           $self->{EXTENSION_TO}  = $input;
           $self->{INPUT} = 'EXT';
           return ; 
        } 
      } 
    } 
    ## is it potentially a valid option ...
    my (@potential_opts) = $self->is_option_intro($input); 
    ## is there more than one valid option begining with that value? 
    if (scalar(@potential_opts) > 1 )  {
    } else {
      my $opt = $potential_opts[0];  
      if (length($opt) > 1 ) { 
        if ($opt =~ /^($input)EXT/ ) {
          my $input2 = $ctport->collect($self->{MAX_EXT_LENGTH}, $main::CONF->get_var('COLLECT_TIME')); 
          $self->{EXTENSION_TO}  = $input2;
          $input .= 'EXT'             
        }  else { 
          my $input2 = $ctport->collect( (length($opt) - 1), $main::CONF->get_var('COLLECT_TIME')); 
          $input .= $input2; 
        } 
      } 
    }  
    $self->{INPUT} = $input; 
}


#################################
## sub validate_input
#################################
sub validate_input {
  my $self = shift ; 
  my $input = $self->{INPUT} ; 

  $log->debug("Validating input ---> $input \n"); 
  my $menuOptions = $self->{MENU_OPTIONS} ; 
  
  if ($input =~/EXT/) {
     if (!($self->is_valid_extension($self->{EXTENSION_TO} )) )  {
       return 0 ; 
     } 
  } 
  
  if (defined($menuOptions->{$input}) ) {
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
  my $next_id =  $self->{MENU_OPTIONS}->{$input}->{dest_id} ; 
  my $param2  = undef; 

  if ($input =~ /EXT/ ) {
    $param2 = $self->{EXTENSION_TO}; 
  } 
  $log->debug("process....input is $input next_id $next_id param2 (EXTENSION) = $param2 ");
  return ($action, $next_id,$param2) ;    
}


#################################
## sub clear
#################################
sub clear {
  ## this clears out all variable except the ctport and dbh var
  my $self = shift  ; 
  $self->{INPUT} = undef ; 
  $self->{LOST_CALL_FLAG} = undef ; 
  $self->{EXTENSIONS} = undef ; 
}


#################################
## sub is_ext_intro
#################################
sub is_ext_intro { 
  my $self = shift; 
  my $in  = shift ; 
  my $exts = $self->get_active_extensions();  
  ## see if
  my @list = grep /^$in/, @{$exts};

  if (scalar(@list)) {
     return 1; 
  } else {
    return  0 ; 
  } 
}


#################################
## sub is_option_intro
#################################
sub is_option_intro {
  my $self = shift; 
  my $in  = shift ; 
  my @opts =  keys %{$self->{MENU_OPTIONS}}; 

  $in =~ s/\*/\\*/; 
  my @potentials = grep (/^$in.+|^\?.+/, @opts);

  return @potentials; 
} 


#################################
## sub is_valid_extension
#################################
sub is_valid_extension {
  my $self = shift  ;
  my $ext_to = shift  ;
  my $exts = $self->get_active_extensions();  
  foreach  my $ext ( @{$exts} ) {
    if ($ext eq $ext_to) { 

      return 1; 
    } 
  } 
  return 0; 

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

#################################
## sub aa_type
#################################

sub aa_type {
  my $self  = shift; 
  if (@_ ) { 
    $self->{AA_TYPE} = shift; 
  } 
  return $self->{AA_TYPE} ; 

}

1;
