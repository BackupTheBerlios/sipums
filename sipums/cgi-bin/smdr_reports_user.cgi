#!/usr/bin/perl

#  close (STDERR) ; 
#  open  (STDERR, ">>/tmp/openums-www.err");
#  print STDERR "called begin :) \n"  ;

## all the required

use strict; 
use lib '/usr/local/openums/lib';
use OpenUMS::DbUtils ; 
require 'openums-www.pl'; 

my ($dbh, $cgi, $session,$permissions) = begin(); 

use HTML::Template ; 
use OpenUMS::Common ; 
use OpenUMS::WWW::WebUser ; 

## the main template

my $tmpl = HTML::Template->new(filename => 'templates/reports/u_smdr_reports.html');

## if they have Super permission, set the SUPER var
#if ($session->param('permission_id') =~ /^SUPER/) { 
#  $tmpl->param(SUPER => 1); 
#}

## get the module they are calling .... 
my $mod = $cgi->param('mod') || 'Reports' ; 
my $func = $cgi->param('func') || 'main'; 
my $webUser = new OpenUMS::WWW::WebUser($dbh,$cgi,$session,$permissions); 
my $tmpl_det; 

if (isValidMod($mod)) { 
  if (isValidModFunc($mod,$func) )  { 
     my $modRef = getModRef($mod, $webUser); 
     $tmpl_det = $modRef->$func(); 
  }  
}  
## nothing came back?????
if (!defined( $tmpl_det ) )  {
   $tmpl_det = HTML::Template->new(filename => 'templates/invalid.html'); 
} 

$tmpl->param('RIGHT_COL', $tmpl_det->output() ) ;

print $cgi->header (); 
print $tmpl->output() ; 

finish($dbh); 
