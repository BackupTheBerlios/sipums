package OpenUMS::WWW::Server;
### $Id: Server.pm,v 1.1 2004/07/20 03:14:53 richardz Exp $
#
# WWW/User.pm
#
# this is the User Module for the web interface : )
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
use OpenUMS::Permissions; 
use Telephony::CTPortManager;


use base ("OpenUMS::WWW::WebModuleBase"); 

#################################
## sub module
#################################
sub module {
  return "User"; 
}
#################################
## sub main
#################################
sub main {
  my $self = shift ; 
  return unless (defined($self))  ; 
  my $wu = $self->{WEBUSER}; 
  my $session = $wu->cgi_session(); 
  my $dbh = $wu->dbh (); 
  my $cgi = $wu->cgi (); 

  ## setup the template 
  my $tmpl = new HTML::Template(filename =>  'templates/server_main.html');  
  ##my $info = `/usr/local/openums/CPcheck`;
  my $info;

  my $ctport = new Telephony::CTPortManager();  
  my $port_status = $ctport->port_status(); 
  my @rows ; 

  foreach my $port (keys %{$port_status} ) {
    my %row; 
    $row{port} = $port; 
    $row{status} = $port_status->{$port} ; 
    push  @rows, \%row ; 
  } 
  $tmpl->param('kelepona_status' => \@rows); 
  my %openums_stats;
  my $data = `tail -1000 /var/log/openums/openums.log`;
 
  my @data = split(/\n/,$data);
  my $size = scalar(@data) ;

  foreach my $line (@data) {
    $line =~ m/\[(\d\d\d\d)\]/ ;
    my $port = $1;
    if ($port =~ /1200|1201|1202|1203/ ){
      $openums_stats{$port} = $line;
    }
  }
  my @ou_rows ; 
  foreach my $port (keys %openums_stats) { 
    my %row;
    $row{port} = $port;
    $row{status} = $openums_stats{$port} ;
    push  @ou_rows, \%row ; 
 
    print STDERR "$port $openums_stats{$port} \n"; 
  } 

  $tmpl->param('openums_status' => \@ou_rows ); 

  $tmpl->param('msg' => $cgi->param('msg')); 
  $tmpl->param('error_msg' => $cgi->param('error_msg')); 
#  $tmpl->param('info' => $new_info); 

  return $tmpl; 
}
1; 
