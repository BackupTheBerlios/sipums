package OpenUMS::Object::User;
### $Id: User.pm,v 1.4 2004/08/05 09:14:14 kenglish Exp $
#
# User.pm
#
# This object is used to manipulate and retrieve information about user's of the Voicemail system
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

=pod
=head1 NAME
                                                                                                                             
OpenUMS::Menu::User - User object for the OpenUMS Menu system 
           
=head1 SYNOPSIS
 
  use OpenUMS::Menu::User;
  use OpenUMS::Common;
  my $dbh = OpenUMS::Common::get_dbh();
  my $user = new OpenUMS::Menu::User($dbh,$ext_to, $ext_from)

  #### loging in
  $user->extension($extension);  ## set the extension...
  $user->login($password);  ## send the password

   ###  to verify the user is logged in
   if ($user->authenticated()) {
      ## tell him something personal
   } 
  ## user the 'extension()' sub when u need the user's extension
  ## and he should be logged in...

  &update_user_birthday($user->extension(), "1/27/1977");
  &update_user_birthday($user->extension(), "1/27/1977");
  ## other functions:
  $user->get_value('new_user_flag');  ## retrieves a database field's value from a local data structure,
                                    ## user must be logged i
  $user->get_message_spool('N')    ## gets user's message spool, 'N' for new, 'S' for Saved
  $user->get_dbnm_spool();         ## gets a dbnm spool, 'N' for new, 'S' for Saved
  $user->delete_message_spool('N') ## deletes a user's message spool forcing a new query to run next time
  $user->get_greeting();           ## gets the user's greeting
  $user->get_name                  ## gets the user's name
  $user->new_message_count         ## get's the number of new messages for user, must be logged in
  $user->saved_message_count       ## get's the number of saved messages for user, must be logged in


=head1 DESCRIPTION

This module implements an Object-Oriented interface to User data for 
OpenUMS database. 

=head1 AUTHOR

Kevin English, kenglish@comtelhi.com
Matt Darnell , mdarnell@comtelhi.com
Dean Takemori, dtakemore@comtelhi.com
                                                                                                                             
=cut

use strict ; 

use OpenUMS::Config ; 

use OpenUMS::Object::DbnmSpool;
use OpenUMS::Object::ForwardMessageObj;
use OpenUMS::DbUtils ; 
use OpenUMS::IMAP;
use OpenUMS::Log ;
use OpenUMS::Object::IpAddress ;
use OpenUMS::Object::MessageSpool ; 



#################################
## sub new
#################################
sub new {
  ## this your standard 'new', it intializes the hash and blesses it
  ## expected parametes:
  ##  $dbh = a valid database handle. Should already be connected to a database
  ## containing an instance of our standard voicemail database   
  my $proto = shift;
  my $dbh = shift;
  my $ext_to   = shift;
  my $ext_from = shift;

  my $class = ref($proto) || $proto;
  my $self = {}; ## self is a hash ref

  ## we add the parameters to the hash ref..
  $self->{DBH} = $dbh;
  $self->{MENU_OBJ} = $dbh;
  $log->info("Create new USER "); 
  if ($ext_to) { 
    $self->{EXTENSION_TO} = $ext_to;
  } else {
    $self->{EXTENSION_TO} = undef; 
  } 
  ## bless that puppy, ie, make it an object ref
  if ($ext_from) { 
    $self->{EXTENSION_FROM} = $ext_from ;
  } else {
    $self->{EXTENSION_FROM} = undef; 
  } 
  ## get the current datetime from the DB, important to get it from db...
  my $sql = qq{SELECT NOW() } ; 
  my $sth = $dbh->prepare($sql);
  $sth->execute();
  my $now = $sth->fetchrow();
  $sth->finish(); 
  $log->debug("last vist will be $now"); 
  $self->{LAST_VISIT} = $now ; 
  
  ## here we will define what Input processors and Sound Players we'll be using
#  $self->{PROCS}->{B} = new OpenUMS::InputCollector($dbh,$ctport); 
#  $self->{PLAYER}->{B} = new OpenUMS::Presenter($dbh,$ctport); 
   
  bless($self, $class);
  return $self;
}

#######################################
##  sub extension() 
##    Used For 2 purposes
##    1) when called and passed and extension, like this
##       $user->extension(122)
##       it will validate that it was given a valid extension
##    2) when called without an extension, it will return the extension
##       only if the user is logged in, thus ensuring some security
#######################################

sub extension {
  my $self  = shift ; 
  if (@_) { 
    ## they are calling it like a set...
    my $ext_to_validate = shift ; 
    if (OpenUMS::DbQuery::validate_mailbox($self->{DBH}, $ext_to_validate) )  { 
      $self->{EXTENSION}  = $ext_to_validate ; 
    } else {
      return 0; 
    }
  } else {
    if (!$self->authenticated() ) {
       return 0; 
    } 
  }    
  return $self->{EXTENSION} ; 
} 

#######################################
##  sub authenticated() 
##    Returns 1 if the user is logged in
#######################################

sub authenticated {
  my $self  = shift ;
  return $self->{AUTHETICATED} ;
} 

#######################################
##  sub auto_login($extension)
##    Returns 1 
##    Sets the user to AUTHENTICATED flag
#######################################
                                                                                                                                               
sub auto_login {
  my $self = shift ;
  my $ext = shift ;

  $self->{EXTENSION} = $ext ;
  $self->_login(); 
  return 1;
}

#######################################
##  sub login($password) 
##    Returns 1 if the password is correct
##    Sets the user to AUTHENTICATED flag
##    returns 0 if the password is invalid
#######################################

sub login {
  my $self = shift ; 
  my $passwd = shift ; 
  my $ext = $self->{EXTENSION} ; 
  $log->normal("User login called, ext = $ext, passwd = $passwd\n"); 
  if ((!$ext) &&  (!$passwd)) { 
    return 0; 
  } 
  if (OpenUMS::DbQuery::validate_password($self->{DBH},$ext,$passwd) ) {
    $self->_login(); 
    return 1; 
  } else { 
    $self->{AUTHETICATED}  = undef ;
    return 0 ; 
  }  
}
sub _login {
  my $self = shift ; 

  $self->{AUTHETICATED}  = 1 ;
    ## fetch their info from the DB...
  
  $self->{DB_VALUES} = OpenUMS::DbQuery::get_user_info($self->{DBH},$self->{EXTENSION}  ) ;
  $self->{DBNM_SPOOL} =undef;
    ## clear out their message spools too
  $self->{N_MSGS} = undef;
  $self->{S_MSGS} = undef;
  $self->{N_MSG_COUNT} = undef;
                                                                                                                                               
  $self->{S_MSG_COUNT} = undef;
  if ($self->{DB_VALUES}->{store_flag} eq 'E') {
    ## IMAP stub, here you could start the query
  }
  $log->debug("[User.pm] calling check_flags"); 
  $self->check_flags();  
  return 1; 
} 
sub check_flags {
  my $self = shift ;
  my $dbh = $self->{DBH}; 
  $log->debug("[User.pm] in check_flags, new_user_flag=" .  $self->get_value('new_user_flag') . " auto_new_messages_flag = " . $self->get_value('auto_new_messages_flag') ); 
  
  if ( $self->get_value('new_user_flag') ) {
     my $menu_id = OpenUMS::DbQuery::get_action_menu_id($dbh, 'user_tutorial')  ; 
     $log->debug("[User.pm] got menu = $menu_id "); 
     $self->set_jump_to_menu_id($menu_id ) ;  
     return ; 
  } 
  if ( $self->get_value('auto_new_messages_flag') ) {
     my $menu_id = OpenUMS::DbQuery::get_action_menu_id($dbh, 'N_messages')  ; 
     $log->debug("[User.pm] got menu = $menu_id "); 
     $self->set_jump_to_menu_id(OpenUMS::DbQuery::get_action_menu_id($dbh, 'N_messages') ) ;  
     return ; 
  } 

}

#######################################
##  sub get_value($db_field) 
##    Returns database value for the field given
##    valid field names can be found in the VM_Users table
##    
#######################################

sub get_value {
  my $self = shift; 
  my $field = shift ; 
  return $self->{DB_VALUES}->{$field}; 
}

#################################
## sub empty_spool
#################################
sub empty_spool {
   my $self = shift ;
  my $message_status_id = shift ;
  if (defined($self->{$message_status_id . "_MSGS"} ) )   { 
    return 0; 
  }  else {
    return 1; 
  } 

}

#######################################
##  sub get_message_spool($message_status_id) 
##    Returns a MessageSpool object for the given message_status_id 
##    valid message_status_ids : 'N' ->'New' or 'S' => 'Saved' 
##    if the message spool exists it returns it, otherwise it queries 
##      the db and gets via the MessageSpool interface.
#######################################

sub get_message_spool {
  my $self = shift ; 
  my $message_status_id = shift ;
  if (defined($self->{$message_status_id . "_MSGS"} ) )   { 
    return $self->{$message_status_id . "_MSGS"} ;      
  }  else { 
    my $ms_new = new OpenUMS::Object::MessageSpool($self->{DBH}, $self,$message_status_id) ;  
    $ms_new->query($message_status_id) ; 
    $log->debug("[User] gonna check the self's message_jump_flag " . $self->get_message_jump_flag()  );
    if ($self->get_message_jump_flag() ) {
       $ms_new->jump_to_message($self->last_message_file() );
       $self->unset_message_jump_flag();
       $self->clear_last_message_file();
    }

    $self->{$message_status_id . "_MSGS"} = $ms_new; 
    return $self->{$message_status_id . "_MSGS"}; 
  } 
} 

#######################################
##  sub get_dbnm_spool()
##    Returns a DbnmSpool object for the given input  (dbnm = Dial By Name Menu :)
##    call like this $dbnmSpool = $user->get_dbnm_spool('327', 'BOTH');       
##    valid Dbnm_types : 'FIRST' (First name), 'LAST' (Last Name), 'BOTH' (Guess!?)
#######################################

sub get_dbnm_spool {
  my $self = shift ;
  my $user_input = shift ;   
  my $dbnm_type = shift ;   
  if (defined($self->{DBNM_SPOOL}) && ($self->{DBNM_SPOOL}->{USER_INPUT} eq $user_input))   {
    return $self->{DBNM_SPOOL} ;
  }  else {
    my $dbnm = new OpenUMS::Object::DbnmSpool($self->{DBH}, $user_input, $dbnm_type) ;
    $dbnm->query() ;
    $self->{DBNM_SPOOL} = $dbnm ;
    return $self->{DBNM_SPOOL};
  }
}

#######################################
##  sub delete_message_spool($message_status_id)
##    Removes the reference to the MessageSpool  for the given message_status_id
##    You would call this if u want to force a requery of the messages 
#######################################

sub delete_message_spool {
  my $self = shift ; 
  my $message_status_id  = shift ; 
  $self->{$message_status_id . "_MSGS"}  = undef ; 

  return ;
} 

#######################################
##  sub get_greeting() 
##    Returns the users current greeting.
#######################################

sub get_greeting {
  my $self = shift ;  
  my ($greeting_wav_file , $greeting_wav_path) = OpenUMS::DbQuery::get_current_greeting_file($self->{DBH}, $self->extension()); 
  return ($greeting_wav_file , $greeting_wav_path) ; 
}

#################################
## sub save_name
#################################
sub save_name {
  my $self = shift ;
  my ($temp_file, $temp_path) =  $self->get_temp_file('RECNAME');
  my ($new_file,$new_path) =  OpenUMS::DbQuery::get_new_name_file ($self->extension());
  my $target_file  = BASE_PATH . "$new_path$new_file" ; 
   
  if (!(-e "$temp_path$temp_file") )  {
     ## if the file don't exist, return ...
     return 0;
  }

  OpenUMS::Common::adjust_volume ("$temp_path$temp_file");

  use File::Copy ;
  $log->debug( "moving ... $temp_path$temp_file to $target_file " );
  move("$temp_path$temp_file", "$target_file");

  $log->debug("Updating the name");
  OpenUMS::DbUtils::update_name($self->{DBH}, $self->extension(),$new_file,$new_path) ;
  return 1;

}

#################################
## sub save_greeting
#################################
sub save_greeting {
  my $self = shift ;  
  my ($greeting_wav_file , $greeting_wav_path) = OpenUMS::DbQuery::get_current_greeting_file($self->{DBH}, $self->extension()); 
  my ($temp_file, $temp_path) =  $self->get_temp_file('RECGREET');
  my ($new_file,$new_path) =  OpenUMS::DbQuery::get_new_greeting_file ($self->extension());
   
  my $target_file  = "$new_path$new_file" ; 
  $log->debug( "moving ... $temp_path$temp_file to $target_file" );

  if (!(-e "$temp_path$temp_file") )  {
     ## if the file don't exist, return ...
     return 0;
  }

  OpenUMS::Common::adjust_volume( "$temp_path$temp_file" ); 

  use File::Copy ; 
  move("$temp_path$temp_file", "$target_file");

  
  if ($greeting_wav_file) { 
    $log->debug("They have a greeting we need to update it");  
    OpenUMS::DbUtils::update_user_greeting($self->{DBH}, $self->extension(),$new_file,$new_path) ; 
  }  else {
    OpenUMS::DbUtils::create_user_greeting($self->{DBH}, $self->extension(),$new_file,$new_path) ; 
  } 
  
  return ($greeting_wav_file , $greeting_wav_path) ; 

}

#######################################
##  sub get_name() 
##    Returns the users current name.
#######################################

sub get_name {
  my $self = shift ;  
  my ($name_wav_file , $name_wav_path) = OpenUMS::DbQuery::get_name_file($self->{DBH}, $self->extension() ); 
  return ($name_wav_file , $name_wav_path) ; 

}

#######################################
##  sub new_message_count() 
##    Returns the number of new messages the user has
##    if the user is using Email Store, it calls the IMAP object
##    otherwise it queries the Database
#######################################

sub new_message_count {
  my $self = shift ;   
  if (!$self->{N_MSG_COUNT}  ) {
     if ($self->{DB_VALUES}->{store_flag} eq 'E' ) {
        ## they are using 'email store'... call the IMAP new_imap_count
        
       ## stub: here u see if the query came back...
        my $msgs_aref = OpenUMS::IMAP::new_imap_count($self->{DBH}, $self->extension() );
        return ($self->{N_MSG_COUNT} = 0) unless (defined($msgs_aref));
        $self->{N_MSG_COUNT} = scalar(@$msgs_aref);
     } else {
       $self->{N_MSG_COUNT} = OpenUMS::DbQuery::new_message_count($self->{DBH}, $self->extension()  ) ;
     }
  }
  return $self->{N_MSG_COUNT}; 
} 

#######################################
##  sub saved_message_count() 
##    Returns the number of saved messages the user has
##    if the user is using Email Store, it calls the IMAP object
##    otherwise it queries the Database
#######################################

sub saved_message_count {
  my $self = shift ;   
  if (!$self->{S_MSG_COUNT} ) {
     if ($self->{DB_VALUES}->{store_flag} eq 'E' ) {
        ## they are using 'email store'... call the IMAP saved_imap_count
       my $msgs_aref = OpenUMS::IMAP::saved_imap_count($self->{DBH}, $self->extension()  );
       return ($self->{S_MSG_COUNT} = 0) unless (defined($msgs_aref));
       $self->{S_MSG_COUNT} = scalar(@$msgs_aref);
     } else { 
       $self->{S_MSG_COUNT} = OpenUMS::DbQuery::saved_message_count($self->{DBH}, $self->extension() ) ; 
     }
  }
  return $self->{S_MSG_COUNT}; 
} 

#######################################
##  sub new_password() 
##    sets the user's new  password pending they verify the change...
##    Returns the new password 
##    NOTE: This does not save the password
#######################################

sub new_password {
  my $self = shift; 
  if (!$self->authenticated() ) {
    return undef; 
  } 
  if (@_ ) {
     $self->{NEW_PASSWD}  = shift; 
  } 
  return $self->{NEW_PASSWD} ; 
}

#######################################
##  sub clear_extension_to_admin()
##    sets the an extension to add they verify the change...
##    NOTE: This does not save the new extension 
#######################################
                                                                                                                             
sub clear_extension_to_admin {
  my $self = shift;
  $self->{NEW_EXT}  = undef;
} 

#######################################
##  sub extension_to_admin()
##    sets the an extension to add they verify the change...
##    NOTE: This does not save the new extension 
#######################################

sub extension_to_admin {
  my $self = shift;
  if (!$self->authenticated() ) {
    return undef;
  }
  if (@_ ) {
     $self->{NEW_EXT}  = shift;
  }
  $log->debug("set new extension " . $self->{NEW_EXT} ); 
  return $self->{NEW_EXT} ;
}

#######################################
##  sub clear_box_to_admin()
##    sets the an box_to_admin variable to null 
##    NOTE: This does not save the box 
#######################################
                                                                                                                             
sub clear_box_to_admin {
  my $self = shift;
  $self->{BOX_TO_ADMIN}  = undef;
} 

#######################################
##  sub extension_to_admin()
##    sets the box to administer for the sesssion, 
##    clear by calling clear_box_to_admin
##    NOTE: This does not save the new extension 
#######################################

sub box_to_admin {
  my $self = shift;
  if (!$self->authenticated() ) {
    return undef;
  }
  if (@_ ) {
     $self->{BOX_TO_ADMIN}  = shift;
  }
  $log->debug("set new box_to_admin " . $self->{BOX_TO_ADMIN} );
  return $self->{BOX_TO_ADMIN} ;
}

#######################################
##  sub create_temp_file()
##    gets the name of temporary file for recording 
##    clear by calling clear_box_to_admin
##    NOTE: This does not save the new extension
#######################################

sub create_temp_file { 
  my $self = shift;  
  my $prefix = shift;  
  my $val = int (rand 998877 ) + 1 ;
  $self->{TEMP_FILE} = "$prefix$val.wav"; 

  return ($self->{TEMP_FILE} , BASE_PATH .  TEMP_PATH ); 
} 

#######################################
##  sub get_temp_file()
##    gets the name of temporary file for recording 
##    clear by calling clear_box_to_admin
##    NOTE: This does not save the new extension
#######################################

sub get_temp_file {
  my $self = shift;  
  my $prefix = shift;  
 # if (!$self->{TEMP_FILE} ) {
 #    my $val = int (rand 998877 ) + 1 ; 
 #    $self->{TEMP_FILE} = "$val.wav"   
 # }     
  if (defined($self->{TEMP_FILE} ) && ($self->{TEMP_FILE} =~/^$prefix/ || (!$prefix))  ) { 
    return ($self->{TEMP_FILE} ,  BASE_PATH .  TEMP_PATH ); 
  } else {
     return (undef,undef); 
  } 
}

#######################################
##  sub clear_temp_file()
##    clears the tempory file name so it can be reset..
#######################################
sub clear_temp_file { 
  my $self = shift; 
  unlink ( TEMP_PATH . $self->{TEMP_FILE} ); 
  $self->{TEMP_FILE}  = undef; 
}


#######################################
##  sub set_password() 
##    sets the user's new  password pending they verify the change...
##    NOTE: This DOES save the password and writes it to the database
##    new_password($someval) must be called before this
#######################################

sub save_new_password {
  ## saves the user's new  password 
  my $self = shift; 

  $log->debug("called save_new_password, new password = " . $self->new_password() ); 

  if (defined($self->new_password() )  && (length($self->new_password() ) > 2)  )  {
    $log->debug("Going to SAVE IT " ); 
    OpenUMS::DbUtils::change_password($self->{DBH}, $self->extension(), $self->new_password() )  ; 
    return 1; 
  }  else { 
    return  0; 
  } 
} 

#######################################
##  sub permission_id() 
##    Returns the users permission_id
##    If the user is not logged in (ie, it's an anoymous caller) 
##    we return 'ANON' 
#######################################

sub permission_id {
  my $self = shift; 
  my $dbvalues =  $self->{DB_VALUES}; 
  if (defined($dbvalues->{permission_id}) ) {
     return $dbvalues->{permission_id} ;   
  } else {
     return 'ANON';  ## default is Anonymous outside caller
  } 
}


#################################
## sub get_sound_queue
#################################
sub get_sound_queue {
  my $self = shift ;      
  my $NAME = shift;  


  if (!$NAME ) {
     return undef; 
  } 
  my $user_key = $NAME . " _SOUND_QUEUE" ;  ## this is the name of the queue

  my $message_status_id = shift ;
  ## is the queue defined
  if (defined($self->{$user_key}) ) {
    my $sq = $self->{$user_key};
    ## has it been marked expired, if  
    if ($sq->expired() ) {
       $sq->query() ;
       return $sq ; 
    } else {
       return  $sq; 
    } 
  }  else {
    my $sq; 
    if ($NAME =~ /^GREET/ ) {
       ## create a new queue
#       use OpenUMS::GreetingsQueue; 
#       $sq = new OpenUMS::GreetingsQueue($self->{DBH}, $self); 
    } 
    ## run the query
    $sq->query(); 
    ## set it to the user's session 
    $self->{$user_key} = $sq; 
    ## return the queue
    return $sq ; 
  }
}

#################################
## sub save_mobile_email_flag ()
##    updates the user's mobile_email_flag in the database
#################################

sub save_mobile_email_flag { 
  my $self = shift ;  
  my $new_flag = shift ; 
  my $dbh = $self->{DBH}; 
  my $upd = "UPDATE VM_Users " ; 
  if ($new_flag) {
    $upd .= "  SET mobile_email_flag = 1 "; 
  } else { 
    $upd .= "  SET mobile_email_flag = 0 "; 
  } 
  $upd .= " WHERE extension = " . $self->extension() ; 
  $log->debug("UPDATING mobile_email_flag : $upd"); 
  $self->{DB_VALUES}->{mobile_email_flag} = $new_flag ; 
  $dbh->do($upd);
  return 1; 
}

#################################
## sub update_last_vist ()
#################################

sub update_last_visit () {
  my $self = shift ; 
  my $dbh = $self->{DBH};
  my $ext = $self->{EXTENSION} ; 
  if (!$ext){ 
     $ext = $self->{EXTENSION_TO}; 
  } 
  if (!$ext) { 
     return 0; 
  } 
  my $last_visit = $self->{LAST_VISIT}; 
  my $upd = qq{UPDATE VM_Users set last_visit = '$last_visit' WHERE extension = $ext}; 
  $dbh->do($upd); 

} 
#################################
## sub append_file ()
#################################
sub append_file {
  my $self = shift ;
  my $file2  = shift ;
  my ($file1,$gibber) =  $self->get_message_file(); 
  
  $file1   =  BASE_PATH . TEMP_PATH . $file1; 
  $file2   =  BASE_PATH . TEMP_PATH . $file2; 
  
  my @array = ($file1, $file2);
  $log->debug("calling append : $file1  $file2 "); 
  ## call dean's brilliant discovery
  OpenUMS::Common::cat_wav($file1, \@array); 

}


#################################
## sub set_message_file
#################################
sub set_message_file {
  my $self = shift ;
  my $message_file =  shift ; 
  my $message_path =  shift ; 
  $self->{MESSAGE_FILE} = $message_file; 
  $self->{MESSAGE_PATH} = $message_path; 
}


#################################
## sub get_message_file
#################################
sub get_message_file {
  my $self = shift ;
  return ($self->{MESSAGE_FILE},$self->{MESSAGE_PATH} ) ; 
}

#################################
## sub clear_message_file ()
#################################
sub clear_message_file () {
  my $self = shift ;
  $self->{MESSAGE_FILE} = undef; 
  $self->{MESSAGE_PATH} = undef; 
}


#################################
## sub save_message
#################################
sub save_message {
  my $self = shift;
  my $dbh = $self->{DBH};

  ## all the checks for saving a message...
  my ($message_file, $message_path) = $self->get_message_file() ;
  my ($extension_to,$blah) = split (/_/, $message_file,2 ) ;
  my $return_flag =0 ;
  if ( $message_path && $message_file ) {
    my ($valid, $msg) = OpenUMS::Common::validate_message($message_file);  
    if ($valid) { 
       $log->debug("[User.pm] Message created for " . $extension_to . ", file = " . $message_file . ", FROM " . $self->{EXTENSION_FROM});
       my $msg_id = OpenUMS::DbUtils::create_message( $dbh, $extension_to, $message_file, $message_path,
               $self->{EXTENSION_FROM} );
       $log->debug("Message ID = $msg_id ");
       $return_flag= 1; 
     }  else {
       $return_flag= 0; 
       $log->debug("Message not created. msg = $msg");
       # unlink($livefile);
     }
  } else {
     $return_flag= 0; 
     $log->debug("No Message on User's session "); 
  }
  ## clear it off his session...
  $self->clear_message_file(); 
  return $return_flag; 
}
#######################################
## sub last_message_file
#######################################

sub last_message_file {
  my $self = shift ; 
  if (scalar(@_) ) { 
    $self->{LAST_MESSAGE_FILE} = shift; 
  }  
  return $self->{LAST_MESSAGE_FILE} ;

}
#######################################
## sub clear_last_message_file
#######################################

sub clear_last_message_file {
  my $self = shift ; 
  $self->{LAST_MESSAGE_FILE} = undef;
}

#################################
## sub end_session
#################################

sub end_session {
  my $self = shift ; 
  $self->update_last_visit(); 
  $self->save_message(); 

  ### If the user is email-store, then move their deleted messages
  if ($self->get_value('store_flag') eq 'E') {
    my $ext = $self->get_value('extension');
    my $dbh = OpenUMS::Common::get_dbh();
    my $sql = qq(SELECT message_wav_file
                   FROM VM_Messages m INNER JOIN VM_Users u on
                       (m.extension_to = u.extension)
                   WHERE m.message_status_id = 'D'
                     AND m.message_status_changed > u.last_visit);
    my $files_aref = $dbh->selectcol_arrayref($sql);

    OpenUMS::IMAP::delete_imap_message($dbh, $ext, $files_aref);
  }
}
sub get_forward_object {
  my $self = shift ;

  if (!defined($self->{FORWARD_OBJECT} ) )  { 
    my $forwardObject =  new OpenUMS::Object::ForwardMessageObj($self);   
    $self->{FORWARD_OBJECT}  = $forwardObject  ; 
  } 
  return $self->{FORWARD_OBJECT} ;

}


#######################################
## sub last_message_status_id
#######################################
sub last_message_status_id {
  my $self = shift ;
  if (scalar(@_) ) {
    $self->{LAST_MESSAGE_STATUS_ID} = shift;
  }
  return $self->{LAST_MESSAGE_STATUS_ID} ;
}
                                                                                                                                               
#######################################
## sub clear_last_message_status_id
#######################################
                                                                                                                                               
sub clear_last_message_status_id {
  my $self = shift ;
  $self->{LAST_MESSAGE_STATUS_ID} = undef;
}
sub set_message_jump_flag {
  my $self = shift; 
  $self->{MESSAGE_JUMP_FLAG} = 1; 
}
sub get_message_jump_flag {
  my $self = shift; 
  return $self->{MESSAGE_JUMP_FLAG}; 
}
sub unset_message_jump_flag {
  my $self = shift; 
  $self->{MESSAGE_JUMP_FLAG} = undef; 
}
sub get_ip_object {
  my $self = shift ;
  if (!defined($self->{IP_OBJECT} ) )  { 
    $self->{IP_OBJECT} = new OpenUMS::Object::IpAddress; 
  } 
  return $self->{IP_OBJECT} ; 
}
sub jump_to_menu_id {
  my $self = shift ;
  return $self->{JUMP_TO_MENU_ID}; 
}

sub set_jump_to_menu_id {
  my $self = shift ;
  if (@_ ) { 
     $self->{JUMP_TO_MENU_ID} = shift ;
  } 
}

sub clear_jump_to_menu_id {
  my $self = shift ; 
  $self->{JUMP_TO_MENU_ID} = undef; 

}
1; 
