package OpenUMS::WWW::Stations;
### $Id: Stations.pm,v 1.1 2004/07/20 03:14:53 richardz Exp $
#
#
# Copyright (C) 2003 Integrated Comtel Inc.

use strict ; 

use HTML::Template; 

use OpenUMS::WWW::WebTools;
use Date::Calc; 
use Date::Format ;
                                                                                                                                               
use CGI::Enurl;


## always use the web tools
use OpenUMS::WWW::WebTools;

use base ("OpenUMS::WWW::WebModuleBase"); 

#################################
## sub module
#################################
sub module {
  return "Stations";
}
#################################
## sub main
## just the main guy, call station groups
#################################
sub main {
  my $self = shift ;
  return $self->station_groups();
}

#################################
## sub stations
## displays all the stations
#################################
sub stations { 
  my $self = shift ;
  return unless (defined($self))  ;
  my $wu = $self->{WEBUSER};
  my $dbh = $wu->dbh ();
  $dbh->do("use " . SMDR_DB); 
  my $cgi = $wu->cgi ();
  my $session = $wu->cgi_session();
  print STDERR " Got the session: id=" . $session->id() . "ext=" . $session->param('extension') . "\n" if (WEB_DEBUG);

  my $tmpl = new HTML::Template(filename =>  'templates/reports/station_main.html');
  my $sql = qq{SELECT station, first_name, last_name FROM smdr_stations ORDER by station} ; 
  print STDERR "sql = $sql\n "; 
  my $sth = $dbh->prepare($sql); 
  $sth->execute(); 
  my $station_data; 
  my $I =0; 
  while (my ($station, $first_name, $last_name) = $sth->fetchrow_array() ) {
      $station_data->[$I]->{station} = $station; 
      $station_data->[$I]->{first_name} = $first_name; 
      $station_data->[$I]->{last_name} = $last_name; 
      $station_data->[$I]->{mod} = $self->module();
      $I++; 
  } 
  if ($station_data) { 
    $tmpl->param('STATION_DATA', $station_data); 

  }
  $tmpl->param('mod', $self->module() ); 
  $tmpl->param('MSG', $cgi->param('msg') ); 
  $dbh->do("use " . VOICEMAIL_DB); 
  return $tmpl ;
}

#################################
## sub list_group
## lists stations that belong to a given group.
#################################
sub list_group {
  my $self = shift ;
  return unless (defined($self))  ;
  my $wu = $self->{WEBUSER};
  my $dbh = $wu->dbh ();
  $dbh->do("use " . SMDR_DB);
  my $cgi = $wu->cgi ();
  my $session = $wu->cgi_session();
  my $group_id = $cgi->param('group_id');  
  if (!$group_id) {
     return $self->station_groups();
  }  
  my $tmpl = new HTML::Template(filename =>  'templates/reports/station_group_list.html');

  my @values = $dbh->selectrow_array("SELECT group_name FROM smdr_groups WHERE group_id = $group_id") ; 
  my $group_name = $values[0]; 
  $tmpl->param('msg', $cgi->param('msg') ); 
  $tmpl->param('group_name' => $group_name ); 
  $tmpl->param('group_id' => $group_id ); 
  
  my $sql = qq(SELECT s.station, first_name, last_name FROM
    smdr_stations s INNER JOIN group_station_map m ON (s.station = m.station)
    WHERE group_id = $group_id ); 

  my $sth = $dbh->prepare($sql); 
  $sth->execute(); 

  my ($data,$I) = (undef,0); 
  while (my ($station, $first_name, $last_name)  = $sth->fetchrow_array()  ) { 
    $data->[$I]->{station} = $station ; 
    $data->[$I]->{first_name} = $first_name ; 
    $data->[$I]->{last_name} = $last_name ; 
    $I++;
  } 

  if ($data) { 
     $tmpl->param('GROUP_STATION_DATA',$data); 
  } 
  $tmpl->param('mod', $self->module() ); 
  $tmpl->param('func', 'delete_selected_stations' ); 
  $sth->finish();
  $dbh->do("use " . VOICEMAIL_DB);
  return $tmpl ; 
}

#################################
## sub delete_selected_stations
##  deletes from  the group the stations selected by the user
#################################
sub delete_selected_stations {

  my $self = shift ;

  my $wu = $self->{WEBUSER};
  my $dbh = $wu->dbh ();
  $dbh->do("use " . SMDR_DB);
  my $cgi = $wu->cgi ();
  my $session = $wu->cgi_session();

  my $group_id = $cgi->param('group_id'); 
  my @stations = $cgi->param('station'); 
  if (!$group_id ) { 
     print $cgi->redirect('admin.cgi?mod=' . $self->module() . "");
     exit ;
  }
 
  my $msg; 
  print STDERR "group id = $group_id\n" if (WEB_DEBUG);
  if ($group_id eq '1') {
    $msg .= "Sorry, you can't delete from the Everyone group. "; 
    print $cgi->redirect('admin.cgi?mod=' . $self->module() . "&func=list_group&group_id=$group_id&msg=$msg");
    exit; 
  } 
  if ($group_id ) { 
    my $sql  = qq{DELETE FROM group_station_map WHERE station = ? AND group_id = ? } ;  
    my $sth  = $dbh->prepare($sql); 
    foreach my $station (@stations) { 
       $sth->execute($station,$group_id); 
       print STDERR "station = $station\n" if (WEB_DEBUG);
       $sth->finish(); 
    } 
  } 
  $msg = join (", ", @stations); 
  $msg .= " deleted from this group "; 
  print $cgi->redirect('admin.cgi?mod=' . $self->module() . "&func=list_group&group_id=$group_id&msg=$msg");
  exit ;
  return $self->station_search(); 

}


#################################
## sub add_member_save
##  adds members to the group
##  if it's a new group, it creates that group too
#################################
sub add_member_save {

  my $self = shift ;

  my $wu = $self->{WEBUSER};
  my $dbh = $wu->dbh ();
  $dbh->do("use " . SMDR_DB);
  my $cgi = $wu->cgi ();
  my $session = $wu->cgi_session();

  my @stations = $cgi->param('station');
  if (scalar(@stations) == 0 ) { 
    my $msg = "Nothing to add :("; 
    print $cgi->redirect('admin.cgi?mod=' . $self->module() . "&msg=$msg");
  } 

  my $group_id ;  

  if ($cgi->param('add_to_group') )  { 
    $group_id = $cgi->param('group_id'); 
  } elsif ( $cgi->param('add_new_group') )  {
    $group_id = $self->create_group($cgi->param('new_group_name') ) ; 
  } 

  print STDERR "group id = $group_id\n" if (WEB_DEBUG);
  if ($group_id ) { 
    my $sql  = qq{INSERT INTO group_station_map (station,group_id) VALUES (?,?) } ;  
    my $sth  = $dbh->prepare($sql); 
    foreach my $station (@stations) { 
       $sth->execute($station,$group_id); 
       print STDERR "station = $station\n" if (WEB_DEBUG);
       $sth->finish(); 
    } 
  } 
  my $msg = join(",", @stations) . " added"; 
  print $cgi->redirect('admin.cgi?mod=' . $self->module() . "&msg=$msg");
  exit ;
}

#################################
## sub station_search
##   search for a station to add
#################################
sub station_search {
  my $self = shift ;
  return unless (defined($self))  ;
  my $wu = $self->{WEBUSER};
  my $dbh = $wu->dbh ();
  $dbh->do("use " . SMDR_DB);
  my $cgi = $wu->cgi ();
  my $session = $wu->cgi_session();
  my $tmpl = new HTML::Template(filename =>  'templates/reports/station_search.html');

  my $search_val = $cgi->param('search_val'); 
  $tmpl->param('mod', $self->module() ); 
  $tmpl->param('search_func', "station_search"); 
  $tmpl->param('search_val', $search_val); 

  if ($search_val || $cgi->param('list_all') ) {
    my $data = $self->get_search_data($search_val); 
    $tmpl->param('add_func', 'add_member_save'); 
    if ($data) { 
      $tmpl->param('search_data', $data ); 
    }  ## else {
       ## $tmpl->param('search_data', undef ); 
       ## } 
    my $group_opts = $self->get_group_opts($cgi->param('group_id') )  ; 
    if ($group_opts) { 
       $tmpl->param('group_opts', $group_opts ); 
    }  
  } 
  

  $dbh->do("use " . VOICEMAIL_DB);
  return $tmpl ;
}

#################################
## sub get_search_data
##   returns the search results to be placed in the template
#################################
sub get_search_data {
  my ($self, $search_val ) = @_ ; 
  my $wu = $self->{WEBUSER};
  my $dbh = $wu->dbh ();
  $dbh->do("use " . SMDR_DB);
  my $sql = qq(SELECT station, first_name, last_name 
     FROM smdr_stations 
     WHERE station  like '$search_val%'
        OR first_name  like '$search_val%'
        OR last_name  like '$search_val%' ); 
  my $sth = $dbh->prepare($sql); 
  $sth->execute(); 
  my ($data,$I) = (undef,0); 
  
  while (my ($station, $first_name, $last_name) = $sth->fetchrow_array() ) {
    $data->[$I]->{station} = $station;
    $data->[$I]->{first_name} = $first_name;
    $data->[$I]->{last_name} = $last_name;
    $I++; 
  }
  $sth->finish();
  return $data; 
}

#################################
## sub station_groups
##  lists all the groups availabe 
#################################
sub station_groups {
  my $self = shift ;
  return unless (defined($self))  ;
  my $wu = $self->{WEBUSER};
  my $dbh = $wu->dbh ();
  $dbh->do("use " . SMDR_DB);
  my $cgi = $wu->cgi ();
  my $session = $wu->cgi_session();

  my $tmpl = new HTML::Template(filename =>  'templates/reports/station_groups.html');
  my $sql = qq{SELECT group_name, group_id, everyone FROM smdr_groups } ;
  print STDERR "sql = $sql\n " if (WEB_DEBUG);
  my $sth = $dbh->prepare($sql);
  $sth->execute();
  my $data;
  my $I =0;
  while (my ($group_name, $group_id,$everyone) = $sth->fetchrow_array() ) {
      print STDERR "group_name = $group_name $everyone \n"; 
      $data->[$I]->{group_id} = $group_id;
      $data->[$I]->{group_name} = $group_name;
      $data->[$I]->{everyone} = $everyone;
      $data->[$I]->{mod} = $self->module();
      $I++;
  }
  if ($data) {
    $tmpl->param('GROUP_DATA', $data);
  }
  $tmpl->param('MSG', $cgi->param('msg') );
  $tmpl->param('MOD', $self->module() );
  $dbh->do("use " . VOICEMAIL_DB);
  return $tmpl ;

  

}


#################################
## sub edit_station
##  allows basic info in station table (first_name, last_name) to be changed 
#################################
sub edit_station  {

  my $self = shift ;
  return unless (defined($self))  ;
  my $wu = $self->{WEBUSER};
  my $session = $wu->cgi_session();
  my $dbh = $wu->dbh ();
  $dbh->do("use " . SMDR_DB); 
  my $cgi = $wu->cgi ();
                                                                                                                                               
  my $station  = $cgi->param('station');
  if (!$station) { 
    return $self->main(); 
  } 

  ## setup the template
  my $tmpl = new HTML::Template(filename =>  'templates/reports/station_edit.html');
  $tmpl->param(mod => $self->module() ) ; 
  $tmpl->param(func => "edit_station_save" ) ; 

  $tmpl->param(STATION => $station );
  my $u; 
  ## get the user info
  if ($self->{error_message} ) {
    $u = $cgi->Vars();
  } else {
    my $sql = qq{SELECT first_name, last_name FROM smdr_stations WHERE station = ?};
    my $sth = $dbh->prepare($sql) ; 
    $sth->execute($station); 
    $u = $sth->fetchrow_hashref(); 
    $sth->finish(); 
  }

  $tmpl->param(FIRST_NAME => $u->{'first_name'}  );
  $tmpl->param(LAST_NAME => $u->{'last_name'} ) ;
                                                                                                                                               
  $dbh->do("use " . VOICEMAIL_DB); 
  return $tmpl ;

}

#################################
## sub edit_station_save
##   saves the edit_station form
#################################
sub edit_station_save  {
  my $self = shift ;
  return unless (defined($self))  ;
  my $wu = $self->{WEBUSER};
  my $session = $wu->cgi_session();
  my $dbh = $wu->dbh ();
  $dbh->do("use " . SMDR_DB); 
  my $cgi = $wu->cgi ();

  my $msg = "Station updated.";
  if ($cgi->param('station') ) { 
    my $msg = "Station saved.";
    my $upd = "UPDATE smdr_stations SET first_name = " 
        . $dbh->quote($cgi->param('first_name') ) . ", "
        .  "last_name = " 
        . $dbh->quote($cgi->param('last_name') )
        . " WHERE station = ". $cgi->param('station') ; 
    $dbh->do($upd); 
    print $cgi->redirect('admin.cgi?mod=' . $self->module() . "&func=stations&msg=$msg");
    exit ;
  }  else { 
    print $cgi->redirect('admin.cgi?mod=' . $self->module() . "&func=stations");
    exit ;
  } 
}
#################################
## sub edit_group
##  change the group  name, basically that's all there is to edit
#################################
sub edit_group {

  my $self = shift ;

  return unless (defined($self))  ;
  my $wu = $self->{WEBUSER};
  my $session = $wu->cgi_session();
  my $dbh = $wu->dbh ();
  $dbh->do("use " . SMDR_DB);
  my $cgi = $wu->cgi ();
  my $group_id = $cgi->param('group_id'); 
  if (!$group_id) { 
    return $self->main(); 
  } 
    if ($group_id eq '1') {
    ## 1 is the Everyone group, don't let them do this...
    my $msg .= "Sorry, you can't edit 'Everyone' group. ";
    print $cgi->redirect('admin.cgi?mod=' . $self->module() . "&func=station_groups&msg=$msg");
    exit;
  }


  my @values = $dbh->selectrow_array("SELECT group_name FROM smdr_groups where group_id = $group_id") ;
  my $group_name = $values[0];
  my $tmpl = new HTML::Template(filename =>  'templates/reports/station_group_edit.html');
  $tmpl->param('old_group_name' => $group_name );
  $tmpl->param('group_id' => $group_id );
 
  $tmpl->param(mod => $self->module() ) ;
  $tmpl->param(func => "edit_group_save" ) ;
  $dbh->do("use " . VOICEMAIL_DB);
  return $tmpl; 

}

#################################
## sub edit_group_save
## saves the edit form, updates the name
#################################
sub edit_group_save {

  my $self = shift ;
  return unless (defined($self))  ;
  my $wu = $self->{WEBUSER};
  my $session = $wu->cgi_session();
  my $dbh = $wu->dbh ();
  $dbh->do("use " . SMDR_DB);
  my $cgi = $wu->cgi ();

  my $group_id = $cgi->param('group_id');
  if (!$group_id) { 
     print $cgi->redirect('admin.cgi?mod=' . $self->module() );
      exit ;
  } 

  if ($group_id eq '1') {
    ## 1 is the Everyone group, don't let them do this...
    my $msg .= "Sorry, you can't save changes to the  'Everyone' group. ";
    print $cgi->redirect('admin.cgi?mod=' . $self->module() . "&func=station_groups&msg=$msg");
    exit;
  }

  my $group_name = $cgi->param('new_group_name');
  my $upd = qq(UPDATE smdr_groups SET group_name = '$group_name' WHERE group_id = $group_id ); 
  $dbh->do($upd); 
  my $msg = "$group_name updated.."; 
  print $cgi->redirect('admin.cgi?mod=' . $self->module() . "&msg=$msg");
  $dbh->do("use " . VOICEMAIL_DB);
  exit ;

}



#################################
## sub delete_group_conf
##  Asks them if they really wanna delete the group
#################################
sub delete_group_conf {
  my $self = shift ;

  return unless (defined($self))  ;
  my $wu = $self->{WEBUSER};
  my $session = $wu->cgi_session();
  my $dbh = $wu->dbh ();
  $dbh->do("use " . SMDR_DB);
  my $cgi = $wu->cgi ();
  my $group_id = $cgi->param('group_id'); 
  if (!$group_id) { 
    return $self->main(); 
  } 

  if ($group_id eq '1') {
    ## 1 is the Everyone group, don't let them do this...
    my $msg .= "Sorry, you can't delete 'Everyone' group. ";
    print $cgi->redirect('admin.cgi?mod=' . $self->module() . "&func=station_groups&msg=$msg");
    exit;
  } 

  my @values = $dbh->selectrow_array("SELECT group_name FROM smdr_groups WHERE group_id = $group_id") ;
  my $group_name = $values[0];
  my $tmpl = new HTML::Template(filename =>  'templates/reports/station_group_delete_conf.html');
  $tmpl->param('group_name' => $group_name );
  $tmpl->param('group_id' => $group_id );
 
  $tmpl->param(mod => $self->module() ) ;
  $tmpl->param(func => "delete_group" ) ;
  $dbh->do("use " . VOICEMAIL_DB);
  return $tmpl; 


}

#################################
## sub get_group_opts
##  gets the array ref required to make the group_opts drop down 
#################################
sub get_group_opts {
  my ($self,$sel) = @_ ; 
  my $wu = $self->{WEBUSER};
  my $dbh = $wu->dbh ();
  $dbh->do("use " . SMDR_DB);
  my $sql = qq(SELECT group_id, group_name FROM smdr_groups WHERE everyone = 0  ); 
  my $sth = $dbh->prepare($sql); 
  $sth->execute(); 
  my ($data,$I) = (undef,0); 
  while (my ($group_id, $group_name ) = $sth->fetchrow_array() ) {
    $data->[$I]->{group_id} = $group_id; 
    $data->[$I]->{group_name} = $group_name; 
    $I++; 
  } 
  $sth->finish(); 
  return $data; 
}


#################################
## sub create_group
##  accepts a group name, makes a record in the db and returns the new group id
#################################
sub create_group {
  my $self = shift ;
  my $group_name  = shift ;
  return unless (defined($self))  ;
  my $wu = $self->{WEBUSER};
  my $session = $wu->cgi_session();
  my $dbh = $wu->dbh ();
  $dbh->do("use " . SMDR_DB);
  my $cgi = $wu->cgi ();
  my $ins = "INSERT INTO smdr_groups (group_name) VALUES (" . $dbh->quote($group_name) . ")";
  $dbh->do($ins);
  my $new_group_id = $dbh->{mysql_insertid} ; 
  if (!$new_group_id) {
     ## maybe it already exists  
     my @values = $dbh->selectrow_array("SELECT group_id FROM smdr_groups WHERE group_name = " . $dbh->quote($group_name) ) ;
     $new_group_id  = $values[0] ;
  } 
  return $new_group_id ; 
}

#################################
## sub delete_group
##  deletes the given group id
#################################
sub delete_group {
  my $self = shift ;
  return unless (defined($self))  ;
  my $wu = $self->{WEBUSER};
  my $session = $wu->cgi_session();
  my $dbh = $wu->dbh ();
  $dbh->do("use " . SMDR_DB);
  my $cgi = $wu->cgi ();

  my $group_id = $cgi->param('group_id');
  if (!$group_id) { 
     print $cgi->redirect('admin.cgi?mod=' . $self->module() );
      exit ;
  } 

  if ($group_id eq '1') {
    ## 1 is the Everyone group, don't let them do this...
    my $msg .= "Sorry, you can't delete 'Everyone' group. ";
    print $cgi->redirect('admin.cgi?mod=' . $self->module() . "&func=station_groups&msg=$msg");
    exit;
  }

  my $group_name = $cgi->param('new_group_name');
  my $del1 = qq(DELETE FROM smdr_groups WHERE group_id = $group_id ); 
  $dbh->do($del1); 
  $del1 = qq(DELETE FROM group_station_map WHERE group_id = $group_id ); 
  $dbh->do($del1); 
  my $msg = "$group_name deleted.."; 
  print $cgi->redirect('admin.cgi?mod=' . $self->module() . "&msg=$msg");
  $dbh->do("use " . VOICEMAIL_DB);
  exit ;


}

1;
