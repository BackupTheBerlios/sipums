#!/usr/bin/perl

use strict ; 
use lib '/usr/local/openums/lib'; 
use CGI;
use CGI::Session;
use CGI::Session::MySQL;
use OpenUMS::Permissions; 
use HTML::Template ; 
$CGI::Session::MySQL::TABLE_NAME = 'web_sessions';

sub begin; 
sub get_admin_template  ; 
sub finish; 
sub isValidMod ; 
sub getModRef ; 

sub begin {
  close (STDERR ); 
  open  (STDERR, ">>/tmp/openums-www.err"); 

  my $cgi  = new CGI;
  my $sid = $cgi->cookie("CGISESSID") || undef;


  if (!$sid ) {
    ## they aren't even logged in : ( 
    print $cgi->redirect ("login.cgi");
    exit ;
  }

  use OpenUMS::Common;
  my $dbh  = OpenUMS::Common::get_dbh();

  my $session = new CGI::Session("driver:MySQL", $sid, {Handle=>$dbh});
  if ($sid ne $session->id() ) {
    ## it created a new session id so that means theirs did not come up 
    print $cgi->redirect ("login.cgi");
    exit ;
  }
  my $perm = new OpenUMS::Permissions($dbh);  
   
  return ($dbh, $cgi, $session,$perm) ;
  
}
sub finish  { 
  ## any cleanup stuff should go here...
  my ($dbh )  = shift ; 
  if (!$dbh) { 
    $dbh->disconnect(); 
  } 
} 
sub isValidMod {
  my $mod = shift  ; 
  my $pkgname = "OpenUMS::WWW::$mod";  
  my $code = " use $pkgname; \n" ; 
  my $eval = eval($code);

  if ($@) {  
    print STDERR "OpenUMS::WWW::$mod is not a valid module\n"; 
    return 0 
  } else {
    return 1; 
  } 
  $code .= " $pkgname:: use $pkgname; \n" ; 
}
sub isValidModFunc {
  my ($mod,$func)  = @_  ; 
  return 1; 
  my $pkgname = "OpenUMS::WWW::$mod";  
  my $code = "use " . $pkgname . ";\n" . $pkgname . "::" . $func . "(); ";
  my $eval = eval($code);
  if ($@) {
    print STDERR "OpenUMS::WWW::". $mod. "::" . "$func is not a valid func\n";
    return 0
  } else {
    return 1;
  }
} 

sub getModRef {
  my ($mod, $wu )  = @_ ; 

  my $pkgname = "OpenUMS::WWW::$mod"; 
  my $pkgname_path = $pkgname;

  $pkgname_path =~ s/::/\//g;
  require "$pkgname_path.pm";
  import $mod;

  my $ref = new $pkgname($wu) ; 

} 
sub post_login {
  ## they are good, let's hoook them up...
  my ($dbh, $cgi, $ext) = @_ ;

  my $u = OpenUMS::DbQuery::get_user_info($dbh, $ext); 
  print STDERR "Going to get pemrission id \n"; 
  my $permission_id = OpenUMS::DbQuery::user_permission_id($dbh,$ext ); 
  print STDERR "pemrission id = $permission_id \n"; 

  use CGI::Session;
  use CGI::Session::MySQL;
  $CGI::Session::MySQL::TABLE_NAME = 'web_sessions';
  my $session = new CGI::Session("driver:MySQL", undef, {Handle=>$dbh});


  $session->param('extension', $ext) ; 
  $session->param('permission_id',  $permission_id) ; 
  ## get the session id and create a cookie
  my $CGISESSID = $session->id() ;  
  my $cookie = $cgi->cookie(CGISESSID => $CGISESSID );
  ## redirect and send the cookie...
  my $ip = OpenUMS::Common::get_ip(); 
  print STDERR "ip = $ip \n"; 
  
  my $uri = "http://$ip/cgi-bin/";
  ## user.cgi";  ## default, redirect them to the user page....
  print STDERR "permission_id is $permission_id\n"; 
  if ($permission_id =~ /^SUPER|^ADMIN/ ) { 
    $uri .= "admin.cgi"; 
  } else {
    $uri .= "user.cgi"; 
  }  
  if ( 0 ) { 
#  if ($u->{store_flag} eq 'E') {} 
     print STDERR "It's e-mail store, we check check to make sure their password is valid...\n";
     use OpenUMS::IMAP; 
     my $imap = OpenUMS::IMAP::open_imap_connection($dbh, $ext) ;
  
     if (defined($imap) ) { 
       print STDERR "Imap connection is ok, closing it\n"; 
       $imap->close() ; 
     } else { 
       print STDERR "Imap connection could not be establish, sending user to page to change password\n"; 
        $uri = "user.cgi?mod=User&func=edit_email_password"; 
     }
  } 

  print $cgi->redirect(-uri=>$uri , -cookie=>$cookie );
 

}

1; 
