package OpenUMS::PhoneSystem::PhoneSystemBase; 
### $Id: PhoneSystemBase.pm,v 1.2 2004/07/31 21:51:15 kenglish Exp $
#
## this will be a template for functions that 


use OpenUMS::Common;
use OpenUMS::Config;
use OpenUMS::Log;

#################################
## sub new: the constructor
#################################

sub new {
  my $proto = shift;
  my $ctport = shift ; 
  my $dbh = shift ; 

  my $class = ref($proto) || $proto;
  my $self = {}; ## self is a hash ref
  $self->{CTPORT} = $ctport; 
  $self->{DBH} = $dbh; 
  $self->{INPUT_STACK} = ""; 

  ## we add the parameters to the hash ref..
  ## bless that puppy, ie, make it an object ref


  bless($self, $class);
  return $self;
}

#################################
## sub _log_call; logs call to the database...
#################################

sub _log_call {
  my ($self,$dbh, $digits, $caller_id,$function) = @_ ;   

  my $sql = qq{INSERT INTO call_log ( intergration_digs , caller_id, vm_function )
       VALUES ('$digits', '$caller_id','$function')} ; 
  $dbh->do($sql) ; 
  return; 
}

#################################
## sub input_stack
##  returns the string value of the input stack...
#################################
sub input_stack {
  my $self = shift ;
  return  $self->{INPUT_STACK} ; 
} 


#################################
## sub push_input
##  adds a value to the end of the input stack
#################################
sub push_input {
  my $self = shift ;
  my $input = shift ; 
  $self->{INPUT_STACK} .=  $input;
  $log->debug("phone_sys->{INPUT_STACK} " . $self->{INPUT_STACK} ) ; 
} 


#################################
## sub clear_input_stack()
##  clears the input stack. This must be called everytime we 
##  receive a new call.
#################################
sub clear_input_stack() {
  my $self = shift ;
  $self->{INPUT_STACK} = ""; 
} 


#################################
## sub update_mwi
##  calls sub in OpenUMS::PhoneSystem::Mwi to update Message Waiting Lights
#################################
sub update_mwis {
  my ($self, $dbh) = @_  ;
  return OpenUMS::PhoneSystem::Mwi::update_mwis($self->{CTPORT},$dbh, $self); 
}

############ BEGIN STUBS, THESE SHOULD BE IMPLEMENTED BY  ############
############ THE CHILD CLASS, PLEASE PRACTICE GOOD PROGRAMMING ############


#################################
## sub send_mwi
##  each phone system has it's own ways of sending mwis
#################################
sub send_mwi {
  ## stub, child class should implement...
  return 1;
}
#################################
## sub intergration_digits
##  process the intergration digits
#################################
sub intergration_digits {
  ## stub...
  return 0; 
} 
#################################
## sub is_hanup
##  Each phone system has it's own was of detecting hangups
#################################
sub is_hangup {
  my ($self, $ctport, $input)  = @_ ; 
  return 0; 
}

#################################
## sub do_xfer
##  Each phone system has it's own was of Transfering calls
#################################
sub do_xfer {
  ## stub
  return 1; 
}
#################################
## sub is_rec_msg ()
##  Some phone system won't tell u if the call should go to voicemcail
##  or be treated as a transfer until later 
#################################
sub is_rec_msg () {
  ## stub
  return 0; 
} 
sub do_transfer {
  ## stub
  return 0; 
} 
1; 
