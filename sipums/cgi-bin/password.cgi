#!/usr/bin/perl

close (STDERR)  ; 
open (STDERR, ">>/tmp/password.err"); 
print STDERR "-------- begin sess.cgi" ;

use strict ; 
use lib "/usr/local/openums/lib"; 

use CGI; 
use HTML::Template ; 
use OpenUMS::Common ; 
use OpenUMS::DbQuery ; 

my $cgi = new CGI; 

my $ext_enc = $cgi->param('p1'); 
my $pw_enc = $cgi->param('p2'); 

## first make sure they filled out the form...

if (!$ext_enc || !$pw_enc) {
  print  $cgi->redirect("login.cgi?msg=Invalid Login");  
  exit ; 
} 

#  NOw verfiy their password

my $dbh = OpenUMS::Common::get_dbh(); 
my $ext = OpenUMS::DbQuery::web_password_validate($dbh, $ext_enc, $pw_enc); 

if (!$ext) { 
  print  $cgi->redirect("login.cgi?msg=AUTH FAILED");  
} else {
  ## they are good, let's hoook them up...
  require 'openums-www.pl';
  &post_login($dbh, $cgi, $ext) ;
  exit ;
}
