package OpenUMS::Object::ForwardMessageObj  ; 

# FwdMsgObj.pm
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
use OpenUMS::DbUtils ;


use strict ; 

#################################
## sub new
#################################
sub new {
  ## this your standard 'new', it intializes the hash and blesses it
  my $proto = shift;

  my $user  = shift ;

  my $class = ref($proto) || $proto;
  my $self = {}; ## self is a hash ref
  ## we'll add the parameters to the hash ref..
  $self->{USER} = $user; 
  $self->{MAILBOX_ARRAY} =undef ; 

  bless($self, $class);
  return $self;
}
#################################
## sub add_mailbox
#################################
sub add_mailbox {
  my $self =shift ;
  my $mailbox = shift ; 
  if (!defined($self->{MAILBOX_ARRAY}) ) { 
    my @array; 
    push @array,  $mailbox  ; 
    $self->{MAILBOX_ARRAY} = \@array; 
    $log->debug("ADD MAILBOX : new array, size = ". scalar(@{$self->{MAILBOX_ARRAY}}) ) ; 
  } else {
    my $exist; 
    foreach my $mb (@{$self->{MAILBOX_ARRAY}}  ) { 
      if ($mb eq $mailbox) { 
         $exist = 1; 
      } 
    } 
    if (!$exist) { 
      push (@{$self->{MAILBOX_ARRAY}}, $mailbox ); 
    }
    $log->debug("ADD MAILBOX : existing array array, size = ". scalar(@{$self->{MAILBOX_ARRAY}} ) ); 
  } 
  $log->debug("add mailbox $mailbox") ; 
  return ;
}
sub forward_message {
  my $self = shift ; 
  my $user = $self->{USER} ; 
  my $dbh = $user->{DBH}; 

  foreach my $mb (@{$self->{MAILBOX_ARRAY}}  ) { 
    $log->debug("we have $mb ") ; 
  } 


   my $message_file = $user->last_message_file();   
   my $message_path = $main::CONF->get_var('VM_PATH') . USER_PATH . $user->extension() . "/messages/" ; 

    $log->debug("COMMENT_POSITION = " . $self->{COMMENT_POSITION} ) ; 
   if (defined($self->{COMMENT_POSITION}) ) { 
     my $src = "$message_path$message_file" ; 
     $message_file =~ s/\.wav$//g;
     $message_file .= "_fwd.wav";

     my $dst = $main::CONF->get_var('VM_PATH') . TEMP_PATH .  $message_file;
     $message_path = $main::CONF->get_var('VM_PATH') . TEMP_PATH ; 
     my $cp_cmd = "cp $src $dst" ; 
     $log->debug("COMMENT 1 : $cp_cmd"); 
     my $success = system("$cp_cmd");
     my $comment_file = $self->{COMMENT_PATH} . $self->{COMMENT_FILE} ; 
     my @arr ;
     if ($self->{COMMENT_POSITION} eq 'BEGIN')  { 
       $arr[0] = $comment_file;   
       $arr[1] = "$message_path$message_file";   
     }  elsif ($self->{COMMENT_POSITION} eq 'END') {
       $arr[0] = "$message_path$message_file";   
       $arr[1] = $comment_file;   
     } 
     OpenUMS::Common::cat_wav("$message_path$message_file", \@arr); 
  } 

  $log->debug("gonna create "); 
  foreach my $ext_to (@{$self->{MAILBOX_ARRAY}} ) { 
       my ($dest_message_file,$dest_message_path) =  OpenUMS::DbQuery::get_new_message_file_name ($ext_to, 1);
       my $dst =  $main::CONF->get_var('VM_PATH') . TEMP_PATH . $dest_message_file ; 
       my $cp_cmd = "cp $message_path$message_file $dst" ; 
    
       my $success = system("$cp_cmd");
      
       $log->debug("forward_message : cmd = $cp_cmd, success = $success " ); 
       OpenUMS::DbUtils::create_message($dbh, $ext_to, $dest_message_file, $dest_message_path, $user->extension(), 0,1);         
  } 
   
  return ;
}
sub _set_comments {
  my $self = shift ; 
  my ($file, $path,$position) = @_; 
  $self->{COMMENT_POSITION} = $position ; 
  $self->{COMMENT_FILE} = $file ; 
  $self->{COMMENT_PATH} = $path ; 
  return ;
  
} 
sub set_begin_comment {
  my $self = shift ; 
  my ($file, $path) = @_; 
  return $self->_set_comments($file, $path, 'BEGIN'); 
}
sub set_end_comment {
  my $self = shift ; 
  my ($file, $path) = @_; 
  return $self->_set_comments($file, $path, 'END'); 
}
1;
