package OpenUMS::Menu::AAGMP; 
### $Id: AAGMP.pm,v 1.5 2004/09/10 01:36:32 kenglish Exp $
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
use OpenUMS::Holidays;
use OpenUMS::DbQuery;

use base ("OpenUMS::Menu::MenuProcessor");

sub _post_data {
  my $self = shift ;
  my $menu_id = $self->{MENU_ID} ;
  my $dbh = $self->{DBH};

  $log->debug("[AAGMP] Let's check to see if it's a holiday");
  my ($holiday_name) = OpenUMS::Holidays::get_holiday_name($dbh);
  my $menuSounds;
  if ($holiday_name) { 
    $log->debug("today is a holiday! $holiday_name");
    $menuSounds = OpenUMS::Holidays::get_holiday_menu_sounds($dbh,$holiday_name); 
  } else { 
    my $sound_file = OpenUMS::DbQuery::get_aag_sound($dbh);
    my $custom_sound_flag=1; ## auto attendant greetings should always be custom
    my $sound_type ='M'; ## auto attendant greetings should always be custom
    $log->debug("[AAGMP] _post_data: current sound =- $sound_file custom_sound_flag=$custom_sound_flag,sound_type=$sound_type ");
    my $sound_ref ;
    $sound_ref->{sound_title} = "auto attendat sound";
    $sound_ref->{sound_file} = $sound_file ;
    if ($sound_file ) {
       $sound_ref->{PROMPT_OBJ} = new OpenUMS::Object::Prompt($sound_file, $custom_sound_flag) ;
    }
    push @{$menuSounds->{$sound_type}} , $sound_ref ;
  }
  $self->{SOUNDS_ARRAY}  = $menuSounds ;
  return ;


#  if (!$self->{IS_HOLIDAY}  && $self->{HOLIDAY_NAME} ) {
#    return ; 
#  } 
#                                                                                                                                               
#  my $sql = "SELECT sound_file, order_no " ;
##  $sql  .= " FROM holiday_sounds ";
#  #$sql  .= " WHERE holiday_name =   " . $dbh->quote($self->{HOLIDAY_NAME}) ; 
#  $sql  .= " WHERE holiday_name = ?  "; 
#  $sql  .= " ORDER BY order_no "; 

#  my $sth = $dbh->prepare($sql) ;
#  $sth->execute($self->{HOLIDAY_NAME} );
#  my $menuSounds;
#  my $count =0; 

#  while (my ($sound_file, $order_no) = $sth->fetchrow_array() ) {
#     my $sound_ref ;
#     $sound_ref->{sound_file} = $sound_file ;
#     $log->debug("_post_data " . $sound_file ); 
#     push @{$menuSounds->{'M'}} , $sound_ref ;
#     $count++; 
#  }
#  $sth->finish();
#
#  if ($count) { 
#     ## something is wrong so don't hose the sounds_array... 
#     $self->{SOUNDS_ARRAY}  = $menuSounds ;
#  } 

  return ;

}
######################################
## sub _play_menu()
## this the most basic of basic plays....
######################################
                                                                                                                                               
sub _play_menu () {
  my $self = shift ;
  my $ctport = $self->{CTPORT} ;

# if (!$self->{IS_HOLIDAY}  && $self->{HOLIDAY_NAME} ) {
#    return ;
#  }

  ## get the array of sounds
  my $menuSounds = $self->{SOUNDS_ARRAY};

  ## get the first sound off that sound array
  my @sounds ; 
  foreach my $hr (@{$menuSounds->{M}} ) {
     my $sound_file =  $hr->{PROMPT_OBJ}->file();  
     push @sounds, $sound_file; 
     $log->debug("[AAGMP] sound_file = $sound_file ...");
  } 

  my $sound =  join(" ", @sounds); 

  $log->debug("sound is $sound"); 
  if (defined($sound) ) {
    ## hey, if there, let 'em hear it
    $ctport->play($sound);
  }
  return ;
}


#################################
## sub play_invalid
#################################
sub play_invalid {
  ## this is executed if they user enters an invalid option

  my $self = shift ; 

  ## get the local objects...
  my $ctport = $self->{CTPORT}; 
  my $menuSounds = $self->{SOUNDS_ARRAY}; 

  my $invalid_sound  = $menuSounds->{I}->[0]->{sound_file};
  if ($invalid_sound) { 
      $ctport->play(OpenUMS::Common::get_prompt_sound(  $invalid_sound) ) ; 
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
  $input = $ctport->collect(1,$self->{COLLECT_TIME});
  $log->debug("hey, we got input=$input");  

  if (defined($self->{MENU_OPTIONS}->{$input}) && $self->{MENU_OPTIONS}->{$input}->{item_action} eq 'SPECLOGIN') { 
       $log->info( "[AAGMP.pm] Input is SPECIAL LOGIN" ); 
       $self->{INPUT_COLLECTED} = $input;
       $self->{INPUT} = ""; 
  
       my $ext_input = $self->get_var_len_input() ; 
       my $password = $self->get_var_len_input() ; 

       $self->{INPUT_COLLECTED} .= $ext_input . $password ;

       if (length($ext_input ) > 0  &&  length($ext_input ) > 0) {  
         my $user = $self->{USER}; 
            my $ext = $user->extension($ext_input);
            my $authed = $user->login($password);
            if ($authed) {
              $self->{INPUT} = $input; 
              return ;
            } else {
              $log->warning("[AAGMP.pm] during SPECIAL LOGIN:  Invalid mailbox or password, extension=$ext_input");
              return ;
            }
       } 
    } else {
      $log->debug("input is not special login"); 
    }  

    ## if they are using the direct ??? to transfer to extension...
    if ( defined($self->{MENU_OPTIONS}->{EXT}) && ($input =~ /[1-9]/) ) { 
      my $is_ext_intro = $self->is_ext_intro($input) ; 
      if ($is_ext_intro) {
        my $input2 = $self->get_var_len_input(($self->{MAX_EXT_LENGTH} - 1)) ; 
        $log->debug("[AAGMP.pm] Got more input $input2 "); 
     
        # did they enter the entire extension?
        if (length($input2) == ($self->{MAX_EXT_LENGTH} - 1)) {
           $input .= $input2;
           $log->debug("[AAGMP.pm] Setting extension to $input "); 
           $self->{EXTENSION_TO}  = $input;
           $self->{INPUT_COLLECTED}  = $input;

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
          my $input2 = $ctport->collect($self->{MAX_EXT_LENGTH}, $self->{COLLECT_TIME}); 
          $self->{EXTENSION_TO}  = $input2;
          $self->{INPUT_COLLECTED} = $input . $input2;

          $input .= 'EXT'             
        }  else { 
          my $input2 = $ctport->collect( (length($opt) - 1), $self->{COLLECT_TIME}); 
          $self->{INPUT_COLLECTED} = $input . $input2;
          $input .= $input2; 
        } 
      } 
    }  
    $log->info("[AAGMP.pm] Input is $input"); 
    $log->info("[AAGMP.pm] EXTENSIONT_TO  " . $self->{EXTENSION_TO} . " "); 
    $self->{INPUT} = $input; 
}


#################################
## sub validate_input
#################################
sub validate_input {
  my $self = shift ; 
  my $input = $self->{INPUT} ; 

  my $menuOptions = $self->{MENU_OPTIONS} ; 
  if ($input =~/EXT/) {
      
     $log->info("[AAGMP.pm] Input is $input"); 
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
  $log->debug("[AAGMP.pm] process next_id=$next_id param2 (EXTENSION) = $param2 ");
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
# sub is_valid_extension {
#   my $self = shift  ;
#   my $ext_to = shift  ;
#   my $exts = $self->get_active_extensions();  
#   foreach  my $ext ( @{$exts} ) {
#     if ($ext eq $ext_to) { 
#       return 1; 
#     } 
#   } 
#   return 0; 
# 
# } 
#####################################                               

#################################
## sub get_active_extensions
#################################
#  sub get_active_extensions {
#    my $self = shift  ;
#    if (defined($self->{EXTENSIONS}) ) {
#      ## if it's there, use the cached one...
#      return $self->{EXTENSIONS}; 
#    } else {
#      ## if it's there, use the cached one...
#      $self->{EXTENSIONS} = OpenUMS::DbQuery::get_active_extensions($self->{DBH}); 
#      $self->{MAX_EXT_LENGTH} = OpenUMS::DbQuery::get_max_ext_length($self->{DBH}); 
#      ## now we figure out what the max length is...
#      return $self->{EXTENSIONS}; 
#    } 
#  }

#################################
## aa_type
#################################
sub aa_type {
  my $self  = shift; 
  if (@_ ) { 
    $self->{AA_TYPE} = shift; 
  } 
  return $self->{AA_TYPE} ; 

}

1;
