package OpenUMS::Log;
### $Id: Log.pm,v 1.1 2004/07/20 02:52:15 richardz Exp $
#
# Log.pm
#
# OpenUMS's master logger/custom syslog sub.
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

use strict;
use warnings;

use Date::Calc;
use Exporter;

our $log;
our @ISA = ("Exporter");
our @EXPORT = qw($log);


=pod
=head1 NAME

OpenUMS::Log - Abstract logging facility for the OpenUMS package

=cut


my $PORT = 0;

# new {{{
sub new {
  my $class = shift;
  my $port  = shift;

  $class = ref($class) || $class;

  my $self = shift;
  if (!defined $self) { $self = { }; }
  bless ($self, $class);

  if ($port && ($port =~ /^\d+$/)) {
    $PORT = $port;
  }

  return $self;
}

sub file {
  my $self= shift ; 
  if (@_) { 
    $self->{FILE} = shift ; 
  }
  return $self->{FILE} ; 
}
# }}}

# From syslog(3)
#
# LOG_EMERG     A panic condition.  This is normally broadcast to all
#               users.
# LOG_ALERT     A condition that should be corrected immediately, such as a
#               corrupted system database.
# LOG_CRIT      Critical conditions, e.g., hard device errors.
# LOG_ERR       Errors.
# LOG_WARNING   Warning messages.
# LOG_NOTICE    Conditions that are not error conditions, but should possi-
#               bly be handled specially.
# LOG_INFO      Informational messages.
# LOG_DEBUG     Messages that contain information normally of use only when
#               debugging a program.

########## Comtel extensions
# LOG_NORMAL    Informational messages that indicate a process is proceeding
#               normally and behaving as expected.
# LOG_VERBOSE   A higher level of DEBUG
# LOG_UNKNOWN   Indicates an undefined Log::subroutine call

sub AUTOLOAD {
  my $self = shift;
  my $sub = our $AUTOLOAD;
  $sub =~ s/.*:://;

  return _logger("UNKNOWN:$sub", $self->{FILE}, @_);
}

# emerg {{{
sub emerg {
  my $self = shift;

  return _logger('EMERG',$self->{FILE}, @_);
}
# }}}

# alert {{{
sub alert {
  my $self = shift;

  return _logger('ALERT',$self->{FILE}, @_);
}
# }}}

# crit {{{
sub crit {
  my $self = shift;

  return _logger('CRIT',$self->{FILE}, @_);
}
# }}}

# err {{{
sub err {
  my $self = shift;

  return _logger('ERR',$self->{FILE}, @_);
}
# }}}

# warning {{{
sub warning {
  my $self = shift;

  return _logger('WARNING', $self->{FILE},@_);
}
# }}}

# notice {{{
sub notice {
  my $self = shift;

  return _logger('NOTICE',$self->{FILE}, @_);
}

# }}}
sub normal {
  my $self = shift;

  return _logger('NORMAL',$self->{FILE}, @_);
}

sub verbose {
  my $self = shift;

  return _logger('VERBOSE', $self->{FILE}, @_);
}

# info {{{
sub info {
  my $self = shift;

  return _logger('INFO',$self->{FILE}, @_);
}
# }}}

# debug {{{
sub debug {
  my $self = shift;

  return _logger('DEBUG',$self->{FILE}, @_);
}
# }}}

# logger {{{
sub _logger {
  my $level = shift;
  my $file = shift;
  if ($file) { 
    $file = " [$file]"; 
  }  else { 
    $file = ""; 
  } 
  my @lines = @_;
  my ($yy, $mm, $dd, $hr, $min, $sec) = Date::Calc::Today_and_Now();

  for my $line (@lines) {
    # strip off all the newlines to improve the logging format
    $line =~ s/\n+/ /g;
    $line =~ s/\s+$/ /;

    printf "%04d/%02d/%02d %02d:%02d:%02d [%04d/%s]$file %s\n",
     $yy, $mm, $dd, $hr, $min, $sec, $PORT, $level, $line;
  }

  return 1;
}
# }}}

BEGIN {
  if (!defined($log)) {
      $log = new OpenUMS::Log();
  }
  $SIG{CHLD} = 'IGNORE';
}


1;

# vim: softtabstop=2 tabstop=8 expandtab
