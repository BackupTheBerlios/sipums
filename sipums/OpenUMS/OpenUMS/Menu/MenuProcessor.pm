package OpenUMS::Menu::MenuProcessor;
### $Id: MenuProcessor.pm,v 1.8 2005/03/12 01:15:51 kenglish Exp $
#
# MenuProcessor.pm
#
# Generic/general subs for playing messages/prompts, getting input from the the ctport
# validating that input and processing the input.
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

=pod
=head1 NAME
                                                                                                                             
OpenUMS::MenuProcessor - The base/parent class for all menus in the OpenUMS system.
                                                                                                                             
=head1 SYNOPSIS
                                                                                                                             
Calling programs should use the MenuProcessor like this

use Telephony::CTPort;
                                                                                                                             

my $dbh = OpenUMS::Common::get_dbh() ; ## a DBI handle ref
my $ctport = new Telephony::CTPort(1200); # A Ctport ref
my $user = new OpenUMS::User; ## A user ref

## get these 2 from the 'menu' table in the database:
## SELECT menu_id, permission_id FROM menu
my ($menu_id, $permission_id)  = @_;

my $menuProcessor = new OpenUMS::MenuProcessor($dbh, $ctport, $user, $menu_id, $permission_id); 

## play the menu
$menuProcessor->play_menu();

## here the input from the user
$menuProcessor->get_input();

## 2 parts of the validation:

## 1) is it valid?
my $valid = $menuProcessor->validate_input();

## 2) if it's invalid, is it invalid because they didn't hit a button?
$menuProcessor->no_input();
if ($valid) {
  ## if it is valid, u should process the input:
  my ($action, @params) =  $menuProcessor->process() ;
}



=head1 DESCRIPTION
                                                                                                                             
This module implements an Object-Oriented interface for Menu Processor. 
Terms: 
   Menu: The entire menu tree structure.
   MenuProcessor: One of the elements in the menu structure. Each one has different behavior.
   menu_items: An option in the MenuProcessor. Normally like, 1, 2 , 3, #, etc. In some cases it can be variable length.
   menu_sounds: The sound or prompt that the user hears for the MenuProcessor. 
        Different sounds include : 1) M - Main Sound, 2) I - Invalid sound
   menu_item_actions: Hooks that should be looked at during 'process.' For example, if '1' is an option to delete message, you could give it menu_item_action = 'DELMSG'. Then in process when u see that action, u know to insert code to delete the message.
   
                                                                                                                             
=head1 AUTHOR
                                                                                                                             
Kevin W. English, kenglish@comtelhi.com

                                                                                                                             
=cut

use strict;

use OpenUMS::Config; 
use OpenUMS::Object::Prompt; 
use OpenUMS::Log; 
use Telephony::SemsIvr; 

######################################
## sub new
##   returns a blessed hash ref...
##   calls _pre_data(), then _get_data(), then get_data2()
######################################
sub new {
  ## this your standard 'new', it intializes the hash and blesses it
  my $proto = shift;

  my $dbh = shift;
  my $ctport = shift;
  my $user = shift;
  my $phone_sys = shift; ## new phone system object...

  my $menu_id = shift;
  my $permission_id = shift;
  my $collect_time = shift;


  my $class = ref($proto) || $proto;
  my $self = {}; ## self is a hash ref
  ## we'll add the parameters to the hash ref..
  $self->{DBH} = $dbh;
  $self->{CTPORT} = $ctport;
  $self->{USER} = $user;
  $self->{PHONE_SYSTEM} = $phone_sys; ## new phone system object...
  $self->{MENU_ID} = $menu_id;
  $self->{PERMISSION_ID} = $permission_id;
  if (!defined($collect_time) ) { 
     $self->{COLLECT_TIME} =  $main::CONF->get_var('COLLECT_TIME') ;
  } elsif ($collect_time =~ /[0-9]+/) {
     $self->{COLLECT_TIME} = $collect_time;
  }  else { 
     $self->{COLLECT_TIME} =  $main::CONF->get_var('COLLECT_TIME') ;
  }
  $self->{FIRST_FLAG} = 1;

  $self->{INPUT_COLLECTED} = "";

  bless($self, $class);
  ## this is used mainly to overide stuff before get data
  $self->_pre_data(); 

  $self->_get_data(); 
  $self->_get_data2(); 
  $self->_post_data(); 
  
  return $self;
}
######################################
## sub _pre_data
##  This should be used by child classes if they 
##  know something that they must do before the 
##  data for the menu is retrieved 
##  For example, AutoAttendantMP uses it change the menu_id 
##    based on auto attendant setting for that time of day  
######################################

sub _pre_data {
  my $self  = shift ; 
  return ; 
}
######################################
## sub _get_data
##   this sub does a query on the voicemail database.
##   it constructs an data structure that will be used internally 
##   by this class to play files of present options...
######################################

sub _get_data  {
  ## this sub does a query on the voicemail database.
  ## it constructs an data structure that will be used internally 
  ## by this class to play files of present options...

  my $self = shift ; 
  my $menu_id = $self->{MENU_ID} ; 
  my $dbh = $self->{DBH};

  my $sql = "SELECT sound_type, sound_title, sound_file, var_name, custom_sound_flag " ;
  $sql  .= qq{ FROM menu_sounds WHERE menu_id = ? order by order_no };

  ##################$log->debug($sql . $menu_id); 
  if ($menu_id eq '606'){
     $log->log("606 === " . $sql );  
  } 

  my $sth = $dbh->prepare($sql) ;
  $sth->execute($menu_id);
  my $menuSounds;
  while (my ($sound_type, $sound_title , $sound_file, $var_name , $custom_sound_flag) = $sth->fetchrow_array() ) {
     my $sound_ref ;
     $sound_ref->{sound_title} = $sound_title ;
     $sound_ref->{var_name} = $var_name ;
     # $sound_ref->{custom_sound_flag} = $custom_sound_flag ;
     if ($sound_file ) { 
       $sound_ref->{PROMPT_OBJ} = new OpenUMS::Object::Prompt($sound_file, $custom_sound_flag) ;
     } 
     push @{$menuSounds->{$sound_type}} , $sound_ref ; 
  }
  $sth->finish();
  $self->{SOUNDS_ARRAY}  = $menuSounds ; 
  return ;
} 
######################################
## sub _get_data2
##   this sub gets the options or items in  each  menu... it should
##   really only be called by create_menu... thus the _ at the beginning..
######################################
sub _get_data2 {

  my $self = shift ;  
  my $menu_id = $self->{MENU_ID} ;
  my $dbh = $self->{DBH};

  my $sql = qq{SELECT menu_item_id , menu_item_option , dest_menu_id, menu_item_action 
     FROM menu_items
     WHERE menu_id = ? };

  my $sth = $dbh->prepare($sql) ;
  $sth->execute($menu_id);
  my $menuOptions;
  $self->{MAX_INPUT_LENGTH} = 0 ; 
  $self->{MIN_INPUT_LENGTH} = 20000; 
  while (my ($menu_item_id , $menu_item_option , $dest_menu_id,$menu_item_action) = $sth->fetchrow_array() ) {
     if (length($menu_item_option) > $self->{MAX_INPUT_LENGTH}) {
        $self->{MAX_INPUT_LENGTH} = length($menu_item_option) ; 
     }  
     if (length($menu_item_option) < $self->{MIN_INPUT_LENGTH}) {
        $self->{MIN_INPUT_LENGTH} = length($menu_item_option) ; 
     }  
     $menuOptions->{$menu_item_option}->{dest_id} = $dest_menu_id ;
     $menuOptions->{$menu_item_option}->{item_action} = $menu_item_action ;
  }

  $sth->finish();
  $self->{MENU_OPTIONS} = $menuOptions ; 
  return ;
} 
######################################
## sub _post_data
##  This should be used by child classes if they
##  know something that they must do before the
##  data for the menu is retrieved
##  For example, AutoAttendantMP uses it change the menu_id
##    based on auto attendant setting for that time of day
######################################
                                                                                                                                               
sub _post_data {
  my $self  = shift ;
  return ;
}

######################################
## sub init()
######################################
sub init() {

  ## stub...


}

######################################
## sub play_menu()
######################################

sub play_menu {
  my $self = shift ;
  my $menu = shift ; 
  my $attempt = shift ; 

  ## we do what we have to to play the sound....
  $self->_play_menu($attempt); 
  return ;
}

######################################
## sub _play_menu()
## this the most basic of basic plays....
######################################

sub _play_menu () {
  my $self = shift ; 
  my $ctport = $self->{CTPORT} ; 

##############3
  ## take this out, this logs kevin in no matter what : )
  my $user = $self->{USER} ;
# uncomment to test...
#  $log->debug("auth = " . $user->authenticated() ) ;
#   if (!$user->authenticated() ) {
#     $user->extension('901');
#     $user->login('9876');
#     $log->debug("authorized kevin\n");
#  }
##############3
  
  ## get the array of sounds  
  my $menuSounds = $self->{SOUNDS_ARRAY}; 
  ## get the first sound off that sound array 
  my $sound_file = $menuSounds->{M}->[0]->{PROMPT_OBJ}->file(); 

  ## $log->debug("sound_file = " . $sound_file ) ;
  ## $log->debug("CUSTOM_FLAG = " . $menuSounds->{M}->[0]->{PROMPT_OBJ}->{CUSTOM_FLAG} )  ;

  if (defined($sound_file) ) { 
    ## hey, if there, let 'em hear it
      $ctport->play($sound_file); 
  } 
  return ;
} 

######################################
## sub play_invalid()
## this the most invalid players, for 99% of the cases this is all you need...
######################################

sub play_invalid {
  my $self = shift ; 
  ## get the 2 objects...

  my $ctport = $self->{CTPORT}; 
  my $menuSounds = $self->{SOUNDS_ARRAY}; 
  
  $log->debug("in play_invalid  defined = " . defined($menuSounds)  );

  if (defined($menuSounds->{I}) ) { 
     ## they could define a blank invalid sound.... 
      my $invalid_sound  = $menuSounds->{I}->[0]->{PROMPT_OBJ}->file() ;
      if ($invalid_sound) { 
        $ctport->play($invalid_sound ); #OpenUMS::Common::get_prompt_sound( $invalid_sound) ) ; 
      } 
  } else {
      ## it's just faster to do it this way....
      #my $prompt = OpenUMS::Object::SoundVariables($self->{DBH},'DEFAULT_INVALID_SOUND');  
      my $sound_file = OpenUMS::Common::get_prompt_sound(DEFAULT_INVALID_SOUND) ; 
      $log->debug("invalid sound_file = $sound_file");
      $ctport->play($sound_file) ; 
  } 
  return ;
} 

######################################
## sub check_loop_drop()
## this doesn't really work but it's not hurting anyone
######################################

sub check_loop_drop {
  my $self = shift ; 
  my $ctport = $self->{CTPORT}; 
  if (defined($ctport->event() ) )   {
##    my $in = $ctcollect-> 
    if ($ctport->event eq "loop drop") {
      $self->{LOST_CALL_FLAG} = 1 ;
      return ;
    }
  } 
}

######################################
## sub clear()
## this clears out all variable except the ctport and dbh var
######################################

sub clear {
  my $self = shift  ; 
  $self->{INPUT} = undef ; 
  $self->{LOST_CALL_FLAG} = undef ; 
}

######################################
## sub user_hung_up()
## returns 1 if the user hung up, returns 0 if he's still around...
######################################

sub user_hung_up {
  my $self  = shift ;
  ## returns 1 if the user hung up, returns 0 if he's still around...
  my $flag ; 

  if ($self->{LOST_CALL_FLAG} ) {
    $log->normal("----------------USER HUNG UP-------------"); 
    $flag = 1; 
  } else {
    $flag = 0 ; 
  } 
  $self->_user_hung_up(); 
  return $flag; 
}
######################################
## sub _user_hung_up()
##  this a stub for the child. It  allows child to do things 
##  after the guy hangs up. 
######################################
sub _user_hung_up () {
  return ;
}

######################################
## sub _user_hung_up()
## this sub tells u if there was nothing input by the user...
######################################
sub no_input {
  my $self = shift ; 
  if (!OpenUMS::Common::is_phone_input( $self->{INPUT} ) && 
       $self->{INPUT} ne 'EXT'  && 
       $self->{INPUT} ne 'IP') { 

     $log->debug("[MenuProcessor.pm] no input"); 
     return 1; 
  }  else {
    $log->debug("[MenuProcessor.pm] there's input--".  $self->{INPUT} ); 
    return  0 ; 
  } 
} 
######################################
## sub get_input()
## gets the input from the user but calls _get_input to do the actual get
## for now, the dection of the '999' hang up signal from the NEC Aspire 
## Phone system is hard coded in here
######################################

sub get_input {
  my $self = shift; 
  my $ctport = $self->{CTPORT}; 

  ## get the input
  $self->_get_input(); 

  my $phone_sys = $self->{PHONE_SYSTEM};
  $phone_sys->push_input( $self->{INPUT_COLLECTED} ) ;
  ##if ($phone_sys->hangup_occurred() ) {
  ##    $self->{LOST_CALL_FLAG} = 1 ;
  if ( $phone_sys->is_hangup($self->{INPUT}) )    {
     $self->{LOST_CALL_FLAG} = 1 ;
  }


  return ;

## old, hardcoded way of looking for hang up...
  ## check one more time....
#  if (!TEXT_MODE) { 
#    my $extra = $ctport->collect(2,1); 
#     ## do this crazy hack for now, this is for the NEC Aspire....      
#
#    if ($extra  eq '99' ) { 
#      if ($self->{INPUT} . $extra eq '999' ) { 
#         $log->debug("Received 999,  Setting LOST_CALL_FLAG :)"); 
#         $self->{LOST_CALL_FLAG} = 1 ;
#      } elsif (my $next = $ctport->collect(1,1)) { 
#         if ($extra . $next eq '999') {
#           $log->debug("Received 999,  Setting LOST_CALL_FLAG :)"); 
#           $self->{LOST_CALL_FLAG} = 1 ;
###         } 
#      } 
#    }
#  } 
#  $ctport->clear ; 
} 

######################################
## sub _get_input()
##   this generic one gets a single digit, 
##   to implement something more complex, 
##    extend this class and write your own _get_input :)
######################################

sub _get_input { 
  my $self = shift ; 
  my $ctport = $self->{CTPORT}; 
  my $input ; 
  ## phone mode here dood...
  $log->debug("__get_input + $self->{COLLECT_TIME} "); 
  $input = $ctport->collect(1,$self->{COLLECT_TIME});
  $self->{INPUT_COLLECTED} = $input ;
  if (OpenUMS::Common::is_phone_input($input) ) {
    $self->{INPUT} = $input;
  }  else {
    $self->{INPUT} = undef;
  } 
}

######################################
## sub validate_input()
##   this is the basic of basic validation routines
##   if the user's input is a valid option in the menu
##   it returns true, otherwise false
##   to implement something more complex, 
##    extend this class and write your own validate_input :)
######################################

sub validate_input {
  my $self = shift ; 

  my $input       = $self->{INPUT} ; 
  my $menuOptions = $self->{MENU_OPTIONS} ; 
  if (defined($menuOptions->{$input}) ) {
    return  1 ;
  } else {
    return 0; 
  }
  
} 
######################################
## sub process()
##   this is the basic of process routines
##   it returns 'NEXT' action 
##      and the destination menu_id for the option entered
######################################

sub process {
  my $self = shift;
  my $input = $self->{INPUT} ; 

  my $action = "NEXT"; 
  my $next_id =  $self->{MENU_OPTIONS}->{$input}->{dest_id} ; 
  $log->debug("action = $action, next_id = $next_id "); 
  return ($action, $next_id) ;    
}

sub process_default {
  my $self = shift ; 
  if (defined($self->{MENU_OPTIONS}->{'DEFAULT'}->{dest_id} )  ) { 
     return ("NEXT", $self->{MENU_OPTIONS}->{'DEFAULT'}->{dest_id} ); 
  }  else {
     return (undef,undef); 
  } 

}


#################################
## sub get_sound_var_ref
#################################
sub get_sound_var_ref {
  my $self = shift; 
  my $var_name = shift; 
  my $menuSounds = $self->{SOUNDS_ARRAY}; 
  foreach my $ref (@{$menuSounds->{V}} ) {
    if ($ref->{var_name} eq $var_name ) {        
      return $ref ; 
    }
  } 
  return ; 
}

######################################
## sub get_item_action_input($action)
##   returns the input value for a specific item action 
##   this is sort of a reverse hack. Normally, you want
##   to get the input then figure out if it has an item_action
##   then if it does, you do that action. One would use this if they  
##   want to fool a menu to think that a certain input was enter thus 
##   triggering the action for the given item_action.... 
######################################

sub get_item_action_input {
  my $self = shift; 
  my $action = shift; 

  my $menuItems = $self->{MENU_OPTIONS};
  foreach my $input (keys  %{ $menuItems } ) {
    if ($menuItems->{$input}->{item_action} eq $action ) {
       return $input;
    } 
  }
  return ;
} 
######################################
## sub permission_id
##   returns the permission_id set when the 
##   object was created. it can not be edited....
######################################
sub permission_id {
  my $self = shift; 
  return $self->{PERMISSION_ID} ; 
}

######################################
## sub get-var_len_input
##   This is the mdarnell contribution :
##   It takes in max length  and a terminating char (default is '#') 
##   tries to collect max length but if '#' is enter it returns all the 
##   digits the enter before they hit the '#' 
######################################

sub get_var_len_input {  
  my $self = shift ; 
  my $maxlength = shift || 10 ;
  my $terminator = shift || '#' ; ## no, not arhnold, he's the governor now :)
  my $include_terminator = shift || 0 ; ## no, not arhnold, he's the governor now :)

  my $ctport = $self->{CTPORT} ; ## who's this?

  my ($input,$last_input) ; 
  my $count = 0;

  do {
      $count++; 
      $last_input = $ctport->collect(1, 3, 3);
      $input .= $last_input ;
      $log->debug("last_input=$last_input,input=$input,count=$count,maxlength=$maxlength") 

  } until (!OpenUMS::Common::is_phone_input($last_input) 
         || ($last_input eq '#')  
         || ($count >= $maxlength))  ;

  if (!$include_terminator) { 
    ## lose a pound, hahahaha  but only if a long string, if it's one character, it might be an option
    if ($input =~ /\#$/ && length($input) > 1 ) {
      chop($input);
    }
  }
  return $input; 
}
#################################
## sub get_active_extensions
#################################
sub get_active_extensions {
  my $self = shift  ;
  if (defined($self->{EXTENSIONS}) ) {
    ## if it's there, use the cached one...
    return $self->{EXTENSIONS};
  } else {
    ## if it's there, use the cached one...
    $self->{EXTENSIONS} = OpenUMS::DbQuery::get_active_extensions($self->{DBH});
    $self->{MAX_EXT_LENGTH} = OpenUMS::DbQuery::get_max_ext_length($self->{DBH});
    ## now we figure out what the max length is...
    return $self->{EXTENSIONS};
  }
}
#################################
## sub is_valid_extension
#################################
sub is_valid_extension {
  my $self = shift  ;
  my $ext_to = shift  ;
  my $exts = $self->get_active_extensions();

  foreach  my $ext ( @{$exts} ) {
    $log->debug("is_valid_extension $ext $ext_to"); 
    if ($ext eq $ext_to) {
      return 1;
    }
  }
  return 0;
}
1;
