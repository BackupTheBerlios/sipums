#! /usr/bin/perl
################################################################################
$VERSION='replace.pl v1.1'; # December 1996 Dale Bewley <dale@bewley.net>
#VERSION='replace.pl v1'; # July 1996 Dale Bewley <dale@bewley.net>
#------------------------------------------------------------------------------#
# This script and others found at: http://www.bewley.net/perl/
#
# nph-replace.pl is a simple demo of a multipart document and server push. 
# If you have always wondered how to have a CGI output some virtual HTML then 
# think for a while and output more virtual HTML now you know.
#
################################################################################

$| = 1;

require 'openums-www.pl' ; 


close (STDERR);
open STDERR, ">>/tmp/restart.err"; 

#print STDERR "Hi kievn\n";
my ($dbh, $cgi, $session,$permissions) = begin();
if ($session->param('permission_id') !~ /^SUPER/ && $session->param('permission_id') !~/^ADMIN/ ) {
   print '<META HTTP-EQUIV="Pragma" CONTENT="no-cache"> <META HTTP-EQUIV="Expires" CONTENT="-1">'; 
   print "<H1><font color='red'>YOU DO NOT HAVE PERMISSION TO PERFORM THIS ACTION</h1>";
   exit ;
}

use CGI qw/:standard/;
use CGI::Enurl;

$|=1;					# don't buffer output

#  print "Content-type: text/html\n\n"; 	# tells it what kind
print header(-nph  => 1);                      # Top-Header


print '<META HTTP-EQUIV="Pragma" CONTENT="no-cache"> <META HTTP-EQUIV="Expires" CONTENT="-1">'; 
print "<h1>RESTARTING CONVERGE-PRO<BR>DO NOT HIT STOP!!!!</h1>\n";
print " By hitting the 'Stop' button on your browser, you could send the system into an unstable state. <BR><BR><BR>\n";

print "stopping....\n";
my $stop = system("sudo /usr/local/openums/CPstop 1>> /var/log/openums/stop.out 2>> /var/log/openums/stop.err");
sleep(5);
print "starting....\n";
my $start = system("sudo /usr/local/openums/CPstart 1>> /var/log/openums/start.out 2>> /var/log/openums/start.err"); 

$start >>= 8; ### Bit shift to get exit status of program
$stop >>= 8;

my $url = "admin.cgi?mod=Server"; 
my $url_append; 

if (($start == 0) && ($stop == 0))
  {
    my $msg = enurl("NO GOOD: start=$start and stop=$stop" );
    open (LOG, "/var/log/openums/stop.out");
    while (<LOG>)
      { 
        next unless $_ =~ /ERR/;
        $url_append = "&error_msg=$msg" ;  
      }
    close(LOG);
    open (LOG, "/var/log/openums/start.out");
    while (<LOG>)
      {
        next unless $_ =~ /ERR/;
        $url_append = "&error_msg=$msg" ;
      }
    close(LOG);
    print "server restart failed, redirecting...\n"; 
  }
else
  {
    my $msg = enurl("Converge Pro Server Restarted" );
    $url_append = "&msg=$msg" ;
    print "server restarted, redirecting...\n";
  }

$url = "admin.cgi?mod=Server$url_append"; 

    print <<EOF

<meta http-equiv="REFRESH" content="0;url=$url" /> 
EOF

#  }

