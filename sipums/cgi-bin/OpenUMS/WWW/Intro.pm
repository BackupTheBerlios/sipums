package OpenUMS::WWW::Intro;
### $Id: Intro.pm,v 1.1 2004/07/20 03:14:53 richardz Exp $
#
# WWW/Intro.pm
#
# Introduction to ...
#
# Copyright (C) 2003 Integrated Comtel Inc.


use HTML::Template; 
use OpenUMS::DbQuery; 

## always use the web tools
use OpenUMS::WWW::WebTools;

use base ("OpenUMS::WWW::WebModuleBase"); 


#################################
## sub main
#################################
sub main {
  my $self = shift ; 
  return unless (defined($self))  ; 
  my $wu = $self->{WEBUSER}; 
  my $session = $wu->cgi_session(); 
  print STDERR " Got the session: id=" . $session->id() . "ext=" . $session->param('extension') . "\n" if (WEB_DEBUG); 
#  my $session_id = $session->session_id() ; 

  my $tmpl = new HTML::Template(filename =>  'templates/welcome.html');  
#  $tmpl->param('session_id',$session->id()  ) ; 
  my $dbh = $wu->dbh(); 
  my ($first_name,$last_name) = OpenUMS::DbQuery::get_first_last_names($dbh,$session->param('extension'));
#  $tmpl->param('ext',$session->param('extension') ); 
  $tmpl->param('permission_id',$session->param('permission_id') ); 
  $tmpl->param('first_name',$first_name ); 
  $tmpl->param('last_name',$last_name   ); 
  if ($wu->permission_id() ne 'USER') {
    $tmpl->param(SHOW_PERMISSION => 1   ); 
  }
  return $tmpl ;  


} 

1; 
