package OpenUMS::IMAP;
### $Id: IMAP.pm,v 1.2 2004/07/31 20:27:05 kenglish Exp $
#
# IMAP.pm
#
# This impliments OpenUMS's email interface.  The name IMAP.pm
# is for historical reasons.
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

use Date::Format;
use Date::Parse;
use DBI;
use File::Copy;
use IO::Socket;
use Mail::IMAPClient;
use MIME::Base64;
use MIME::Lite;
use MIME::Parser;
use POSIX qw(&floor &ceil);

use OpenUMS::Config;
use OpenUMS::Log;


################################################################# use Exporter
use Exporter;

our @ISA = qw(Exporter);
our @EXPORT = qw(&open_imap_connection &recreate_message &new_imap_messages
                 &new_imap_count &saved_imap_messages &saved_imap_count
                 &get_email_delivery &VMINBOX %MARKUP);
our @EXPORT_OK = qw();
our %EXPORT_TAGS = ();

############################################################ HTML/TEXT markups
### This is either incredibly elegant or ugly as sin.  Probably both.
our %MARKUP = ( 'P'      => { 'T' => "\n\t",  'H' => '<P>' },
                'LI'     => { 'T' => "\t-- ", 'H' => '<LI>' },
                'LIST'   => { 'T' => '', 'H' => '<UL>' },
                'TSIL'   => { 'T' => '', 'H' => '</UL>' },
                'HEADER' => { 'T' => '', 'H' => '<HTML><TITLE></TITLE><BODY>' },
                'REDAEH' => { 'T' => '', 'H' => '</BODY></HTML>' } );


##################################################################### VMINBOX
sub VMINBOX($$)
{
  my $dbh = shift;
  my $extension = shift;

  my $sql = qq(SELECT email_delivery
               FROM VM_Users
               WHERE extension = $extension);
  my $sth = $dbh->prepare($sql);
  $sth->execute();
  my $delivery = $sth->fetchrow();
  $sth->finish();

  if ($delivery eq 'I')
    { return("\"In Box Voicemail\""); }
  return("\"Inbox\"");
}


##################################################### open_imap_connection($$)
### Given a users' extension (and the database handle), open the
### user's IMAP email box.  Returns undef on failure.
sub open_imap_connection($$)
{
  my $dbh = shift;
  my $extension = shift;

  ### Get the user's email settings from database
  my $sql = qq(SELECT email_server_address,
                      email_user_name,
                      email_password
               FROM VM_Users
               WHERE extension = $extension);
  my $sth = $dbh->prepare($sql);
  $sth->execute();
  my ($email_server, $email_name, $email_password) = $sth->fetchrow_array();
  $sth->finish();

  return(undef) if ( !defined($email_name) || !defined($email_password) );

  ### Connect to the user's email account.  We will be using UID's
  ### instead of sequence numbers so we don't have to keep track of
  ### (possibly) changing sequences.
  $log->debug("Opening IMAP account for $email_name on $email_server");
  my $imap = Mail::IMAPClient->new(User     => $email_name,
                                   Password => $email_password,
                                   Server   => $email_server,
                                   Port     => IMAP_PORT,
                                   Debug    => IMAP_DEBUG,
                                   Timeout  => IMAP_TIMEOUT,
                                   Uid      => 1);
  unless (defined($imap))
    {
      $log->warning("Unable to open email for user $email_name\@$email_server: $@\n");
      return(undef);
    }

  ### Create the VMINBOX and VMSAVED folders if they aren't there.
  my @folders = $imap->folders;
  foreach my $target (&VMINBOX($dbh, $extension), VMSAVED)
    {
      my $found;
      foreach my $folder (@folders)
        {
          if (uc("\"$folder\"") eq uc($target))
            {
              $found = 1;
              last;
            }
        }
      next if $found;
      $log->info("Creating $target folder");
      $imap->create($target);
    }

  return($imap);
}

######################################################## recreate_message($$)
### Given $dbh and the name of a X-CPVoicemail message file,
### returns the full path to the file on disk or undef if the file cannot
### be found or recreated.  If at first, the file cannot be found on disk,
### an attempt is made to recreate it from a matching email in either
### the user's VMINBOX, VMSAVED or "Deleted Items" folder.
sub recreate_message($$$)
{
  my $dbh = shift;
  my $file = shift;
  my $status = shift;
                                                                                
  return(undef) unless $file =~ /^(\d{3})_(\d{14})_(\d{2})\.vox$/;
  my ($extension, $timestamp, $port) = ($1, $2, $3);
                                                                                
  my $soundfile = BASE_PATH . USER_PATH . "$extension/messages/$file";
                                                                                
  return($soundfile) if( (-e $soundfile) && (-r $soundfile) );
                                                                                
  $log->debug("File $file not found on disk.  Going to try email.\n");

  my $box;
  if ($status eq 'N') 
    { $box = &OpenUMS::IMAP::VMINBOX($dbh, $extension); }
  elsif ($status eq 'S')
    { $box = VMSAVED; }
  elsif ($status eq 'D')
    { $box = "\"Deleted Items\""; }
  else
    {
      $log->err("recreate_message called with illegal state '$status'");
      return(undef);
    }


  my $imap = open_imap_connection($dbh, $extension);
  return(undef) unless defined($imap);
                                                                                
  $imap->select($box);

  ### We need to search on email storage name, not cannonical name
  my $wavfile =~ s/vox$/wav/;
  $log->debug("Searching in $box for $wavfile\n");
  my @uids = $imap->search("FROM $wavfile");
  return(undef) unless (@uids);

  $log->debug("Found $file as $uids[0] in $box.  Saving to disk now.\n");
  my $hdr = $imap->bodypart_string("$uids[0]");
  open(TMP, ">$soundfile.txt");
  print(TMP $hdr);
  close(TMP);

  $imap->logout;

  my $parser = new MIME::Parser;
  $parser->output_dir(BASE_PATH . USER_PATH . "$extension/messages");
  $log->debug("Exploding MIME message $soundfile.txt");
  my $entity = $parser->parse_open("$soundfile.txt");
  unlink("$soundfile.txt");

  if( (-e $soundfile) && (-r $soundfile) )
    {
#      my $dbh = OpenUMS::Common::get_dbh();
      ###
      ### Kevin: The database insert code goes here.
      ###
      use OpenUMS::DbUtils ; 
       my $message_path = BASE_PATH . USER_PATH . "$extension/messages/"; 
       my $statement = qq{SELECT count(*) from VM_Messages WHERE message_wav_file = '$file' }; 
       my @row_ary  = $dbh->selectrow_array($statement); 
       ## if it doesn't exist, we'll create the db record
       if (!$row_ary[0]) { 
         $log->debug("creating db record fro $file");
          my $msg_id = OpenUMS::DbUtils::create_message($dbh, $extension, $file, $message_path);
       } else {
         $log->debug("db record exist $file");
       } 
##      my $sql = qq(INSERT INTO VM_Messages
 ##                 );
#      my $sth = $dbh->prepare($sql); 
#      $sth->execute();
#      $sth->finish();
      return($soundfile);
    }

  $log->err("Unable to find file $wavfile in box.\n");
  return(undef);
}


####################################################### new_imap_messages ($$)
### Get the X-Voicemail messages in a user's email VMINBOX.
### returns a reference to an array of .wav file names.
sub new_imap_messages ($$)
{
   my $dbh = shift;
   my $extension = shift;

   return(undef) unless (defined($extension));
   my $imap = open_imap_connection($dbh, $extension);
   return(undef) unless defined($imap);

   my $uid_aref = search_imap($imap, &VMINBOX($dbh, $extension));
   undef(my @files);
   if (defined($uid_aref))
     { @files = get_x_cpvoicemails($imap, $uid_aref); }

   $log->verbose("Closing IMAP connection");
   $imap->logout;

   return(undef) unless (@files);
   my $delivery_option = get_email_delivery($dbh,$extension);
   if ( ($delivery_option eq 'I') || ($delivery_option eq 'S') )
     { update_database($dbh, 'N', \@files); }
   return(\@files);
}

####################################################### new_imap_count ($$)
### returns a reference to an array of filenames
sub new_imap_count ($$)
{
   my $dbh = shift;
   my $extension = shift;

   return(undef) unless (defined($extension));
   my $imap = open_imap_connection($dbh, $extension);
   return(undef) unless defined($imap);

   my $uid_aref = search_imap($imap, &VMINBOX($dbh, $extension));
   undef(my @files);
   if (defined($uid_aref))
     { @files = get_x_cpvoicemails($imap, $uid_aref); }

   $log->verbose("Closing IMAP connection");
   $imap->logout;

   return(\@files);
}


##################################################### saved_imap_messages($$)
### Get the saved  X-Voicemail messages (from VIMSAVED).
### returns a reference to an array of .wav file names
sub saved_imap_messages($$)
{
  my $dbh = shift;
  my $extension = shift;

  return(undef) unless (defined($extension));
  my $imap = open_imap_connection($dbh, $extension);
  return(undef) unless defined($imap);

  my $uid_aref = search_imap($imap, VMSAVED);
  undef(my @files);
  if (defined($uid_aref))
    { @files = get_x_cpvoicemails($imap, $uid_aref); }

  $log->verbose("Closing IMAP connection.");
  $imap->logout;

  return(undef) unless (@files);
  my $delivery_option = get_email_delivery($dbh, $extension);
  if ( ($delivery_option eq 'I') || ($delivery_option eq 'S') )
    { update_database($dbh, 'S', \@files); }
  return(\@files);
}


##################################################### saved_imap_count($$)
### returns a reference to an array of filenames
sub saved_imap_count($$)
{
  my $dbh = shift;
  my $extension = shift;

  return(undef) unless (defined($extension));
  my $imap = open_imap_connection($dbh, $extension);
  return(undef) unless defined($imap);

  my $uid_aref = search_imap($imap, VMSAVED);
  undef(my @files);
  if (defined($uid_aref))
    { @files = get_x_cpvoicemails($imap, $uid_aref); }

  $log->verbose("Closing IMAP connection.");
  $imap->logout;

  return(\@files);
}


########################################################## search_imap($)
sub search_imap($$)
{
  my $imap = shift;
  my $folder = shift;

  $log->verbose("Selecting $folder");
  $imap->select($folder);
  $log->debug("Searching in " . $folder . " for NOT DELETED");
  my $uid_aref = $imap->search("FROM __CP_Voicemail__ NOT DELETED"); 

  unless (defined($uid_aref))
    { $log->err("Search returned nothing : $@"); }

  return($uid_aref);
}


#################################################### get_x_cpvoicemails($)
### If parse_headers is passed a reference to an array of UIDs as the
### first parameter, it returns a hash whose key is the UID and values
### are references to hashes whose keys are the header field and
### values are references to arrays of values.  Got that?
### Good, explain it to me!
sub get_x_cpvoicemails
{
  my $imap = shift;
  my $uid_aref = shift;

  my @filenames;
  my $hash = $imap->parse_headers($uid_aref, 'X-CPVoicemail');

  foreach my $uid (@$uid_aref)
    {
      my $filename = $hash->{$uid}->{'X-CPVoicemail'}[0];
      $log->verbose('Found ' . $filename);

      ### Convert the emailmail storage name (.wav) to cannonical
      $filename =~ s/\.wav/\.vox/;
      push(@filenames, $filename);
    }

  return(@filenames);
}


################################################### update_database($$)
sub update_database($$$)
{
  my $dbh = shift;
  my $state = shift;
  my $files_ref = shift;

  ### Synchronize database entries.
  # $log->verbose("Synchronizing database");
  my $filelist = "'" . join("','", @$files_ref)  . "'";
  my $sql = qq(UPDATE VM_Messages
               SET message_status_id = ?,
                   message_status_changed = NOW()
               WHERE message_wav_file in ($filelist));
  my $sth = $dbh->prepare($sql);
  $sth->execute($state);
  $sth->finish();

  $sql = qq(UPDATE VM_Messages
            SET message_status_id = ?
            WHERE message_status_id = ?
              AND  message_status_changed = NOW()
              AND message_wav_file NOT in ($filelist) );
  $sth = $dbh->prepare($sql);
  $sth->execute('D', $state);
  $sth->finish();
}

################################################### update_entry($$)
sub update_entry($$$)
{
  my $dbh = shift;
  my $state = shift;
  my $file = shift;

  ### Synchronize database entries.
  # $log->verbose('Synchronizing database');
  my $sql = qq(UPDATE VM_Messages
               SET message_status_id = ?,
		   message_status_changed = NOW()
               WHERE message_wav_file = ?);
  my $sth = $dbh->prepare($sql);
  $sth->execute($state, $file);
  $sth->finish();
}


#################################################### delete_imap_message($$$$)
### Delete from a user's folder the message
sub delete_imap_message($$$)
{
  my $dbh = shift;
  my $extension = shift;
  my $files_aref = shift;

###  unless (my $pid = fork)
    {
      $log->verbose('Deleting queued messages.');
      #my $dbh = OpenUMS::Common::get_dbh();
      my $imap = open_imap_connection($dbh, $extension);
      return(undef) unless defined($imap);
      foreach my $folder (&VMINBOX($dbh, $extension), VMSAVED)
        {
          my $uid_aref = search_imap($imap, $folder);
          foreach my $file (@$files_aref)
            {
              ### Convert cannonical filename to email storage name
              $file =~ s/\.vox$/\.wav/;
              undef(my $found);
              foreach my $uid (@$uid_aref)
                {
                  $found = $imap->search("FROM $file NOT DELETED UID $uid");
                  last if ( defined(@$found) && (@$found[0] == $uid) );
                }
              next unless (defined (@$found[0]));
              move_to_folder($imap, "\"Deleted Items\"", @$found[0]);
            }
        }
      $log->verbose('Closing IMAP connection.');
      $imap->logout;
      $dbh->disconnect;
      $log->verbose('Delete queue cleared.');
###      exit;
    }
  return;
}


###################################################### save_imap_message($$$)
### "Save" the current message.
sub save_imap_message($$$)
{
  my $dbh = shift;
  my $extension = shift;
  my $file = shift;

  return(undef) unless (defined($extension));
  my $imap = open_imap_connection($dbh, $extension);
  return(undef) unless defined($imap);

  my $status = get_status($dbh, $file);
  return(undef) unless defined($status);

  if ($status eq 'S') { return(1); }
  unless ($status eq 'N') { return(undef); }

  $imap->select(&VMINBOX($dbh, $extension));

  ### Convert cannonical name to one we can search for in email
  $file =~ s/\.vox$/\.wav/;
  my $uid_aref = search_imap($imap, &VMINBOX($dbh, $extension));
  undef(my $found);
  foreach my $uid (@$uid_aref)
    {
      $found = $imap->search("FROM $file NOT DELETED UID $uid");
      last if ( defined(@$found) && (@$found[0] == $uid) );
    }

  return(undef) unless defined(@$found);
  # $log->verbose("Found @$found[0]");

  move_to_folder($imap, VMSAVED, @$found[0]);
  update_entry($dbh, 'S', $file);

  $log->verbose('Closing IMAP connection.');
  $imap->logout;
}

################################################# mark_new_imap_message($$$)
### Move a saved message into inbox (and mark as new)
sub mark_new_imap_message($$$)
{
  my $dbh = shift;
  my $extension = shift;
  my $file = shift;

  return(undef) unless (defined($extension));
  my $imap = open_imap_connection($dbh, $extension);
  return(undef) unless defined($imap);

  my $status = get_status($dbh, $file);
  return(undef) unless defined($status);

  if ($status eq 'N') { return(1); }
  unless ($status eq 'S') { return(undef); }

  ### Convert cannonical name to one we can search for in email
  my $wavfile =~ s/\.vox$/\.wav/;
  $imap->select(VMSAVED);
  $log->debug('Searching in ' . VMSAVED . " for NOT DELETED $wavfile");
  my ($uid) = $imap->search("FROM $wavfile NOT DELETED");

  # $log->verbose("Found $uid");
  return(undef) unless defined($uid);

  $imap->deny_seeing($uid);
  move_to_folder($imap, &VMINBOX($dbh, $extension), $uid);
  update_entry($dbh, 'N', $file);

  $log->verbose('Closing IMAP connection.');
  $imap->logout;
}


########################################################## get_status($)
sub get_status
{
  my $dbh = shift;
  my $file = shift;

  my $sql = qq(SELECT message_status_id
               FROM VM_Messages
               WHERE message_wav_file = ?);
  my $sth = $dbh->prepare($sql);
  $sth->execute($file);
  my ($status) = $sth->fetchrow_array();
  $sth->finish();

  # $log->verbose("$status");
  return($status);
}


##################################################### move_to_folder($$)
sub move_to_folder($$$)
{
  my $imap = shift;
  my $folder = shift;
  my $msg_uid = shift;

  $log->debug("Moving $msg_uid to $folder");
  $imap->see($msg_uid);
  $imap->move($folder, $msg_uid);
  $imap->_send_line("1 UID EXPUNGE $msg_uid");
}


####################################################### get_email_delivery($$)
sub get_email_delivery($$)
{
  my $dbh = shift; 
  my $extension = shift;

  #my $dbh = OpenUMS::Common::get_dbh();
  my $sql = qq(SELECT email_delivery FROM VM_Users WHERE extension = ?);
  my $sth = $dbh->prepare($sql);
  $sth->execute($extension);
  my $email_int = $sth->fetchrow();
  $sth->finish();

  return($email_int);
}



1;
