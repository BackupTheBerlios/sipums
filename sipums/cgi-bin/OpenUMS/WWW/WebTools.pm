package OpenUMS::WWW::WebTools ; 
### $Id: WebTools.pm,v 1.1 2004/07/20 03:14:53 richardz Exp $
#
# WWW/WebTools.pm
#
# Common tools for web interface
#
# Copyright (C) 2003 Integrated Comtel Inc.
use strict; 
use Exporter;
                                                                                                                             
our @ISA = ('Exporter');

use constant WEB_DEBUG     => 1; 
use constant SMDR_AREA_CODE => '808'; 
use constant SMDR_DB     => "smdr"; 
use constant VOICEMAIL_DB     => "voicemail"; 

our @EXPORT=qw(WEB_DEBUG SMDR_AREA_CODE SMDR_DB VOICEMAIL_DB) ; 



################################################3
## sub get_min_dd : 
##   template used : none
##   function :  Applies the regen to the auto attendant
#######

 sub get_min_dd { 
   my $selected  = shift  ; 
   my @array = (0,15,30,45) ;
   my @ret; 
   foreach my $val (@array) {
     my %data; 
     my $min = sprintf("%02d", $val) ; 
     $data{min} = $min;
     if ($min eq $selected) {
       $data{SEL} = 1;   
     } 
     push @ret, \%data ; 
   } 
   return \@ret; 
 } 

################################################3
## sub get_hour_dd : 
##   template used : none
##   function :  Applies the regen to the auto attendant
#######

sub get_hour_dd {
  my $selected  = shift  ;
  my @ret; 
  for (my $i = 1; $i < 13 ; $i++) {
    my %data;
    my $hour = $i ;
    $data{hour} = $hour;
    if ($hour eq $selected) {
      $data{SEL} = 1;
    }
    push @ret, \%data ;
  } 
  return \@ret; 

}

################################################3
## sub get_menu_dd : 
##   template used : none
##   function :  Applies the regen to the auto attendant
#######

 sub get_menu_dd { 
  my $dbh  = shift ;
  my $selected = shift; 
   my $sql = qq{SELECT menu_id, title FROM menu WHERE menu_type_code in ('AAG' ) } ; 
   my $sth = $dbh->prepare($sql); 
   $sth->execute();
   my @ret ; 
   while (my ($menu_id, $title) = $sth->fetchrow_array() ) {
      my %data ; 
      $data{menu_id} = $menu_id ; 
      $data{title} = $title; 
      if ($menu_id eq $selected) {
        $data{SEL} = 1;
      }
     push @ret, \%data ;
   } 
   return \@ret; 
 
 }

#################################
## sub military_hour_to_ampm
#################################
sub military_hour_to_ampm {
  my $hour = shift ; 
  if ($hour == 0) {
     return (12, "AM"); 
  } elsif ($hour > 0 && $hour  < 12) {
     return ($hour, "AM"); 
  } elsif ($hour == 12)  {
     return ($hour, "PM"); 
  } else {
     return (($hour -12), "PM"); 
  }
}

#################################
## sub ampm_hour_to_military
#################################
sub ampm_hour_to_military {
  my ($hour,$ampm) = @_ ; 

  if ($hour == 12 ) {
     if ($ampm eq 'AM') {
         return 0; 
     }  else {
         return 12; 
     }  
  } 

  if ($ampm eq 'PM') {
     return $hour + 12; 
  }  else {
     return $hour; 
  }

}
1; 
