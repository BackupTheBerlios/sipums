package OpenUMS::Greeting;
### $Id: Greeting.pm,v 1.6 2005/03/12 01:15:50 kenglish Exp $
# Greeting.pm
#
# Handles logic for Greeting .
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
  my $sound = OpenUMS::Common::get_prompt_sound("imsorry")  ;
  $sound .= " " ;
  $sound .= OpenUMS::Common::get_prompt_sound("extension");
  my $ext_sound = OpenUMS::Common::ext_sound_gen($ext );
  if ($ext_sound ) {
    $sound .= " $ext_sound";
  }
  $sound .= " " . OpenUMS::Common::get_prompt_sound(  "doesnotanswer");
  return $sound ;
}

sub get_greeting_sound {
  my ($dbh, $ext ) = @_ ; 
  if (!$ext) {
    return OpenUMS::Common::get_prompt_sound("invalid_mailbox"); 
  } 

  if (OpenUMS::Greeting::user_is_on_vacation($dbh,$ext) ) {

     my $ret_sound ; ##= OpenUMS::Common::get_prompt_sound("imsorry") ; 
     my $name_sound = OpenUMS::Greeting::get_name_sound($dbh, $ext);
     my $dayback_sound = OpenUMS::Greeting::get_dayback_sound($dbh,$ext); 
     $ret_sound .= "$name_sound " .  OpenUMS::Common::get_prompt_sound("out_of_office_until") ;
     $ret_sound .= " $dayback_sound " . OpenUMS::Common::get_prompt_sound("record_message_after_tone");   
     return $ret_sound ; 
  }  else {
     my ($greeting_wav_file, $greeting_wav_path) = OpenUMS::Greeting::get_current_greeting_file($dbh,$ext) ; 
     if (!$greeting_wav_file) {
       return OpenUMS::Greeting::get_no_greeting_sound($ext);    
     } else { 
       return  $main::CONF->get_var('VM_PATH') . "$greeting_wav_path$greeting_wav_file"; 
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
                                                                                                                             
  my ($name_wav_file, $name_wav_path ) = ("","");
  ($name_wav_file, $name_wav_path) = $sth->fetchrow_array();
 
  $sth->finish();
  if ($name_wav_file) { 
     return $main::CONF->get_var('VM_PATH') . "$name_wav_path$name_wav_file";
  } else {
    my $name_sound  =  OpenUMS::Common::get_prompt_sound("extension");
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
     $dow_sound = OpenUMS::Common::get_prompt_sound($dow_sound);
                                                                                                                             
     ## get the month name
     my $month_sound = Date::Calc::Month_to_Text($emonth);
     $month_sound = OpenUMS::Common::get_prompt_sound(lc($month_sound) );
                                                                                                                             
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
