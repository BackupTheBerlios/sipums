package OpenUMS::Object::SoundVariables;

#
# SoundVariables.pm
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
use OpenUMS::Object::Prompt;


################################################################# use Exporter
#use Exporter;

sub get_prompt($$) {
  my ($dbh,$var_name) = @_ ; 

  my $q   = qq(SELECT sound_var_file, custom_sound_flag FROM sound_variables  
    WHERE sound_var_name = '$var_name' );
  $log->debug("get_prompt $q" ); 
  
  my ($sound_file, $custom_sound_flag) = $dbh->selectrow_array($q); 
  my $prompt = new OpenUMS::Object::Prompt($sound_file, $custom_sound_flag) ;

  return $prompt; 

}
1;
