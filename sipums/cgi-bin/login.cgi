#!/usr/bin/perl

use strict ;
close (STDERR)  ; 
open (STDERR, ">>/tmp/login.err"); 

use lib "/usr/local/openums/lib"; 

use CGI; 
use HTML::Template ; 
use OpenUMS::Common ; 


my $cgi = new CGI; 
print $cgi->header (); 

my $tmpl = HTML::Template->new(filename => 'templates/login.html');
$tmpl->param('ACTION', 'auth.cgi') ;
$tmpl->param('EXT' , $cgi->param('ext') ) ;
$tmpl->param('MSG' , $cgi->param('msg') ) ;

print $tmpl->output() ; 










