package OpenUMS::WWW::Holiday ;
### $Id: Holiday.pm,v 1.1 2004/07/20 03:14:53 richardz Exp $
#
# WWW/Holiday.pm
#
# Web interface for setting/changing the holiday schedules
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
use OpenUMS::Holidays; 
use Date::Format ; 


use base ("OpenUMS::WWW::WebModuleBase"); 

#################################
## sub module
#################################
sub module () {
  return "Holiday" ; 
}

################################################3
## sub main: 
##   template used : templates/menu_main.html
##   function : prints Menu Summary, Auto Attendant menus and transfer menus  
##    but no user menus
#######


sub main {
  my $self = shift ; 
  return unless (defined($self))  ; 

  my $wu = $self->{WEBUSER}; 
  my $session = $wu->cgi_session(); 
  my $cgi = $wu->cgi (); 
  my $dbh = $wu->dbh (); 

  my $tmpl = new HTML::Template(filename =>  'templates/holiday_main.html');  

  my $next_holidays = OpenUMS::Holidays::get_next_holidays();

  my $all_hd_hr = OpenUMS::Holidays::holiday_settings($dbh);

  my @holidays ; 

  use CGI::Enurl;
  my $count =0; 

  foreach my $next_date (sort keys %{$next_holidays} ) {

     my $holiday_name = $next_holidays->{$next_date}; 
     my %row ; 

     $row{mod} = $self->module(); 
     $row{edit_func} = "edit"; 
     $row{holiday_name} = $holiday_name ; 
     $row{odd_row} = $count%2;
     $row{holiday_name_enc} = enurl( $holiday_name ) ;
     $row{next_holiday_date} = $next_date ;
     my $hd_hr = $all_hd_hr->{$holiday_name} ;  
      
     if ($hd_hr->{menu_id} ) {
          $row{menu_id} = $hd_hr->{menu_id} ;
          $row{menu_title} = $hd_hr->{menu_title} ;
          my $start_hour = $hd_hr->{start_hour};
          my $start_minute = $hd_hr->{start_minute};
          my $end_hour = $hd_hr->{end_hour};
          my $end_minute = $hd_hr->{end_minute};
                                                                                                                             
          my $unixtime    = Date::Parse::str2time("2003:1:1T$start_hour:$start_minute", "HST");
          my  ($hour, $min,$ampm)  ;
          ($hour, $min,$ampm) = split (/:/, Date::Format::time2str("%l:%M %p", $unixtime, "HST"));
          $row{start_hour} = $hour ;
          $row{start_min} = $min ;
          $row{start_ampm} = $ampm ;
                                                                                                                             
          $unixtime    = Date::Parse::str2time("2003:1:1T$end_hour:$end_minute", "HST");
          ($hour, $min,$ampm) = split (/:/, Date::Format::time2str("%l:%M %p", $unixtime, "HST"));
          $row{end_hour} = $hour ;
          $row{end_min} = $min ;
          $row{end_ampm} = $ampm ;
     }  else {
          $row{menu_id} =  0 ;
     }


     push @holidays, \%row;  
     $count++; 
  } 

  $tmpl->param("HOLIDAYS" => \@holidays ); 
  $tmpl->param("msg" => $cgi->param('msg')) ;

  return $tmpl  ; 
} 

###############################
## sub edit 
#################
sub edit {

  my $self = shift ; 
  return unless (defined($self))  ; 

  my $wu = $self->{WEBUSER}; 
  my $session = $wu->cgi_session(); 
  my $cgi = $wu->cgi (); 
  my $dbh = $wu->dbh (); 
  my $holiday_name = $cgi->param('holiday_name'); 
  ## please declare our variables
  my ($start_hour, $start_min, $end_hour, $end_min) = (8,0,12,45); 
  my ($start_ampm, $end_ampm) = ("AM","PM") ; 
  my $holiday_opt  = 'OFF' ; 
    
  my $hd_href = OpenUMS::Holidays::holiday_settings($dbh, $holiday_name);
  my $hd_hr =  $hd_href->{$holiday_name} ; ## it should be the first row in the array

  print STDERR "db holidaY_name = $holiday_name \n" if (WEB_DEBUG); 

  if ($hd_hr->{menu_id} ) { 
     ## is a menu defined for this record...?
     ($start_hour,$start_min, $end_hour, $end_min) = ($hd_hr->{start_hour}, $hd_hr->{start_min}, $hd_hr->{end_hour}, $hd_hr->{end_min}) ; 
      print STDERR "pre:(start_hour, start_ampm end_hour, end_ampm) = ($start_hour,$start_ampm,$end_hour,$end_ampm)  \n" if (WEB_DEBUG); 
     if ($start_hour < 1 && $start_min < 1) {
       $holiday_opt  = 'ALL' ; 
     }  else { 
       $holiday_opt  = 'HD' ; 
     ($start_hour,$start_ampm) = OpenUMS::WWW::WebTools::military_hour_to_ampm($start_hour); 
     ($end_hour,$end_ampm) = OpenUMS::WWW::WebTools::military_hour_to_ampm($end_hour);
      print STDERR "(start_hour, start_ampm end_hour, end_ampm) = ($start_hour,$start_ampm,$end_hour,$end_ampm)  \n" if (WEB_DEBUG); 
     } 
  }  

  my $tmpl = new HTML::Template(filename =>  'templates/holiday_edit.html');  
  $tmpl->param(mod=> , $self->module()) ;
  $tmpl->param(func=> , "edit_save") ;
  
  $tmpl->param(holiday_name=> $holiday_name ) ; 
  $tmpl->param(start_hour => OpenUMS::WWW::WebTools::get_hour_dd($start_hour));
  $tmpl->param(start_min => OpenUMS::WWW::WebTools::get_min_dd($start_min) ) ;
  $tmpl->param(start_pm_sel => ($start_ampm eq 'PM') );
  $tmpl->param(start_am_sel => ($start_ampm eq 'AM') );
 
  $tmpl->param(end_hour => OpenUMS::WWW::WebTools::get_hour_dd($end_hour) ) ;
  $tmpl->param(end_min => OpenUMS::WWW::WebTools::get_min_dd($end_min) ) ;
  $tmpl->param(end_pm_sel => ($end_ampm eq 'PM') );
  $tmpl->param(end_am_sel => !($end_ampm eq 'AM') );

  $tmpl->param(menus =>  OpenUMS::WWW::WebTools::get_menu_dd($dbh) )  ;

  $tmpl->param(HOLIDAY_ALL_CHECKED =>  ($holiday_opt eq 'ALL') )  ;
  $tmpl->param(HOLIDAY_HD_CHECKED =>  ($holiday_opt eq 'HD') )  ;
  $tmpl->param(HOLIDAY_OFF_CHECKED =>  ($holiday_opt eq 'OFF'))  ;

#  $tmpl->
  return $tmpl;  


}
###############################
## sub edit_save 
#################

sub edit_save {
  my $self = shift ;    
  return unless (defined($self))  ;
                                                                                                                             
  my $wu = $self->{WEBUSER};
  my $session = $wu->cgi_session();
  my $cgi = $wu->cgi ();
  my $dbh = $wu->dbh ();
  my $msg ; 
  print STDERR "holiday_option = " . $cgi->param('holiday_option') . "\n" if (WEB_DEBUG); 

  if ($cgi->param('holiday_option') eq 'OFF') {
     OpenUMS::Holidays::delete_holiday($dbh, $cgi->param('holiday_name') ); 
     OpenUMS::Holidays::remove_holiday_sounds($dbh, $cgi->param('holiday_name') ); 
     $msg = "Settings for ".  $cgi->param('holiday_name') . " have been removed."; 
     print $cgi->redirect("admin.cgi?mod=".  $self->module() . "&msg=$msg");
     exit ;
  } elsif ($cgi->param('holiday_option') eq 'ALL') {

     my ($start_hour, $start_min, $end_hour, $end_min) = (0,0,23,59) ; ## all day

#     my $start_hour = OpenUMS::WWW::WebTools::ampm_hour_to_military($cgi->param('start_hour'), $cgi->param('start_ampm') ) ;  
#     my $end_hour = OpenUMS::WWW::WebTools::ampm_hour_to_military($cgi->param('end_hour'), $cgi->param('end_ampm') ) ;  
     ## first delete the old one
     OpenUMS::Holidays::delete_holiday($dbh, $cgi->param('holiday_name') ); 

     ## now add the new old one
     my $menu_id = HOLIDAY_MENU_ID; ## HOLIDAY_MENU_ID will always be the holiday menu 
     OpenUMS::Holidays::load_holiday_sounds($dbh, $cgi->param('holiday_name') ); 
     OpenUMS::Holidays::add_holiday($dbh, $cgi->param('holiday_name'),HOLIDAY_MENU_ID,
               $start_hour, $start_min, $end_hour, $end_min,10 ); 

     $msg = "Settings for ".  $cgi->param('holiday_name') . " have been activated."; 
     print $cgi->redirect("admin.cgi?mod=".  $self->module() . "&msg=$msg");
     exit ;
  }  elsif ($cgi->param('holiday_option') eq 'HD') {
     my ($start_hour, $start_min, $end_hour, $end_min) = (0,0,23,59) ; 

     $start_hour = OpenUMS::WWW::WebTools::ampm_hour_to_military($cgi->param('start_hour'), $cgi->param('start_ampm') ) ;  
     $start_min = $cgi->param('start_minute'); 

     ## first delete the old one
     OpenUMS::Holidays::delete_holiday($dbh, $cgi->param('holiday_name') ); 

     ## now add the new old one
     my $menu_id = HOLIDAY_MENU_ID; ## 603 will always be the holiday menu 

     OpenUMS::Holidays::load_holiday_sounds($dbh, $cgi->param('holiday_name') ); 

     OpenUMS::Holidays::add_holiday($dbh, $cgi->param('holiday_name'),HOLIDAY_MENU_ID,
               $start_hour, $start_min, $end_hour, $end_min,10 ); 

     $msg = "Settings for ".  $cgi->param('holiday_name') . " have been activated."; 
     print $cgi->redirect("admin.cgi?mod=".  $self->module() . "&msg=$msg");
     exit ;
  } 
  
  $msg = "No action taken, something was wrong with your request....";
  print $cgi->redirect("admin.cgi?mod=".  $self->module() . "&msg=$msg");
  exit ;

} 
sub edit_sounds {
  my $self = shift ;
  return unless (defined($self))  ;

  my $wu = $self->{WEBUSER};
  my $session = $wu->cgi_session();
  my $cgi = $wu->cgi ();
  my $dbh = $wu->dbh ();

  my $holiday_name = $cgi->param('holiday_name');


  my $tmpl = new HTML::Template(filename =>  'templates/holiday_sounds_edit.html');  
  $tmpl->param(mod=> , $self->module()) ;
  $tmpl->param(func=> , "save_edit_sounds") ;
  $tmpl->param(holiday_name_enc => enurl( $holiday_name ) )  ;

                                                                                                                                               
  $tmpl->param(holiday_name=> $holiday_name ) ;
  my $sql = " SELECT menu_id FROM holidays WHERE holiday_name = " . $dbh->quote($holiday_name)  . " LIMIT 1"; 

  my $sth = $dbh->prepare($sql);
  $sth->execute();
  my $menu_id = $sth->fetchrow();
  $sth->finish(); 

  $sql = " SELECT  sound_file, order_no "
      . " FROM holiday_sounds "
      . " WHERE holiday_name = " . $dbh->quote($holiday_name) ; 
  print STDERR "gonna query $sql \n" if (WEB_DEBUG) ; 
  $sth = $dbh->prepare($sql);
  $sth->execute();
 
#  my $sound_files = $self->get_sound_file_dd($sound_file);
  my @sound_opts;
  my ($sound_file, $order_no) ;
  while (my (@data)  = $sth->fetchrow_array() ) {
     my %row ;
      ($sound_file, $order_no) = @data ;
      $row{sound_files} = $self->get_sound_file_dd($sound_file);
      $row{order_no}  = $order_no ;

     push @sound_opts, \%row;
  }

  $sth->finish();

  $tmpl->param(sound_opts => \@sound_opts);
  $tmpl->param(default_menu_sounds =>  $self->get_menu_sounds($menu_id) )  ;

  return $tmpl; 
}
sub save_edit_sounds {
  my $self = shift ;
  my $sel = shift ;

  my $wu = $self->{WEBUSER};
  my $dbh = $wu->dbh ();
  my $cgi = $wu->cgi ();

#  my $menu_sound_id = $cgi->param('menu_sound_id');
  my $holiday_name  = $cgi->param('holiday_name');
  my $msg ;
 
  my $sql = qq{SELECT order_no
      FROM holiday_sounds 
      WHERE holiday_name = }  ; 
  $sql .= $dbh->quote($holiday_name); 
  my $sth = $dbh->prepare($sql);
  $sth->execute();

  my @sound_opts;
  while (my ($order_no) = $sth->fetchrow_array() ) {

     my $file_id  = $cgi->param("file_id_$order_no") ;

     my $sql1 =  "SELECT sound_file FROM sound_files WHERE file_id  = $file_id" ;
     my $ary_ref = $dbh->selectcol_arrayref($sql1);
     my $new_sound_file = $ary_ref->[0];
     if ($new_sound_file ) {
        my $upd = "UPDATE holiday_sounds SET sound_file = " . $dbh->quote($new_sound_file)
              . " WHERE holiday_name = " .  $dbh->quote($holiday_name) 
              . " AND order_no = $order_no " ;
       print STDERR "update = $upd\n"  if (WEB_DEBUG) ;
        $dbh->do($upd);
        $msg = "Holiday sounds changed for $holiday_name ";
     }  
  }
 
  print $cgi->redirect("admin.cgi?mod=Holiday&func=edit_sounds&holiday_name=" . $holiday_name . "&msg=$msg" );
  exit ;


}
sub add_sound {
  my $self = shift ;
  return unless (defined($self))  ;
  my $wu = $self->{WEBUSER};
  my $session = $wu->cgi_session();
  my $cgi = $wu->cgi ();
  my $dbh = $wu->dbh ();
                                                                                                                                               
  my $holiday_name = $cgi->param('holiday_name');
                                                                                                                                               
  my $tmpl = new HTML::Template(filename =>  'templates/holiday_sounds_add.html');

  $tmpl->param(holiday_name => $holiday_name);
  $tmpl->param(holiday_name_enc => enurl($holiday_name) );
  $tmpl->param(mod => $self->module() );
  $tmpl->param(func => 'save_add_sound' );

  my $sound_files = $self->get_sound_file_dd();
  $tmpl->param(SOUND_FILES =>  $sound_files );
  my @counts = (1,2,3,4,5,6,7,8,9) ;
  my @order_nos;
  my $sql = qq{SELECT max(order_no) + 1 FROM holiday_sounds WHERE holiday_name =  ? } ;
  print STDERR "sql for max = $sql\n" if (WEB_DEBUG) ; 
  my $sth = $dbh->prepare($sql);
  $sth->execute($holiday_name);
  my ($next_order_no) = $sth->fetchrow();
  $sth->finish();
  foreach my $i (@counts) {
     my %data ;
     $data{num} = $i;
     if ($next_order_no == $i) {
       $data{sel} = 1;
     }
     push @order_nos, \%data ;
  }
  $tmpl->param(order_nos =>  \@order_nos);
  return $tmpl  ;

}

sub save_add_sound {
  my $self = shift ;
  my $sel = shift ;
                                                                                                                                               
  my $wu = $self->{WEBUSER};
  my $dbh = $wu->dbh ();
  my $cgi = $wu->cgi ();
                                                                                                                                               
#  my $menu_sound_id = $cgi->param('menu_sound_id');
  my $holiday_name  = $cgi->param('holiday_name');
  my $file_id = $cgi->param('file_id');
  my $msg ;
  my $order_no =  $cgi->param('order_no');
  my $sql1 =  "SELECT sound_file FROM sound_files WHERE file_id  = $file_id" ;
  my $ary_ref = $dbh->selectcol_arrayref($sql1);
  my $new_sound_file = $ary_ref->[0];
  my $sql = "INSERT INTO holiday_sounds (holiday_name, sound_file, order_no)" 
       . " VALUES (" . $dbh->quote($holiday_name) .  ", '$new_sound_file', '$order_no') ";
  $msg = "New Sound File added";
  $dbh->do($sql);
                                                                                                                                               
  print $cgi->redirect("admin.cgi?mod=Holiday&func=edit_sounds&holiday_name=" . $holiday_name . "&msg=$msg" );
  exit ;


}
sub delete_sound {
  my $self = shift ;
  return unless (defined($self))  ;
  my $wu = $self->{WEBUSER};
  my $session = $wu->cgi_session();
  my $cgi = $wu->cgi ();
  my $dbh = $wu->dbh ();
  my $order_no = $cgi->param('order_no') ; 
  my $holiday_name = $cgi->param('holiday_name') ; 
  my $sql = "DELETE FROM holiday_sounds WHERE order_no = $order_no AND holiday_name = " . $dbh->quote($holiday_name); 
  print STDERR "sql = $sql \n" if (WEB_DEBUG); 
  $dbh->do($sql); 
  $sql = "UPDATE holiday_sounds set order_no = order_no - 1 WHERE holiday_name = " .  $dbh->quote($holiday_name) ;  
  $sql .= " AND order_no > $order_no ";  
  $dbh->do($sql); 
  my $msg =  "item at $order_no DELETED";
  print $cgi->redirect("admin.cgi?mod=Holiday&func=edit_sounds&holiday_name=" . $holiday_name . "&msg=$msg" );
  exit ; 

}
sub delete_sound_view {
  my $self = shift ;
  return unless (defined($self))  ;
  my $wu = $self->{WEBUSER};
  my $session = $wu->cgi_session();
  my $cgi = $wu->cgi ();
  my $dbh = $wu->dbh ();

  my $holiday_name = $cgi->param('holiday_name'); 

  my $tmpl = new HTML::Template(filename =>  'templates/holiday_delete_sound_view.html');
  $tmpl->param(mod=> , $self->module()) ;
  $tmpl->param(holiday_name_enc => enurl( $holiday_name ) )  ;
  $tmpl->param(holiday_name=> $holiday_name ) ;
                                                                                                                                               
  my $sql = " SELECT  sound_file, order_no "
      . " FROM holiday_sounds "
      . " WHERE holiday_name = " . $dbh->quote($holiday_name) ;
  print STDERR "gonna query $sql \n" if (WEB_DEBUG) ;
  my $sth = $dbh->prepare($sql);
  $sth->execute();
                                                                                                                                               
#  my $sound_files = $self->get_sound_file_dd($sound_file);
  my @sound_opts;
  my ($sound_file, $order_no) ;
  while (my (@data)  = $sth->fetchrow_array() ) {
     my %row ;
      ($sound_file, $order_no) = @data ;
      $row{sound_file} = $sound_file; 
      $row{holiday_name_enc} = enurl($holiday_name); 
      $row{mod} = $self->module()  ; 
      $row{order_no}  = $order_no ;
                                                                                                                                               
     push @sound_opts, \%row;
  }
                                                                                                                                               
  $sth->finish();
  $tmpl->param(sound_opts => \@sound_opts);
  return $tmpl;
}

#################################
## sub get_menu_sounds
#################################
sub get_menu_sounds {
  my $self = shift ;
  my $menu_id = shift ;
  my $wu = $self->{WEBUSER};
  my $dbh = $wu->dbh ();
  my $sth = $self->{STH};
  if (!defined($sth) ) {
#    $sth->execute();
#    my $sound = $sth->fetchrow();
    my $sql =  " SELECT menu_sound_id,sound_file FROM menu_sounds WHERE menu_id = ? AND sound_type ='M' ";
    print STDERR "Prepared $sql"  if (WEB_DEBUG) ;
    $sth = $dbh->prepare($sql);
    $self->{STH} = $sth;
  }
  $sth->execute($menu_id);
  my @menu_sounds  ;
  while (my ($menu_sound_id, $sound_file) = $sth->fetchrow_array()) {
    my %hash ;
    $hash{menu_sound_id} = $menu_sound_id;
    $hash{sound_file} = $sound_file;
    push @menu_sounds, \%hash;
  }
                                                                                                                                               
  return (\@menu_sounds) ;
}

1;
