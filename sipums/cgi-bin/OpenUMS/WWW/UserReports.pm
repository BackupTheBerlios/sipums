package OpenUMS::WWW::UserReports;
### $Id: UserReports.pm,v 1.1 2004/07/20 03:14:53 richardz Exp $
#
#
# Introduction to ...
#
# Copyright (C) 2003 Integrated Comtel Inc.

use strict ; 

use HTML::Template; 
use Date::Calc; 

use OpenUMS::WWW::WebTools;
                                                                                                                                               
use HTML::Template;
use OpenUMS::WWW::WebTools;

use Date::Format ;
 use CGI::Enurl;


## always use the web tools
use OpenUMS::WWW::WebTools;

use base ("OpenUMS::WWW::WebModuleBase"); 

#################################
## sub module
#################################
sub module {
  return "UserReports";
}
#################################
## sub main
#################################
sub main {
  my $self = shift ;
  return $self->detail_params() ; 

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
  my $tmpl = new HTML::Template(filename =>  'templates/reports/u_detail_params.html');

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

#  my $sql_stations = "SELECT station,first_name, last_name from smdr_stations "; 
#  my $sth_stations = $dbh->prepare($sql_stations) ;
#  $sth_stations->execute();
#  my $stations ; 
#  $I =0 ; 
#  
#  $stations->[$I]->{station} = "All"; 
#  $stations->[$I]->{station_desc} = "All"; 
#  $I++;
#  while (my ($station,$first_name,$last_name) = $sth_stations->fetchrow_array() ) {
#    $stations->[$I]->{station} = $station; 
#    my $station_desc ; 
#    if ($last_name || $first_name ) { 
#       $station_desc = "$station - $first_name $last_name"; 
#    }  else { 
#       $station_desc = "$station"; 
#    } 
#    $stations->[$I]->{station_desc} = $station_desc; 
#    $I++;
#  } 
#  $tmpl->param(stations => $stations); 

  my @call_types ; 
  push @call_types, {"smdr_call_type" => 'All'}; 
  push @call_types, {"smdr_call_type" => 'OUTBOUND'}; 
  push @call_types, {"smdr_call_type" => 'INBOUND'}; 
  push @call_types, {"smdr_call_type" => 'XFERED'}; 
  push @call_types, {"smdr_call_type" => 'BLOCKED'}; 

  $tmpl->param(smdr_call_types => \@call_types);


  $tmpl->param(mod => $self->module()); 
  $tmpl->param(func => "detail"); 

  $dbh->do("use voicemailCT"); 
  return $tmpl;   
}

#################################
## sub get_date_range
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
       ($end_year,$end_month,$end_day)= ($cyear,$cmonth,$cday) ;
       # ($end_hour,$end_minute,$end_second) =(23,59,59);
       # weekday
       ($start_year,$start_month,$start_day)= ($cyear,$cmonth,$cday) ;
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

  my $tmpl = new HTML::Template(filename =>  'templates/reports/u_detail.html');

  my @wheres ;
  my %rpt_params ; 
  my %display_params ; 

  my $extension = $session->param('extension'); 
  my ($start_year,$start_month,$start_day, $end_year,$end_month,$end_day);
  ## get the date options
  my $where2 = " station = $extension "  ; 
  push @wheres, $where2;

  
  if ($PARAMS->{date_opt_sel} eq 'date_opt') {
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

  ## end date 
  if ($end_year && $end_month && $end_day ) { 
     my $where1 = " received_date <=" . $dbh->quote(sprintf("%04d-%02d-%02d", $end_year, $end_month, $end_day)); 
     $rpt_params{end_received_date} = "$end_month/$end_day/$end_year"; 
     $display_params{'End Date'} = $rpt_params{end_received_date}; 
     push @wheres, $where1; 
  } 

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
   print STDERR "smdr_call_type = $PARAMS->{smdr_call_type} \n" if (WEB_DEBUG); 

  if ($PARAMS->{smdr_call_type}  && $PARAMS->{smdr_call_type} ne 'All'  ) {
     my $where1 = " smdr_call_type  = " . $dbh->quote($PARAMS->{smdr_call_type} ) ; 
     print STDERR "wher1 = $where1\n" if (WEB_DEBUG);
     $rpt_params{smdr_call_type} = $PARAMS->{smdr_call_type} ; 
     $display_params{"Call Type"} = $rpt_params{smdr_call_type}; 
     push @wheres, $where1; 
     if ($PARAMS->{smdr_call_type} =~ /INCOMING/) { 
       $tmpl->param(number_dialed_label => "CALLER ID"); 
     }
  } 


  my $where_clause = join (" AND ", @wheres) ; 
  print STDERR "where_clause=$where_clause scalar = " . scalar(@wheres) ."\n" if (WEB_DEBUG); 

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
        $sql .=   " ORDER BY $sb1 DESC , received_datetime DESC "; 
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
  print STDERR "sql = $sql\n" if (WEB_DEBUG);
  my $sth = $dbh->prepare($sql);
  $sth->execute(); 
  my $I_outer=0;
  my $rpt; 
  while (my $hr = $sth->fetchrow_hashref() ) {
    
     $rpt->[$I_outer]->{smdr_call_type}= $hr->{smdr_call_type}; 
     if ($hr->{smdr_call_type} eq 'INCOMING' ) { 
        $hr->{number_dialed} =~ s/^808//; 
        $rpt->[$I_outer]->{number_dialed} = $hr->{number_dialed} ; 
    }  else { 
        $rpt->[$I_outer]->{number_dialed} = $hr->{number_dialed} ; 
     } 
     $rpt->[$I_outer]->{station}= $hr->{station}; 
     $rpt->[$I_outer]->{received_date} = $hr->{received_date} ; 
     $rpt->[$I_outer]->{call_init_time} = $hr->{call_init_time} ; 
     $rpt->[$I_outer]->{call_end_time} = $hr->{call_end_time} ; 
     $rpt->[$I_outer]->{account_number} = $hr->{account_number} ; 
     $rpt->[$I_outer]->{trunk_line} = $hr->{trunk_line} ; 
     $rpt->[$I_outer]->{duration} = $hr->{duration} ; 
     $rpt->[$I_outer]->{odd_row} = $I_outer%2;
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
  $dbh->do("use voicemailCT"); 
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
1; 
