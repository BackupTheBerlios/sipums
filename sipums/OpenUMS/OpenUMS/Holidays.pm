package OpenUMS::Holidays;
### $Id: Holidays.pm,v 1.1 2004/07/20 02:52:15 richardz Exp $
#
# Holidays.pm
#
# Generates holiday dates
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

use Date::Calc qw(Today Today_and_Now Delta_Days);
use Date::Calendar;
use Date::Calendar::Profiles;

use OpenUMS::Config;
use OpenUMS::Log;


################################################################# use Exporter
use Exporter;

our @ISA = qw(Exporter);
our @EXPORT = qw(add_holidays);
our @EXPORT_OK = qw();
our %EXPORT_TAGS = ();

#############################################################################

my $Holidays =
  {
    "New Years Day"       => \&Date::Calendar::Profiles::US_New_Year,
    "MLK Day"             => "3/Mon/Jan",
    "Presidents Day"      => "3/Mon/Feb",
    "Kuhio Day"           => \&Kuhio_day,
    "Memorial Day"        => "5/Mon/May",
    "Kamehameha Day"      => \&Kamehameha_day,
    "Independence Day"    => \&Date::Calendar::Profiles::US_Independence,
    "Admissions Day"      => "3/Fri/Aug",
    "Labor Day"           => \&Date::Calendar::Profiles::US_Labor,
    "Columbus Day"        => "2/Mon/Oct",
    "Election Day"        => \&Date::Calendar::Profiles::US_Election,
    "Veterans Day"        => \&Date::Calendar::Profiles::US_Veteran,
    "Thanksgiving Day"    => "4/Thu/Nov",
    "Day After Thanksgiving"    => "4/Fri/Nov",
    "Boxing Day"          => "Dec/26",
    "Christmas Eve"       => "Dec/24",
    "Christmas Day"       => \&Date::Calendar::Profiles::US_Christmas,
    "Day After Christmas" => "Dec/26",
    "New Years Eve"       => "Dec/31"
  };

my $Holiday_Sounds =
  {
    "New Years Day"       => "new_years_day.vox", 
    "MLK Day"             => "martin_luther_king_junior_day.vox", 
    "Presidents Day"      => "presidents_day.vox", 
    "Kuhio Day"           => "kuhio_day.vox",
    "Memorial Day"        => "memorial_day.vox",
    "Kamehameha Day"      => "kamehameha_day.vox",
    "Independence Day"    => "independence_day.vox",
    "Admissions Day"      => "admissions_day.vox",
    "Labor Day"           => "labor_day.vox",
    "Columbus Day"        => "columbus_day.vox",
    "Election Day"        => "election_day.vox", ## add
    "Veterans Day"        => "veterans_day.vox", 
    "Thanksgiving Day"    => "thanksgiving_holiday.vox", 
    "Day After Thanksgiving"    => "thanksgiving_holiday.vox", 
    "Boxing Day"          => "christmas_holiday.vox",
    "Christmas Eve"       => "christmas_holiday.vox",
    "Christmas Day"       => "christmas_holiday.vox",
    "Day After Christmas" => "christmas_holiday.vox",
    "New Years Eve"       => "new_years_eve.vox"
  };



##################################
## sub get_next_holidays()
## returns a hash with human readable dates for each holiday... 
#################################
sub get_next_holidays {
  
  my ($today_year, $today_month,$today_day) = Today();
  my $calendar = Date::Calendar->new($Holidays);
#          next unless ($name eq $holiday);
  my %next_holidays ;  
  foreach my $holiday (keys %$Holidays)  { 
     $calendar->year($today_year);
     my @dates = $calendar->search($holiday); 
     $dates[0] =~ /^(\d{4})(\d{2})(\d{2})$/; 
     my ($h_year,$h_month,$h_day)  =  ($1,$2,$3);

     my $dd = Delta_Days($today_year, $today_month,$today_day,
                              $h_year,$h_month,$h_day);
     if ($dd < 0) {
        my $calendar_jr = Date::Calendar->new($Holidays);
        $calendar_jr->year($today_year + 1); ## get the one next year
        @dates = $calendar_jr->search($holiday); 
        $dates[0] =~ /^(\d{4})(\d{2})(\d{2})$/; 
        ($h_year,$h_month,$h_day)  =  ($1,$2,$3);
     } 
      my $dow = Date::Calc::Day_of_Week($h_year,$h_month,$h_day );
      my $dow_string = Date::Calc::Day_of_Week_Abbreviation($dow);
      $next_holidays{"$h_year-$h_month-$h_day"} =   $holiday; 
  }
  return \%next_holidays ; 

}


#################################
## sub add_holiday($$$$$$$$)
#################################
sub add_holiday($$$$$$$$)
{
  my $dbh = shift;
  my $holiday = shift;
  my $menu_id = shift;
  my $start_hour = shift;
  my $start_min = shift;
  my $end_hour = shift;
  my $end_min = shift;
  my $years = shift;
                                                                                                    
  my @today = Today();

   print STDERR "holiday=$holiday \n"; 
  
 # foreach my $name (keys %$Holidays) 
 #   {
    print STDERR "gonna add holiday $holiday \n"; 
 
      for (my $i=0 ; $i < $years ; $i++)
        {
          my $calendar = Date::Calendar->new($Holidays);
          $calendar->year($today[0] + $i);
          print STDERR "year = " . ($today[0] +$i) ."\n " ;
#          next unless ($name eq $holiday);
          my @dates = $calendar->search($holiday); # =~ /^(\d{4})(\d{2})(\d{2})$/;
          if (!scalar(@dates) ) { 
              return 0; 
          } 
          print STDERR "mydate=$dates[0] \n"; 

          $dates[0] =~ /^(\d{4})(\d{2})(\d{2})$/; 
          my $date =  "$1-$2-$3";
          print STDERR "mydate=$date \n"; 

          my $sql = qq{REPLACE holidays (holiday_date, holiday_name,
                                       start_hour, start_minute,
                                       end_hour, end_minute,
                                       menu_id) VALUES  ( }; 
          $sql .= $dbh->quote($date) . ", " . $dbh->quote($holiday) . "," ; 
          $sql .=" $start_hour, $start_min, $end_hour, $end_min, $menu_id) " ;
          print STDERR "sql=$sql\n"; 

          $dbh->do($sql);

        }
#    }
}

#################################
## sub get_holiday_menu_id($$$$$$$$)
#################################

sub get_holiday_menu_id($)
{
  my $dbh = shift;

  my ($yr, $mo, $dy, $hr, $mn, $sc)  = Today_and_Now();
  my $date = sprintf("%04d-%02d-%02d", $yr, $mo, $dy);
  my $sql = qq(SELECT menu_id, holiday_name
               FROM holidays
               WHERE (holiday_date = '$date')
                     AND ( ($hr > start_hour AND $hr < end_hour)
                           OR ($hr = start_hour AND $mn > start_minute)
                           OR ($hr = end_hour AND $mn < end_minute) ) );
  my $sth = $dbh->prepare($sql);
  $sth->execute();
  my ($menu_id,$holiday_name) = $sth->fetchrow_array();
  $sth->finish();
  return($menu_id, $holiday_name );
}

#### these are the local/Hawaii Holidays...

#################################
## sub Kuhio_day
#################################
sub Kuhio_day
{
    my($year,$label) = @_;
    return( Date::Calendar::Profiles::Nearest_Workday($year,3,26) );
}
                                                                                                    

#################################
## sub Kamehameha_day
#################################
sub Kamehameha_day
{
    my($year,$label) = @_;
    return( Date::Calendar::Profiles::Nearest_Workday($year,6,11) );
}


#################################
## sub delete_holiday
#################################
sub delete_holiday {
   my ($dbh, $holiday_name) = @_ ; 
   my $statement = "DELETE FROM holidays WHERE holiday_name =  " . $dbh->quote($holiday_name) ;  
   $dbh->do($statement);
   return 1

}


#################################
## sub holiday_settings
#################################
sub holiday_settings {
   my $dbh  = shift ; 
   my $holiday_name = shift ;
    ## first we get the number of holidays....

   my $sql  = qq{ SELECT  holiday_name 
      FROM holiday_names  }; 
   if ($holiday_name ) {
      $sql .= " WHERE holiday_name = " . $dbh->quote($holiday_name) ; 
   } 
   $sql  .= " ORDER BY holiday_ord_num "  ;

   my  $sth = $dbh->prepare($sql);
   $sth->execute(); 
   my $hash_ref ; 

   while (my $holiday_name = $sth->fetchrow() ) { 
      $hash_ref->{$holiday_name} = $holiday_name  ; 
      $sql = "SELECT start_hour, start_minute , end_hour , end_minute , m.menu_id, m.title " . 
            " FROM holidays h INNER JOIN menu m on (h.menu_id = m.menu_id) WHERE holiday_name = ". $dbh->quote($holiday_name)   ; 
      my @row_ary  = $dbh->selectrow_array($sql);
      my $hr2  ; 
      $hr2->{holiday_name} = $holiday_name ;
      if (scalar(@row_ary) ) { 
         $hr2->{start_hour} = $row_ary[0];  
         $hr2->{start_minute} = $row_ary[1];
         $hr2->{end_hour} = $row_ary[2];
         $hr2->{end_minute} = $row_ary[3];
         $hr2->{menu_id} = $row_ary[4];
         $hr2->{menu_title} = $row_ary[5];
      } 
      $hash_ref->{$holiday_name} = $hr2; 
   } 
   return $hash_ref ; 
}
sub load_holiday_sounds {
  my ($dbh, $holiday_name)  = @_; 
  my $sql1 = qq{INSERT INTO holiday_sounds (holiday_name, sound_file, order_no) VALUES (?,?,?) }; 
  my $sth = $dbh->prepare($sql1); 
  my @files = ("aloha_and_ty4_calling.vox", $Holiday_Sounds->{$holiday_name},"aa_menu.vox") ; 
  my $ord = 1; 
  foreach my $file ( @files )  {
     $sth->execute($holiday_name, $file,$ord);
     $sth->finish(); 
     $ord++; 
  } 
 return ; 
}
sub remove_holiday_sounds {
  my ($dbh, $holiday_name)  = @_; 
  my $sql = "DELETE FROM holiday_sounds WHERE holiday_name = " . $dbh->quote($holiday_name) ; 
  $dbh->do($sql); 

}
1;
