package OpenUMS::CallRecorder; 
### $Id: CallRecorder.pm,v 1.2 2004/08/11 03:32:27 kenglish Exp $
#
# CallRecorder.pm
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
use OpenUMS::Log; 
use OpenUMS::Common; 
use OpenUMS::Object::User ; 
use OpenUMS::DbUtils; 
use OpenUMS::DbQuery ; 



#################################
## sub new
#################################
sub new {
  ## this your standard 'new', it intializes the hash and blesses it
  my $proto = shift;
 
  my $dbh = shift;
  my $ctport = shift;
  my $ext_to = shift;

  $log->debug("extention to = $ext_to called" ); 

  my $class = ref($proto) || $proto; 
  my $self = {}; ## self is a hash ref

  ## we'll add the parameters to the hash ref..
  $self->{DBH} = $dbh ;
  $self->{CTPORT} = $ctport ;
  $self->{EXTENSION_TO} = $ext_to ;

  bless($self, $class);
   
  return $self;
} 


#################################
## sub record
#################################
sub record  {
  ## this the most basic of basic plays....
  my $self = shift ; 
  $log->debug("recordi called" ); 
  my $ctport = $self->{CTPORT} ; 
  my $dbh = $self->{DBH} ; 
  my $ext_to = $self->{EXTENSION_TO} ; 

  my ($record_file,$record_path) =  OpenUMS::DbQuery::get_new_message_file_name ( $ext_to, $ctport->{HANDLE}); 
  $log->debug("recording call at $record_file,$record_path" ); 

  $self->{RECORD_FILE} = $record_file ; 
  $self->{RECORD_PATH} = $record_path ; 

  OpenUMS::Common::comtel_record($ctport, $main::CONF->get_var('VM_PATH') . TEMP_PATH . $record_file, (60 * ($main::CONF->get_var('RC_TIMEOUT')) ) , RECORD_TERM_KEYS, RC_SILENCE_TIMEOUT,1);
   
  return ;
} 


#################################
## sub process
#################################
sub process {
  my $self = shift ;
  my $dbh = $self->{DBH} ; 
  $log->debug("processin recorded calll.."); 
  
  return $self->save_message(); ## always try to save the message...

}

#################################
## sub save_message
#################################
sub save_message {
  my $self = shift; 
  my $dbh = $self->{DBH}; 
  my $user = $self->{USER}; 
  my $ext_to = $self->{EXTENSION_TO} ; 
  ## all the checks for saving a message...
  if ( $self->{RECORD_PATH} && $self->{RECORD_FILE} ) { 
      my $livefile  = $main::CONF->get_var('VM_PATH') . TEMP_PATH . $self->{RECORD_FILE} ;
      ## check that file exists and is readable
      if ( (-e $livefile) && (-r $livefile)  )  {

         $log->debug("Message File exists" );
         ## get the message file duration
         my $fileduration = &sound_duration($livefile);
         $log->debug("Message File duration is $fileduration sec" );

         if ( $fileduration > $main::CONF->get_var('MIN_MESSAGE_LENGTH') ) {

            $log->debug("Message created for " . $self->{EXTENSION_TO} . ", file = " . $self->{RECORD_FILE} );
            my $msg_id = OpenUMS::DbUtils::create_message( $dbh,
                    $ext_to, $self->{RECORD_FILE}, $self->{RECORD_PATH},
                    $user->{EXTENSION_FROM},1 );
#            OpenUMS::Mwi::mwi_extension_on($dbh,$ext_to);
         } 
      }
  } else {
     $log->debug("ATTEMPTED TO SAVE MESSAGE with a null value for RECORD_FILE=--" . $self->{RECORD_FILE}  .  "-- or RECORD_PATH =--" . $self->{RECORD_PATH} . "--"); 
    
  } 
}

1;

