package OpenUMS::WWW::AASetting;
### $Id: AASetting.pm,v 1.1 2004/07/20 03:14:53 richardz Exp $
#
# WWW/AASetting.pm
#
# AutoAttendant settings
#
# Copyright (C) 2003 Integrated Comtel Inc.
use strict; 

use lib '/usr/local/openums/lib'; 

## always use the web tools
use OpenUMS::WWW::WebTools;

use HTML::Template; 
use OpenUMS::DbQuery; 
use OpenUMS::DbUtils; 
use OpenUMS::Common; 
use OpenUMS::Config; 


use base ("OpenUMS::WWW::WebModuleBase"); 

#################################
## sub module
#################################
sub module  {
  return "AASetting"; 
} 


################################################3
## sub main: 
##   template used : templates/menu_main.html
##   function : prints Menu Summary, Auto Attendant menus and transfer menus  
##    but no user menus
#######
my $MODULE = 'Menu'; 

sub main {
  my $self = shift ; 
  return unless (defined($self))  ; 
  my $wu = $self->{WEBUSER}; 
  my $session = $wu->cgi_session(); 
  my $cgi = $wu->cgi (); 
  my $dbh = $wu->dbh (); 

  my $tmpl = new HTML::Template(filename =>  'templates/aa_main.html');  
  my $arrs = OpenUMS::DbQuery::aa_settings($dbh);
  my @arr ; 
  my $last_day; 
  foreach  my $hr ( @{$arrs} ) {
    my %data ; 
    $data{aa_day}   = $hr->{aa_day} ; 
    if ($data{aa_day} eq $last_day) {
       $data{hide_day}   = 1; 
    } 
    $data{aa_start_hour_ampm}   = $hr->{aa_start_hour_ampm} ; 
    $data{aa_start_minute}   = $hr->{aa_start_minute} ; 
    $data{aa_start_ampm}   = $hr->{aa_start_ampm} ; 
    $data{aa_start_hour}   = $hr->{aa_start_hour} ; 
    $data{aa_dayofweek}   = $hr->{aa_dayofweek} ; 
    $data{menu_id}   = $hr->{menu_id}; 
    $data{menu_title}   = $hr->{menu_title}; 
    push @arr, \%data; 
    $last_day = $hr->{aa_day};  
  } 
  
  $tmpl->param(AA_SETTINGS => \@arr); 
  $tmpl->param(MSG => $cgi->param('msg') ); 
 


  return $tmpl  ; 
} 
#################################
## sub regen_sun
#################################
sub regen_sun {
  my $self = shift ;
  my $tmpl = new HTML::Template(filename =>  'templates/aa_regen_dayoff.html');
  $tmpl->param('aa_setting_name'=> "Sunday Settings ");
                                                                                                                             
  $tmpl->param(mod  => $self->module() ) ;
  $tmpl->param(func => "save_regen" ) ;

  $tmpl->param(setting_days => "1") ;
  $tmpl->param(allday_menus => $self->get_menu_dd() ) ;  

  $tmpl->param(ALL_DAY_CHECKED => 1 )  ;  
  ## default for weekday
  my $open_hour = 8; 
  my $close_hour = 1; 

  return $self->regen_generic($tmpl,$open_hour, $close_hour);



}
################################################3
## sub regen:
##   template used : templates/aa_regen.html
##   function :  This allows the user to regenerate the auto attendant
##    settings  
#######

sub regen {
  my $self = shift ;
  my $tmpl = new HTML::Template(filename =>  'templates/aa_regen.html');
  $tmpl->param('aa_setting_name'=> "Week day Settings (M-F)"); 

  $tmpl->param(mod  => $self->module() ) ;  
  $tmpl->param(func => "save_regen" ) ;  
  $tmpl->param(setting_days => "2,3,4,5,6") ; 
  ## default for weekday 
  my $open_hour = 7; 
  my $close_hour = 5; 

  return $self->regen_generic($tmpl,$open_hour, $close_hour); 
}

################################################3
## sub regen_generic: 
##   template used :parameter 
##   function :  This allows the user to regenerate the auto attendant
##    settings  
#######

sub regen_generic {

  my $self = shift ;
  return unless (defined($self))  ;
  my ($tmpl,$open_hour, $close_hour) = @_; 

  my $wu = $self->{WEBUSER};
  my $session = $wu->cgi_session();
  my $cgi = $wu->cgi ();
  my $dbh = $wu->dbh ();
                                                                                                                             
  ## set up open hour
  $tmpl->param(aa_open_hour => $self->get_hour_dd($open_hour) ) ;  
  $tmpl->param(aa_open_min => $self->get_min_dd() ) ;  
  $tmpl->param(aa_open_am_sel => 1); 

  $tmpl->param(aa_close_hour => $self->get_hour_dd($close_hour) ) ;  
  $tmpl->param(aa_close_min => $self->get_min_dd() ) ;  
  $tmpl->param(aa_close_pm_sel => 1); 

  $tmpl->param(daytime_menus => $self->get_menu_dd() ) ;  
  $tmpl->param(nighttime_menus => $self->get_menu_dd() ) ;  

  return $tmpl; 

}

################################################3
## sub regen_sat: 
##   template used : templates/aa_regen.html
##   function :  This allows the user to regenerate the auto attendant
##    settings  
#######
sub regen_sat {
  my $self = shift ;
  my $tmpl = new HTML::Template(filename =>  'templates/aa_regen_dayoff.html');
  $tmpl->param('aa_setting_name'=> "Saturday Settings"); 
  $tmpl->param(mod  => $self->module() ) ;  
  $tmpl->param(func => "save_regen" ) ;  
  $tmpl->param(allday_menus => $self->get_menu_dd() ) ;  
  $tmpl->param(setting_days => "7") ;
  $tmpl->param(ALL_DAY_CHECKED => 1 )  ;  

  my $open_hour = 8; 
  my $close_hour = 1; 

  return $self->regen_generic($tmpl,$open_hour, $close_hour ); 

}



################################################3
## sub save_regen: 
##   template used : none
##   function :  Applies the regen to the auto attendant
#######

sub save_regen {
  my $self = shift ;
  return unless (defined($self))  ;
  my $wu = $self->{WEBUSER};
  my $session = $wu->cgi_session();
  my $cgi = $wu->cgi ();
  my $dbh = $wu->dbh ();
  my $offday_setting = $cgi->param('offday_setting'); 
  my $msg; 
  if ($offday_setting =~ /^ALL_DAY/) {
    ## this means they are closed all day, so we just set up a menu for the  whole day 
      my $setting_days = $cgi->param('setting_days') ;  
      my @days = split (/,/,  $setting_days );

      my $del  = "DELETE FROM auto_attendant WHERE aa_dayofweek  in ($setting_days) "; 

         print STDERR "DELTEING $del --------------------\n" if (WEB_DEBUG) ; 
      $dbh->do($del ) ;

      my $menu_id = $cgi->param('allday_menu_id');

      foreach my $day (@days) {
         ## it really should only be one day but still....
        my $ins1 = qq{REPLACE INTO auto_attendant  (aa_dayofweek, aa_start_hour , aa_start_minute, menu_id)
        VALUES ($day, 0,0,$menu_id)}; 
         $dbh->do($ins1); 
        print STDERR "$ins1\n-----------------------------------------\n" if (WEB_DEBUG) ; 
   
      }

      $msg = "Auto Attendant Settings reset"; 
  }  else { 
      my $aa_open_hour = $cgi->param('aa_open_hour'); 
      my $aa_open_min = $cgi->param('aa_open_minute'); 
      my $aa_close_hour = $cgi->param('aa_close_hour'); 
      my $aa_close_min = $cgi->param('aa_close_minute'); 
      print STDERR " aa_open_ampm = ". $cgi->param('aa_open_ampm') . " $aa_open_hour \n" if (WEB_DEBUG) ; 
      print STDERR " aa_close_ampm = ". $cgi->param('aa_close_ampm') . " $aa_close_hour \n" if (WEB_DEBUG) ; 
      if ($cgi->param('aa_open_ampm') eq 'PM' && $aa_open_hour ne '12') {
         $aa_open_hour += 12; 
      }
      if ($cgi->param('aa_close_ampm') eq 'PM' && $aa_close_hour ne '12') {
         $aa_close_hour += 12; 
      }
      my $setting_days = $cgi->param('setting_days') ;  
      my @days = split (/,/,  $setting_days );

      my $dmenu_id = $cgi->param('daytime_menu_id');
      my $nmenu_id = $cgi->param('nighttime_menu_id');
      my $del  = "DELETE FROM auto_attendant WHERE aa_dayofweek  in ($setting_days) "; 
      $dbh->do($del ) ;
      foreach my $day (@days) {
         my $ins1 = qq{REPLACE INTO auto_attendant  (aa_dayofweek, aa_start_hour , aa_start_minute, menu_id)
          VALUES ($day, 0,0,$nmenu_id)}; 
         my $ins2 = qq{REPLACE INTO auto_attendant  (aa_dayofweek, aa_start_hour , aa_start_minute, menu_id)
          VALUES ($day, $aa_open_hour,$aa_open_min,$dmenu_id)}; 
         my $ins3 = qq{REPLACE INTO auto_attendant  (aa_dayofweek, aa_start_hour , aa_start_minute, menu_id)
          VALUES ($day, $aa_close_hour,$aa_close_min,$nmenu_id)}; 
         $dbh->do($ins1); 
         $dbh->do($ins2); 
         $dbh->do($ins3); 
      } 
      $msg = "Auto Attendant Settings reset"; 
  } 
  print $cgi->redirect("admin.cgi?mod=AASetting&msg=" . $msg );
  exit ;

}

################################################3
## sub get_min_dd : 
##   template used : none
##   function :  Applies the regen to the auto attendant
#######

sub get_min_dd { 
  my $self = shift; 
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
  my $self = shift;
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
  my $self = shift;    
  my $selected = shift; 
  my $wu = $self->{WEBUSER};
  my $dbh = $wu->dbh ();
  my $sql = qq{SELECT menu_id, title FROM menu WHERE menu_type_code in ('AAG','AAM' ) } ; 
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
## sub delete_item_conf
#################################
sub delete_item_conf {
  my $self = shift ;
  return unless (defined($self))  ;
  my $wu = $self->{WEBUSER};
  my $session = $wu->cgi_session();
  my $cgi = $wu->cgi ();
  my $dbh = $wu->dbh ();
  my $tmpl ; 
   
  if ($cgi->param('aa_start_hour') eq '0' && $cgi->param('aa_start_minute') eq '00') { 
    $tmpl = new HTML::Template(filename =>  'templates/aa_delete_ban.html');  
  }  else {
    $tmpl = new HTML::Template(filename =>  'templates/aa_delete_conf.html');  
    $tmpl->param(mod => 'AASetting'); 
    $tmpl->param(func => 'delete_item'); 

    my $arrs = OpenUMS::DbQuery::aa_settings($dbh, $cgi->param('aa_dayofweek'), 
             $cgi->param('aa_start_hour'), $cgi->param('aa_start_minute') );

    my $hr  = $arrs->[0] ; 
    my %data ;
   
    $data{aa_day}   = $hr->{aa_day} ;

    $data{aa_start_hour_ampm}   = $hr->{aa_start_hour_ampm} ;
    $data{aa_start_minute}   = $hr->{aa_start_minute} ;
    $data{aa_start_ampm}   = $hr->{aa_start_ampm} ;
    $data{aa_start_hour}   = $hr->{aa_start_hour} ;
    $data{aa_dayofweek}   = $hr->{aa_dayofweek} ;
    $data{menu_id}   = $hr->{menu_id};
    $tmpl->param(%data); 
  }
  return $tmpl; 


} 
#################################
## sub delete_item
#################################
sub delete_item {
  my $self = shift ;
  return unless (defined($self))  ;
  my $wu = $self->{WEBUSER};
  my $session = $wu->cgi_session();
  my $cgi = $wu->cgi ();
  my $dbh = $wu->dbh ();
  my $delete = OpenUMS::DbUtils::delete_aa_item($dbh, $cgi->param('aa_dayofweek'),
             $cgi->param('aa_start_hour'), $cgi->param('aa_start_minute') );
  my $msg; 
  if ($delete) { 
     $msg = "AA Items deleted";  
  }  else {
     $msg = "Could not delete AA Item";  
  } 

  print $cgi->redirect("admin.cgi?mod=AASetting&msg=" . $msg );

}
#################################
## sub add_item
#################################
sub add_item {
  my $self = shift ;
  return unless (defined($self))  ;
  my $wu = $self->{WEBUSER};
  my $session = $wu->cgi_session();
  my $cgi = $wu->cgi ();
  my $dbh = $wu->dbh ();
  my $tmpl ; 

  my %days = (1 => "Sunday", 2 =>"Monday", 3=>"Tuesday",
              4=>"Wednesday", 5=>"Thursday", 6=>"Firday",
              7=>"Saturday") ;

  $tmpl = new HTML::Template(filename =>  'templates/aa_add_item.html');  

  $tmpl->param(mod  => "AASetting" ) ;
  $tmpl->param(func => "save_add_item" ) ;
  $tmpl->param(aa_dayofweek => $cgi->param('aa_dayofweek') ) ; 

  $tmpl->param(aa_day => $days{$cgi->param('aa_dayofweek')} ) ; 
  $tmpl->param(aa_start_hour_opts => $self->get_hour_dd() ) ;
  $tmpl->param(aa_start_min_opts => $self->get_min_dd() ) ;

#  $tmpl->param(aa_start_ampm => 1);
                                                                                                                             
  $tmpl->param(menu_opts => $self->get_menu_dd() ) ;

  return $tmpl ; 
}
#################################
## sub save_add_item
#################################
sub save_add_item {
  my $self = shift ;
  return unless (defined($self))  ;
  my $wu = $self->{WEBUSER};
  my $session = $wu->cgi_session();
  my $cgi = $wu->cgi ();
  my $dbh = $wu->dbh ();
  my $tmpl ;

  my $aa_start_hour = $cgi->param('aa_start_hour');
  my $aa_start_minute = $cgi->param('aa_start_minute');
  my $aa_start_ampm = $cgi->param('aa_start_ampm');
  my $aa_dayofweek = $cgi->param('aa_dayofweek');
  my $aa_day = $cgi->param('aa_day');
  print STDERR " aa_start_hour = ". $cgi->param('aa_start_hour') . " $aa_start_hour \n" if (WEB_DEBUG) ;
  print STDERR " aa_start_minute = ". $cgi->param('aa_start_minute') . " $aa_start_minute \n" if (WEB_DEBUG) ;
  print STDERR " aa_start_ampm = ". $cgi->param('aa_start_ampm') . " $aa_start_ampm \n" if (WEB_DEBUG) ;
  if ($cgi->param('aa_start_ampm') eq 'PM' && $aa_start_hour ne '12') {
     $aa_start_hour  += 12;
  }
  my $menu_id = $cgi->param('menu_id');
   
  my $ins1 = qq{REPLACE INTO auto_attendant  (aa_dayofweek, aa_start_hour , aa_start_minute, menu_id)
     VALUES ($aa_dayofweek, $aa_start_hour,'$aa_start_minute',$menu_id)};
  $dbh->do($ins1); 
  my $msg= "Auto Attendant menu added for $aa_day"; 

  print $cgi->redirect("admin.cgi?mod=AASetting&msg=" . $msg );




}

#################################
## sub edit_item
#################################
sub edit_item {
  my $self = shift;    
  return unless (defined($self))  ;
  my $wu = $self->{WEBUSER};
  my $session = $wu->cgi_session();
  my $cgi = $wu->cgi ();
  my $dbh = $wu->dbh ();
  my $tmpl ;
                                                                                                
  $tmpl = new HTML::Template(filename =>  'templates/aa_edit_item.html');
  my $arrs = OpenUMS::DbQuery::aa_settings($dbh, $cgi->param('aa_dayofweek'),
             $cgi->param('aa_start_hour'), $cgi->param('aa_start_minute') );
                                                                                                                                               
  my $hr  = $arrs->[0] ;
  my %data ;
                                                                                                                                               
  $data{mod}   = $self->module();
  $data{func}   = "save_item";
  $data{aa_day}   = $hr->{aa_day} ;
  ## set the old ones...
  $data{old_aa_start_minute}   = $hr->{aa_start_minute} ;
  $data{old_aa_start_hour}   = $hr->{aa_start_hour} ;


  $data{aa_dayofweek}   = $hr->{aa_dayofweek} ;
  $data{aa_start_hour_ampm}   = $hr->{aa_start_hour_ampm} ;
  $data{aa_start_ampm}   = $hr->{aa_start_ampm} ;
  $data{aa_start_minute}   = $hr->{aa_start_minute} ;
  print STDERR "$data{old_aa_start_hour} ne '0' && $data{old_aa_start_minute} ne '00': \n" if (WEB_DEBUG); 
  if ($data{old_aa_start_hour} ne '0' ) {
     $data{allow_edit_time} = 1 ; 
     $data{aa_start_hour} = $self->get_hour_dd($hr->{aa_start_hour_ampm})   ;
     $data{aa_start_min}  = $self->get_min_dd($hr->{aa_start_minute})    ;
     if ($data{aa_start_ampm} eq 'AM') { 
       $data{aa_start_am_sel}  = 1;
     } else { 
       $data{aa_start_pm_sel}  = 1;
     } 
  } else {  
     print STDERR "No good\n" if (WEB_DEBUG); 
  }
  $data{menu_id} = $hr->{menu_id} ; 
  $data{menus}   = $self->get_menu_dd($hr->{menu_id}) ;  


  $tmpl->param(%data);


  return $tmpl; 
}
sub save_item {
  my $self = shift ;
  my $wu = $self->{WEBUSER};
  my $session = $wu->cgi_session();
  my $cgi = $wu->cgi ();
  my $dbh = $wu->dbh ();
  my $tmpl ;
#  if ($cgi->param('allow_edit_time')) {
#    
#  }  else {
     if ($cgi->param('menu_id') ) { 
       my $upd = "UPDATE auto_attendant SET menu_id = " 
          . $cgi->param('menu_id') 
          . " WHERE aa_start_hour = " . $cgi->param('old_aa_start_hour')
          . " AND aa_start_minute = " . $cgi->param('old_aa_start_minute')
          . " AND aa_dayofweek  = " . $cgi->param('aa_dayofweek'); 
       print STDERR "upd = $upd\n" if (WEB_DEBUG) ; 
       $dbh->do($upd); 
     } 
  if ($cgi->param('allow_edit_time')) {
      my $new_hour = $cgi->param('aa_start_hour');
      my $new_min = $cgi->param('aa_start_minute');

      my $old_hour = $cgi->param('old_aa_start_hour');
      my $old_min = $cgi->param('old_aa_start_minute');
      my $aa_dayofweek = $cgi->param('aa_dayofweek');

      if ($cgi->param('aa_start_ampm') eq 'PM' && $new_hour ne '12') {
         $new_hour += 12;
      }
      print STDERR " new_hour = $new_hour \n" if (WEB_DEBUG) ;
      print STDERR " new_min = $new_min \n" if (WEB_DEBUG) ;
      print STDERR " aa_dayofweek = $aa_dayofweek \n" if (WEB_DEBUG) ;

      my $upd = "UPDATE auto_attendant " 
          . " SET aa_start_hour = $new_hour, aa_start_minute = $new_min   "
          . " WHERE aa_start_hour = $old_hour " 
          . " AND aa_start_minute = $old_min " 
          . " AND aa_dayofweek  = $aa_dayofweek " ; 

      print STDERR "upd = $upd\n" if (WEB_DEBUG) ; 
      $dbh->do($upd); 
  } 
                                                                                                                                               
  my $msg = "Setting Saved";  
  print $cgi->redirect("admin.cgi?mod=AASetting&msg=" . $msg );
  exit ;

}
1; 
