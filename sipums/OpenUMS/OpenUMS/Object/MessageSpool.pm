package OpenUMS::Object::MessageSpool; 
### $Id: MessageSpool.pm,v 1.2 2004/07/30 20:22:13 kenglish Exp $
#
# MessageSpool.pm
#
# Modify/update/add/delete from list of new or saved messages.
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

use OpenUMS::Config;
use OpenUMS::Log;
use OpenUMS::Common;
use OpenUMS::DbQuery ;
use OpenUMS::Object::MessageObj ;


use strict ; 

#################################
## sub new
#################################
sub new {
  ## this your standard 'new', it intializes the hash and blesses it
  my $proto = shift;

  my $dbh = shift;
  my $user = shift ; 
  my $msg_spool_status_id = shift ; 

  my $class = ref($proto) || $proto;
  my $self = {}; ## self is a hash ref
  ## we'll add the parameters to the hash ref..
  $self->{DBH} = $dbh;
  if (!$user->{AUTHETICATED}) { 
    $self->{USER} =  undef ; 
  } else { 
    $self->{USER} = $user;
  }
  $self->{MSG_SPOOL_STATUS_ID} = $msg_spool_status_id ;

  $self->{MSG_LIST} = undef;
  $self->{IS_LIST} = undef; ## this tells us if we need to query or not, if it's not definied, we do!

  bless($self, $class);
#  $log->debug("[MessageSpool] gonna check the user's message_jump_flag " . $user->get_message_jump_flag()  );  
##  if ($user->get_message_jump_flag() ) {
#     $self->jump_to_message($user->last_message_file() ); 
#     $user->unset_message_jump_flag(); 
#     $user->clear_last_message_file(); 
#  } 
  
  return $self;
}

#################################
## sub is_queried
#################################
sub is_queried {
  my $self = shift ;
  return $self->{IS_LIST}; 
}


#################################
## sub query
#################################
sub query {
  ## this the most basic of basic plays....
  my $self = shift ; 
  my $msg_type = $self->{MSG_SPOOL_STATUS_ID} ;  
  if (($msg_type ne 'N') && ($msg_type ne 'S') ) { 
     $log->warning("query called with invalid message type\n"); 
     return ; 
  }  
  if (!defined($self->{USER}) ) { 
     $log->warning("CALLED QUERY with undef user\n"); 
     return ; 
  } 
  my $user = $self->{USER}; 
  my $dbh = $self->{DBH} ; 
  my $msglistref ; 
  if ($user->get_value('store_flag') eq 'E' ) { 
      $msglistref = OpenUMS::DbQuery::get_new_or_saved($self->{DBH}, $user->extension,$msg_type) ;
#    if ($msg_type eq 'N') {
#      $msglistref = OpenUMS::IMAP::new_imap_messages($self->{DBH}, $user->extension) ;
#    } else {
#      $msglistref = OpenUMS::IMAP::saved_imap_messages($self->{DBH}, $user->extension) ;
#    }
  }  else { 
    ## this means they are doing voicemail store, this is 'kevin part...
    $msglistref = OpenUMS::DbQuery::get_messages($self->{DBH}, $user->extension(),  $msg_type );
#    $self->{MSG_LIST} = OpenUMS::DbQuery::get_messages($self->{DBH}, $user->extension(),  $msg_type );  
  }
  ## create the message objects
  my @msglistref2;
  foreach my $msg_hr (@{$msglistref} ) {
    my $msgObj = new OpenUMS::Object::MessageObj($msg_hr); 
    push @msglistref2, $msgObj ; 
  } 
  $self->{MSG_LIST} = \@msglistref2; 
  $self->{MSG_NUM} = 0; 
  $self->{IS_LIST} = 1; 
  return ;
} 


#################################
## sub size ()
#################################
sub size () {
  my $self = shift ; 
  if (defined($self->{MSG_LIST})) { 
    my $size =   scalar(@{$self->{MSG_LIST} } ); 
#    if (!$size && $self->{MSG_SPOOL_STATUS_ID} eq 'N') { 
#       OpenUMS::Mwi::mwi_extension_off($self->{DBH},$self->{USER}->extension() ); 
#    } 
    return scalar(@{$self->{MSG_LIST} } ); 
  } else {
    return 0 ; 
  }
} 

#################################
## sub is_last_message
#################################
sub is_last_message {
  my $self = shift ;
  if ($self->{MSG_NUM} == ($self->size() ) ) {
    return 1; 
  } else {
    return 0 ; 
  }    

}

#################################
## sub next_message
#################################
sub next_message {
  my $self = shift ; 
  $self->{MSG_NUM} = $self->{MSG_NUM} + 1;  ## increment....
} 

#################################
## sub get_current_message
#################################
sub get_current_message  {
  my $self = shift ; 

  if ($self->{MSG_NUM} >= $self->size())  {
    ## reset it, they are looping around again... 
    $self->{MSG_NUM} = 0; 
  } 

  my $msgObj = $self->{MSG_LIST}->[$self->{MSG_NUM}]; 

  return $msgObj ; 
} 

#################################
## sub delete_current_message
#################################
sub delete_current_message {
  my $self = shift ; 
  my $user = $self->{USER};
  my $dbh = $self->{DBH} ;

  my $msgObj =  $self->{MSG_LIST}->[$self->{MSG_NUM}];
  my $msg_hr = $msgObj->get_msg_hr(); 

  if ($user->get_value('store_flag') eq 'E' ) {
    OpenUMS::IMAP::update_entry($dbh, 'D', $msg_hr->{message_wav_file});
  }  else {
    my $msg_id = $msg_hr->{message_id} ; 
    OpenUMS::DbUtils::delete_message($dbh, $user->extension(), $msg_id);  
  } 
  $log->normal("[MessageSpool.pm] Deleting MSG_NUM=" . $self->{MSG_NUM} . "\n");
  splice @{$self->{MSG_LIST}},$self->{MSG_NUM},1;
  return ; 
}

#################################
## sub save_current_message
#################################
sub save_current_message {
  my $self = shift ; 
  my $user = $self->{USER};
  my $dbh = $self->{DBH} ;

  my $msgObj =  $self->{MSG_LIST}->[$self->{MSG_NUM}];
  my $msg_hr = $msgObj->get_msg_hr(); 
  my $box;
  my $status = $self->{MSG_SPOOL_STATUS_ID} ; 

  ## if it's a save message, we do nothing, 
  if ($status eq 'S') {   
    splice @{$self->{MSG_LIST}},$self->{MSG_NUM},1;
    # $self->next_message(); 
     return 1; 
  } else { 
    if ($user->get_value('store_flag') eq 'E' ) {
      OpenUMS::IMAP::save_imap_message($dbh, $user->extension(), $msg_hr->{message_wav_file});
    }  else {
      my $msg_id = $msg_hr->{message_id} ; 
      OpenUMS::DbUtils::save_message($dbh, $user->extension(), $msg_id);  
    } 
    splice @{$self->{MSG_LIST}},$self->{MSG_NUM},1;
    return 1; 
  }
}

#################################
## sub mark_new_current_message
#################################
sub mark_new_current_message {
  my $self = shift ; 
  my $user = $self->{USER};
  my $dbh = $self->{DBH} ;

  my $msgObj =  $self->{MSG_LIST}->[$self->{MSG_NUM}];
  my $msg_hr = $msgObj->get_msg_hr(); 
  my $status = $self->{MSG_SPOOL_STATUS_ID} ; 
  ## if it's a new message, we do nothing, if it's saved we move it from Saved to New
  if ($status eq 'N' ) { 
    # $self->next_message();  
    splice @{$self->{MSG_LIST}},$self->{MSG_NUM},1;
    return 1; 
  }  else {
    if ($user->get_value('store_flag') eq 'E' ) {
      ## dean, i need u to implement this...
      OpenUMS::IMAP::mark_new_imap_message($dbh, $user->extension(), $msg_hr->{message_wav_file});
    }  else {
      my $msg_id = $msg_hr->{message_id} ; 
      OpenUMS::DbUtils::mark_new_message($dbh, $user->extension(), $msg_id);  
    } 
    splice @{$self->{MSG_LIST}},$self->{MSG_NUM},1;
    return 1; 
  }

}

#################################
## sub get_last_action
#################################
sub get_last_action {
  my $self = shift; 
  return $self->{LAST_ACTION}; 
}

#################################
## sub set_last_action
#################################
sub set_last_action {
  my $self = shift; 
  $self->{LAST_ACTION} = shift ; 
}

#################################
## sub get_current_tds_sound
#################################
sub get_current_tds_sound {
  my $self = shift ; 
  my $msgObj =  $self->{MSG_LIST}->[$self->{MSG_NUM}];
  my $msg_hr = $msgObj->get_msg_hr(); 

  use Date::Calc;
                                                                                                                             
  my ($now_year, $now_month, $now_day) = Date::Calc::Today();
  my $dd = Date::Calc::Delta_Days($msg_hr->{m_year}, $msg_hr->{m_month}, $msg_hr->{m_day} ,
              $now_year, $now_month, $now_day);

  my $sound;
                                                                                                                             
  if ($dd == 0 ) {
     $sound = PROMPT_PATH . "today.wav";
  } elsif ($dd == 1 ) {
     $sound = PROMPT_PATH . "yesterday.wav";
  } else {
    my $dow_name = Date::Calc::Day_of_Week_to_Text(
                Date::Calc::Day_of_Week($msg_hr->{m_year}, $msg_hr->{m_month}, $msg_hr->{m_day})) ;
    my $month_name = Date::Calc::Month_to_Text( $msg_hr->{m_month} ) ;
#   my $dow = Date::Calc::Day_of_Week($msg_hr->{m_year}, $msg_hr->{m_month}, $msg_hr->{m_day}) ;
                                                                                                                             
    $month_name = lcfirst($month_name);
    $sound = PROMPT_PATH . $dow_name . ".wav " . PROMPT_PATH . $month_name . ".wav " ; 

    $sound .=  OpenUMS::Common::count_sound_gen($msg_hr->{m_day},1) ;
  }
  if ($msg_hr->{m_hour} > 12) {
    $msg_hr->{m_hour} -= 12;
  }
  $sound .= " " .  PROMPT_PATH . "at.wav " . PROMPT_PATH .  $msg_hr->{m_hour} . ".wav"  ;
  if ($msg_hr->{m_minute} ) {
     if ( $msg_hr->{m_minute} ) {   
       $sound .=  " " . OpenUMS::Common::count_sound_gen ($msg_hr->{m_minute});
     }
  }
  $sound .= " " . PROMPT_PATH . $msg_hr->{m_am_pm} .".wav" ;
  return $sound ;
                                                                                                                             
}
sub jump_to_message {
  my $self = shift ; 
  my $message_to_jump = shift ; 
  $log->debug("the size is "); 

  for (my $I =0; $I < $self->size() ; $I++ ) { 
    my $msgObj = $self->get_current_message();     
    my $msg_hr = $msgObj->get_msg_hr();
    if ($msg_hr->{message_wav_file} eq $message_to_jump) {
       $log->debug("found message_to_jump $message_to_jump"); 
       return ; 
    } 
    $log->debug("message_to_jump not found ... $I " . $msg_hr->{message_wav_file} . " ne $message_to_jump"); 
    $self->next_message(); ## keep going thru the que
  } 
  $log->debug("could not find message_to_jump $message_to_jump"); 

}

1;
