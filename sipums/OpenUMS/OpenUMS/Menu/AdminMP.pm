package OpenUMS::Menu::AdminMP ; 
### $Id: AdminMP.pm,v 1.1 2004/07/20 02:52:15 richardz Exp $
#
# AdminMP.pm
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

## this is the skeleton pacakge for the VmProc

use strict ; 
use OpenUMS::Config; 
use OpenUMS::DbQuery; 
use OpenUMS::DbUtils; 
use OpenUMS::Common; 
use OpenUMS::Log; 
use OpenUMS::Menu::MenuProcessor; 
use base ("OpenUMS::Menu::MenuProcessor");


#################################
## sub _play_menu ()
#################################
sub _play_menu () {
  ## this the most basic of basic plays....
  my $self = shift ; 
  my $ctport = $self->{CTPORT} ; 
  my $user = $self->{USER} ; 

  my $sound  ; 

  my $menuSounds = $self->{SOUNDS_ARRAY}; 
  ## always get the first one... 
  $sound =   PROMPT_PATH . $menuSounds->{M}->[0]->{sound_file}  ; 

  $log->debug ("[AdminMP.pm] setting_type  = " .  $self->setting_type() ); 

  ## if the it's RECPLAY, we play back the greeting to them 
  if ($self->setting_type() =~/^RECPLAY/) {
     my ($file, $path) = $user->get_temp_file();
     $sound = TEMP_PATH . $file; 
     if (!$file ) {
        ## if they don't have it... 
         
         $sound = OpenUMS::DbQuery::get_menu_sound($self->{DBH}, $user->box_to_admin() );

         $sound = $self->get_sound_by_type($self->sound_type(), $user->box_to_admin() );
     
         if (!$sound) {
           $log->warning("[AdminMP.pm] RECPLAY no menu sound");
           return ;
         } else {
            $sound = PROMPT_PATH . $sound ; 
         } 

     }  
  }  else { 
    ## if it's anything else, we loops thru the menu sounds creating th sound they will hear
    my $i =1; 
    my @to_play_sounds; 
#    if ($self->setting_type() =~ /^RECFILE/) {
#       $sound .= " beep.au";  
#    } 
  
    while (defined($menuSounds->{M}->[$i] )  ) {
      my $msound = $menuSounds->{M}->[$i];  
  
      ## stack it on, bra
      if ($msound->{sound_file}) {
        push @to_play_sounds,PROMPT_PATH . $msound->{sound_file} ;
      } else { 
      ## deal with the variable.
         if ($msound->{var_name} eq 'ADMINEXT') {
            my $sound = OpenUMS::Common::ext_sound_gen($user->extension_to_admin() );
            push @to_play_sounds,  $sound;
         } elsif ($msound->{var_name} eq 'RECPLAY') {
            my $sound = OpenUMS::DbQuery::get_menu_sound($self->{DBH}, $user->box_to_admin() );
            if (!$sound) {
               $log->warning("[AdminMP.pm] RECPLAY no menu sound"); 
               return ; 
            } 
            push @to_play_sounds,  PROMPT_PATH . $sound;
         } elsif ($msound->{var_name} eq 'IPADDRESS') { 
            my $ipObj =  $user->get_ip_object(); 
            push @to_play_sounds,  $ipObj->get_internal_ip_address_sound(); 
         } elsif ($msound->{var_name} eq 'IPGATEWAY') {
            my $ipObj =  $user->get_ip_object();
            push @to_play_sounds,  $ipObj->get_internal_gateway_sound();
         } elsif ($msound->{var_name} eq 'IPNETMASK') {
            my $ipObj =  $user->get_ip_object();
            push @to_play_sounds,  $ipObj->get_internal_netmask_sound();
         } elsif ($msound->{var_name}  eq 'IPEXTERNAL')  { 
            my $ipObj =  $user->get_ip_object();
            push @to_play_sounds,  $ipObj->get_external_ip_sound();
         } elsif ($msound->{var_name} =~ /^NEW_IP/) {
            my $value = $msound->{var_name};
            $value =~ s/NEW_//g;
            my $ipObj =  $user->get_ip_object();
            my $ip_sound = $ipObj->get_value_sound($value); 
            push @to_play_sounds,  $ip_sound; 
         } 
      }    

         $i++; 
   } 

   if (scalar(@to_play_sounds) ) {
       $sound .=   " " . join (" ", @to_play_sounds ); 
     } 
   } 
#  this will set it if there's more than one, otherwise it'll just play the 1
# 
 if (defined($sound) ) { 
    ## hey, it's gotta be there...
    $ctport->play($sound); 
 } 
 return ;
} 

#################################
## sub setting_type
#################################
sub setting_type {
  my $self = shift;
  if (@_ ) { 
    $self->{SETTING_TYPE}  = shift ; 
  } 
  return $self->{SETTING_TYPE}; 
}


#################################
## sub _get_input
#################################
sub _get_input {
  my $self = shift ;
  my $ctport = $self->{CTPORT};
  my $input ;
  my $user = $self->{USER}; 
  ## phone mode here dood...
  ## If they are adding an extension or resetting the password
  if ($self->setting_type() =~ /^ADDEXT/  || 
      $self->setting_type() =~ /^PWREXT/ ) { 
      $input = $ctport->collect(MAX_EXTENSION_DIGITS, $self->{COLLECT_TIME}); 
      $self->{INPUT_COLLECTED} = $input ;
      $self->{INPUT} = $input ; 
  }  elsif ($self->setting_type() =~ /^GETID/)  { 
      $input = $ctport->collect(length($self->get_id_var()), $self->{COLLECT_TIME} ); 
      $log->debug("GETID input = $input "); 
      $self->{INPUT_COLLECTED} = $input ;
      $self->{INPUT} = $input ; 
  } elsif ($self->setting_type() =~ /^GETIP/)  {

      my $ip = $self->get_var_len_input( 17,'#',1) ; ##
      $self->{IP} = $ip; 
      $self->{INPUT} = 'IP' ; 
      $self->{INPUT_COLLECTED} = $ip ;
      $log->debug("INPUT = " . $self->{INPUT} . " IP =  " . $self->{IP} ); 
  } elsif ($self->setting_type() =~ /^RECFILE/) {
      $user->create_temp_file(); 
      my ($file, $path) = $user->get_temp_file(); 
      $log->debug( "getting input for RECFILE $file $path"); 
      $ctport->clear();
      ## see if there's a beeeeeeeeeep
     my $menuSounds = $self->{SOUNDS_ARRAY};
     my $sound;
#
     if ($menuSounds->{M}->[1]->{sound_file} ) {
        $sound .=    PROMPT_PATH . $menuSounds->{M}->[1]->{sound_file}  ;
      }
#
      $ctport->play($sound);
      OpenUMS::Common::comtel_record( $ctport, "$path$file",60,"*#",SILENCE_TIMEOUT);

  }  elsif ($self->setting_type =~ /^RECPLAY/)   { 
      $input = $ctport->collect(1,1);
      $log->debug("set input to $input"); 
      $self->{INPUT_COLLECTED} = $input ;
      $self->{INPUT} = $input ; 
  }  else { 
      return $self->SUPER::_get_input();
  } 
}

#################################
## sub validate_input
#################################
sub validate_input {
  my $self = shift ; 
 
  my $input       = $self->{INPUT} ;
  my $menuOptions = $self->{MENU_OPTIONS} ;

  $log->debug("[AdminMP.pm] Validating input for AdminMP" ); 
  if ($self->setting_type() =~ /^ADDEXT/ ) { 
    ## check to see if the mailbox exists, include last 1 to check for inactive...
    if (OpenUMS::DbQuery::validate_mailbox($self->{DBH},$input,1) )  {
      return 0; 
    } else {
      return 1;  
    }
  } elsif ( $self->setting_type() =~ /^PWREXT/) {
    ## check to to make sure it's a valid mailbox...
    if (OpenUMS::DbQuery::validate_mailbox($self->{DBH},$input,1) )  {
      return 1; 
    } else {
      return 0;  
    }
  } elsif ( $self->setting_type() =~ /^GETID/) {
    my $user = $self->{USER} ;
    my $valid; 
    $log->debug("[AdminMP.pm] GETID: checking permissions =  " . $user->permission_id()  ); 
    if ($self->sound_type() =~ /^MENU/) { 
      if ($user->permission_id() =~ /^SUPER/) { 
        $valid  = OpenUMS::DbQuery::validate_menu_box($self->{DBH},$input)  ; 
      } else { 
        $valid  = OpenUMS::DbQuery::validate_aa_box($self->{DBH},$input)  ; 
      } 
    } elsif ($self->sound_type() =~ /^SOUND/)  {
     $valid  = OpenUMS::DbQuery::validate_sound_file_id($self->{DBH},$input)  ; 
     
    } 
    return $valid; 
  } elsif ( $self->setting_type() =~ /^GETIP/ ) {

    use Net::IP;
    my $ip = $self->{IP}; 

    if ($ip eq '#' ) { 
      return 1; 
    } else { 
      ## swap '*'s for '.'s
      $ip =~ s/\*/./g;
      ## remove trailing '#'
      $ip =~ s/#$//g;
      $log->debug("validateing ip $ip");
      my $test_ip = new Net::IP ($ip) || return  0 ;
      return 1; 
    } 
  } elsif ($self->setting_type() =~ /^RECPLAY|^RECFILE/) {
     ## who cares?
     return 1; 
  } else {
     $log->info("[AdminMP.pm] else on validate input, option =  $input"); 
     return $self->SUPER::validate_input();
  } 
  $log->debug("[AdminMP.pm] nothing returning 1"); 
  return 1; 
}


#################################
## sub process
#################################
sub process {
  my $self = shift;
  my $input = $self->{INPUT} ; 

  my $user = $self->{USER}; 
  my ($action, $next_id); 

  ## only one option here.....
  ## here we save stuff...
  if ($self->setting_type() =~ /^ADDEXT/) { 
    $log->debug("[AdminMP.pm] it's ADDEXT, they entered $input"); 
     $user->extension_to_admin($input); 
     $action = "NEXT";
     $next_id =  $self->{MENU_OPTIONS}->{'DEFAULT'}->{dest_id} ;
     return ($action, $next_id) ;    
  } elsif ($self->setting_type() =~ /^SAVEADDEXT/ )  {
    $log->debug("[AdminMP.pm] it's SAVEADDEXT, they entered $input"); 
    if ($self->{MENU_OPTIONS}->{$input}->{item_action} =~ /^SAVEADDEXT/) {
       $log->info("[AdminMP.pm] Adding new user, extension = ". $user->extension_to_admin() ); 
       my ($val, $msg ) = OpenUMS::Common::add_user($self->{DBH}, $user->extension_to_admin(),undef,undef ) ;
       
       ##  clear the nex extension from the user's session...
       $user->clear_extension_to_admin(); 
       ## see if there's a verify sound, if so, play it
       my $menuSounds = $self->{SOUNDS_ARRAY};
       if ($menuSounds->{V}->[0]->{sound_file}) { 
          my $confirm_sound = PROMPT_PATH . $menuSounds->{V}->[0]->{sound_file}  ;
          my $ctport = $self->{CTPORT}; 
          $ctport->play($confirm_sound); 
       } 

    }  else {
       $log->info("[AdminMP.pm] Add user cancelled extension = ". $user->extension_to_admin() ); 
    }  
    $action = "NEXT";
    $next_id =  $self->{MENU_OPTIONS}->{$input}->{dest_id} ;
    return ($action, $next_id) ;    
  } elsif ($self->setting_type() =~ /^PWREXT/ )  {
     $user->extension_to_admin($input);
     $log->debug("[AdminMP.pm] it's PWREXT (reset password menu) for " . $user->extension_to_admin() ); 
     $action = "NEXT";
     $next_id =  $self->{MENU_OPTIONS}->{'DEFAULT'}->{dest_id} ;
     return ($action, $next_id) ;    
  } elsif ($self->setting_type() =~ /^CONFPWR/) {
    ## they say 'yes'!
    if ($self->{MENU_OPTIONS}->{$input}->{item_action} =~ /^SAVEPWR/) {
       $log->debug("[AdminMP.pm] it's SAVEPWR (save password reset) for " . $user->extension_to_admin()  ); 
       OpenUMS::DbUtils::reset_password($self->{DBH}, $user->extension_to_admin() ) ; 
       $user->clear_extension_to_admin();
    } 
    $action = "NEXT";
    $next_id =  $self->{MENU_OPTIONS}->{$input}->{dest_id} ;
    return ($action, $next_id) ;    
  } elsif ($self->setting_type() =~ /^GETID/ )  {
    $user->box_to_admin($input);
    $log->debug("[AdminMP.pm] it's GETID (get menu_id to re-record) menu_id=" . $user->box_to_admin()  ); 
    $action = "NEXT";
    $next_id =  $self->{MENU_OPTIONS}->{$self->get_id_var()}->{dest_id} ;
    return ($action, $next_id) ;    
  } elsif ($self->setting_type() =~ /^GETIP/) {  
    ## they are setting some kind of IP
    my $ip = $self->{IP}; 

    $log->debug("[Admin.pm] process : ip = " . $self->{IP} ) ; 
    my $ipObject = $user->get_ip_object(); 

    ## get the setting type
    my $ip_address_type = $self->setting_type(); 
    $ip_address_type =~ s/^GET//g; 
    if ($ip eq '#') { 
      $log->debug("calling use_current for $ip_address_type " ); 
      $ipObject->use_current($ip_address_type);  
    } else {
      ## swap '*'s for '.'s
      $ip =~ s/\*/./g;
      ## remove trailing '#'
      $ip =~ s/#$//g;
      $ipObject->set_value($ip_address_type,$ip);  
    } 

    $action = "NEXT";
    $next_id =  $self->{MENU_OPTIONS}->{IP}->{dest_id} ;
    return ($action, $next_id) ;    
  } elsif ($self->setting_type() =~ /^RECFILE/)  {
    $log->debug("[AdminMP.pm] it's RECFILE (record file) menu_id=" . $user->box_to_admin()  ); 
    $action = "NEXT";
    $next_id =  $self->{MENU_OPTIONS}->{DEFAULT}->{dest_id} ;
    return ($action, $next_id) ;
  } elsif ($self->setting_type() =~ /^RECOPTS/)  {
    if ($self->{MENU_OPTIONS}->{$input}->{item_action} =~ /^CANCEL/) {
      $user->clear_box_to_admin();
      my ($file, $path) = $user->get_temp_file(); 

      if ($file ) { 
         if (-e "$path$file" && (-f "$path$file")) { 
           unlink ("$path$file"); 
         } 
      }

      $user->clear_temp_file();
    } elsif ($self->{MENU_OPTIONS}->{$input}->{item_action} =~ /^RECSAVE/ ) {
      my ($file, $path) = $user->get_temp_file(); 
      if ((-e "$path$file") && (-f "$path$file")) { 
         OpenUMS::Common::adjust_volume("$path$file");
         if ($self->sound_type() =~ /^MENU/) { 
            $log->info("[AdminMP.pm] SAVING NEW AA GREETING FOR MENU " . $user->box_to_admin() . " $path$file" ); 
            OpenUMS::DbUtils::save_new_greeting($self->{DBH},$user->box_to_admin(), $file, $path); 

            # my $file_id = OpenUMS::DbUtils::add_sound_file($self->{DBH}, $file, $path);

         } elsif ($self->sound_type() =~ /^SOUND/) { 
            $log->info("[AdminMP.pm] UPDATING SOUND id =" . $user->box_to_admin() . " $path$file" ); 
            OpenUMS::DbUtils::update_sound_file($self->{DBH},$user->box_to_admin(), $file, $path); 
         }  else {
            $log->debug("[AdminMP.pm] Save Add sound");
            my $file_id = OpenUMS::DbUtils::add_sound_file($self->{DBH}, $file, $path);

            my $menuSounds = $self->{SOUNDS_ARRAY};
            my $confirm_sound .=  PROMPT_PATH . $menuSounds->{V}->[0]->{sound_file}  ;
            $confirm_sound .= " " . OpenUMS::Common::ext_sound_gen($file_id);
            my $ctport = $self->{CTPORT};
            $ctport->play($confirm_sound);

         } 
         ## clear the box and the temp file
      } 
      $user->clear_box_to_admin();
      $user->clear_temp_file();
    } 
    $action = "NEXT";
    $next_id =  $self->{MENU_OPTIONS}->{$input}->{dest_id} ;
   
    return ($action, $next_id) ;
  } elsif ($self->setting_type() =~ /^RECPLAY/ ) { 
    $action = "NEXT";
    $next_id =  $self->{MENU_OPTIONS}->{DEFAULT}->{dest_id} ;
    $log->debug("RECPLAY -> dest = " . $self->{MENU_OPTIONS}->{DEFAULT}->{dest_id} ) ; 

    return ($action, $next_id) ;
  } elsif ($self->setting_type() =~ /^PLAY/) { 
    $action = "NEXT";
    $next_id =  $self->{MENU_OPTIONS}->{DEFAULT}->{dest_id} ;
    $log->debug($self->setting_type() . " -> dest = " . $self->{MENU_OPTIONS}->{DEFAULT}->{dest_id} ) ;
                                                                                                                                               
    return ($action, $next_id) ;
  } else {
    if ($self->{MENU_OPTIONS}->{$input}->{item_action} eq 'SAVEIP') { 
        my $ipObject = $user->get_ip_object();  
        $ipObject->save_ip(); 
    } 
    $action = "NEXT";
    $next_id =  $self->{MENU_OPTIONS}->{$input}->{dest_id} ;
    return ($action, $next_id) ;

  }  
}

#################################
## sub sound_type
#################################
sub sound_type {
  my $self = shift;
  if (@_ ) {
    $self->{SOUND_TYPE}  = shift ;
  }
  return $self->{SOUND_TYPE};
}

sub get_sound_by_type {
  my $self = shift ;
  my $type = shift ;
  my $id = shift ;

  return "invalid.vox" if (!$id);

  my $dbh = $self->{DBH}; 
  if ($type eq 'MENU') {
                                                                                                                                              
    my $sql  = qq{SELECT sound_file FROM menu_sounds
                WHERE menu_id = ? AND order_no = 1 AND sound_type = 'M'};

     my $sth = $dbh->prepare($sql);
     $sth->execute($id);
     my $sound_file = $sth->fetchrow();
     $sth->finish();
     return $sound_file ;
  } elsif ($type eq 'SOUND') {
    my $sql  = qq{SELECT sound_file FROM sound_files
                WHERE file_id = ? };
    my $sth = $dbh->prepare($sql);
    $sth->execute($id);
    my $sound_file = $sth->fetchrow();
    $sth->finish();
    return $sound_file ;
  }  
} 
sub get_id_var {
  my $self = shift ;
  my $menu_options =  $self->{MENU_OPTIONS} ; 

  foreach my $item (keys %{$menu_options}) {
     if ($item =~ /^\?/ ) {
       return $item; 
     } 
  } 
  return '???'; 
}



1; 
