package Telephony::CTPortJr;

# CTPortJr - part of ctserver client/server library for Computer Telephony 
# programming in Perl
#
# Copyright (C) 2001-2003 David Rowe
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
=pod
=head1 NAME

Telephony::CTPortJr - Computer Telephony programming in Perl

=head1 SYNOPSIS

use Telephony::CTPortJr;

$ctport = new Telephony::CTPortJr(1200); # first port of CT card
$ctport->off_hook;
$ctport->play("beep");                 
$ctport->record("prompt.wav",5,"");    # record for 5 seconds
$ctport->play("prompt.wav");           # play back
$ctport->on_hook;

=head1 DESCRIPTION

This module implements an Object-Oriented interface to control Computer 
Telephony (CT) card ports using Perl.  It is part of a client/server
library for rapid CT application development using Perl.

=head1 AUTHOR

David Rowe, support@voicetronix.com

Ben Kramer, support@voicetronix.com

=cut

use strict;
use warnings;
use Carp;
use Sys::Syslog qw(:DEFAULT setlogsock);
use Telephony::SemsIvr; 
use File::Copy ;
use Audio::Wav; 


require Exporter;

our @ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use Telephony::CTPortJr ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw( ) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw( );
our $VERSION = '1.01';
our $port; 

use constant CTPORT_DEBUG     => 1;
# Preloaded methods go here.

# constructor - opens TCP/IP connection to server and makes sure we are
# on hook to start with
=pod

=head1 CONSTRUCTOR

new Telephony::CTPortJr(SERVER_PORT);

Connects Perl client to the "ctserver" server via TCP/IP port SERVER_PORT,
where SERVER_PORT=1200, 1201,..... etc for the first, second,..... etc
CT ports.

=head1 METHODS

=cut
sub new($) {
	my $proto = shift;
	my $class = ref($proto) || $proto;
	my $self = {};

	$self->{EVENT}  = undef;         # holds the events
	$self->{DEF_EXT} = ".wav";       # default audio file extension
	$self->{PATHS} = [];             # user supplied audio file paths
	$self->{INTER_DIGIT} = undef;		# holds the IDD
	$self->{DEFEVENTS} = undef;		# Used to hold default event handlers
	$self->{CONFIG} = undef;		# Used to hold Config values
	$self->{DAEMON} = undef;		# Used to hold daemon state
	$self->{IGNORE_DTMF} = 0;		# holds the ignore dtmf state
        Telephony::SemsIvr::init();

	bless($self, $class);
	return $self;
}

=pod

=head2 on_hook()

=over

Places the port on hook, just like hanging up.

 $ctport->on_hook();

=back

=cut

sub on_hook() {
	my $self = shift;
        ## get the perl ref to the java object...
        syslog('debug', 'this is another test');
        return ;
}

=pod

=head2 off_hook()

=over

Takes port off hook, just like picking up the phone.

 $ctport->off_hook();

=back

=cut

sub off_hook() {
	my $self = shift;
        ## get the perl ref to the java object...
        $self->logger("stub for off hook..."); 
        return ;
}

=pod

=head2  dial()

=over

Dials a DTMF string.  Valid characters are 1234567890#*,&ABCD

 $result=$ctport->dial("0,5555555");

=over 4

=item *

, gives a 1 second pause, e.g. $ctport->dial(",,1234) will wait 2 seconds, 
then dial extension 1234.

=item *

& generates a hook flash (used for transfers on many PBXs) e.g. :

$ctport->dial("&,1234) will send a flash, wait one second, then dial 1234. 

=back

=back

=cut

sub dial($) {
  my $self = shift;
  my($dial_str) = shift;
  ## get the java object
  my $object = $self->{CTPORTCLONE};
  ## print if debugging
  if (CTPORT_DEBUG) {
    my $port =  $object->getPort->get_value();
    $self->logger("going to dial $dial_str on $port...");
  }
  $object->dial($dial_str . ":string");
  return ;
}

=pod

=pod

=head2 wait_for_ring()

=over

Blocks until port detects 2 rings (by default), then returns. 
You can pass it a number of rings to wait. The caller ID (if 
present) will be returned.

 $ctport->wait_for_ring(3);

=back

=cut

sub wait_for_ring() {
  my $self = shift;
  ## get the java object
  my $object = $self->{CTPORTCLONE};
  ## print if debugging
  if (CTPORT_DEBUG) {
    my $port =  $object->getPort->get_value();
    $self->logger("going into wait_for_ring...");
  }
  $object->waitForRing();
  $self->logger("returned from wait for ring...");
  return ;
}

=pod

=pod

=head2 wait_for_ring()

=over

Blocks until port detects 2 rings (by default), then returns.
You can pass it a number of rings to wait. The caller ID (if
present) will be returned.

 $cid=$ctport->wait_for_ring();

 $cid=$ctport->wait_for_ring(3);

=back

=cut

sub wait_for_event {
  my $self = shift;
  ## get the java object
  my $object = $self->{CTPORTCLONE};
  ## print if debugging
  if (CTPORT_DEBUG) {
    my $port =  $object->getPort->get_value();
    $self->logger("going into wait_for_event...");
  }
  my $event = $object->waitForEvent->get_value();
  $self->logger("Got Event:$event\n");
  ## see if there's a message for us too
  
  my $message_obj = $object->getMessage ; 
  my (@ret_array, $message); 
  if ($message_obj) { 
    $message =  $message_obj->get_value();  
    $self->logger("message received=$message") ; 
    if ($message ) { 
       ## if there was a message, split it up, it's divided by '|'...
       @ret_array = split (/\|/, $message) ; 
       $object->clearMessage() ; 
     } 
  }
  $self->logger("returned from wait for event...$event message = $message");
  return ($event,@ret_array);
}



sub play($) {
  my $self = shift;
  my $files_str = shift;

  if (!$files_str ) { 
     syslog('debug', "PLAY CALLED WITH NO FILE " . $files_str );
     return 
  }; 
  ## get the java object
  my $object = $self->{CTPORTCLONE};
  ## print if debugging
  unless (length($files_str)) {return;}
  my @files_array = split(/ /,$files_str);


  foreach my $file (@files_array) {
      Telephony::SemsIvr::play($file); 
      syslog('debug', "in play " . $Telephony::SemsIvr::MEDIA_STATE );
      if ($Telephony::SemsIvr::MEDIA_STATE != MEDIA_PLAYING) { 
        #playing was interrupted
        last; 
      } 
      
   } 

  return ;
}


=pod

=head2 collect()

=over

 $digits=$ctport->collect($max_digits,$max_seconds,$IDD);

Returns up to $max_digits by waiting up to $max_seconds.  Will return as soon
 as either $max_digits have been collected or $max_seconds have elapsed.

DTMF digits pressed at any time are collected in the digit buffer.  The digit
buffer is cleared by the clear() method.  Thus it is possible for this function
to return immediately if there are already $max_digits in the digit buffer.

=back

=cut

sub collect {
   my $self = shift;
   my $maxdigits = shift;
   my $maxseconds = shift;
   my $idd = shift; ## inter-digit delay isn't yet implemented
   my $digits = Telephony::SemsIvr::collect($maxdigits, $maxseconds); 
   return $digits;		  
}

=pod

=head2 record()

=over

Records to a file, terminating on time, digits, an event or silence timeout.

 $ctport->record($file_name,$time_out,$term_keys,$silence_timeout);

If silence_timeout is not defined or zero, it defaults to time_out.
Records $file_name for $time_out seconds or until any of the digits in 
$term_keys are pressed.  The path of $file_name is considered absolute if 
there is a leading /, otherwise it is relative to the current directory.


=back

=cut

sub record($$$$$) {
   my $self = shift;
   my $file = shift;
   my $timeout = shift;
   my $term_digits = shift;
   my $silence_timeout = shift;
   my $no_beep_flag = shift;

   ## get the perl ref to the java object...
   syslog('debug', "file $file");
   Telephony::SemsIvr::record($file, $timeout, $term_digits, $silence_timeout,$no_beep_flag);
   
 
   my $wav = new Audio::Wav;
   my $read ; 
   
   syslog('debug', "Going to Read WAV");

   ivr::msleep(20);
   $read = $wav->read($file); 
   syslog('debug', "Read Wave file");


   use Data::Dumper;
   my $details = $read->details();
   my $length = $details->{'length'};
   my $trim_length = $length - 0.060;
   my $tmp_file = $file; 
   $tmp_file =~ s/\.wav$/tmp.wav/; 
   my $cmd = "sox $file $tmp_file trim 0 $trim_length";
  # 
  # syslog('debug', "comd $cmd ");
  #  
   `$cmd`;
   syslog('debug', "gonna move");
   move($tmp_file, $file); 
   syslog('debug', "mved $tmp_file to $file");
   return ;

}

sub set_paths($) {
        my $self = shift;
        my $paths = shift;
        my $object = $self->{CTPORTCLONE};
        $object->setPaths($paths); 
}
sub clearevents {
  my $self = shift ; 
  $self->logger("clear events is just a stub...");


}

#sub send_interupt {
#  my $self =shift 
#  ##my $object = $self->{CTPORTCLONE};
###  $object->setPaths($paths); 
#}
                                                                                                                                               
=pod
                                                                                                                                               
=head2 openlogger()
                                                                                                                                               
=over
                                                                                                                                               
Opens a logfile for this port.
                                                                                                                                               
 $ctport->openlogger("mylogfile");
                                                                                                                                               
Will open the logfile "20030915-mylogfileA.log", then alternate between this file
and 20030915-mylogfileB.log when each log file reached 10000 lines.  This example
assumes the log file was opened on 15 September 2003 (20031509).
                                                                                                                                               
=back
                                                                                                                                               
=cut
                                                                                                                                               
sub openlogger($){
        my $self = shift;
        my $logfile = shift;
                                                                                                                                               
        my $foo = strftime("%Y%m%d%H%M",localtime(time));
        our $logfileA = $logfile . $foo . "A.log";
        our $logfileB = $logfile . $foo . "B.log";
        our $currentlogfile = $logfileA;
        our $logfilelines = 0;
                                                                                                                                               
        open (our $LOGFILE,">$currentlogfile") or
                        open ($LOGFILE,">/dev/null") ;
        autoflush $LOGFILE 1;
}


=pod
                                                                                                                                               
=head2 logger()
                                                                                                                                               
=over
                                                                                                                                               
Logs to the log file opened with openlogger.
                                                                                                                                               
 $ctport->logger("New call from $cli");
                                                                                                                                               
=back
                                                                                                                                               
=cut


sub logger_jr($){
        my $self = shift;
        my $text = shift;
        my $foo = strftime("%Y/%m/%d-%H:%M:%S",localtime(time));
        our $logfilelines;
        our $logfileA;
        our $logfileB;
        our $currentlogfile;
        our $LOGFILE;
                                                                                                                                               
        if ($self->{DAEMON}){
                print $LOGFILE "$foo [".$port."] $text\n";
                                                                                                                                               
                $logfilelines++;
                if ($logfilelines > 1000) {
                    # swap A-B log files
                                                                                                                                               
                    print $LOGFILE "line limit reached, swapping logfiles\n";
                    close ($LOGFILE);
                    $logfilelines = 0;
                    if ($currentlogfile eq $logfileA) {
                        $currentlogfile = $logfileB;
                    }
                    else {
                        $currentlogfile = $logfileA;
                    }
                                                                                                                                               
                    open ($LOGFILE,">$currentlogfile") or
                                open ($LOGFILE,">/dev/null") ;
                    autoflush $LOGFILE 1;
                }
        }
        else {
                print STDERR "$foo [".$port."] $text\n";
        }
}

=pod
                                                                                                                                               
=head2 closelogger()
                                                                                                                                               
=over
                                                                                                                                               
Closes the logfile for this port.
                                                                                                                                               
 $ctport->closelogger();
                                                                                                                                               
=back
                                                                                                                                               
=cut
                                                                                                                                               
sub closelogger($){
        my $self = shift;
        close (our $LOGFILE);
}
sub clear {
  my $self = shift ; 
  syslog('debug', 'Called clear, dummy stub');
}
sub finalize() {
  ## do clean up
  Telephony::SemsIvr::cleanup();
}
1; 
