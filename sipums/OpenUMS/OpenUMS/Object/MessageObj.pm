package OpenUMS::Object::MessageObj; 

# MessageObj.pm
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

use OpenUMS::Config;
use OpenUMS::Log;
use OpenUMS::Common;
use OpenUMS::DbQuery ;


use strict ; 

#################################
## sub new
#################################
sub new {
  ## this your standard 'new', it intializes the hash and blesses it
  my $proto = shift;

  my $msg_hr  = shift;

  my $class = ref($proto) || $proto;
  my $self = {}; ## self is a hash ref
  ## we'll add the parameters to the hash ref..
  $self->{MSG_DB_HR} = $msg_hr; 
  my $duration = OpenUMS::Common::file_duration($msg_hr->{message_wav_file}, $main::CONF->get_var('VM_PATH')  .  $msg_hr->{message_wav_path}) ;
  $self->{TOTAL_DURATION} = $duration; 
  bless($self, $class);
  return $self;
}

#################################
## sub get_sound_file
## this just returns the unique sound_file, no path, nothing....
#################################
sub get_sound_file {
  my $self = shift;
  my $msg_hr = $self->{MSG_DB_HR} ;
  my $wav_file = $msg_hr->{message_wav_file} ;  
  return $wav_file ;  

}

#################################
## sub get_sound
#################################

sub get_sound {
  my $self = shift; 
  my $msg_hr = $self->{MSG_DB_HR} ; 
  if ( $self->{TEMP_FILE} ) { 
    my $temp_file = $self->{TEMP_FILE}->filename(); 
    my $base_begin = $main::CONF->get_var('VM_PATH') ;  
    $temp_file  =~ s/^$base_begin//g ;
    $log->debug("get_sound temp_file = $temp_file");
    return $temp_file; 
  } else { 
    my $wav_file = $msg_hr->{message_wav_file} ;  
    my $wav_path = $msg_hr->{message_wav_path} ;  
    return "$wav_path$wav_file"; 
  }
}

#################################
## sub get_msg_hr
#################################

sub get_msg_hr {
  my $self = shift; 
  return $self->{MSG_DB_HR} ; 

}

#################################
## sub play_started
#################################

sub play_started {
 my $self = shift;  
 $self->{START_TIME} = time; 
 return ;
}

#################################
## sub play_stopped
#################################
sub play_stopped {
 my $self = shift;  
 $self->{STOP_TIME} = time; 

 if ($self->{TEMP_FILE} ) {
   $self->{TEMP_FILE} = undef; 
 } 

 return ;
}

#################################
## sub played_duration
#################################
sub played_duration {
  my $self = shift ; 
  if ($self->{START_TIME} && $self->{STOP_TIME} ) 
  { 
     my $dur = $self->{STOP_TIME} -  $self->{START_TIME}  ; 
     return $dur ;
  } else 
  { 
    return 0; 
  }
}


#################################
## sub rewind
#################################
sub rewind {
  my $self = shift ;
  $self->shift_position (- ($main::CONF->get_var('REWIND_SECS')) ,'REWIND' )  ;
}

#################################
## sub fast_forward
#################################
sub fast_forward {
  my $self = shift ;
  $self->shift_position ( ($main::CONF->get_var('REWIND_SECS')) ,'FASTFORWARD' )  ;
}


#################################
## sub shift_position
#################################
sub shift_position {
  my $self = shift; 
  my $jump_secs = shift ; 
  my $name = shift ; 

  my $msg_hr = $self->{MSG_DB_HR} ; 

  my $wav_file = $msg_hr->{message_wav_file} ;  
  my $wav_path = $msg_hr->{message_wav_path} ;  

  use File::Temp ; 
  my $play_dur = $self->played_duration() ; 
  ## where to jump to into in the file. Take the duration and add the jump_secs
  my $to_jump = $play_dur + $jump_secs ;  ## for rewind, we subtract
  my $last_offset = 0; 
  if (defined($self->{LAST_OFFSET}) )  { 
     $log->debug("$name: ALREADY OFFSET"); 
     $last_offset = $self->{LAST_OFFSET} ;
  } 
  ## add any offset from a previous jump

  $to_jump += $last_offset;  
  $log->debug("$name: $play_dur (play_dur) + $jump_secs (jump_secs)  +  " . $self->{LAST_OFFSET} . " (LAST_OFFSET) = $to_jump (to_jump)");

  if ($to_jump > 0  && $to_jump < $self->{TOTAL_DURATION} ) { 
     $self->{LAST_OFFSET} = $to_jump; 
     $log->debug("$name : to_jump is negative, just repeating message"); 
     my $temphandle = new File::Temp(UNLINK => 1, SUFFIX => '.vox', DIR=>$main::CONF->get_var('VM_PATH')  . TEMP_PATH);
     my $soxout = $temphandle->filename;
     OpenUMS::Common::trim_file( "$soxout", $main::CONF->get_var('VM_PATH')  ."$wav_path$wav_file", $to_jump);
     $self->{TEMP_FILE} = $temphandle ; 
     ## mark it unheard...
     $self->repeat(); 
     return ;
  } elsif($to_jump <= 0 ) {
     $log->debug("$name : to_jump is negative, just repeating message"); 
     $self->{LAST_OFFSET} = undef; 
     return $self->repeat(); 
  } elsif ($to_jump >= $self->{TOTAL_DURATION} && $jump_secs > 0 ) {
     ## can't go any farther forward....
     $log->debug("$name : to_jump is greater than TOTAL_DURATION "); 
     $self->{LAST_OFFSET} = undef; 
     return $self->heard()  ; 
  } elsif ($to_jump > $self->{TOTAL_DURATION} && $jump_secs < 0)   {
     ## rewind jump  seconds from the end...

     $to_jump = $self->{TOTAL_DURATION} + $jump_secs ; 
     $self->{LAST_OFFSET} = $to_jump; 
     $log->debug("$name : to_jump is greater than TOTAL_DURATION" . $self->{TOTAL_DURATION} . " , new to_jump = $to_jump "); 
     my $temphandle = new File::Temp(UNLINK => 1, SUFFIX => '.vox', DIR=>$main::CONF->get_var('VM_PATH')  . TEMP_PATH);
     my $soxout = $temphandle->filename;
     OpenUMS::Common::trim_file( "$soxout", $main::CONF->get_var('VM_PATH')  ."$wav_path$wav_file", $to_jump);
     $self->{TEMP_FILE} = $temphandle ; 
     $self->repeat(); 
     return ;
##     return $self->heard()  ; 
  } 
}

sub mark_heard {
 my $self = shift ;

 $self->{HEARD} = 1;  
}


#################################
## sub heard
#################################
sub heard {
 my $self = shift ;
 return $self->{HEARD};  
}

#################################
## sub repeat
#################################
sub repeat {
 my $self = shift ;
 $self->{HEARD} = undef;  
 return ;
}

#################################
## sub get_extension_from
#################################
sub get_extension_from {
  my $self  =shift  ;  
  my $msg_hr = $self->{MSG_DB_HR} ;
  return $msg_hr->{extension_from}; 

}
1;
