package OpenUMS::DbUtils;
### $Id: DbUtils.pm,v 1.1 2004/07/20 02:52:15 richardz Exp $
#
# DbUtils.pm
#
# Reading from or writing to the database subs.
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

use File::Copy ; 
use OpenUMS::IMAP;
use OpenUMS::Log;
use OpenUMS::Common;
use OpenUMS::DbQuery;

#################################
## sub change_password
##   updates the user's password in the database
#################################

sub change_password {
  my ($dbh, $extension, $new_password) = @_;
  my $sql = qq{UPDATE VM_Users
               SET password = PASSWORD('$new_password')
               WHERE extension = $extension};
  my $upd = $dbh->do($sql);
  $log->info("Changing password for $extension");
  return 1;
}

#################################
## sub change_password
##   this updates the name wav file in the db...
#################################
sub update_name {
  my ($dbh, $extension, $name_wav_file, $name_wav_path) = @_;
  if (!$name_wav_file){
    ## huhh?
    return 0;
  }
  my $sql = "UPDATE VM_Users SET name_wav_file = '$name_wav_file'";
  if ($name_wav_path){
     ## they wanna update the wav path, should need to do this...
    $sql .= " , name_wav_path = '$name_wav_path'"
  }
  $sql .= " WHERE extension =  $extension  ";
  $dbh->do($sql);
  return;
}

#################################
## sub create_user_greeting
##    creates a greeting for the user..
#################################
sub create_user_greeting {
  my ($dbh, $extension, $greeting_wav_file, $greeting_wav_path) = @_;
  my $ins = qq{INSERT INTO VM_Greetings 
    (extension, greeting_wav_path, greeting_wav_file, current_greeting, last_updated)
    VALUES 
    ($extension, '$greeting_wav_path', '$greeting_wav_file', 1, NOW())};
  $log->debug("create_user_greeting : " . $ins); 
  $dbh->do($ins); 

}

#################################
## sub create_user_greeting
## stuff to change greetings.
#################################
sub update_user_greeting {
  my ($dbh, $extension, $greeting_wav_file, $greeting_wav_path) = @_;
  if (!$greeting_wav_file){
    $log->debug("update_current_greeting => $greeting_wav_file, $greeting_wav_path"); 
    ## huhh?
    return 0;
  }

## first we update all the greetings so they aren't one
#  my $upd = qq{UPDATE VM_Greetings 
#               SET user_greeting_no = user_greeting_no + 1 
#               WHERE extension =$extension } ;
#  $log->debug($upd); 
#  $dbh->do($upd); 
## then we insert the new greeting...

  my $upd =  qq{UPDATE VM_Greetings SET
       greeting_wav_path ='$greeting_wav_path', 
       greeting_wav_file = '$greeting_wav_file'
       WHERE extension = $extension }; 

  $dbh->do($upd); 
  return;

  ## check that the extenstion dir exists, if not, make it
}

####################################################
##  sub delete_message
##   Accepts : dbh, extension, message_id
##   Marks messages as 'D' for deleted in database, 
##   Note: this doesn't delete the file or database entry or anything like that
####################################################

sub delete_message {
  my $dbh = shift;
  my $extension = shift;
  my $msg_id = shift;
  return change_message_status($dbh, $extension, $msg_id, 'D');
}


#################################
## sub mark_new_message
#################################
sub mark_new_message {
  my $dbh = shift;
  my $extension = shift;
  my $msg_id = shift;

  return change_message_status($dbh, $extension, $msg_id, 'N');
}

#################################
## sub save_message
#################################
sub save_message {
  my $dbh = shift;
  my $extension= shift;
  my $msg_id = shift;
  return change_message_status($dbh, $extension, $msg_id, 'S');
}



#################################
## sub change_message_status
#################################
sub change_message_status {
  my $dbh = shift;
  my $extension= shift;
  my $msg_id = shift;
  my $new_status = shift;
  $log->info("Changing message_status_id for ext=$extension;msg_id=$msg_id;new_status= $new_status");
  my $sql =  qq{UPDATE VM_Messages
                SET message_status_id = ?, 
                    message_status_changed = NOW() 
                WHERE message_id = ?
                  AND extension_to = ?};
  my $sth = $dbh->prepare($sql);

  $sth->execute($new_status, $msg_id, $extension);
  $sth->finish();
  return;
}


#################################
## sub create_message
#################################
sub create_message {
  my ($dbh, $ext, $filename, $message_path,$ext_from,$record_call_flag,$forward_msg_flag) = @_;
  if ($ext_from !~ /[0-9]/) {
     $ext_from = 'NULL'
  } 
  if ($record_call_flag ne '1') {
    $record_call_flag = '0' ;   
  } 
  if ($forward_msg_flag ne '1') {
    $forward_msg_flag = '0' ;   
  } 

  my $sql = qq{INSERT INTO VM_Messages
                 (message_created, message_status_id,
                  extension_to,extension_from, message_wav_path, message_wav_file, record_call_flag, forward_message_flag )
               VALUES (now(), 'V', $ext,$ext_from, '$message_path', '$filename', $record_call_flag,$forward_msg_flag  ) };

  $dbh->do($sql);
  my $msg_id =  $dbh->{'mysql_insertid'};
  return $msg_id;
}



#################################
## sub update_phone_keys
#################################
sub update_phone_keys {
  ## this will update the phone_keys
  my ($dbh, $ext) = @_;
  my ($first_name,$last_name) = OpenUMS::DbQuery::get_first_last_names($dbh,$ext);
  if ($first_name ) {
    my $phone_keys = OpenUMS::DbUtils::get_phone_keys($first_name);
    my $upd = "UPDATE VM_Users SET phone_keys_first_name = $phone_keys WHERE extension=$ext";
    $dbh->do($upd);
  }
  if ($last_name ) {
    my $phone_keys = OpenUMS::DbUtils::get_phone_keys($last_name);
    my $upd = "UPDATE VM_Users SET phone_keys_last_name = $phone_keys WHERE extension=$ext";
    $dbh->do($upd);
  }

}

#################################
## sub get_phone_keys
#################################
sub get_phone_keys {
  my $val = shift;
  return if (!$val);  
  my $keys;
  for (my $i =0; $i < 3; $i++){
   my $l = substr($val,$i,1);
   my $key;
   if ($l =~ /[a-c]/i) {
     $key = 2;
   } elsif ($l =~ /[d-f]/i) {
     $key = 3;
   } elsif ($l =~ /[g-i]/i) {
     $key = 4;
   } elsif ($l =~ /[j-l]/i) {
     $key = 5;
   } elsif ($l =~ /[m-o]/i) {
     $key = 6;
   } elsif ($l =~ /[p-s]/i) {
     $key = 7;
   } elsif ($l =~ /[t-v]/i) {
     $key = 8;
   } elsif ($l =~ /[w-z]/i) {
     $key = 9;
   }
   $keys .= $key;
  }
  return $keys;
}

#################################
## sub get_new_or_saved
##  takes a dbh, an extension and a msg_status_id
##  returns an array ref of hash ref contain the
##   new or saved messages
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

#############################
## sub unset_new_user_flag
##   sets the new_user_flag = 0 for a given extension
##   should be called when the user completes the tutorial
##########################33
sub unset_new_user_flag {
  my ($dbh, $ext) = @_; 
  if ($ext ) { 
      $dbh->do("UPDATE VM_Users SET new_user_flag = 0 WHERE extension = $ext " ); 
      return 1 ; 
  } else {
      return 0 ; 
  } 
} 


#################################
## sub set_user_inactive
#################################
sub set_user_inactive {
  my ($dbh, $ext) = @_; 
  if ($ext) { 
    my $sql = qq{UPDATE VM_Users set active =0 where extension = $ext}; 
    $dbh->do($sql); 
  } 
  return ;
} 


#################################
## sub delete_user
#################################
sub delete_user {
  my ($dbh, $ext,$dir_flag) = @_;
  if ($ext) {
    ## delete from the VM_Users 
    my $stmt = qq{DELETE FROM VM_Users WHERE extension = $ext};
    $dbh->do($stmt);

    $stmt = qq{DELETE FROM VM_Messages WHERE extension_to = $ext};
    $dbh->do($stmt);

    $stmt = qq{DELETE FROM VM_Greetings WHERE extension = $ext};
    $dbh->do($stmt);

    if ($dir_flag) {
      ## they want to delete the user's directory too
      my $dir = BASE_PATH . USER_PATH . $ext ; 
      print STDERR "dir=$dir \n";
      my $val = `rm -R $dir` ; 
      print STDERR "delete dir = $val\n";
    }
    
  }
  return ;
}

#################################
## sub generic_update
#################################
sub generic_update {
  ## this is for the guy who really knows what he's doing....
  my ($dbh,$table_name, $data_ref, @key_fields) = @_;  
  my @assignments ;  

  foreach my $f (keys %{$data_ref} ) { 
     my $key_flag =0 ;  
     foreach my $k (@key_fields) {
       if ($k eq $f) { 
         $key_flag = 1 ; 
         last; 
       } 
     }  
     if (!$key_flag ) { 
       if ($data_ref->{$f} eq 'NULL' ) {
          push @assignments, " $f = NULL "; 
       } else { 
          push @assignments, " $f = " . $dbh->quote($data_ref->{$f}) . " " ; 
       }
     } 
  }  

  my @wheres ;  
  foreach my $k (@key_fields) { 
    push @wheres, "$k = " . $dbh->quote($data_ref->{$k}) . " " 
  } 
  
  my $sql = "UPDATE $table_name SET "; 
  $sql .= join(",", @assignments ); 
  $sql .= " WHERE "; 
  $sql .= join(" AND ", @wheres ); 
  print STDERR "updat e= $sql \n"; 
  $dbh->do($sql); 
}

#################################
## sub generic_insert
#################################
sub generic_insert {
  ## this is for the guy who really knows what he's doing....
  my ($dbh,$table_name, $data_ref) = @_;  
  my @fields ;  
  my @values ;  

  foreach my $f (keys %{$data_ref} ) { 
    push @fields, $f;   
    push @values, $dbh->quote($data_ref->{$f})  ;   
  }  

  
  my $sql = "INSERT INTO $table_name ( "; 
  $sql .= join(" , ", @fields ); 
  $sql .= ")  VALUES ("; 
  $sql .= join(" , ", @values ); 
  $sql .= " ) "; 
  print STDERR "generic insert = $sql \n"; 
  $dbh->do($sql); 
}
#####################################
## sub reset_password
##  resets a user's password to their extension
##############################333

sub reset_password {
  my ($dbh, $ext)  = @_ ; 
  OpenUMS::DbUtils::change_password($dbh,$ext,$ext); 
}

#################################
## sub update_sound_file
##   NOTE: this is for auto attendant greetings not user greetings
#################################
sub update_sound_file {
  my ($dbh , $file_id, $file, $path) = @_; 
  my $new_file = "sound_file_$file_id.vox" ; 

  $log->debug( "moving ... $path$file " . BASE_PATH . PROMPT_PATH ."$new_file\n" );  
  if (!(-e "$path$file") )  {
     ## if the file don't exist, return it...
     return 0; 
  } 

  move("$path$file", BASE_PATH . PROMPT_PATH ."$new_file");
  my $upd = qq{ UPDATE sound_files set sound_file =  '$new_file' WHERE file_id = $file_id }; 
  my $affected = $dbh->do($upd)  ; 

}

#################################
## sub add_sound_file
##   NOTE: this is for auto attendant greetings not user greetings
#################################
sub add_sound_file {
  my ($dbh , $file, $path) = @_;
                                                                                                                                               
  $log->debug( "add_sound_file: creating database record " );
  my $ins = qq{INSERT INTO sound_files values (0, '$file', 'new sound', 0) };
  $dbh->do($ins);

  my $file_id = $dbh->{'mysql_insertid'};

  my $new_file = "sound_file_$file_id.vox" ;
  if (!(-e "$path$file") )  {
     ## if the file don't exist, return it...
     return 0;
  }

  move("$path$file", BASE_PATH . PROMPT_PATH ."$new_file");
  $log->debug( "add_sound_file: new_file  = $new_file " );

  my $upd = qq{ UPDATE sound_files SET sound_file =  '$new_file' WHERE file_id = $file_id };
  my $affected = $dbh->do($upd)  ;
  return $file_id ; 
                                                                                                                                               
}




#################################
## sub save_new_greeting
##   NOTE: this is for auto attendant greetings not user greetings
#################################
sub save_new_greeting {
  my ($dbh , $box, $file, $path) = @_; 

  my $new_file = "custom_aa_$box.vox" ; 
  $log->debug( "moving ... $path$file " . BASE_PATH . PROMPT_PATH ."$new_file\n" );  
  if (!(-e "$path$file") )  {
     ## if the file don't exist, return it...
     return 0; 
  } 
  my $sql = qq{SELECT sound_file from menu_sounds 
               WHERE menu_id = $box 
               AND order_no = 1 
               AND sound_type = 'M' } ; 
  my @row_ary  = $dbh->selectrow_array($sql);
  my $old_sound_file = $row_ary[0]; 
   
  if (-e (BASE_PATH . PROMPT_PATH . "$old_sound_file" ) ) { 
     my $ts = OpenUMS::Common::get_timestamp(); 
     # move(BASE_PATH . PROMPT_PATH . "$old_sound_file", BASE_PATH . PROMPT_PATH ."$old_sound_file.$ts.bak");
  }

  move("$path$file", BASE_PATH . PROMPT_PATH ."$new_file");

  if (!$old_sound_file) {
     # we need to create.... 
     my $ins = qq{INSERT INTO sound_files values (0, '$new_file', 'CUstom Sound for box $box', 0) };
     my $affected = $dbh->do($ins)  ; 
     $ins = qq{REPLACE INTO menu_sounds (menu_id, sound_title, sound_file, order_no , sound_type)
        VALUES ($box, 'Greeting for box $box', '$new_file',1,'M') } ; 
     $affected = $dbh->do($ins)  ; 
  } else { 
     ## we just update ...
     my $upd = qq{ UPDATE menu_sounds set sound_file =  '$new_file' WHERE menu_id = $box and order_no = 1 and sound_type = 'M' }; 
     my $affected = $dbh->do($upd)  ; 
  }
  return ; 
}
#sub save_user_greeting {
#  my ($dbh, $user) = @_; 
#
#  my ($new_file,$new_path) =  OpenUMS::DbQuery::get_new_greeting_file ($extension);
#  $log->debug( "moving ... $path$file to $new_path$new_file" );  
#   
#  if (!(-e "$path$file") )  {
#     ## if the file don't exist, return it...
#     return 0; 
#  } 
#  
#  move("$path$file", BASE_PATH . "$new_path$new_file");
#  # we need to set all others as inactive... and bump up their number
#  
#
##  my $upd = qq{UPDATE VM_Greetings SET current = 0, user_greeting_no = user_greeting_no +1 
#                WHERE  extension = $extension}; 
#  my $affected = $dbh->do($upd); 
#
#  $log->debug( "$upd\naffecte = $affected \n"); 

#  my $ins = qq{INSERT INTO VM_Greetings 
#              ( extension, user_greeting_no, current, professional, 
#               greeting_wav_path, greeting_wav_file) 
#              VALUES ($extension,1,1,0,
#              '$new_path', '$new_file') } ; 
#  $affected = $dbh->do($ins)  ; 
#  $log->debug( "$ins\naffecte = $affected \n"); 
#
#  return ; 
#}

#################################
## sub delete_aa_item
##   NOTE: given a day of week, start hour and start minute,
##   this removes that auto attendant setting from the db
#################################
sub delete_aa_item {
  my $dbh = shift ; 
  my ($aa_dayofweek, $aa_start_hour, $aa_start_minute) = @_;
                                                                                                                             
  if (defined($aa_dayofweek) &&  defined($aa_start_hour) &&  defined($aa_start_minute)) {
     my $sql = "DELETE FROM auto_attendant  ";
     $sql .= " WHERE aa_dayofweek = $aa_dayofweek and aa_start_hour = $aa_start_hour  " ;
     $sql .= " and aa_start_minute = '$aa_start_minute' ";
     $dbh->do($sql); 
     return 1 ; 
  }
  return 0 ; 
} 

1; 
