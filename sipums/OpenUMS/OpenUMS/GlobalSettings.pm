package OpenUMS::GlobalSettings;
### $Id: GlobalSettings.pm,v 1.5 2004/09/01 03:16:35 kenglish Exp $
# GlobalSettings.pm
#
# OpenUMS's global setting program
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

use Date::Calc;
use OpenUMS::Common;
use OpenUMS::Config;
use OpenUMS::Log;
use Exporter;

our $CONF;
our @ISA = ("Exporter");
our @EXPORT = qw($CONF);


=pod
=head1 NAME

OpenUMS::GlobalSettings - Abstract logging facility for the OpenUMS package

=cut



my $PORT = 0;

# new {{{
sub new {
  my $class = shift;

  $class = ref($class) || $class;

  my $self = shift;
  if (!defined $self) { $self = { }; }
   
  bless ($self, $class);

  return $self;
}
#################
## sub load_settings 
#################

sub load_settings($) {
  my $self= shift ; 
  my $db = shift ; 
  if (!$db) { 
    $log->error("loading global settings called with no $db");
    return ;
  } else {
    $log->debug("loading global settings from $db");
  }  

  my $dbh = OpenUMS::Common::get_dbh($db)  ; 
  my $sql = qq{SELECT var_name, var_value FROM global_settings};  
  my $sth = $dbh->prepare($sql);
  ## undef the old one...
  $self->{GLOBAL_SETTINGS} = undef; 
  $sth->execute();
  my %settings; 
  while (my ($name, $val) = $sth->fetchrow_array() ) {
    if ($name =~ /VM_PATH/) { 
      $settings{$name} = BASE_PATH . $val . "/" ; 
      $log->debug("$name = $settings{$name}"); 
    } else {  
      $settings{$name} = $val; 
    }
  } 
  $self->{GLOBAL_SETTINGS} = \%settings; 
  $dbh->disconnect(); 
  return 1; 

}
#################
## sub get_var 
#################

sub get_var{
  my $self  = shift ;
  my $var_name = shift ;
  return $self->{GLOBAL_SETTINGS}->{$var_name}; 
}

BEGIN {
  if (!defined($CONF)) {
      $CONF = new OpenUMS::GlobalSettings;
  }
  $SIG{CHLD} = 'IGNORE';
}
1; 
