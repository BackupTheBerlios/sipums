package OpenUMS::Object::Prompt;

#
# Sound.pm
#
# This is the code library for general utility subs or non-specific
# subs that don't really belong anywhere else.
#
# Copyright (C) 2004 Servpac Inc.
# 
#  This library is free software; you can redistribute it and/or modify it
#  under the terms of the GNU Lesser General Public License as published by the
#  Free Software Foundation; either version 2.1 of the license, or (at your
#  option) any later version.
# 
#  This library is distributed in the hope that it will be useful, but WITHOUT
#  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
#  FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public License for more
#  details.
# 
#  You should have received a copy of the GNU Lesser General Public License
#  License along with this library; if not, write to the Free Software
#  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  US



use strict;
use warnings;

use OpenUMS::Config;
use OpenUMS::Log;


################################################################# use Exporter
#use Exporter;

sub new {
  my $proto = shift;
  my $file_name = shift;
  my $custom_flag = shift;
  my $class = ref($proto) || $proto;
  my $self = {}; ## self is a hash ref
  $self->{SOUND_FILE}=$file_name; 
  if ($custom_flag) { 
    $log->debug("SOUND_FILE  $file_name");
    $self->{CUSTOM_FLAG} = 1 ; 
  } else {
    $self->{CUSTOM_FLAG} = 0 ; 
  } 
  $self->{FILE_EXISTS} =undef;
  bless($self, $class);
  $self->file_exists(); 
  return $self; 

}

sub file_exists() {
 my $self = shift ; 
 if (defined($self->{FILE_EXISTS})  ) { 
    return $self->{FILE_EXISTS}; 
 } 
 my $file =  $self->_get_path() . $self->{SOUND_FILE} ; 
 if (-f $file  && -r $file) {
   return 1; 
 } else {
   $log->debug("PROMPT CREATED BUT FILE ".  $file . " DOES NOT EXIST");
    return 0; 
 } 

}
sub is_custom {
  my $self = shift; 
  return $self->{CUSTOM_FLAG}; 
} 
sub _get_path {
  my $self = shift ;  
  my $path ; 
  if ($self->is_custom()) {
    $path= $main::CONF->get_var('VM_PATH') . PROMPT_PATH ; 
    $log->debug("CUSTOM PROMPT PATH " .$path);  
  } else {
    $path= BASE_PATH . PROMPT_PATH ; 
  }
  return $path; 

} 

sub file() {
  my $self = shift ; 
  if (!$self->file_exists()) { 
    $log->debug("called Sound file where file does not exist");
    return ""; 
  }  

  my $new_file; ## = $main::CONF->get_var('VM_PATH') . PROMPT_PATH . $file ; 

  $new_file= $self->_get_path(). $self->{SOUND_FILE};

  if ($new_file !~ /\.wav$/) {
     ## add the extension
     $new_file .= ".wav";
  }
  $log->debug("returning file " . $new_file);
  return $new_file;
}
1; 
