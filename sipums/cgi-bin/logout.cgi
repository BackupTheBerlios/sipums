#!/usr/bin/perl

#close (STDERR)  ; 
#open (STDERR, ">>/tmp/logout.err"); 

use strict ; 
use lib "/usr/local/openums/lib"; 

require 'openums-www.pl';
my ($dbh, $cgi, $session) = begin();
print STDERR "-- called begin logout.cgi" ;
print STDERR "-- session id is " . $session->id() . "\n" ;  ;
$session->close() ; 
$session->delete() ; 

print  $cgi->redirect("login.cgi");  
exit ; 
