package OpenUMS::WWW::Reports;
### $Id: Reports.pm,v 1.1 2004/07/20 03:14:53 richardz Exp $
#
# WWW/Intro.pm
#
# Introduction to ...
#
# Copyright (C) 2003 Integrated Comtel Inc.

use strict ; 

use HTML::Template; 
use Date::Calc; 
use OpenUMS::WWW::WebTools;
use HTML::Template;
use Date::Format ;
use CGI::Enurl;

## always use the web tools

use base ("OpenUMS::WWW::WebModuleBase"); 

#################################
## sub module
#################################
sub module {
  return "Reports";
}
#################################
## sub main
#################################
sub main {
  my $self = shift ;
  return unless (defined($self))  ;
  my $wu = $self->{WEBUSER};
  my $dbh = $wu->dbh ();
  my $session = $wu->cgi_session();
  print STDERR " Got the session: id=" . $session->id() . "ext=" . $session->param('extension') . "\n" if (WEB_DEBUG);
#  my $session_id = $session->session_id() ;

  my $tmpl = new HTML::Template(filename =>  'templates/reports/hello.html');
  my ($first_name,$last_name) = OpenUMS::DbQuery::get_first_last_names($dbh,$session->param('extension'));
  $tmpl->param('first_name',$first_name  ) ;
  $tmpl->param('last_name',$last_name );
  return $tmpl ;

}
#################################
## sub date_params
#################################
sub date_params {
  my $self = shift ;
  return unless (defined($self))  ;
  my $wu = $self->{WEBUSER};
  my $session = $wu->cgi_session();
  my $dbh = $wu->dbh ();
  my $cgi = $wu->cgi ();
  my $tmpl = new HTML::Template(filename =>  'templates/reports/date_params.html');  
#  $tmpl->param(mod => $self->module() ) ; 
  $tmpl->param(start_date => $cgi->param('start_date' ) )  ; 
  $tmpl->param(end_date => $cgi->param('end_date' ) ) ; 
  $tmpl->param(url_params => $cgi->param('url_params' ) ) ; 
  print STDERR "date_params = " . $cgi->param('date_params') . "\n";
#  if ($cgi->param('date_params') ) {
#     my ($where, $params) =   $self->process_date_params()  ;  
#     $tmpl->param(where => $where ) ; 
#  } 
  return $tmpl; 
}
#################################
## sub group_summary
#################################
sub group_summary {
  my $self = shift ; 
  return unless (defined($self))  ; 
  my $wu = $self->{WEBUSER};
  my $session = $wu->cgi_session();
  my $dbh = $wu->dbh ();
  my $cgi = $wu->cgi ();

  $dbh->do("use smdr"); 
  my $stations_hr = $self->get_stations_hr();  
  my $date = $cgi->param('date'); 
  my $sql = qq(
SELECT count(*) AS call_count,
  sum(if(smdr_call_type='INBOUND',1,0)) AS incoming_sum,
sum(if(smdr_call_type='OUTBOUND',1,0)) AS outgoing_sum,
sum(if(smdr_call_type='XFERED',1,0)) AS xfered_sum,
sum(if(smdr_call_type='BLOCKED',1,0)) AS blocked_sum,
group_name, g.group_id  group_id,  received_date

FROM smdr_groups g, group_station_map m, smdr_data d
WHERE g.group_id =m.group_id
AND m.station = d.station
     );
  if (!$date) { 
    $sql .= " AND  received_date = current_date()   " 
  }  else {
    $sql .= " AND  received_date = '$date' " 
  } 
  $sql .= qq{ 
     GROUP BY received_date, group_name,g.group_id ORDER BY received_date DESC, group_name 
    };
  my $sth = $dbh->prepare($sql); 
  print STDERR "sql = $sql \n" if (WEB_DEBUG) ; 
  $sth->execute(); 
  my $tmpl = new HTML::Template(filename =>  'templates/reports/group_summary.html');  

  my $rpt;
  my $I_outer=0;
  my $I_inner =0;
  my $break_val;
  my $first_flag = 0  ;

                                                                                                                                               
  while (my $hr = $sth->fetchrow_hashref() ) {
    if (($first_flag != 0) && $rpt->[$I_outer]->{received_date} ne $hr->{received_date} ) {
      $I_outer++;
      $I_inner=0; 
    } elsif ($first_flag == 0 ) {
         $first_flag = 1 ;
    }
    $rpt->[$I_outer]->{received_date} = $hr->{received_date};
    $rpt->[$I_outer]->{date_report}->[$I_inner]->{call_count} = $hr->{call_count};
    $rpt->[$I_outer]->{date_report}->[$I_inner]->{mod} = $self->module();
    $rpt->[$I_outer]->{date_report}->[$I_inner]->{group_id} = $hr->{group_id}; 
    $rpt->[$I_outer]->{date_report}->[$I_inner]->{date} = $date; 
    $rpt->[$I_outer]->{date_report}->[$I_inner]->{group_name} = $hr->{group_name} ; 
    $rpt->[$I_outer]->{date_report}->[$I_inner]->{blocked_sum} = $hr->{blocked_sum};
    $rpt->[$I_outer]->{date_report}->[$I_inner]->{incoming_sum} = $hr->{incoming_sum};
    $rpt->[$I_outer]->{date_report}->[$I_inner]->{outgoing_sum} = $hr->{outgoing_sum};
    $rpt->[$I_outer]->{date_report}->[$I_inner]->{xfered_sum} = $hr->{xfered_sum};
    my $avg = $hr->{average_duration} ;
    my $avg_min = (int($avg/60)); 
    my $avg_sec = $avg%60; 
    $rpt->[$I_outer]->{date_report}->[$I_inner]->{average_duration} = sprintf("%02d:%02d",$avg_min, $avg_sec) ; 
    $rpt->[$I_outer]->{date_report}->[$I_inner]->{average_duration} = $avg  ; 
    $rpt->[$I_outer]->{date_report}->[$I_inner]->{odd_row} = $I_inner%2; 
    $I_inner++;
  }
  $sth->finish();
  $dbh->do("use voicemail"); 
  if (defined($rpt) ) { 
    $tmpl->param(report => $rpt); 
  }
  if ($date) { 
    $sql = qq(select DATE_SUB('$date', INTERVAL 1 DAY) AS prev,
     if(DATE_ADD('$date', INTERVAL 1 DAY) > current_date(), null, 
       DATE_ADD('$date', INTERVAL 1 DAY)) AS next );
  } else {
    $sql = qq(select DATE_SUB(current_date, INTERVAL 1 DAY) AS prev,
       NULL AS next );
  } 

  $sth = $dbh->prepare($sql);
  $sth->execute(); 
  my ($prev, $next) = $sth->fetchrow_array();
  $tmpl->param(mod => $self->module()); 
  $tmpl->param(func => "group_summary"); 
  $tmpl->param(prev_date => $prev); 
  $tmpl->param(next_date => $next); 
   
  
  return $tmpl; 
} 




#################################
## sub extension_summary
#################################
sub extension_summary {
  my $self = shift ; 
  return unless (defined($self))  ; 
  my $wu = $self->{WEBUSER};
  my $session = $wu->cgi_session();
  my $dbh = $wu->dbh ();
  my $cgi = $wu->cgi ();

  $dbh->do("use smdr"); 
  my $stations_hr = $self->get_stations_hr();  
  my $date = $cgi->param('date'); 
  my $group_id = $cgi->param('group_id'); 
  my $sql = qq(SELECT count(*) AS call_count, 
  sum(if(smdr_call_type='INBOUND',1,0)) AS incoming_sum,
sum(if(smdr_call_type='OUTBOUND',1,0)) AS outgoing_sum,
sum(if(smdr_call_type='XFERED',1,0)) AS xfered_sum,
sum(if(smdr_call_type='BLOCKED',1,0)) AS blocked_sum,
station,
     DATE_FORMAT(received_date,'%m/%d/%Y') AS received_date, 
     SEC_TO_TIME(avg(duration)) average_duration FROM smdr_data 
     WHERE  );

  my ($where, $rpt_params_tmp ) = $self->process_date_params(); 
  if ($where)  { 
     $sql .= " $where "; 
  } else { 
    $sql .= " received_date = current_date()   " 
  } 

  if (!$where) { 
  }  else {
    print STDERR "no where $where " ; 
  } 
  my $group_name; 
  if ($group_id) { 
    my @values = $dbh->selectrow_array("SELECT group_name FROM smdr_groups WHERE group_id = $group_id" ) ;
    $group_name = $values[0]; 
    my $station_aref = $dbh->selectcol_arrayref("SELECT station FROM group_station_map WHERE group_id = $group_id" ) ;
    my $exts = join (',', @$station_aref); 
    $sql .= " AND station in ($exts) " 
  } 
  else {
    $group_name  = undef; 
    $sql .= " AND station <> '' " 
  } 
  $sql .= qq{ 
     GROUP BY received_date, station ORDER BY received_date DESC, station  };
  my $sth = $dbh->prepare($sql); 
   
  $sth->execute(); 
  my $tmpl = new HTML::Template(filename =>  'templates/reports/extension_summary.html');  
  $tmpl->param('group_name' => $group_name ); 
  $tmpl->param('group_id' => $group_id ); 
  my $url_param = "mod=" . $self->module() . "&func=extension_summary" ; 
  print STDERR "url_param=$url_param \n"; 
  $url_param = enurl($url_param); 
  print STDERR "url_param=--$url_param--\n"; 
  $tmpl->param('url_params' => $url_param); 

  my $rpt;
  my $I_outer=0;
  my $I_inner =0;
  my $break_val;
  my $first_flag = 0  ;

                                                                                                                                               
  while (my $hr = $sth->fetchrow_hashref() ) {
    if (($first_flag != 0) && $rpt->[$I_outer]->{received_date} ne $hr->{received_date} ) {
      $I_outer++;
      $I_inner=0; 
    } elsif ($first_flag == 0 ) {
         $first_flag = 1 ;
    }
    $rpt->[$I_outer]->{received_date} = $hr->{received_date};
    $rpt->[$I_outer]->{date_report}->[$I_inner]->{call_count} = $hr->{call_count};
    $rpt->[$I_outer]->{date_report}->[$I_inner]->{station} = $hr->{station} ; 
    if (defined($stations_hr->{$hr->{station}} ) )  { 
       if (defined($stations_hr->{$hr->{station}}->{first_name} )   || defined($stations_hr->{$hr->{station}}->{last_name})  ) { 
           $rpt->[$I_outer]->{date_report}->[$I_inner]->{station} .= " - " 
           . $stations_hr->{$hr->{station}}->{first_name} . " " .  $stations_hr->{$hr->{station}}->{last_name}  ;
       }
    } 
    $rpt->[$I_outer]->{date_report}->[$I_inner]->{blocked_sum} = $hr->{blocked_sum};
    $rpt->[$I_outer]->{date_report}->[$I_inner]->{incoming_sum} = $hr->{incoming_sum};
    $rpt->[$I_outer]->{date_report}->[$I_inner]->{outgoing_sum} = $hr->{outgoing_sum};
    $rpt->[$I_outer]->{date_report}->[$I_inner]->{xfered_sum} = $hr->{xfered_sum};
    my $avg = $hr->{average_duration} ;
    my $avg_min = (int($avg/60)); 
    my $avg_sec = $avg%60; 
    $rpt->[$I_outer]->{date_report}->[$I_inner]->{average_duration} = sprintf("%02d:%02d",$avg_min, $avg_sec) ; 
    $rpt->[$I_outer]->{date_report}->[$I_inner]->{average_duration} = $avg  ; 
    $rpt->[$I_outer]->{date_report}->[$I_inner]->{odd_row} = $I_inner%2; 
    $I_inner++;
  }
  $sth->finish();
  $dbh->do("use voicemail"); 
  if (defined($rpt) ) { 
    $tmpl->param(report => $rpt); 
  }
  if ($date) { 
    $sql = qq(select DATE_SUB('$date', INTERVAL 1 DAY) AS prev,
     if(DATE_ADD('$date', INTERVAL 1 DAY) > current_date(), null, 
       DATE_ADD('$date', INTERVAL 1 DAY)) AS next );
  } else {
    $sql = qq(select DATE_SUB(current_date, INTERVAL 1 DAY) AS prev,
       NULL AS next );
  } 

  $sth = $dbh->prepare($sql);
  $sth->execute(); 
  my ($prev, $next) = $sth->fetchrow_array();
  $tmpl->param(mod => $self->module()); 
  $tmpl->param(func => "extension_summary"); 
  $tmpl->param(prev_date => $prev); 
  $tmpl->param(next_date => $next); 
   
  
  return $tmpl; 
} 



#################################
## sub most_active_phone_numbers
#################################
sub most_active_phone_numbers {
  my $self = shift ;
  return unless (defined($self))  ;
  my $wu = $self->{WEBUSER};
  my $session = $wu->cgi_session();
  my $dbh = $wu->dbh ();
  my $cgi = $wu->cgi ();

  my $tmpl = new HTML::Template(filename =>  'templates/reports/most_active_phone_numbers.html');  

  my $sql = qq{SELECT COUNT(*) count_dialed, number_dialed, smdr_call_type
      FROM smdr_data
      WHERE number_dialed <> ''
       AND smdr_call_type = ? 
      GROUP BY number_dialed, call_type 
      ORDER BY count_dialed DESC  LIMIT 20} ; 

  $dbh->do("use smdr"); 
  my $sth = $dbh->prepare($sql);
  $sth->execute("OUTBOUND"); 
  my $I_outer=0;
  my $out_rpt; 
  while (my $hr = $sth->fetchrow_hashref() ) {
    $out_rpt->[$I_outer]->{smdr_call_type}= $hr->{smdr_call_type}; 
    $out_rpt->[$I_outer]->{number_dialed}= $hr->{number_dialed}; 
    $out_rpt->[$I_outer]->{count_dialed}= $hr->{count_dialed}; 
    $out_rpt->[$I_outer]->{odd_row}= $I_outer%2; 
    $I_outer++; 
  }
  $tmpl->param(out_report => $out_rpt); 
  $sth->finish(); 
  $sth->execute("INBOUND");
  $I_outer=0;
  my $in_rpt;
  while (my $hr = $sth->fetchrow_hashref() ) {
    $in_rpt->[$I_outer]->{smdr_call_type}= $hr->{smdr_call_type};
    $hr->{number_dialed} =~ s/^808//;
    $in_rpt->[$I_outer]->{number_dialed}= $hr->{number_dialed};
    $in_rpt->[$I_outer]->{count_dialed}= $hr->{count_dialed};
    $in_rpt->[$I_outer]->{odd_row}= $I_outer%2;
    
    $I_outer++;
  }

  if (defined($in_rpt) ) { 
    $tmpl->param(in_report => $in_rpt); 
  }

  $tmpl->param(mod => $self->module()); 
  $tmpl->param(func => "most_active_phone_numbers"); 
  $dbh->do("use voicemail"); 
  return $tmpl; 

}

#################################
## sub longest_calls
#################################
sub longest_calls {
  my $self = shift ;
  return unless (defined($self))  ;
  my $wu = $self->{WEBUSER};
  my $session = $wu->cgi_session();
  my $dbh = $wu->dbh ();
  my $cgi = $wu->cgi ();
                                                                                                                                               
  my $tmpl = new HTML::Template(filename =>  'templates/reports/longest_calls.html');
                                                                                                                                               
  
  my $sql = qq{select station,number_dialed,smdr_call_type,duration from smdr_data order by duration desc limit 20 };

  $dbh->do("use smdr"); 
  my $sth = $dbh->prepare($sql);
  $sth->execute(); 
  my $I_outer=0;
  my $rpt; 
  while (my $hr = $sth->fetchrow_hashref() ) {
    $rpt->[$I_outer]->{station}= $hr->{station}; 
    $rpt->[$I_outer]->{call_type}= $hr->{smdr_call_type}; 
    if ($hr->{smdr_call_type} eq 'INCOMING') {
        $hr->{number_dialed} =~ s/^808//g;
    }
    $rpt->[$I_outer]->{number_dialed}= $hr->{number_dialed}; 
    $rpt->[$I_outer]->{duration}= $hr->{duration}; 
    $rpt->[$I_outer]->{odd_row}= $I_outer%2; 
    $I_outer++; 
  }
  $tmpl->param(report => $rpt); 
  $tmpl->param(mod => $self->module()); 
  $tmpl->param(func => "longest_calls"); 

  $dbh->do("use voicemail"); 
  return $tmpl; 

}
sub call_distribution_main {

}

#################################
## sub most_active_ext_by_dur
#################################
sub most_active_ext_by_dur {
  my $self = shift ;
  return unless (defined($self))  ;
  my $wu = $self->{WEBUSER};
  my $session = $wu->cgi_session();
  my $dbh = $wu->dbh ();
  my $cgi = $wu->cgi ();
                                                                                                                                               
  my $tmpl = new HTML::Template(filename =>  'templates/reports/longest_calls.html');
                                                                                                                                               
  my $sql = qq{SELECT station, number_dialed, call_type, duration FROM smdr_data ORDER BY duration desc limit 20 };

  $dbh->do("use smdr"); 
  my $sth = $dbh->prepare($sql);
  $sth->execute(); 
  my $I_outer=0;
  my $rpt; 
  while (my $hr = $sth->fetchrow_hashref() ) {
    $rpt->[$I_outer]->{station}= $hr->{station}; 
    $rpt->[$I_outer]->{call_type}= $hr->{call_type}; 
    $rpt->[$I_outer]->{number_dialed}= $hr->{number_dialed}; 
    $rpt->[$I_outer]->{duration}= $hr->{duration}; 
    $I_outer++; 
  }
  $tmpl->param(report => $rpt); 
  $tmpl->param(mod => $self->module()); 
  $tmpl->param(func => "longest_calls"); 

  $dbh->do("use voicemail"); 
  return $tmpl; 
}



#################################
## sub detail_params
#################################
sub detail_params {
  my $self = shift ;
  return unless (defined($self))  ;
  my $wu = $self->{WEBUSER};
  my $session = $wu->cgi_session();
  my $dbh = $wu->dbh ();
  my $cgi = $wu->cgi ();
                                                                                                                                               
  $dbh->do("use smdr");
  my $tmpl = new HTML::Template(filename =>  'templates/reports/detail_params.html');

  ## about them dates? 
  my ($now_year, $now_month, $now_day) = Date::Calc::Today(); 
  my $PARAMS = $cgi->Vars;
  if ($PARAMS->{begin_received_date}) { 
     $tmpl->param(begin_received_date => $PARAMS->{begin_received_date}); 
  } else { 
    my ($year,$month,$day) = Date::Calc::Monday_of_Week(Date::Calc::Week_of_Year($now_year,$now_month,$now_day)); 
   $tmpl->param(begin_received_date => "$month/$day/$year"); 
  } 
                                                                                                                                               
  if ($PARAMS->{'end_received_date'} ) { 
     $tmpl->param(end_received_date => $PARAMS->{'end_received_date'}); 
  } else { 
     $tmpl->param(end_received_date => "$now_month/$now_day/$now_year"); 
  } 
                                                                                                                                               
  my %sb_hash = ("smdr_call_type" => "Call Type",
                 "station" => "Station", 
                 "received_datetime" => "Received Date",
                 "call_init_time" => "Call Began",
                 "call_end_time" => "Call End",
                 "number_dialed" => "Number Dialed",
                 "account_number" => "Account",
                 "trunk_line" => "Trunk Line",
                 "duration" => "Duration");
  my $sb ; 
  my $I =0 ; 
  foreach my $field_name (keys %sb_hash ) { 
    $sb->[$I]->{field_name} = $field_name; 
    $sb->[$I]->{field_desc} = $sb_hash{$field_name} ; 
    $I++;
  }                   
  $tmpl->param(sb => $sb); 

  my $sql_stations = "SELECT station,first_name, last_name from smdr_stations "; 
  my $sth_stations = $dbh->prepare($sql_stations) ;
  $sth_stations->execute();
  my $stations ; 
  $I =0 ; 
  
  $stations->[$I]->{station} = "All"; 
  $stations->[$I]->{station_desc} = "All"; 
  $I++;
  while (my ($station,$first_name,$last_name) = $sth_stations->fetchrow_array() ) {
    $stations->[$I]->{station} = $station; 
    my $station_desc ; 
    if ($last_name || $first_name ) { 
       $station_desc = "$station - $first_name $last_name"; 
    }  else { 
       $station_desc = "$station"; 
    } 
    $stations->[$I]->{station_desc} = $station_desc; 
    $I++;
  } 
  $tmpl->param(stations => $stations); 

  my @call_types ; 
  push @call_types, {"smdr_call_type" => 'All'}; 
  push @call_types, {"smdr_call_type" => 'OUTBOUND'}; 
  push @call_types, {"smdr_call_type" => 'INBOUND'}; 
  push @call_types, {"smdr_call_type" => 'XFERED'}; 
  push @call_types, {"smdr_call_type" => 'BLOCKED'}; 

  $tmpl->param(smdr_call_types => \@call_types);


  $tmpl->param(mod => $self->module()); 
  $tmpl->param(func => "detail"); 

  $dbh->do("use voicemail"); 
  return $tmpl;   
}
sub process_date_params {
  my $self = shift ;
  my $date_field_name = shift || 'received_date' ;
  my $viewer_opt = shift ;
  return unless (defined($self))  ;
  my $wu = $self->{WEBUSER};
  my $dbh = $wu->dbh ();
  my $cgi = $wu->cgi ();
  my ($start_year,$start_month,$start_day, $end_year,$end_month,$end_day) ;
  print STDERR "date_opt_sel = " . $cgi->param('date_opt_sel') . "\n";
  if ($cgi->param('date_opt_sel') eq 'date_opts') {
     ($start_year,$start_month,$start_day, $end_year,$end_month,$end_day) =
     $self->get_date_range($cgi->param('date_opt') );
  }  elsif($cgi->param('date_opt_sel') eq 'date_params')  {
     if ($cgi->param('start_date') ) {
        ($start_month, $start_day, $start_year) = split (/\//, $cgi->param('start_date') ) ;  
     }
     if ($cgi->param('end_date')  && $cgi->param('end_date') ne $cgi->param('start_date') ) {
        ($end_month, $end_day, $end_year) = split (/\//, $cgi->param('end_date') )  ; 
     }
  } else {
     return undef;
  } 
  my @wheres; 
  my %display_params; 

  if ($start_year && $start_month && $start_day ) {
     my $where1 = " $date_field_name >= " . $dbh->quote(sprintf("%04d-%02d-%02d", $start_year, $start_month, $start_day));
     $display_params{"Start Date"} = "$start_month/$start_day/$start_year";
     push @wheres, $where1;
  }

  ## end date
  if ($end_year && $end_month && $end_day ) {
     my $where1 = " $date_field_name <=" . $dbh->quote(sprintf("%04d-%02d-%02d", $end_year, $end_month, $end_day));
     $display_params{'End Date'} = "$end_month/$end_day/$end_year";
     push @wheres, $where1;
  }

  print STDERR "$start_year && $start_month && $start_day $end_year && $end_month && $end_day \n";
  my $where ;  
  if (scalar(@wheres) == 0) {
     $where =undef; 
  } elsif (scalar(@wheres) == 1) {
     $where = $wheres[0]; 
     $where =~ s/>=|<=/=/;
  } else {  
     $where = join(" AND " , @wheres); 
  } 
  return ($where, \%display_params); 

} 

#################################
## sub get_date_param
#################################
sub get_date_range {
  my $self = shift ;
  my $viewer_opt = shift ; 
  return unless (defined($self))  ;
  my $wu = $self->{WEBUSER};
  my $dbh = $wu->dbh ();

  my ($cyear,$cmonth,$cday,$chour,$cminute,$csecond) = Date::Calc::Today_and_Now();
  my ($start_year,$start_month,$start_day,$end_year,$end_month,$end_day) = 
     (undef      ,undef       ,undef     ,undef    ,undef     ,undef); 
     if ($viewer_opt eq 'today' ) {
        ## this gets today's data
       ($start_year,$start_month,$start_day)= ($cyear,$cmonth,$cday) ;
       #($end_year,$end_month,$end_day)= ($cyear,$cmonth,$cday) ;
       # weekday
     } elsif ($viewer_opt eq 'yesterday' ) {
        ## this gets today's date
       ($start_year,$start_month,$start_day)= Date::Calc::Add_Delta_Days($cyear,$cmonth,$cday,-1) ;
       # ($end_hour,$end_minute,$end_second) =(23,59,59);
       # weekday
       ($start_year,$start_month,$start_day)= ($end_year,$end_month,$end_day);
       # ($start_hour,$start_minute,$start_second) =(0,0,0);
     } elsif ($viewer_opt eq 'thismonth') {
      ## this gets this month's data
       ($end_year,$end_month,$end_day)= ($cyear,$cmonth,$cday);
       # ($end_hour,$end_minute,$end_second) =(23,59,59);
                                                                                                                                               
       ($start_year,$start_month,$start_day)=  ($cyear,$cmonth,1);
       # ($start_hour,$start_minute,$start_second) =(0,0,0);
     }  elsif ($viewer_opt eq 'thisweek') {
       my ($week,$year) = Date::Calc::Week_of_Year($cyear,$cmonth,$cday) ;
       my ($mon_year,$mon_month,$mon_day) = Date::Calc::Monday_of_Week( $week,$year );

       ($end_year,$end_month,$end_day)= ($cyear,$cmonth,$cday);
       # ($end_hour,$end_minute,$end_second) =(23,59,59);

       ($start_year,$start_month,$start_day)=  ($mon_year,$mon_month,$mon_day);
       # ($start_hour,$start_minute,$start_second) =(0,0,0);
     }  elsif ($viewer_opt eq 'lastweek') {
       my ($week,$year) = Date::Calc::Week_of_Year($cyear,$cmonth,$cday) ;
       ($end_year,$end_month,$end_day) = Date::Calc::Monday_of_Week( $week,$year );
       ($end_year,$end_month,$end_day) = Date::Calc::Add_Delta_Days($end_year,$end_month,$end_day,-1);
       # ($end_hour,$end_minute,$end_second) =(0,0,0);
                                                                                                                                               
       ($start_year,$start_month,$start_day) = Date::Calc::Monday_of_Week( ($week-1),$year );
       # ($start_hour,$start_minute,$start_second) =(0,0,0);
                                                                                                                                               
     }

     return ($start_year,$start_month,$start_day, $end_year,$end_month,$end_day);
}
#################################
## sub detail
#################################
sub detail {
  my $self = shift ;
  return unless (defined($self))  ;
  my $wu = $self->{WEBUSER};
  my $session = $wu->cgi_session();
  my $dbh = $wu->dbh ();
  my $cgi = $wu->cgi ();

  $dbh->do("use smdr"); 
  my $PARAMS = $cgi->Vars;

  my $tmpl = new HTML::Template(filename =>  'templates/reports/detail.html');

  my @wheres ;
  my %rpt_params ; 
  my %display_params ; 

  my ($start_year,$start_month,$start_day, $end_year,$end_month,$end_day);
  ## get the date options
  if ($PARAMS->{date_opt_sel} eq 'date_opts') {
     ($start_year,$start_month,$start_day, $end_year,$end_month,$end_day) = 
     $self->get_date_range ($PARAMS->{date_opt} ); 
  }  else {
     if ($PARAMS->{begin_received_date} ) { 
        ($start_month, $start_day, $start_year) = split (/\//, $PARAMS->{begin_received_date}); 
     } 
     if ($PARAMS->{end_received_date} ) { 
        ($end_month, $end_day, $end_year) = split (/\//, $PARAMS->{end_received_date}); 
     } 
  } 

  ## begin date 
  if ($start_year && $start_month && $start_day ) { 
     my $where1 = " received_date >= " . $dbh->quote(sprintf("%04d-%02d-%02d", $start_year, $start_month, $start_day)); 
     $rpt_params{begin_received_date} = "$start_month/$start_day/$start_year"; 
     $display_params{"Start Date"} = $rpt_params{begin_received_date}; 
     push @wheres, $where1; 
  } 
  $tmpl->param('begin_date' => $rpt_params{begin_received_date});

  ## end date 
  if ($end_year && $end_month && $end_day ) { 
     my $where1 = " received_date <=" . $dbh->quote(sprintf("%04d-%02d-%02d", $end_year, $end_month, $end_day)); 
     $rpt_params{end_received_date} = "$end_month/$end_day/$end_year"; 
     $display_params{'End Date'} = $rpt_params{end_received_date}; 
     push @wheres, $where1; 
  } 
  $tmpl->param('end_date' => $rpt_params{end_received_date});

  ## account number
  if ($PARAMS->{account_number} ) {
     my $where1 = " account_number like '" . $PARAMS->{account_number} . "%'"; 
     $rpt_params{account_number} = $PARAMS->{account_number}; 
     $display_params{'Account Number'} = $rpt_params{account_number}; 
     push @wheres, $where1; 
  } 

  ## number dialed 
  if ($PARAMS->{number_dialed} ) {
     my $where1 = " number_dialed like '%" . $PARAMS->{number_dialed} . "%'"; 
     $rpt_params{number_dialed} = $PARAMS->{number_dialed}; 
     $display_params{'Number Dialed'} = $rpt_params{number_dialed}; 
     push @wheres, $where1; 
  } 

  ## station
  if ($PARAMS->{station} && $PARAMS->{station} ne 'All' ) {
     my $where1 = " station = '" . $PARAMS->{station} . "'"; 
     $rpt_params{station} = $PARAMS->{station}; 
     $display_params{'Station'} = $rpt_params{station}; 
     push @wheres, $where1; 
  } 

  ## smdr call type

  if ($PARAMS->{smdr_call_type}  && $PARAMS->{smdr_call_type} ne 'All'  ) {
     my $where1 = " smdr_call_type  = " . $dbh->quote($PARAMS->{smdr_call_type} ) ; 
     $rpt_params{smdr_call_type} = $PARAMS->{smdr_call_type} ; 
     $display_params{"Call Type"} = $rpt_params{smdr_call_type}; 
     push @wheres, $where1; 
     if ($PARAMS->{smdr_call_type} =~ /INCOMING/) { 
       $tmpl->param(number_dialed_label => "CALLER ID"); 
     }
  } 


  my $where_clause = join (" AND ", @wheres) ; 

  my $sql = qq{SELECT station,received_date, number_dialed, account_number, trunk_line, duration, 
          DATE_FORMAT(call_init_datetime,'%T') AS call_init_time, 
          DATE_FORMAT(call_end_datetime,'%T') AS call_end_time, 
          smdr_call_type  FROM smdr_data };
  if (scalar(@wheres) ) { 
    $sql .= " WHERE $where_clause "; 
  }
  ## the sort shit...

  if ($PARAMS->{sb1}) { 
     my $sb1 = $PARAMS->{sb1} ;
     my $sb2 = $PARAMS->{sb2} ;
     if (!$sb2) { 
        $sql .=   " ORDER BY $sb1 DESC, received_datetime DESC "; 
     } else {
        $sql .=   " ORDER BY $sb1, received_datetime DESC "; 
     } 
     my $var_name = $sb1 . '_sb' ; 
     $tmpl->param($var_name => !($sb2) ) ;
  }  else {
    ## default order by received_datetime
      $sql .=   " ORDER BY received_datetime DESC "; 
  } 

  ### report run here....
  print STDERR "sql = $sql\n" ; ##  if (WEB_DEBUG);
  my $sth = $dbh->prepare($sql);
  $sth->execute(); 
  my $I_outer=0;
  my $rpt; 
  while (my $hr = $sth->fetchrow_hashref() ) {
    
     $rpt->[$I_outer]->{smdr_call_type}= $hr->{smdr_call_type}; 
     if ($hr->{smdr_call_type} eq 'INCOMING' ) { 
        $hr->{number_dialed} =~ s/^808//; 
        $rpt->[$I_outer]->{number_dialed} =  $self->phone_number_format($hr->{number_dialed}) ; 
    }  else { 
        $rpt->[$I_outer]->{number_dialed} = $self->phone_number_format($hr->{number_dialed}) ; 
     } 
     $rpt->[$I_outer]->{station}= $hr->{station}; 
     $rpt->[$I_outer]->{received_date} = $hr->{received_date} ; 
     $rpt->[$I_outer]->{call_init_time} = $hr->{call_init_time} ; 
     $rpt->[$I_outer]->{call_end_time} = $hr->{call_end_time} ; 
     $rpt->[$I_outer]->{account_number} = $hr->{account_number} ; 
     $rpt->[$I_outer]->{trunk_line} = $hr->{trunk_line} ; 
     $rpt->[$I_outer]->{duration} = $hr->{duration} ; 
     $rpt->[$I_outer]->{odd_row} = $I_outer%2;
     $rpt->[$I_outer]->{num} = $I_outer+1 ; 
     $I_outer++;
  } 
  $tmpl->param(total => $I_outer); 
  if ($rpt) { 
    $tmpl->param(report => $rpt); 
  }

  my @http_args_ar;
  foreach my $key (keys %rpt_params) {
    push @http_args_ar, "$key=" . enurl($rpt_params{$key}); 
  } 
  my $http_args = join('&', @http_args_ar); 
  $tmpl->param(http_args => $http_args); 

  if (scalar(keys %display_params ) )  { 
    my $disp_params; 
    $I_outer=0;
    foreach my $title ( keys %display_params) {
       print  STDERR "disp_param = $title " if (WEB_DEBUG); 
       $disp_params->[$I_outer]->{title} = $title; 
       $disp_params->[$I_outer]->{value} = $display_params{$title}; 
       $I_outer++;
    } 
    $tmpl->param(disp_params => $disp_params); 
  }

  $tmpl->param(mod => $self->module()); 
  $tmpl->param(func => "detail"); 
   
  $sth->finish(); 

  my $sql_summary = qq{SELECT SEC_TO_TIME(sum(TIME_TO_SEC(duration))), count(*) FROM smdr_data } ; 
  if (scalar(@wheres) ) {
    $sql_summary .= " WHERE $where_clause ";
  }

  my @row_arry = $dbh->selectrow_array($sql_summary); 
  $tmpl->param(total_duration => $row_arry[0] ); 
  
   

  $dbh->do("use voicemail"); 
  return $tmpl; 
}
sub get_stations_hr {
  my $self = shift ; 

  my $wu = $self->{WEBUSER};
  my $session = $wu->cgi_session();
  my $dbh = $wu->dbh ();
  my $cgi = $wu->cgi ();

  my $sql = qq{SELECT station, first_name, last_name FROM smdr_stations };
  print STDERR "get_stations_hr = $sql\n" if (WEB_DEBUG); 
  my $hr  = $dbh->selectall_hashref($sql, "station");

  return $hr;
}
sub phone_number_format {
  my $self = shift ;
  my $number = shift ;
   ## take off any  1 at the beginning for outbound for
  $number =~ s/^1//g;
  #if ($number =~ /^1/) {
  #
  #}
  if ($number =~ /^(\d{3})(\d{3})(\d{4})$/) {
    my $area_code = $1;
    $number = "$2-$3";
    if ($area_code ne SMDR_AREA_CODE) {
       $number = "($area_code)$number";
    }
  } elsif ($number =~ /^(\d{3})(\d{4})$/) {
     $number = "$1-$2";
  }
  return $number  ;

}
1; 
