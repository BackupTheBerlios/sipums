package OpenUMS::PhoneSystem::NECAspire ; 
### $Id: NECAspire.pm,v 1.1 2004/07/20 02:52:15 richardz Exp $
#
# NECAspire.pm
#
## this will be a template for functions that 
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
use strict ; 
use OpenUMS::PhoneSystem::PhoneSystemBase;
use OpenUMS::Log;
use OpenUMS::DbQuery;
use OpenUMS::Config;

use base ("OpenUMS::PhoneSystem::PhoneSystemBase"); 



#################################
## sub integration_digits
#################################
sub integration_digits {
  my $self = shift ; 
  my $dbh = shift ;
  my $digits = shift ;
  my $ctport = $self->{CTPORT} ;

  $ctport->clear;

  if (!$digits) { 
    $log->debug("NECAspire::intergration_digits Digits not present, collecting '$digits'\n");
    $digits = $ctport->collect(22, $main::GLOBAL_SETTINGS->get_var('INTERGRATION_WAIT') , 3);
  } else {
     $log->debug("NECAspire::intergration_digits Digits already present, processing '$digits'\n");
  } 

  $log->debug("NECAspire::intergration_digits Digits received are '$digits'\n");
  if ($digits =~ /999$/ ) {
     $log->debug("got *999, i think the user hung up!\n");
     return ("","");
  } 

  my $mod_digits = $digits;
  $mod_digits =~ s/^9+//;
  $mod_digits =~ s/^\*+//;
  my $extension = undef ;
  my $function = undef ; 
  my $caller_id = undef ;
  
   
  #If we only have three digits, it is a user logon
  #Check for direct user logon, #XXX, XXX=extension

  if ($mod_digits =~ /^8/ ) {
     ## it's record call baby!
     $function = "record_call"; 
     $extension = substr($mod_digits, 1, EXTENSION_LENGTH); 
  } elsif ((length($mod_digits) == EXTENSION_LENGTH ) ||  ($mod_digits =~ /^#/) ) {
     ## it's record station login,  baby!
    $extension = $mod_digits;
    $extension =~ s/#//g ; 
    $function  = "station_login" ; 
  } elsif  ($mod_digits =~ /^2|^5|^300|^4|^3/) {
     ## it's record take a message for the extension,  baby!
    $function = "take_message" ; 
    $extension = substr($mod_digits, 4, EXTENSION_LENGTH);
    if (!OpenUMS::DbQuery::validate_mailbox($dbh, $extension) ) { 
       $function = "auto_attendant"; 
    } 
  } elsif (substr($mod_digits, 0, 1) eq "1") {
    ## it's record go to the auto_attendant
    $function = "auto_attendant"; 
    $caller_id =  substr($mod_digits,1,EXTENSION_LENGTH); 
  } 

  $log->debug("mod_digits=$mod_digits,function=$function,ext=$extension,caller_id=$caller_id");
  
  ## if nothing else, it's an outside caller 
  if (!$caller_id ) { 
    my $garbage ; 
    ($garbage, $caller_id) = split (/\*/, $mod_digits); 
  } 

  ## if nothing else, it's an outside caller 
  if (!$function) {
    $function = "auto_attendant"; 
  } 

  if ($dbh) { 
     $self->SUPER::_log_call($dbh,$digits,$caller_id, $function); 
  }

  return ($function,$extension, $caller_id );
} 

#################################
## sub is_hangup
#################################
sub is_hangup {
 my ($self, $input)  = @_ ;

 my $ctport = $self->{CTPORT}; 

 if ($input eq '9') {
  ## if it's a 9, we need 2 more to see a hang up...
   my $extra = $ctport->collect(2,1);
   $self->push_input($extra); 
   $input .= $extra; 
 }   else {
  ## collect 3 , we need 2 more to see a hang up...
   $input = $ctport->collect(3,1);
   $self->push_input($input); 
 } 

 if ($self->{INPUT_STACK}  =~ /999$/ ) {
    $log->debug("NECASPIRE : Received $input  (USER HUNG UP) ");
    return 1; 
 }  else {
  return 0 ; 
 }
}

sub hangup_occurred {
  my ($self, $input_stack)  = @_ ;
  $log->debug("NECAspire::hangup_occurred 999" .  $self->{INPUT_STACK} ) ; 
  if ($self->{INPUT_STACK} =~ /999$/){ 
   ## if the last 3 digits are "999", the NEC is telling us the caller has hung up...
    return 1; 
  }  else {
    return 0; 
  } 
 


}

#################################
## sub do_xfer
#################################
sub do_xfer { 
   my ($self, $ext)  = @_ ;
                                                                                                                             
   my $ctport = $self->{CTPORT};

   $ctport->dial("&,$ext,");
   $ctport->clear();

}

1; 
