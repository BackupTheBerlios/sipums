package OpenUMS::DbQuery;
### $Id: DbQuery.pm,v 1.5 2004/09/10 01:36:32 kenglish Exp $
#
# DbQuery.pm
#
# This should only have select statements, 
#  all other stuff should go in DbUtils
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
=pod
=head1 NAME

Telephony::CTPort - Computer Telephony programming in Perl

=head1 SYNOPSIS

use OpenUMS::DbUtils;

=head1 DESCRIPTION

This module implements an Object-Oriented interface to control Computer
Telephony (CT) card ports using Perl.  It is part of a client/server
library for rapid CT application development using Perl.

=head1 AUTHOR

Dean Takemori, support@linuxvoicemail.com

Matt Darnell, support@linuxvoicemail.org

=cut
use strict;
use DBI;
use OpenUMS::Config;
use OpenUMS::Log;
use OpenUMS::Common;

#####################################
## sub validate_mailbox
##  Accepts : dbh, extension
## this returns 1 if a mailbox is valid and zero if it is not
## eg: 
## $isvalid =  OpenUMS::DbQuery::validate_mailbox($dbh, $mailbox) ; 
######################################

sub validate_mailbox {
  
  my ($dbh, $param,$include_invalid) = @_;
  if (!$param ){
     ## why did they call with no param?
     return 0;
  }
  ## this query just selects their extension,
  ## we need to ignore the '0', that's the outside caller guy

  my $sql = qq{SELECT extension
               FROM VM_Users
               WHERE extension = ?
                 AND extension <> 0}; 
  if (!$include_invalid ) { 
     $sql .= "  AND active = 1" ;
  } 
  my $sth = $dbh->prepare($sql);
  $sth->execute($param);
  my $ext = $sth->fetchrow();
  return $ext;
}
######################################
## sub  validate_password
##  Accepts : dbh, ext_encension, password
##   this returns 1 if a password for a given extension is valid 
######################################
sub web_password_validate {
  my ($dbh, $ext_enc, $pw_enc) = @_;
  my $sql = qq{SELECT extension 
               FROM VM_Users
               WHERE PASSWORD(extension) = ?
                 AND password = ? };
  my $sth = $dbh->prepare($sql);

  $sth->execute($ext_enc, $pw_enc);
  my $extension=0;
  $extension = $sth->fetchrow();
  $sth->finish();
  return $extension;

}

######################################
## sub  validate_password
##  Accepts : dbh, extension, password
##   this returns 1 if a password for a given extension is valid 
##    and zero if it is not
##   eg: 
##   $isvalid =  OpenUMS::DbQuery::validate_password($dbh, $mailbox,$password) ; 
######################################
sub validate_password {


  my ($dbh, $ext, $password) = @_;
  my $sql = qq{SELECT COUNT(*)
               FROM VM_Users
               WHERE extension = ?
                 AND password = PASSWORD(?) };
  my $sth = $dbh->prepare($sql);
  $sth->execute($ext, $password);
  my $count=0;
  $count = $sth->fetchrow();
  $sth->finish();
  return $count;
}

############################################################
##   sub get_user_info {
##      this gets all of the data from the User table for a given extension
##      the data is returned in the form of a hash ref
##      eg: 
##      $user = OpenUMS::DbQuery::get_user_info($dbh,$extension);
##      to get at the data, it'd be like this:
##        print $user->{last_name};   
##        print $user->{first_name};   
##       see database for a list of valid fields
###############3###############3###############3###############

sub get_user_info {
  my ($dbh, $ext) = @_;
  my $sql = qq{SELECT * FROM VM_Users WHERE extension = $ext }; 
  my $hr = $dbh->selectrow_hashref($sql) ;  
} 

############################################################
## sub get_name_file
##    returns the path and file name for a user's name:
##    eg: 
##      ($name_file, $name_path) = OpenUMS::DbQuery::get_name_file($dbh, $extension); 
###################

sub get_name_file {
  my ($dbh, $ext) =  @_;
  my $sql = qq{SELECT name_wav_file, name_wav_path
               FROM VM_Users
               WHERE extension = $ext};
  my $sth = $dbh->prepare($sql);
  $sth->execute();

  my ($name_wav_file, $name_wav_path ) = ("","");
  ($name_wav_file, $name_wav_path) = $sth->fetchrow_array();
  $sth->finish();
  return ($name_wav_file, $name_wav_path);
}

############################################################
## sub get_new_name_file
##    returns the a new file name and path for a user's name:
##    eg:
##      ($name_file, $name_path) = OpenUMS::DbQuery::get_name_file($dbh, $extension);
###################

sub get_new_name_file {
  my $ext = shift;
  my $now = OpenUMS::Common::get_timestamp();
  ## for now we'll just put them in the greeeting dir..
  my $name_wav_path = USER_REL_PATH . "$ext/greetings/";
  my $name_wav_file = $ext . "_name_" . $now . ".wav";
                                                                                                                             
  return ($name_wav_file, $name_wav_path );
}


############################################################
## sub get_current_greeting_file
##   returns the path and file name for a user's greeting:
##   eg: 
##   ($greet_file, $greet_path) = OpenUMS::DbQuery::get_greeting_file($dbh, $extension); 
############################################################

sub get_current_greeting_file {
  my ($dbh, $ext) =  @_;
  my $sql = qq{SELECT greeting_wav_file, greeting_wav_path
               FROM VM_Greetings
               WHERE extension = $ext and current_greeting = 1 };
  my $sth = $dbh->prepare($sql);
  $sth->execute();

  my ($greeting_wav_file, $greeting_wav_path) = ("","");
  ($greeting_wav_file, $greeting_wav_path) = $sth->fetchrow_array();
  $sth->finish();
  return  ($greeting_wav_file, $greeting_wav_path);
}

############################################################
## sub get_current_greeting_file
##   Accepts : extension
##   Returns a file_name and path for a users greeting
##   my ($greet_file, $greet_path) = OpenUMS::DbQuery::get_new_greeting_file($extension); 
##    the file name will contain a timestamp
############################################################

sub get_new_greeting_file {
  my $ext = shift;
  my $now = OpenUMS::Common::get_timestamp();
  my $greeting_wav_path = "users/$ext/greetings/";
  my $greeting_wav_file =  $ext . "_greeting_" . $now . ".wav";
                                                                                                                             
  return ($greeting_wav_file , $greeting_wav_path);
}


############################################################
## saved_message_count
##     returns the number of saved messages for a give extension
##     should only be called if the user is using 'voicemail' store
##   example:
##     $saved_count = OpenUMS::DbQuery::saved_message_count($dbh, $extension); 
############################################################

sub saved_message_count {
  my $dbh = shift;
  my $ext= shift || return;
  my $sql = qq{SELECT COUNT(*)
               FROM VM_Messages
               WHERE message_status_id = 'S' AND extension_to = $ext};
  my $sth = $dbh->prepare($sql);
  $sth->execute();

  my $count = $sth->fetchrow();
  $sth->finish();
  return $count;
}

############################################################
## sub new_message_count
##   returns the number of saved messages for a give extension
##   should only be called if the user is using 'voicemail' store
## example:
##   $new_count = OpenUMS::DbQuery::get_new_message_count($dbh, $extension);
############################################################

sub new_message_count {

  my $dbh = shift;
  my $ext= shift || return;
  my $sql = qq{SELECT COUNT(*)
               FROM VM_Messages
               WHERE message_status_id = 'N' AND extension_to = $ext};
  my $sth = $dbh->prepare($sql);
  $sth->execute();

  my $count = $sth->fetchrow();
  $sth->finish();
  return $count;
}

############################################################
## sub get_new_messages 
##    returns a hashref with new messages for a give extension
##    should only be called if the user is using 'voicemail' store
##   example:
##     $hash = OpenUMS::DbQuery::get_new_messages($dbh, $extension);
############################################################

sub get_new_messages {
  my $dbh = shift;
  my $ext= shift || return;
  return get_messages($dbh, $ext,'N');
}

############################################################
## sub get_saved_messages
##    returns a hash ref with saved messages for a give extension
##    should only be called if the user is using 'voicemail' store
##   example:
##     $hash = OpenUMS::DbQuery::get_saved_messages($dbh, $extension);
############################################################

sub get_saved_messages {
  my $dbh = shift;
  my $ext= shift || return;
  return get_messages($dbh, $ext,'S');
}
############################################################
## sub get_deleted_messages
##    returns a hash ref with deleted messages for a give extension
##    should only be called if the user is using 'voicemail' store
##   example:
##     $hash = OpenUMS::DbQuery::get_deleted_messages($dbh, $extension);
############################################################

sub get_deleted_messages {
  my $dbh = shift;
  my $ext= shift || return;
  return get_messages($dbh, $ext,'D');
}
sub get_message {
  my $dbh = shift;
  my $message_wav_file = shift || return;
  
  my $sql = qq{SELECT message_id, message_created,message_status_changed, message_last_played ,message_status_id,
                 extension_to, extension_from, message_wav_path,
                 message_wav_file, YEAR(message_created) m_year ,
                 MONTH(message_created) m_month,
                 DAYOFMONTH(message_created) m_day,
                 HOUR(message_created) m_hour,
                 MINUTE(message_created) m_minute,
                 lower(DATE_FORMAT(message_created,'%p')) m_am_pm
               FROM VM_Messages
               WHERE message_wav_file = ?
               ORDER BY message_created };

  my $sth = $dbh->prepare($sql);
  $sth->execute($message_wav_file);
  my @msg_arr ;  ## this is a hash ref

  my $rs_hr = $sth->fetchrow_hashref() ; 
  $sth->finish();
  return $rs_hr;

}

############################################################
## sub get_messsages
##    Accepts : dbh, extension, message_status
##    This is the catch all for all get_****_messages routines. 
##    It returns a hash ref with messages for a give extension
##    that have the status 'message_status.' Valid status flags are
##    'N' (new), 'S' (Saved) and 'D' (Deleted)
##   example:
##     $hash = OpenUMS::DbQuery::get_messages($dbh, $extension,'N'); ## gets new messages
############################################################

sub get_messages {
  my $dbh = shift;
  my $ext= shift || return;
  my $status = shift || return;

  my $sql = qq{SELECT message_id, message_created,message_status_changed, message_last_played ,message_status_id,
                 extension_to, extension_from, message_wav_path,
                 message_wav_file, YEAR(message_created) m_year ,
                 MONTH(message_created) m_month,
                 DAYOFMONTH(message_created) m_day,
                 HOUR(message_created) m_hour,
                 MINUTE(message_created) m_minute,
                 lower(DATE_FORMAT(message_created,'%p')) m_am_pm
               FROM VM_Messages
               WHERE extension_to = ? AND message_status_id = ?
               ORDER BY message_created DESC};

  my $sth = $dbh->prepare($sql);
  $sth->execute($ext, $status);
  my @msg_arr ;  ## this is a hash ref

  while (my $rs_hr = $sth->fetchrow_hashref() ){
    my $msg_hr ; 
#    my $message_id = $rs_hr->{message_id};
    foreach my $key (keys %{$rs_hr}) {
      $msg_hr->{$key} = $rs_hr->{$key};
    }
    push @msg_arr, $msg_hr; 
  }
  $sth->finish();
  return \@msg_arr;
}


#################################
## sub get_new_message_file_name
#################################
sub get_new_message_file_name {
  ## gets a valid filename for a new message recorded and the path where it will be saved for voicemail

  my $ext = shift;
  my $ctport_handle = shift;


  $ctport_handle = sprintf("%02d", $ctport_handle);

  my $filename = "$ext" . "_" . OpenUMS::Common::get_timestamp();
  $filename .= "_" . $ctport_handle;
  $filename .= ".wav";

  return ($filename,"users/$ext/messages/");
}


#################################
## sub get_message_id_status
#################################
sub get_message_id_status {
  my $dbh = shift;
  my $ext = shift;
  my $wav_file_name = shift;
  my $sql = qq{SELECT message_id, message_status_id, message_mail_sync_status
               FROM VM_Messages
               WHERE extension_to = ?
                  AND message_wav_file = ?  };
  my $sth = $dbh->prepare($sql);
  $sth->execute($ext, $wav_file_name);
  my ($msg_id, $msg_status_id, $sync_status) = $sth->fetchrow_array();
  $sth->finish();
  return ($msg_id, $msg_status_id, $sync_status);
}


#############################################
## sub get_active_extensions
##   Accepts : dbh
##   Returns an array ref with all active extensions
##   eg:
##    my ($first,$last) = OpenUMS::DbQuery::get_first_last_names($dbh, 122)
#############################################

sub get_active_extensions {
  my $dbh = shift;
  my $sql = qq{SELECT extension FROM VM_Users where active = 1 and extension <> 0 };
  my $exts = $dbh->selectcol_arrayref($sql) ;
  return ($exts );
}

#############################################
## sub get_max_extension_length
##   Accepts : dbh
##   This queries the database and returns  the maximum extension length,
##    NOTE: this is  different than the global var MAX_EXTENSION_LENGTH
##   eg:
##    my ($max_len) = OpenUMS::DbQuery::get_max_ext_length($dbh)
#############################################

sub get_max_ext_length {
  my $dbh = shift;
  my $sql = qq{SELECT max(length(extension))  FROM VM_Users
   WHERE active = 1
  AND extension <> 0 } ; 
  my $sth = $dbh->prepare($sql) ; 
  $sth->execute(); 
  my $len = $sth->fetchrow(); 
  $sth->finish(); 
  return $len;
} 

#############################################
## sub get_first_last_names
##   Accepts : dbh, extension
##   Returns first_name and last_name
##   eg:
##    my ($first,$last) = OpenUMS::DbQuery::get_first_last_names($dbh, 122)
#############################################

sub get_first_last_names  {
  my ($dbh, $ext) = @_;
  my $sql = qq{SELECT first_name, last_name FROM VM_Users where extension = ?};
  my $sth = $dbh->prepare($sql);
  $sth->execute( $ext );
  my ($first_name, $last_name) = $sth->fetchrow_array();
  $sth->finish();
  return ($first_name,$last_name);
}

############################################# 
## sub get_by_name_phone_keys 
##   Accepts : dbh, keys
##   Given phone keys entered by a user in a dial by name menu, 
##    This will return an array ref of hash ref for each matching 
##    extension, the hash refs will contain 3 fields: 
##      extension, name_wav_file, name_wav_path
#############################################

sub get_by_name_phone_keys {
  my $dbh = shift;
  my $keys = shift;
  my $option = shift; ## can be FIRST, or LAST or nothing will do both

  if (!$keys) {
     return;
  }
  my $where ; 
  if ($option =~ /^FIRST/) {
    $where  = " phone_keys_first_name like '$keys%' ";  
  } elsif ($option =~ /^LAST/) {
    $where  = " phone_keys_last_name like '$keys%' ";  
  } else {
    $where  = " phone_keys_last_name like '$keys%' OR phone_keys_first_name like '$keys%' " ; 
  } 

  my $sql = qq{SELECT extension, name_wav_file, name_wav_path
       FROM VM_Users
       WHERE  $where 
       ORDER BY extension } ;

  my $sth = $dbh->prepare($sql); 
  $sth->execute(); 
  my @pkey_arr ; 
  while (my $rs_hr = $sth->fetchrow_hashref() ){
    ## if they have a recorded name only....
    if ($rs_hr->{name_wav_file} ) { 
      push @pkey_arr, $rs_hr;
    }
  }
  return \@pkey_arr ; 
## old way...
#  my $hr = $dbh->selectall_hashref($sql,"extension");
#  return $hr;

}

############################################# 
## sub get_user_xfer 
##   Accepts : dbh, extension
##   Returns 1 if the users transfer setting is on, 0 if it is off.
#############################################

sub get_user_xfer {
  my $dbh = shift ; 
  my $ext = shift ; 
  if (!$ext ) {
     return 0; 
  }
  my $sql  =  qq{SELECT transfer FROM VM_Users WHERE extension = $ext } ;  
#  print "$sql\n" ; 
  my $sth = $dbh->prepare($sql);
  $sth->execute();
#  print "$sql"; 
  my $xfer = $sth->fetchrow(); 
  $sth->finish();
  return $xfer ; 
}


#################################
## sub get_new_or_saved($$$)
#################################
sub get_new_or_saved($$$)
{
  my $dbh = shift;
  my $extension = shift;
  my $msg_status = shift;
                                                                                
  my $files;
  if ($msg_status eq 'S')
    { $files = OpenUMS::IMAP::saved_imap_messages($dbh, $extension); }
  else ### if ($msg_status eq'N')
    { $files = OpenUMS::IMAP::new_imap_messages($dbh, $extension); }
  return(undef) unless defined($files);

  my @msg_array;
  my $filelist = "'" . join("','", @{$files}) . "'" ;
  my $sql = qq{SELECT message_id, message_created, message_status_changed,
                   message_last_played ,message_status_id, extension_to,
                   extension_from, message_wav_path, message_wav_file,
                   YEAR(message_created) m_year ,
                   MONTH(message_created) m_month,
                   DAYOFMONTH(message_created) m_day,
                   HOUR(message_created) m_hour,
                   MINUTE(message_created) m_minute,
                   lower(DATE_FORMAT(message_created,'%p')) m_am_pm
               FROM VM_Messages
               WHERE message_wav_file in ($filelist)};
  my $sth = $dbh->prepare($sql);
  $sth->execute();
                                                                                
  while (my $msg_hr = $sth->fetchrow_hashref())
    { unshift(@msg_array, $msg_hr); }
                                                                                
  return(\@msg_array);
}
##########################################
## sub get_dbnm_list
##  Accepts: dbh, option (FIRST, LAST or BOTH)
##  Returns: Array Ref with all valid phone keys 
##    for the company directory 
##########################################

sub get_dbnm_list {
  my ($dbh, $option) = @_ ; 
  my $pkeys_ar; 

  if ($option =~ /^FIRST/ || $option =~ /^BOTH/) {
    $pkeys_ar = _get_dbnm_list_det($dbh, 'phone_keys_first_name',$pkeys_ar); 
  }

  if ($option =~ /^LAST/ || $option =~ /^BOTH/) {
    $pkeys_ar = _get_dbnm_list_det($dbh, 'phone_keys_last_name',$pkeys_ar); 
  }
  return $pkeys_ar; 
}

##########################################
## sub _get_dbnm_list_det
##  Accepts: dbh, col (db column), pkeys_ar (an array ref, empty of not, it will append to it)
##  Returns: Array Ref with all valid phone keys
##    for the company directory, should only be called from inside this package
##########################################

sub _get_dbnm_list_det {
  my ($dbh, $col, $pkeys_ar) = @_ ; 
  if ($col !~ /^phone_keys_first_name$|^phone_keys_last_name$/) { 
      return  ; 
  }  

  my $sql = qq{SELECT $col
       FROM VM_Users
       WHERE extension <> 0
        AND $col is not null
        AND name_wav_file is not null 
        AND name_wav_file <> '' 
       ORDER BY $col } ;
  my $sth = $dbh->prepare($sql);
  $sth->execute();

  while (my $pkey = $sth->fetchrow() ) {
    push @{$pkeys_ar}, $pkey ;
  }
  return $pkeys_ar;  
}  

####################################################
## sub get_current_aa_menu_id 
##   gets the menu_id that should play at this time...
##
####################################################

#sub get_current_aa_menu_id {
#  my $dbh = shift;
#  my ($now_year,$now_mon, $now_day, $now_hour, $now_min, $now_sec,$now_dayofweek,$test);
#  ($test, $now_dayofweek, $now_hour, $now_min) = @_;
#
#  if (!$test) {
#     ($now_year,$now_mon, $now_day, $now_hour, $now_min, $now_sec) = Date::Calc::Today_and_Now() ;
#     ## ok, mysql considers sunday to be day of week 1 whereas perl's Date::Calc considers
#     ## sunday to be day seven. so we trick it by adding 1 to the current day...
#                                                                                                                             
#     ## these are the trick day,
#     my ($tr_year, $tr_mon,$tr_day) = Date::Calc::Add_Delta_Days($now_year, $now_mon, $now_day,1);
#     $now_dayofweek = Date::Calc::Day_of_Week($tr_year,$tr_mon,$tr_day);
#  }
#  
# my $sql = qq{SELECT  aa.menu_id
#        FROM auto_attendant aa
#        WHERE aa.aa_dayofweek = $now_dayofweek
#          AND (aa.aa_start_hour  < $now_hour
#          OR (aa.aa_start_hour = $now_hour  AND aa.aa_start_minute <= $now_min ) )
#        ORDER BY aa.aa_start_hour DESC  , aa.aa_start_minute DESC LIMIT 1
#          };
#
#  my $sth = $dbh->prepare($sql);
#  $sth->execute();
#  my $menu_id = $sth->fetchrow()  ;
#  $sth->finish();
#  
#  $log->debug("[DbQuery] get_current_aa_menu_id = $menu_id ");  
#  return ($menu_id) ;
#
#
#}

sub get_aag_sound {
  my $dbh = shift;
  my ($now_year,$now_mon, $now_day, $now_hour, $now_min, $now_sec,$now_dayofweek,$test);
  ($test, $now_dayofweek, $now_hour, $now_min) = @_;

  if (!$test) {
     ($now_year,$now_mon, $now_day, $now_hour, $now_min, $now_sec) = Date::Calc::Today_and_Now() ;
     ## ok, mysql considers sunday to be day of week 1 whereas perl's Date::Calc considers
     ## sunday to be day seven. so we trick it by adding 1 to the current day...
                                                                                                                             
     ## these are the trick day,
     my ($tr_year, $tr_mon,$tr_day) = Date::Calc::Add_Delta_Days($now_year, $now_mon, $now_day,1);
     $now_dayofweek = Date::Calc::Day_of_Week($tr_year,$tr_mon,$tr_day);
  }
  
 my $sql = qq{SELECT  menu_sound
        FROM auto_attendant aa
        WHERE aa.aa_dayofweek = $now_dayofweek
          AND (aa.aa_start_hour  < $now_hour
          OR (aa.aa_start_hour = $now_hour  AND aa.aa_start_minute <= $now_min ) )
        ORDER BY aa.aa_start_hour DESC  , aa.aa_start_minute DESC LIMIT 1
          };

  my $sth = $dbh->prepare($sql);
  $sth->execute();
  my $menu_sound = $sth->fetchrow()  ;
  $sth->finish();
  
  $log->debug("[DbQuery] get_aag_sound = $menu_sound ");  
  return ( $menu_sound ) ;

} 


##################################################3
## sub get_action_menu_id 
##  Accepts: dbh, action
##  returns the menu_id for an action
##  current valid menu_functions:
##  +----------------+---------+
##  | menu_func_name | menu_id |
##  +----------------+---------+
##  | station_login  |     202 |
##  | take_message   |     801 |
##  | auto_attendant |     601 |
##  | auto_login     |     215 |
##  | N_messages     |     204 |
##  | S_messages     |     205 |
##  +----------------+---------+
##  This should be called by the after the action has
##  be determined by evaluating the intergration digitis 
##   the VM_Users table
##  NEW: If it is auto_attendant, it
##   looks at the auto_attendant table to get the correct menu id...

##################################################3

sub get_action_menu_id {
  my ($dbh, $action) = @_; 
#  if ($action =~ /^auto_attendant/) { 
#     return OpenUMS::DbQuery::get_current_aa_menu_id($dbh); 
#  }  else { 
     my $sql  = qq{SELECT menu_id FROM menu_functions WHERE menu_func_name = '$action' }; 
     my $sth = $dbh->prepare($sql); 
     $sth->execute();
     my $menu_id = $sth->fetchrow();
     $sth->finish(); 
     return $menu_id; 
#  }

}

##################################################3
## sub all_users 
##  Accepts: dbh, active
##  returns the standard selectall_hashref structure fo 
##   the VM_Users table
##################################################3

sub all_users {
  my ($dbh, $active,$sb1,$sb2) = @_; 

  my $sql = "SELECT * FROM VM_Users WHERE extension <> 0  " ; 
  if ($active) { 
    $sql .= " AND active = 1 "; 
  } 

  my $aref = $dbh->selectall_hashref($sql,'extension'); 
  return $aref; 
}

##################################################3
## sub menu_data 
##  Accepts: dbh, menu_id
##  returns the standard selectall_hashref structure fo 
##   the menu table
##################################################3

sub menu_data {
  my $dbh = shift ; 
  my $menu_id = shift ; 

  my (@fields) = @_; 

  my $field_list ;  
  if (scalar(@fields) )  { 
    $field_list = join(",", @fields); 
  } else {
    $field_list = " * "; 
  }

  my $sql = "SELECT $field_list FROM menu  " ; 
  if ($menu_id) {
     $sql .= " WHERE menu_id = $menu_id "; 
  } 

  my $aref = $dbh->selectall_hashref($sql,'menu_id'); 

  return $aref; 
}
##################################################3
## sub menu_item_data 
##  Accepts: dbh, menu_item_id
##  returns the standard selectall_hashref structure fo 
##   the menu_items table
##################################################3

sub get_menu_item {
  my $dbh = shift ;
  my $menu_item_id = shift ;
                                                                                                                             
  my (@fields) = @_;
                                                                                                                             
  my $field_list ;
  if (scalar(@fields) )  {
    $field_list = join(",", @fields);
  } else {
    $field_list = " * ";
  }
                                                                                                                             
  my $sql = "SELECT $field_list FROM menu_items  " ;

  if ($menu_item_id) {
     $sql .= " WHERE menu_item_id = $menu_item_id ";
  }
                                                                                                                             
  my $aref = $dbh->selectall_hashref($sql,'menu_item_id');
                                                                                                                             
  return $aref;
}

##################################################3
## sub menu_item_data 
##  Accepts: dbh, menu_id (otpional) if menu_id is not provied, 
##      all menus will be query
##  Returns a hash ref with all menu items,
##  the structure is kind of funky, look at the example in 
##  the comment below to see how the data is returned, it's
##   a kind master/detail tree structure of hashes
##################################################3

sub menu_item_data {
  my $dbh = shift ; 
  my $menu_id = shift  ; 
#  my $sql = "select * from menu m LEFT OUTER JOIN menu_items mi ON (m.menu_id = mi.menu_id) "  ; 
  my $sql = qq{ select m.menu_id AS menu_id, title, menu_type_code, max_attempts,
   param1, param2 , param3 , param4 , menu_item_id ,
   menu_item_title , menu_item_option , dest_menu_id ,
   menu_item_action, permission_id
FROM menu m LEFT OUTER JOIN menu_items mi
    ON (m.menu_id = mi.menu_id) } ; 
### WHERE m.menu_id = 803  ORDER BY m.menu_id

  if ($menu_id ) { 
     $sql .= " WHERE m.menu_id = $menu_id "  ; 

  } 
  $sql .= " ORDER BY m.menu_id " ; 

  ## ok, i know this looks ugly, so here's how u get it out:
  ##
  ##  my $data = OpenUMS::DbQuery::menu_detail_data($dbh); 
  ##  foreach my $menu_id ( sort keys %{$data} ) { 
  ##    print "$menu_id: \n"; 
  ##    ##   this will get the info about the menu.... like the title, the type, etc
  ##    foreach my $f (keys %{$data->{$menu_id}}  ) { 
  ##       if ($f ne 'menu_items' ) { 
  ##           print "$f:$data->{$menu_id}->{$f}, " ; 
  ##       }  
  ##    }
  ##    print "---\n"; 
  ##    ##   this will get all the details, the menu_items 
  ##    my $menu_items = $data->{$menu_id}->{menu_items}  ; 
  ##    foreach my $menu_item_id (keys %{$menu_items } ) { 
  ##      print "$menu_item_id :" ; ##    . $data->{$menu_id}->{menu_items}->{$f} . ", " ; 
  ##      ##   now, foreach of the fields in the menu_items table...
  ##      foreach my $f (sort keys %{$menu_items->{$menu_item_id}} ) {
  ##         print "$f =  $menu_items->{$menu_item_id}->{$f}  "; 
  ##      } 
  ##      print "\n"; 
  ##    } 
  ##    print "\n"; 
  ##  } 


  my $sth  = $dbh->prepare($sql); 
  $sth->execute(); 
  my $data; 
  my @fields ; 
  while (my $hr = $sth->fetchrow_hashref()) { 
    $data->{$hr->{menu_id}}->{title} =  $hr->{title} ; 
    $data->{$hr->{menu_id}}->{max_attempts} =  $hr->{max_attempts} ; 
    $data->{$hr->{menu_id}}->{menu_type_code} =  $hr->{menu_type_code} ; 
    $data->{$hr->{menu_id}}->{permission_id} =  $hr->{permission_id} ; 
    $data->{$hr->{menu_id}}->{param1} =  $hr->{param1} ; 
    $data->{$hr->{menu_id}}->{param2} =  $hr->{param2} ; 
    $data->{$hr->{menu_id}}->{param3} =  $hr->{param3} ; 
    $data->{$hr->{menu_id}}->{param4} =  $hr->{param4} ; 
    my $menu_items ;
    $menu_items->{dest_menu_id} =  $hr->{dest_menu_id} ;
    $menu_items->{menu_item_option} =  $hr->{menu_item_option} ;
    $menu_items->{menu_item_title} =  $hr->{menu_item_title} ;
    $menu_items->{menu_item_action} =  $hr->{menu_item_action} ;
    $menu_items->{menu_item_id} =  $hr->{menu_item_id} ;
    $menu_items->{menu_item_action} =  $hr->{menu_item_action} ;

    $data->{$hr->{menu_id}}->{menu_items}->{$hr->{menu_item_id}}  = $menu_items ; 
  }   
  
  return $data; 
}

#############################################
## sub is_menu_item_option:
##  Accepts: dbh, menu_id, menu_item_option, menu_item_id
##  Returns 1 if the passed menu_item_options is already in the menu 
##  designated by menu_id. If the menu_item_id is passed, that
##  item will be ignored. 
##  This check should be performed to ensure an option does not get more
##  entry in the menu_items table
########################################

sub is_menu_item_option {
  ## this returns 1 if there is already an option 
  ## 
  my $dbh = shift ; 
  my ($menu_id, $menu_item_option,$menu_item_id)  = @_; 
  
  my $sql = qq{SELECT count(*) FROM menu_items mi,menu m1, menu m2
      WHERE m1.menu_id = $menu_id
      AND mi.menu_id = m1.menu_id
      AND m2.menu_id = mi.dest_menu_id
      AND mi.menu_item_option  = '$menu_item_option' };

  if ($menu_item_id) { 
     # this is for edits, we wanna see if there's one that isn't the same as this one....
     $sql  .= " AND menu_item_id <> $menu_item_id "; 
  } 
   

  print STDERR "sql = $sql\n"; 
  my $sth  = $dbh->prepare($sql);
  $sth->execute();
  my $opt_count = $sth->fetchrow();
  $sth->finish(); 
  return  $opt_count;    
}
#############################################
## sub get_next_menu_id:
##   Returns the all the valid menu_type_codes
##   for a menu
########################################
                                                                                                                                               
sub get_next_menu_id {
  my $dbh = shift;
  my $menu_id_begin = shift ; 
  my $statement = qq{SELECT max(menu_id) + 1  menu_id FROM menu WHERE menu_id >  $menu_id_begin AND menu_id < ($menu_id_begin + 100) } ; 
  my @row_ary  = $dbh->selectrow_array($statement);
  my $menu_id = $row_ary[0]; 

  return $menu_id ;
}


#############################################
## sub get_next_xfer_id:
##   Returns the all the valid menu_type_codes 
##   for a menu
########################################

sub menu_types { 
  my $dbh = shift; 
  my $sql = "SELECT menu_type_code , menu_type_code_descr FROM menu_types " ; 
  my $data = $dbh->selectall_hashref($sql,"menu_type_code");
  return $data ; 

}
#############################################
## sub get_next_xfer_id:
##   Returns the next valid menu_id for a Transfer (XFER) 
##   type of menu
########################################

sub get_next_xfer_id {
  my $dbh = shift; 
  my $sql = "SELECT max(menu_id) + 1 FROM menu WHERE menu_id like '8%' ";
  my $sth = $dbh->prepare($sql); 
  $sth->execute(); 
  my $next_menu_id = $sth->fetchrow();
  $sth->finish(); 
  return $next_menu_id; 
}

#############################################
## sub get_next_aam_id:
##   Returns the next valid menu_id for an auto_attendant 
##   type of menu
########################################

sub get_next_aam_id {
  my $dbh = shift;
  my $sql = "SELECT max(menu_id) + 1 FROM menu WHERE menu_id like '6%' ";
  my $sth = $dbh->prepare($sql);
  $sth->execute();
  my $next_menu_id = $sth->fetchrow();
  $sth->finish();
  return $next_menu_id;
}

#############################################
## sub get_dbnm_typs:
##   Accepts a menu_id
##   Returns a array ref of hash refs
##   with the menu_id, menu title  and menu_item_options
##   of any menus that have the parameter menu_id in as an option
##   this data should reviewed called before trying to delete a menu to 
##   make sure u do not break any existing menus
########################################

sub get_menu_deps {
  my ($dbh,$menu_id)  = @_; 
  my $sql = qq{SELECT m.menu_id, m.title,  mi.menu_item_option menu_item_option FROM menu m INNER JOIN menu_items mi
        ON (m.menu_id = mi.menu_id ) WHERE mi.dest_menu_id = $menu_id };  
  my $sth = $dbh->prepare($sql);
  
  $sth->execute();
  my @dep_arr; 
  while (my ($m,$tit,$opt)  = $sth->fetchrow_array() ) {
      my %hash; 
      $hash{menu_id} = $m; 
      $hash{title} = $tit; 
      $hash{menu_item_option} = $opt; 
      push @dep_arr, \%hash; 
  } 
  $sth->finish(); 
  if (!scalar( @dep_arr)  ) { 
     return undef;
  } else {
     return \@dep_arr; 
  }
}

#############################################
## sub get_dbnm_typs:
##   Returns valid type for a Dial by Name Menu
##
########################################

sub get_dbnm_types {
  my $dbh = shift ;
  my @arr = ('BOTH', 'FIRST','LAST'); 
  return \@arr; 
}

#############################################
## sub user_is_admin:
##   checks the user's permission_id to make sure 
##   they are either 'ADMIN' or 'SUPER'
##
########################################

sub user_is_admin {
  ## returns 1 if extension has adminstrative rights, 0 if not...
  my ($dbh  , $ext) = @_;
  my $sql = qq{SELECT count(*) FROM VM_Users WHERE extension = $ext and permission_id in ('ADMIN','SUPER') } ;
  my $sth = $dbh->prepare($sql);
  $sth->execute();
  my $admin = $sth->fetchrow();
  $sth->finish() ;
  return $admin ;
                                                                                                                             
}
#############################################
## sub user_permission_id:
##   Accepts: dbh, ext
##   Returns:  an array ref with all the permission ids
##
########################################

sub user_permission_id {
  my ($dbh  , $ext) = @_;

  my $sql = qq{SELECT permission_id FROM VM_Users WHERE extension = $ext } ;
  my $sth = $dbh->prepare($sql);
  $sth->execute();

  my $perm = $sth->fetchrow();
  $sth->finish() ;

  return $perm ;



}

#############################################
## sub get_permission_ids:
##   Accepts: dbh
##   Returns:  an array ref with all the permission ids
##
########################################

sub get_permission_ids {
  my $dbh = shift; 
  my $sql = "SELECT permission_id FROM VM_Permissions order by permission_level"; 
  my $arr = $dbh->selectcol_arrayref($sql) ;
  return $arr; 
}
#############################################
## sub validate_menu_box:
##   Accepts: dbh, menu_id
##   Returns:   validates that a menu_id is a valid 
##       menu, should only be called if user is SUPER
########################################

sub validate_menu_box {
  my $dbh = shift;
  my $menu_id = shift;
  if (!$menu_id) {
    return 0; 
  } 
  my $sql = qq{SELECT count(menu_id)
               FROM menu WHERE  menu_id = $menu_id } ;
  my $sth = $dbh->prepare($sql);
  $sth->execute();
  my $bool = $sth->fetchrow();
  $sth->finish();
  return $bool;
}

#############################################
## sub validate_aa_box:
##   Accepts: dbh, menu_id
##   Returns:   validates that a menu_id is a valid 
##       auto attendant box, if it isn't it return 0
########################################

sub validate_aa_box {
  my $dbh = shift; 
  my $menu_id = shift; 
  return 0 if (!$menu_id); 
  my $sql = qq{SELECT count(menu_id) 
               FROM menu WHERE  menu_id = $menu_id 
                AND menu_type_code in ('AAG', 'AAM','UINFO') } ; 
  my $sth = $dbh->prepare($sql);
  $sth->execute();
  my $bool = $sth->fetchrow();
  $sth->finish(); 
  return $bool; 

}

#############################################
## sub validate_sound_file_id:
##   Accepts: dbh, menu_id
##   Returns:   validates that a menu_id is a valid
##       auto attendant box, if it isn't it return 0
########################################
                                                                                                                                               
sub validate_sound_file_id {
  my $dbh = shift;
  my $file_id = shift;
  return 0 if (!$file_id);
  my $sql = qq{SELECT count(file_id)
               FROM sound_files WHERE  file_id = $file_id } ;
  my $sth = $dbh->prepare($sql);
  $sth->execute();
  my $bool = $sth->fetchrow();
  $sth->finish();
  return $bool;
                                                                                                                                               
}



#############################################
## sub aa_settings:
##   Accepts: dbh
##   Returns:   returns an Array Ref with hashes
##     Each hash represents one setting in the auto_attendant table
##     besides the db fields (aa_dayofweek,  aa_start_hour ,  aa_start_minute , menu_id),
##     this sub generates aa_start_hour_ampm, aa_start_ampm  for friendly display
########################################

#sub aa_settings { 
#  my $dbh  = shift; 
#  my ($aa_dayofweek, $aa_start_hour, $aa_start_minute) = @_;
#
#  my $sql = qq{SELECT  aa_dayofweek,  aa_start_hour ,  aa_start_minute , m.menu_id, m.title
#        FROM auto_attendant aa LEFT JOIN menu m ON (aa.menu_id = m.menu_id ) }; 
#  if (defined($aa_dayofweek) &&  defined($aa_start_hour) &&  defined($aa_start_minute)) { 
#     $sql .= " WHERE aa_dayofweek = $aa_dayofweek and aa_start_hour = $aa_start_hour  " ; 
#     $sql .= " and aa_start_minute = '$aa_start_minute' "; 
#  } 
#  $sql .= " ORDER BY aa_dayofweek,  aa_start_hour ,  aa_start_minute " ; 
#  my $sth = $dbh->prepare($sql) ; 
#  $sth->execute(); 
#
#  my @arr; 
#                                                                                                                             
#  my %days = (1 => "Sunday", 2 =>"Monday", 3=>"Tuesday", 
#              4=>"Wednesday", 5=>"Thursday", 6=>"Firday", 
#              7=>"Saturday") ; 
#
#  while (my ($aa_dayofweek,  $aa_start_hour,  $aa_start_minute, $menu_id,$menu_title ) = 
##          $sth->fetchrow_array() ) {
#    my %data; 
#    ## ok, mysql considers sunday to be day of week 1 whereas perl's Date::Calc considers
#    ## sunday to be day seven. so we trick it by adding 1 to the current day...
#    $data{aa_dayofweek} = $aa_dayofweek ; 
#    $data{aa_start_hour} = $aa_start_hour;
#    $data{aa_start_minute} = sprintf("%02d",$aa_start_minute);
#    if ($aa_start_hour == 0) {
#       $data{aa_start_hour_ampm} = "12";
#       $data{aa_start_ampm} = "AM"; 
#    } elsif ($aa_start_hour > 0 && $aa_start_hour  < 12) {
#       $data{aa_start_hour_ampm} = $aa_start_hour;
#       $data{aa_start_ampm} = "AM"; 
#    } elsif ($aa_start_hour == 12)  {
#       $data{aa_start_hour_ampm} = $aa_start_hour;
#       $data{aa_start_ampm} = "PM"; 
#    } else {
#       $data{aa_start_hour_ampm} = $aa_start_hour -12;
#       $data{aa_start_ampm} = "PM"; 
#    } 
#    $data{menu_id} = $menu_id; 
#    $data{menu_title} = $menu_title; 
#    $data{aa_day} = $days{$aa_dayofweek} ;
#    push @arr , \%data; 
#  }  
#  return \@arr; 
#}
#####################################
## sub get_menu_sound
##  gets the current sound for a menu, only the first 1....not all the others, hehehe, that's version 12
##############################333
                                                                                                                                               
sub get_menu_sound {
  my $dbh = shift;
  my $menu_id = shift;

  return "invalid.wav" if (!$menu_id);

  my $sql  = qq{SELECT sound_file FROM menu_sounds
                WHERE menu_id = ? AND order_no = 1 AND sound_type = 'M'};
  my $sth = $dbh->prepare($sql);
  $sth->execute($menu_id);
  my $sound_file = $sth->fetchrow();
  $sth->finish();
  return $sound_file ;
}

#####################################
## sub user_greetings
##   Accept: dbh, extension
##   returns an array ref of hash refs with 
##   gets the user greetings in order
##############################333

sub user_greetings {
  my ($dbh, $ext)  = @_ ;  

  return undef if (!$ext); 

  my $sql = qq{select *, DATE_FORMAT(last_updated,'%Y-%m-%d %T') last_updated_formatted FROM VM_Greetings
           WHERE extension = $ext 
               AND current = 1 
               ORDER BY user_greeting_no } ; 

  my $sth = $dbh->prepare($sql);

  $sth->execute();  
  my @arr; 
  while (my $rs_hr = $sth->fetchrow_hashref() ){
    my $hr ;
#    my $message_id = $rs_hr->{message_id};
    foreach my $key (keys %{$rs_hr}) {
      my $val = $rs_hr->{$key}; 
      $hr->{$key} = $val ; 
    }
    push @arr, $hr;
  }
  $sth->finish();
  return \@arr;
}

#################################
## sub get_rec_msg_menu_id
#################################
sub get_rec_msg_menu_id {
  my $dbh  = shift ; 
  ## for now, it's just lowest menu_id for RECMSG
  my $sql = qq{ SELECT min(menu_id) FROM menu where menu_type_code = 'RECMSG'};
  my $sth = $dbh->prepare($sql); 
  $sth->execute();
  my $menu_id = $sth->fetchrow();
  $sth->finish();
  return $menu_id ;
}
#################################
## sub get_post_msg_menu_id
#################################

sub get_post_msg_menu_id {
  my $dbh = shift ; 
  my $sql = qq{ SELECT min(menu_id) FROM menu where menu_type_code = 'POSTRECMSG'};

  my $sth = $dbh->prepare($sql); 
  $sth->execute();
  my $menu_id = $sth->fetchrow();
  $sth->finish();
  return $menu_id ;
}

#################################
## sub get_mobile_menu_id
#################################
sub get_mobile_menu_id {
  my $dbh  = shift ; 
  my $mobile_email_flag  = shift ;
  my $sql;  
  if ($mobile_email_flag ) { 
    $sql = qq{SELECT menu_id FROM menu WHERE param1 = 'MOBILEDEACT' }; 
  } else {  
    $sql = qq{SELECT menu_id FROM menu WHERE param1 = 'MOBILEACT' }; 
  } 
  my $sth = $dbh->prepare($sql);
  $sth->execute();
  my $menu_id = $sth->fetchrow();
  $sth->finish();
  return $menu_id ; 

} 

sub is_auto_login_new_user {
  my $dbh  = shift ;
  my $extension  = shift ;
  my $sth = $dbh->prepare("SELECT auto_login_flag,new_user_flag FROM VM_Users WHERE extension = ? " );
  $sth->execute($extension);
  my ($auto_login,$new_user_flag)  = $sth->fetchrow_array() ;
  $sth->finish();
  $log->debug("[DbQuery] is_auto_login_new_user for $extension = $auto_login, $new_user_flag");
  return $auto_login;
}

sub is_auto_login {
  my $dbh  = shift ; 
  my $extension  = shift ;
  my $sth = $dbh->prepare("SELECT auto_login_flag,new_user_flag FROM VM_Users WHERE extension = ? " ); 
  $sth->execute($extension); 
  my $auto_login = $sth->fetchrow() ; 
  $sth->finish();
  $log->debug("[DbQuery] is_auto_login for $extension = $auto_login");
  return $auto_login; 
} 
1; 
