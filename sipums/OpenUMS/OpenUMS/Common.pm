package OpenUMS::Common;
### $Id: Common.pm,v 1.3 2004/07/27 01:43:27 kenglish Exp $
#
# Common.pm
#
# This is the repository for general utility subs or non-specific
# subs that don't really belong anywhere else.
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

use Audio::Wav;
use Date::Calc qw(Today Add_Delta_Days Month_to_Text);
use DBI;
use File::Copy;
use File::Temp;
use IO::Socket;
use Mail::IMAPClient;
use MIME::Base64;
use POSIX qw(:sys_wait_h &ceil);

use OpenUMS::Config;
use OpenUMS::Log;
use OpenUMS::DbUtils;
use OpenUMS::DbQuery;


################################################################# use Exporter
#use Exporter;

our @ISA = qw(Exporter);
our @EXPORT = qw(&valid_filename &message_store_size &adjust_volume &sound_duration);
##our @EXPORT = qw(&valid_filename &message_store_size &add_user);
our @EXPORT_OK = qw();
our %EXPORT_TAGS = ();
#

############################################################### valid_filename
### Returns a true value if its' only argument is of the correct form
### an OpenUMS message filename.  Returns false otherwise.  And yes, the
### comment block is five times longer than the code :p
###
### Note: Currently does no checking to see if the embedded date/time value
### makes sense (ie, 13/32/1900 at 25:61:62), is chronologically correct 
### (ie, April 31st), or causality challenged (ie timestamp is later than 
### current date).
###
### Note: Does no checking for valid extension or port number.
sub valid_filename($)
{
  my $filename = shift;
  return($filename =~ /^\d+_20\d{12}_\d{2}\.vox$/);
};


############################################################ invalid_base64)
### The decode_base64 sub is pretty stupid.  We have to remove leading
### and trailing lines (typically MIME headers, boundaries and whitespace)
### before calling it or we won't get back the original file.
sub invalid_base64($)
{
  my $line = shift;
                                                                                
  return( ($line =~ /^--/)
        || ($line =~ /^Content-/)
        || ($line =~ /^\s*$/) );
}


######################################################## message_store_size($)
### Given the database handle and an extension, returns the size of that
### user's disk message store (in K) or undef on an error.  Note that this
### size is slightly incorrect due links and such, but it ought to be good
### enough for our purposes.
sub message_store_size($)
{
  my $extension = shift;

  my $storedir = BASE_PATH . USER_PATH . "$extension/messages";

  return(undef) unless ( (-d $storedir) && (-r $storedir) );

  opendir(DIR, $storedir);
  my @files = readdir DIR;
  closedir(DIR);

  my $size = 0;
  foreach my $file (@files)
    {
      next if (-l "$storedir/$file");
      $size += 4 * ceil( (-s "$storedir/$file")/4096 );
    }
  return($size);
}


#################################
## sub create_user
#################################
sub create_user 
{
  ## like add_user but for the web interface
  my $dbh = shift;
  my $user_info = shift ; 
  my $extension = $user_info->{extension}; 
  if (OpenUMS::DbQuery::validate_mailbox($dbh, $extension, 1)) {
      
     return(0,"There is already a User record for extesion $extension. Make sure you look at inactive accounts as well as active before adding. ") ; 
  } 
  
  print STDERR " common create_user called $extension \n";
  return(0,"No Extension Specified") unless $extension =~ /^\d+$/;

  print STDERR " checking permission\n" ;

  my $full_user_path = BASE_PATH . USER_PATH;
  ## do exaustive checks of directory permissions...
  print STDERR "checking $full_user_path: " ;
  if ((-e $full_user_path)  ) {
     print STDERR "-e:yes, " ;
  }  else { 
     return(0,"$full_user_path does not exist, please contact comtel ASAP" ); 
  }

  if ((-d $full_user_path ) ) {
     print STDERR "-d:yes, " ;
  } else { 
     return(0,"$full_user_path is not a directory, please contact comtel ASAP" ); 
  } 

  if (-w $full_user_path) {
     print STDERR "-w:yes, " ;
  } else { 
     return(0,"$full_user_path is not writeable, please contact comtel ASAP" ); 
  } 

  if (-x $full_user_path) {
     print STDERR "-x:yes !" ;
  }  else { 
     return(0,"$full_user_path is not executable, please contact comtel ASAP" ); 
  } 

  ## Attempt to create the user directory
  my $new_user_dir = $full_user_path . $extension ; 
  if (!(-e "$full_user_path$extension")) { 
    umask 002; 
    return(0,"Could not make user dir") unless mkdir("$new_user_dir",0775);
    return(0,"Could not create user greeting dir") unless mkdir("$new_user_dir/greetings",0775);
    return(0,"Could not create user message dir") unless mkdir("$new_user_dir/messages",0775);
    umask 022;
    print STDERR " $new_user_dir directory created\n";
  }  else {
    print STDERR " huh? $new_user_dir already exists...\n";
    ## well, let's make sure the 'greetings' and 'messages' dirs are there...
    umask 002; 
    if (!(-e "$new_user_dir/greetings") ) { 
       return (0,"Could not create user greeting dir") unless mkdir("$new_user_dir/greetings",0775);
       print STDERR " $new_user_dir/greetings directory created\n";
    } 
    if (!(-e "$new_user_dir/messages") )  {
       return(0,"Could not create user message dir") unless mkdir("$new_user_dir/messages",0775);
       print STDERR " $new_user_dir/messages directory created\n";
    } 
    umask 022;
  } 

  print STDERR " created $full_user_path$extension \n";

  $user_info->{phone_keys_first_name} = OpenUMS::DbUtils::get_phone_keys ($user_info->{first_name} );
  $user_info->{phone_keys_last_name}  = OpenUMS::DbUtils::get_phone_keys ($user_info->{last_name} );

  $user_info->{password} = $extension;
  if (!$user_info->{email_server_address} ) { 
     $user_info->{email_server_address} = DEFAULT_EMAIL_SERVER ;
  } 
  if (!$user_info->{email_password} ) { 
     $user_info->{email_password} = DEFAULT_EMAIL_PASSWORD ;
  } 
  my $sql = qq {INSERT VM_Users(extension, first_name, last_name,
                                email_address, password, transfer, 
                                phone_keys_first_name, phone_keys_last_name,
                                email_server_address, email_user_name, email_password, 
                                mobile_email, active,email_delivery,vstore_email,auto_login_flag,mwi_flag,new_user_flag )
                VALUES ( } ;
 $sql .= "$user_info->{extension}  , " ;  
 $sql .= $dbh->quote($user_info->{first_name}) . "  , " ;  
 $sql .= $dbh->quote($user_info->{last_name}) . "  , " ;  
 $sql .= $dbh->quote($user_info->{email_address}) . "  , " ;  
 $sql .= " PASSWORD('$user_info->{password}')  , " ;  
 $sql .= $dbh->quote($user_info->{transfer}) . "  , " ;  
 $sql .=  $dbh->quote($user_info->{phone_keys_first_name}) .  ", " ;  
 $sql .=  $dbh->quote($user_info->{phone_keys_last_name}) . ", " ;  
 $sql .= $dbh->quote($user_info->{email_server_address}) . "  , " ;  
 $sql .= $dbh->quote($user_info->{email_user_name}) . "  , " ;  
 $sql .= $dbh->quote($user_info->{email_password}) . " ,  " ;  
 $sql .= $dbh->quote($user_info->{mobile_email}) . "  , " ;  
 $sql .= $dbh->quote($user_info->{active}) . "  , " ;  
 $sql .= $dbh->quote($user_info->{email_delivery}) . "  , " ;  
 $sql .= $dbh->quote($user_info->{vstore_email}) . "  , " ;  
 $sql .= $dbh->quote($user_info->{auto_login_flag}) . "  , " ;  
 $sql .= $dbh->quote($user_info->{mwi_flag}) . "  , " ;  
 $sql .= $dbh->quote($user_info->{new_user_flag}) . "  ) " ;

  $dbh->do($sql);
  print STDERR " created VM_Users record for $extension \n";

  return (1,"User created for extension $user_info->{extension}");  

}

############################################################### add_user($$$$)
### Creates directory structure and database entry with default fields
### for a new user.  Routine should be called from script running
### as user openums.  Doesn't do enough error checkign.
  


sub add_user($$$$)
{
  my $dbh = shift;
  my $extension = shift;
  my $name_first = shift;
  my $name_last = shift;

  return(undef) unless $extension =~ /^\d+$/;

  return(undef) unless ( (-e BASE_PATH) && (-d BASE_PATH) 
                        && (-w BASE_PATH) && (-x BASE_PATH) );
  my $full_user_path = BASE_PATH . USER_PATH;
  print STDERR " full_user_path $full_user_path\n"; 
  return(0,'User directories do not exists') unless ( (-e $full_user_path) && (-d $full_user_path) 
                        && (-w $full_user_path) && (-x $full_user_path) );
  return(0, 'User directory already exists') if (-e "$full_user_path$extension");
  umask 002;
  return(0,"Could not make $full_user_path$extension directory") unless mkdir("$full_user_path$extension");
  return(0,"Could not make $full_user_path$extension/greetings' directory") unless mkdir("$full_user_path$extension/greetings");
  return(0,"Could not make '$full_user_path$extension/messages' directory" ) unless mkdir("$full_user_path$extension/messages");
  umask 022;

  my ($email_user_name, $email_address, $phone_keys_first_name, $phone_keys_last_name) ; 
#  if ($name_first) { 
#     $email_user_name = substr($name_first, 0, 1) . $name_last;
#     $email_address = "";
#     $phone_keys_first_name = OpenUMS::DbUtils::get_phone_keys ($name_first);
#     $phone_keys_last_name = OpenUMS::DbUtils::get_phone_keys ($name_last);
# }
    my $password = $extension;
    my $email_server = DEFAULT_EMAIL_SERVER;
    my $email_password = DEFAULT_EMAIL_PASSWORD;

  my $sql = qq{INSERT VM_Users(extension, first_name, last_name, 
                                email_address, password,
                                phone_keys_first_name, phone_keys_last_name,
                                email_server_address, email_user_name, email_password,new_user_flag,active,transfer)
                VALUES ('$extension', '$name_first', '$name_last',
                        '$email_address', PASSWORD('$password'),
                        '$phone_keys_first_name', '$phone_keys_last_name',
                        '$email_server', '$email_user_name', '$email_password',1,1,1)};
  return(0,"User insert failed : '$sql' " ) unless $dbh->do($sql); 

  return(1, "User created" );
}


################################################################ sweep_old($$)
### This sub removes old (older than DAYS_KEPT) X-CPVoicemails from a
### user's email inbox.  Probably not useful in real life - provided as
### sample code only.
### BE CAREFUL!  DO YOU REALLY WANT TO CALL THIS SUB?
use constant   DAYS_KEPT  =>  -10;  ### Days to keep X-CTVoicemails in email
sub sweep_old($$)
{
  my $dbh = shift;
  my $extension = shift;
                                                                                
  my $imap = open_email_connection($dbh, $extension);
  return unless defined($imap);
                                                                                
  ### The IMAP server expects a date of the form 01-Apr-1999
  my ($yr,$mo,$dy) = Add_Delta_Days(Today(), DAYS_KEPT);
  my $oldday = sprintf("%2d-%.3s-%d", $dy, Month_to_Text($mo), $yr);
                                                                                
  $imap->select("inbox");
  foreach my $uid ($imap->search(
                   "HEADER X-CPVoicemail wav BEFORE $oldday NOT DELETED"))
    {
       my $message = $imap->parse_headers($uid, "X-CPVoicemail");
       my $file = $message->{"X-CPVoicemail"};
       next unless(valid_filename($file));
                                                                                
       $imap->set_flag("\\Seen", $uid);
       unless (defined($imap->move("Deleted Items", $uid)))
         {
           warn("Unable to move email with $file to Deleted Items : $@\n");
           next;
         }
       my $result = $imap->delete_message($uid);
       unless ($result == 1)
         {
           warn("Unexpected result ($result) from delete_message: $@\n");
         }
    }
  $imap->close();
}



#################################
## sub get_dbh
#################################
sub get_dbh 
{
  my $db_name = shift; 
  use DBI;
  $db_name = DB_NAME if (!$db_name); 

  my $dsn = "DBI:mysql:database=$db_name;host=localhost";
  my $user = DB_USER; 
  my $password = DB_PASS; 
  my $dbh = DBI->connect($dsn, $user, $password);
  return $dbh ; 
}

#################################
## sub is_phone_input
#################################
sub is_phone_input 
{
  ## this checks to make sure it's 1, 2, ,3, ,4, ,5 ,6 ,7 ,8 ,8,10,* or #
  ## returns 1 if it is
  ## returns 0 if it's not!
  my $in =  shift ;
  if (!defined($in) ) { 
    return 0 ;
  } 
  if  ($in =~ /([0-9]|#|\*)+/) {
     return 1;
  }  else {
    return 0 ;
  }

}

#################################
## sub port_reboot
#################################
sub port_reboot 
{
  my $port = shift;
  $port -= 1200;
  my ($remote_host,$remote_port) = ("localhost", 1198) ;

  my $socket = IO::Socket::INET->new(PeerAddr => $remote_host,
                                     PeerPort => $remote_port,
                                     Proto    => "tcp",
                                     Type     => SOCK_STREAM);

  if (! $socket) {
    $log->debug("Common::port_reboot Couldn't connect to $remote_host:$remote_port : $@\n");
    return 0;
  }

  ### Try up to 5 resets.
  for (my $i=1; $i<=5; $i++) {
    $log->debug("Common::port_reboot Sending reset #$i to port $port\n");
    print $socket "cmd=portreset dst=$port src=-2 argc=1\n";
    print $socket "cmd=portstatus dst=-2\n";
    my $j = 0;
    while ( ($j <=MAX_PORTS-1) && (defined($socket)) && ($_ = <$socket>) ) {
      my ($pstring, $port_no, $status) = split;
      $log->debug("$pstring, $port_no, $status\n");
      if ($port_no == $port) {
        if ($status eq "WaitingForConnection") {
          return($i);
        }
      }
      $j++;
    }
    sleep(1);
  }
  return(0);
}


#################################
## sub count_sound_gen
#################################
sub count_sound_gen {
  ## this one took a mathemcatical genius to write..
  my $num = shift;
  my $card_flag = shift;
  my $ret_sound = "";
 
  my $tens;
  my $hundreds;
  my @files;
  my $all;
  unless ($num) {return undef};
  if ($num == 0) { push(@files, $num); }
     my $thousands = int($num/1000) * 1000;
     $num = $num - $thousands;
     if ($thousands != 0) {
       my $rem = $thousands/1000;
       push(@files, $rem);
       push(@files, "1000");
     }

     $hundreds = int($num/100) * 100;
     $num = $num - $hundreds;
     if ($hundreds != 0) {
        my $rem = $hundreds/100;
        push(@files, $rem);
        push(@files, "100");
     }
                                                                                                                             
     $tens = int($num/10) * 10;

     if ($num > 20) {
         $num = $num - $tens;
         if ($tens != 0) { push(@files, $tens); }
     }
     if ($num != 0) { push(@files, $num); }
     my $num_files  = scalar(@files) ; 
     for (my $i =0; $i < $num_files ; $i++) {
        if ($i != 0 ) { 
           $ret_sound .= " " ; 
        } 
        $ret_sound .= PROMPT_PATH . $files[$i]  ; 
        if ($card_flag && ($i == ($num_files - 1) ) ) {
          $ret_sound .= "card"  ; 
        } 
        $ret_sound .= ".vox"; 
     } 
  return $ret_sound;
}
sub get_no_greeting_sound {
  my $ext = shift; 
  my $sound = PROMPT_PATH . "imsorry.vox "  ; 
  $sound .= PROMPT_PATH . "extension.vox"; 
  my $ext_sound = OpenUMS::Common::ext_sound_gen($ext ); 
  if ($ext_sound ) {
    $sound .= " $ext_sound"; 
  } 
  $sound .= " " . PROMPT_PATH . "doesnotanswer.vox"; 
  return $sound ; 
}


#################################
## sub ext_sound_gen
#################################
sub ext_sound_gen {
  my $ext = shift ;   
  my $len = length($ext); 

  my @sounds ; 
  for (my $i = 0; $i < $len; $i++ ) {

    my $num = substr($ext, $i, 1 ); 
    my $num_file = PROMPT_PATH . $num . ".vox"; 
    push @sounds, $num_file; 
  }  

  my $fin_sound = join(" ", @sounds); 
  return $fin_sound ; 
} 



#################################
## sub get_timestamp
#################################
sub get_timestamp {
  use Date::Calc;
  my  ($year, $month, $day, $hour, $min, $sec) =  Date::Calc::Today_and_Now();
  my $timestamp = sprintf("%04d%02d%02d%02d%02d%02d", $year, $month, $day, $hour, $min, $sec);
  $timestamp =~ /^(\d{14})$/;
  return $1;
}


#################################
## sub get_ip
#################################
sub get_ip {
  my $interface="eth0";
  # path to ifconfig
  my $ifconfig="/sbin/ifconfig";
  my @lines=qx|$ifconfig $interface| or die("Can't get info from ifconfig: ".$!);
  foreach(@lines){
        if(/inet addr:([\d.]+)/){
                return "$1";
        }
  }
}
#################################
## sub get_password_url()
##  generates a secure password URL for to e-mail to the user
##  is not fully hack proof.
#################################
sub get_password_url($$){
  my ($dbh, $extension) = @_;
#  use Digest::MD5 qw(md5_base64);
#  my  $md5_extension = md5_base64($extension); 

  my $sql = qq{SELECT PASSWORD(extension), password 
              FROM VM_Users WHERE extension = $extension} ; 
  my $sth = $dbh->prepare($sql);
  $sth->execute(); 
  my ($ext_enc, $pw_enc) = $sth->fetchrow_array(); 

  my $IP = OpenUMS::Common::get_ip();  
  my $url  = "https://$IP/cgi-bin/password.cgi?p1=" . $ext_enc . "&p2=" . $pw_enc  ; 
  
  return $url; 
 
} 
#################################
## sub get_callout_url($)
##  generates a the callout url for the user 
#################################


sub get_callout_url($) {
  my $message_file = shift ; 
  my $IP = OpenUMS::Common::get_ip();
  my $url  = "https://$IP/cgi-bin/callout.cgi?message_file=" . $message_file  ;
                                                                                                                                               
  return $url;
}


############################################################### trim_file($$$)
sub trim_file($$$)
{
  my $outfile = shift;
  my $in_file = shift;
  my $secs = shift;

  if ($in_file =~ /\.wav$/)
    { return(&trim_wav($outfile, $in_file, $secs)); }
  elsif ($in_file =~ /\.vox/)
    { return(&trim_vox($outfile, $in_file, $secs)); }

  return(undef);
}

################################################################# trim_wav($$)
### sub arguments are a input file to trim, output file and number of
###  seconds to trim off the beginning
###
sub trim_wav ($$$)
{
  my $outwav = shift;
  my $in_file = shift;
  my $secs = shift;
  my $bool = system("sox $in_file $outwav trim $secs"); 
  return $bool
}

################################################################# trim_vox($$)
### sub arguments are a input file to trim, output file and number of
###  seconds to trim off the beginning
###
sub trim_vox ($$$)
{
  my $outvox = shift;
  my $in_file = shift;
  my $secs = shift;

  return(undef) unless (my $temp = &vox_to_sw($in_file));
  $temp =~ s/\.sw$//;
  system("/usr/bin/sox -r8000 $temp.sw -r8000 $temp-trim.sw trim $secs");
  system("/usr/local/bin/vox -b16 $temp-trim.sw $outvox");
  unlink("$temp.sw");
  unlink("$temp-trim.sw");

  return ( (-e $outvox) && (-r $outvox) );
}


sub comtel_record  {
  my $ctport = shift ; 
  my $file = shift;
  my $timeout = shift;
  my $term_digits = shift;
  my $silence_timeout = shift;
  my $no_beep_flag = shift;
  # my $temphandle = new File::Temp(UNLINK => 1, SUFFIX => '.wav', DIR=>BASE_PATH . TEMP_PATH);

#   my $tempfilename = $temphandle->filename;

    $ctport->record($file, $timeout , $term_digits, $silence_timeout, $no_beep_flag);
    return ; 

#  $log->debug("VT_CARD_TYPE is " . VT_CARD_TYPE ); 
#
#  if (VT_CARD_TYPE  eq 'OPENSWITCH') { 
#    OpenUMS::Common::trim_wav("$tempfilename", "$file", '0.171');
#    my $cmd = "cp --force $tempfilename $file" ; 
#    $log->debug("gonna $cmd " ); 
#    system("$cmd"); 
#    sleep 5; 
#  } 
#
#  return ;
}


################################################################## cat_wav($$)
### sub arguments are a target filename, and a reference to an array of
### wav filenames.  cat_wav concatenates the wav files into the target
### wavfile, returning the target filename on success or undef on failure
### Note, that cat_wav is perfectly happy creating or concatinating
### empty files.
sub cat_wav ($$)
{
  my $outwav = shift;
  my $files_aref = shift;
                                                                                
  ### This is the native output format of the Voicetronix boards.
  my $details = { 'bits_sample' => 8, 'sample_rate' => 8000, 'channels' => 1 };
  use Audio::Wav ; 
  use File::Temp ; 
  my $wav = new Audio::Wav;
                                                                                
  return(undef) unless (defined($files_aref));
                                                                                
  ### Open a temp file for writing.
  my $temphandle = new File::Temp(UNLINK => 1, SUFFIX => '.wav');
  my $tempname = $temphandle->filename;
  my $write = $wav->write($tempname, $details);

  foreach my $file (@$files_aref)
    {
      next unless ( (-e $file) && (-r $file) );

      my $handle = new File::Temp(UNLINK => 1, SUFFIX => '.wav');
      my $soxout = $handle->filename;
      system("/usr/bin/sox -U $file -u $soxout");
      $log->debug("Common::cat_wav is appending $file to $tempname");

      my $read = $wav->read($soxout);
      my $buffer = $read->length();
      my $data = $read->read_raw($buffer);
      $write->write_raw($data, $buffer);
    }

  $write->finish();

  ### tiny race condition!
  if ( (-e $outwav) && (!(-f $outwav) || !(-w $outwav)) )
    { 
      $log->err("Common::cat_wav is unable to write the concatinated file as $outwav"); 
      return(undef);
    }

  $log->debug("Common::cat_wav is returning concatinated file as $outwav");
  my $test = system("/usr/bin/sox -u $tempname -U $outwav");
  return($outwav) unless ($test >> 8);
  return(undef);
}


################################################################## cat_vox($$)
### sub arguments are a target filename, and a reference to an array of
### vox filenames.  cat_vox concatenates the vox files into the target
### voxfile, returning the target filename on success or undef on failure
### Note, that cat_wav is perfectly happy creating or concatinating
### empty files.
sub cat_vox ($$)
{
  my $outvox = shift;
  my $files_aref = shift;

  unless ($outvox =~ /(.+\.vox$)/ )
    {
      $log->err("Cat_vox called with bad target name.");
      return(undef);
    }
  $outvox = $1;

  unless (defined($files_aref))
    {
      $log->debug("Cat called without files");
      return(undef);
    }

  my $temp = new File::Temp(UNLINK => 1,
                            SUFFIX => '.vox',
                            DIR=>BASE_PATH . TEMP_PATH);
  unless(open(OUTFILE, ">$temp"))
    {
      $log->debug("Cat Unable to open $temp for output");
      return(undef);
    }

  foreach my $file (@$files_aref)
    {
      next unless ( (-e $file) && (-r $file) );
      next unless (open(INFILE, "<$file"));
      binmode(INFILE);
      while(<INFILE>)
        { print(OUTFILE $_); }
      close(INFILE);
    }
  close(OUTFILE);

  unlink($outvox);
  copy($temp, $outvox);
  $log->debug("Common::cat_vox is returning concatinated file as $outvox");
  return($outvox);
}


#################################
## sub validate_message()
#################################

sub validate_message {
  my $message_file = shift ; 
  my $tmpfile  = BASE_PATH . TEMP_PATH . $message_file ;
  my ($retval, $msg); 
  $log->debug("[Common.pm] validate_mesage : $tmpfile" ); 
  if ( (-e $tmpfile) && (-r $tmpfile)  )  {
     my $fileduration =  OpenUMS::Common::file_duration($message_file, BASE_PATH . TEMP_PATH); 
     $log->debug("[Common.pm] validate_mesage : Message File duration is $fileduration sec" );

     if ( $fileduration > $main::GLOBAL_SETTINGS->get_var('MIN_MESSAGE_LENGTH') ) {
          $retval = 1; 
     } else {
        $retval =0; 
        $msg = 'MIN';
     }
  } else {
     $retval = 0; 
     $msg = 'NOFILE'; 
  }  
  return ($retval, $msg); 
}

#################################
## sub file_duration()
## based on size, tries to estimate how many secs
## the sound is...
#################################

sub file_duration {
  my ($file, $path) = @_ ; 
  my $file_duration = &sound_duration("$path$file");
  ## alwasy round...

  $file_duration = int($file_duration + 0.5);
  return $file_duration ; 
}


############################################################# adjust_volume($)
### adjust_volume of file "in place"
sub adjust_volume($)
{
  my $infile = shift;

  $log->debug("Checking volume of $infile");

  if ($infile =~ /\.wav$/)
    { &adjust_wav($infile); }
  elsif ($infile =~ /\.vox$/)
    { return; &adjust_vox($infile); }
  else
    { $log->err("Unknown file type!"); }

}

############################################################### adjust_wav($)
sub adjust_wav
{
  my $infile = shift;

  open(VOLUME, "/usr/bin/sox $infile -e stat -v 2>&1 |");
  my $volume = <VOLUME>;
  close(VOLUME);

  chomp($volume);
  $volume =~ /^([\d\.]+)$/;
  $volume = $1;

  $volume = 15.0 if ($volume >= 15.0);
  $log->debug("Volume adjustment = $volume");
  if ( defined($volume) && ($volume > 1.000) )
    {
      $log->debug("Boosting volume by $volume");
  
      my $handle = new File::Temp(UNLINK => 1, SUFFIX => '.wav');
      my $soxout = $handle->filename;
  
      system("/usr/bin/sox -v $volume $infile $soxout");
      if ( (-e $soxout) && (-r $soxout) )
        {
          unlink($infile);
          copy($soxout, $infile);
        }
    }
}

############################################################### adjust_vox($)
sub adjust_vox
{
  my $infile = shift;

  my $temp = vox_to_sw($infile);

  $log->debug("Soxing $temp");
  open(VOLUME, "/usr/bin/sox $temp -e stat -v 2>&1 |");
  my $volume = <VOLUME>;
  close(VOLUME);

  chomp($volume);
  $volume =~ /^([\d\.]+)$/;
  $volume = $1;

  $volume = 15.0 if ($volume >= 15.0);
  $log->debug("Volume adjustment = $volume");

  if ( defined($volume) && ($volume > 1.000) )
    {
      $log->debug("Boosting volume by $volume");

      my $handle = new File::Temp(UNLINK => 1, SUFFIX => '.sw');
      my $soxout = $handle->filename;

      system("/usr/bin/sox -v $volume $temp $soxout");
      if ( (-e $soxout) && (-r $soxout) )
        {
          unlink($infile);
          copy(sw_to_vox($soxout), $infile);
        }
    }
}


################################################################# sw_to_vox($)
# Convert a sw (raw Signed Word) file to vox.
sub sw_to_vox($)
{
  my $infile = shift;

  unless($infile =~ /\.sw$/)
    { return(undef); }

  $infile =~ s/\.sw//;

  if (-e "$infile.vox")
    { unlink("$infile.vox"); }

  $log->debug("Converting $infile.sw to .vox");
  $log->debug("/usr/local/bin/vox -b16 $infile.sw $infile.vox");
  system("/usr/local/bin/vox -b16 $infile.sw $infile.vox");

  unless ( (-e "$infile.vox") && (-r "$infile.vox") )
    { return(undef); }

  return("$infile.vox");
}

################################################################# vox_to_sw($)
# Convert a vox to sw (raw Signed Word)
sub vox_to_sw($)
{
  my $infile = shift;

  unless($infile =~ /\.vox$/)
    { return(undef); }

  $infile =~ s/\.vox$//;

  if (-e "$infile.sw")
    { unlink("$infile.sw"); }

  $log->debug("Converting $infile.vox to .sw");
  system("/usr/local/bin/devox -b16 $infile.vox $infile.sw");

  unless ( (-e "$infile.sw") && (-r "$infile.sw") )
    { return(undef); }

  $log->debug("Returning $infile.sw");
  return("$infile.sw");
}

################################################################# sw_to_wav($)
# Convert an sw file to wav
sub sw_to_wav($)
{
  my $infile = shift;

  unless($infile =~ /\.sw$/)
    { return(undef); }

  $infile =~ s/\.sw//;

  if (-e "$infile.wav")
    { unlink("$infile.wav"); }

  $log->debug("Converting $infile.sw to .wav");
  system("/usr/bin/sox -r8000 $infile.sw -r8000 $infile.wav");

  unless ( (-e "$infile.wav") && (-r "$infile.wav") )
    { return(undef); }

  return("$infile.wav");
}

################################################################# wav_to_sw($)
# Convert a wav file to sw
sub wav_to_sw($)
{
  my $infile = shift;

  unless($infile =~ /\.wav$/)
    { return(undef); }

  $infile =~ s/\.wav//;

  if (-e "$infile.sw")
    { unlink("$infile.sw"); }

  $log->debug("Converting $infile.wav to .sw");
  system("/usr/bin/sox $infile.wav -r8000 $infile.sw");

  unless ( (-e "$infile.sw") && (-r "$infile.sw") )
    { return(undef); }

  return("$infile.sw");
}

################################################################ wav_to_vox($)
# Convert a wav file to vox
sub wav_to_vox($)
{
  my $infile = shift;

  unless($infile =~ /\.wav$/)
    { return(undef); }

  $infile =~ s/\.wav//;

  if (-e "$infile.vox")
    { unlink("$infile.vox"); }

  my $tempf = new File::Temp(UNLINK => 1, SUFFIX => '.sw', DIR=>"/tmp");
  my $tempn = $tempf->filename;

  system("/usr/bin/sox $infile.wav -r8000 $tempn");
  system("/usr/local/bin/vox -b16 $tempn $infile.vox");

  unless ( (-e "$infile.vox") && (-r "$infile.vox") )
    { return(undef); }

  return("$infile.vox");
}

################################################################ vox_to_wav($)
# Convert a vox to wav
sub vox_to_wav($)
{
  my $infile = shift;

  $log->debug("converting $infile to wav");

  unless($infile =~ /\.vox$/)
    { return(undef); }

  $infile =~ s/\.vox//;

  if (-e "$infile.wav")
    { unlink("$infile.wav"); }

  my $tempf = new File::Temp(UNLINK => 1, SUFFIX => '.sw', DIR=>"/tmp");
  my $tempn = $tempf->filename;

  system("/usr/local/bin/devox -b16 $infile.vox $tempn");
  system("/usr/bin/sox -r8000 $tempn -r8000 $infile.wav");

  $log->debug("Done soxing to $infile.wav");

  unless ( (-e "$infile.wav") && (-r "$infile.wav") )
    { return(undef); }

  return("$infile.wav");
}

############################################################ sound_duration($)
sub sound_duration($)
{
  my $file = shift;

  $log->debug("Getting duration of $file");
  if ($file =~ /\.wav/)
    { return( (-s $file)/WAV_BITRATE); }
  elsif ($file =~ /\.vox/)
    { return( (-s $file)/VOX_BITRATE); }

  $log->err("Unknown sound file type.");
}


########################################################### signal_delivermail
sub signal_delivermail
{
  unless (-e OPENUMS_DELIVERPID)
    {
      $log->err("Delivermail lock file does not exist!");
      return(undef);
    }

  unless (open(FILE, "<" . OPENUMS_DELIVERPID))
    {
      $log->err("Unable to access delivermail lock file : $!");
      return(undef);
    }

  my $pid = <FILE>;
  chomp $pid;
  close(FILE);

  ### Explicitly untaint $oldpid.  It must contain a postive integer only
  unless ($pid =~ /^([0-9]+)$/) 
    {
      $log->err("Delivermail lock file contains an invalid value.");
      return(undef);
    }
  $pid = $1;

  unless (kill 0 => $pid)
    {
      $log->err("Unable to signal delivermail : $!");
      return(undef);
    }

  kill 'USR1' => $pid;
}


####################################################################### REAPER
sub REAPER
{
  my $stiff;
  1 until (waitpid(-1, &WNOHANG) == -1);
  $SIG{CHLD} = \&REAPER;
}

sub ser_to_extension {
  my ($dbh, $ser_from ) =@_;
                                                                                                                                               
  $ser_from =~ s/^<sip://g;
  $ser_from =~ s/>$//g;
  print "$ser_from\n";
                                                                                                                                               
  my ($user,$domain) = split('@',$ser_from);
  print "$user $domain\n";
  $dbh->do(" use ser");
  my $sql = qq{SELECT extension FROM subscriber WHERE username ='$user' AND domain = '$domain'};
  my $arr = $dbh->selectrow_arrayref($sql);
  my $ext = $arr->[0];
  print "$sql\n";
  $dbh->do("use voicemail");

  return  $ext;
}


1; 
