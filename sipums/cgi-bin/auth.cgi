#!/usr/bin/perl

close (STDERR)  ; 
open (STDERR, ">>/tmp/auth.err"); 
print STDERR "-------- begin sess.cgi" ;



use strict ; 
use lib "/usr/local/openums/lib"; 

use CGI; 
use HTML::Template ; 
use OpenUMS::Common ; 
use OpenUMS::DbQuery ; 

my $cgi = new CGI; 

print STDERR "hi kef\n";
print STDERR "shoe gazer server=" . $cgi->server_name() . "\n";


my $ext = $cgi->param('ext'); 
my $password = $cgi->param('password'); 

  ## first make sure they filled out the form...

if (!$ext || !$password ) {
  print  $cgi->redirect("login.cgi?ext=$ext&msg=NO EXTENSION");  
  exit ; 
} 

#  NOw verfiy their password

my $dbh = OpenUMS::Common::get_dbh(); 
my $auth = OpenUMS::DbQuery::validate_password($dbh, $ext, $password); 
#my $u = OpenUMS::DbQuery::get_user_info($dbh, $ext); 

if (!$auth) { 
  print  $cgi->redirect("login.cgi?ext=$ext&msg=AUTH FAILED");  
} else {
  ## they are good, let's hoook them up...

  require 'openums-www.pl';
  &post_login($dbh, $cgi, $ext) ; 
  exit ; 
##  my $u = OpenUMS::DbQuery::get_user_info($dbh, $ext); 
##  print STDERR "Going to get pemrission id \n"; 
##  my $permission_id = OpenUMS::DbQuery::user_permission_id($dbh,$ext ); 
##  print STDERR "pemrission id = $permission_id \n"; 
##
## use CGI::Session;
## use CGI::Session::MySQL;
##  $CGI::Session::MySQL::TABLE_NAME = 'web_sessions';
##  my $session = new CGI::Session("driver:MySQL", undef, {Handle=>$dbh});
##
##
##  $session->param('extension', $ext) ; 
##  $session->param('permission_id',  $permission_id) ; 
## get the session id and create a cookie
##  my $CGISESSID = $session->id() ;  
## my $cookie = $cgi->cookie(CGISESSID => $CGISESSID );
## redirect and send the cookie...
##  my $uri = "user.cgi";  ## default, redirect them to the user page....
## print STDERR "permission_id is $permission_id\n"; 
##  if ($permission_id =~ /^SUPER|^ADMIN/ ) { 
##  $uri = "admin.cgi"; 
## } 
##  if ($u->{store_flag} eq 'E') {
##     print STDERR "It's e-mail store, we check check to make sure their password is valid...\n";
##     use OpenUMS::IMAP; 
##     my $imap = OpenUMS::IMAP::open_imap_connection($dbh, $ext) ;
##  
##     if (defined($imap) ) { 
##       print STDERR "Imap connection is ok, closing it\n"; 
##       $imap->close() ; 
##     } else { 
##       print STDERR "Imap connection could not be establish, sending user to page to change password\n"; 
##        $uri = "user.cgi?mod=User&func=edit_email_password"; 
##     }
##  } 
##
##  print $cgi->redirect(-uri=>$uri , -cookie=>$cookie );

}
