package OpenUMS::Greeting;
### $Id: Greeting.pm,v 1.2 2004/07/31 20:27:05 kenglish Exp $
# Greeting.pm
#
# Greets
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
use OpenUMS::Config; 
use OpenUMS::Common; 

sub user_is_on_vacation {
  my ($dbh, $extension)  = @_; 
  return 0 if (!$extension); 
  my $sql = qq{SELECT extension FROM vacations
      WHERE extension = ?
      AND begin_date <= NOW()
      AND dayback_date > NOW()};
  my $sth =  $dbh->prepare($sql);
  $sth->execute($extension);
  my $ext_to_check = $sth->fetchrow();
  $sth->finish();


  if ($ext_to_check eq $extension) {
     return 1; 
  } else {
     return 0; 
  }
}
sub get_no_greeting_sound {
  my $ext = shift;
  my $sound = PROMPT_PATH . "imsorry.wav "  ;
  $sound .= PROMPT_PATH . "extension.wav";
  my $ext_sound = OpenUMS::Common::ext_sound_gen($ext );
  if ($ext_sound ) {
    $sound .= " $ext_sound";
  }
  $sound .= " " . PROMPT_PATH . "doesnotanswer.wav";
  return $sound ;
}

sub get_greeting_sound {
  my ($dbh, $ext ) = @_ ; 
  if (!$ext) {
    return PROMPT_PATH . "invalid_mailbox.wav"; 
  } 

  if (OpenUMS::Greeting::user_is_on_vacation($dbh,$ext) ) {

     my $ret_sound ; ##= PROMPT_PATH . "imsorry.wav" ; 
     my $name_sound = OpenUMS::Greeting::get_name_sound($dbh, $ext);
     my $dayback_sound = OpenUMS::Greeting::get_dayback_sound($dbh,$ext); 
     $ret_sound .= "$name_sound " . PROMPT_PATH . "out_of_office_until.wav $dayback_sound ". PROMPT_PATH . "record_message_after_tone.wav";   
     return $ret_sound ; 
  }  else {
     my ($greeting_wav_file, $greeting_wav_path) = OpenUMS::Greeting::get_current_greeting_file($dbh,$ext) ; 
     if (!$greeting_wav_file) {
       return OpenUMS::Greeting::get_no_greeting_sound($ext);    
     } else { 
       return "$greeting_wav_path$greeting_wav_file"; 
     }
  } 
  return "hi";
}
sub get_name_sound {
  my ($dbh, $ext) =  @_;
  my $sql = qq{SELECT name_wav_file, name_wav_path
               FROM VM_Users
               WHERE extension = $ext};
  my $sth = $dbh->prepare($sql);
  $sth->execute();
                                                                                                                             
  my ($name_vox_file, $name_vox_path ) = ("","");
  ($name_vox_file, $name_vox_path) = $sth->fetchrow_array();
 
  $sth->finish();
  if ($name_vox_file) { 
     return "$name_vox_path$name_vox_file";
  } else {
    my $name_sound  = PROMPT_PATH . "extension.vox";
    $name_sound .=  " " .  OpenUMS::Common::ext_sound_gen($ext); 
     return $name_sound ;
  } 
}
sub get_dayback_sound {
   my ($dbh, $ext) = @_ ; 
   my ($bdatedb, $edatedb) =  OpenUMS::Greeting::vacation_dates($dbh,$ext);
     my ($eyear,$emonth, $eday) = split(/-/,$edatedb);
     ## get the year, maybe we shouldn't play this
     my $year_sound = OpenUMS::Common::count_sound_gen($eyear) ;
     use Date::Calc;
     ## get the day name
     my $dow = Date::Calc::Day_of_Week($eyear,$emonth,$eday);
     my $dow_sound  = Date::Calc::Day_of_Week_to_Text($dow);
     $dow_sound = PROMPT_PATH . $dow_sound . ".vox";
                                                                                                                             
     ## get the month name
     my $month_sound = Date::Calc::Month_to_Text($emonth);
     $month_sound = PROMPT_PATH . lc($month_sound) . ".vox";
                                                                                                                             
     ## get the day in cardinal form
     my $day_sound = OpenUMS::Common::count_sound_gen($eday,1);
     my $final_sound = "$dow_sound $month_sound $day_sound";
     return $final_sound; 



}
#####################################
## sub vacation_dates
#####################################
sub vacation_dates {
  my ($dbh, $ext ) = @_ ; 
  my $sql = qq{SELECT begin_date, dayback_date FROM vacations where extension = ? };
  my $sth = $dbh->prepare($sql);
  $sth->execute($ext) ;
  my ($bdatedb, $edatedb) = $sth->fetchrow_array();
  $sth->finish(); 
  return  ($bdatedb, $edatedb) ; 
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
               AND current_greeting = 1
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
sub get_current_greeting_file {
  my ($dbh, $ext) =  @_;
  my $sql = qq{SELECT greeting_wav_file, greeting_wav_path
               FROM VM_Greetings
               WHERE extension = $ext and current_greeting = 1 };
  my $sth = $dbh->prepare($sql);
  $sth->execute();
                                                                                                                             
  my ($greeting_vox_file, $greeting_vox_path) = ("","");
  ($greeting_vox_file, $greeting_vox_path) = $sth->fetchrow_array();
  $sth->finish();
  return  ($greeting_vox_file, $greeting_vox_path);
}


1;
