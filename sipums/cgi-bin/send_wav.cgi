#!/usr/bin/perl


use strict; 
use lib '/usr/local/openums/lib';
use OpenUMS::DbUtils ; 
require 'openums-www.pl'; 

my ($dbh, $cgi, $session,$permissions) = begin(); 

print STDERR "user session begun ....\n"; 
my $type = $cgi->param('type'); 
my $id = $cgi->param('id'); 

my $sound_file ; 
if ($type =~/^greet/ && $id) {
  use OpenUMS::Config ; 
  ## for added security, make sure it's their greeting
  

  my $sql = qq{SELECT greeting_wav_file , greeting_wav_path  
     FROM VM_Greetings WHERE greeting_id = $id }; 
  if ($session->param('permission_id') !~ /^SUPER/ && $session->param('permission_id') !~/^ADMIN/) {
     ## if it's a user, make sure they aren't listening to someone else's
     my $ext = $session->param('extension') ; 
     $sql .= " AND extension = $ext ";  
  } 
  print STDERR "$sql\n"; 
  my $sth = $dbh->prepare($sql);
  $sth->execute(); 
  my ($greeting_wav_file , $greeting_wav_path) = $sth->fetchrow_array() ;
  $sth->finish(); 
  if (!$greeting_wav_path) {
     &do_invalid; 
     exit ; 
  } 
  $sound_file = BASE_PATH . $greeting_wav_path . $greeting_wav_file  ; 

} elsif ($type =~/^menu/ && $id) {
  my $sql = qq{ SELECT sound_file 
        FROM menu_sounds 
        WHERE menu_id = ? AND sound_type ='M' AND order_no =1}; 

  my $sth = $dbh->prepare($sql);
  $sth->execute($id);
  $sound_file = $sth->fetchrow() ;
  $sth->finish();
  if (!$sound_file) {
     &do_invalid; exit;
  }  else {
     $sound_file = PROMPT_PATH . $sound_file ;
  }

  
  
} elsif ($type =~/^msound/ && $id) {
  if ($session->param('permission_id') !~ /^SUPER/ && $session->param('permission_id') !~/^ADMIN/) {
     ## non-admins shouldn't be listening to these...
     &do_invalid; exit; 
  }
  my $sql = qq{SELECT sound_file 
     FROM menu_sounds WHERE menu_sound_id = $id };
 
  my $sth = $dbh->prepare($sql);
  $sth->execute(); 
  $sound_file = $sth->fetchrow() ;
  $sth->finish(); 
  if (!$sound_file) {
     &do_invalid; exit; 
  }  else {
     $sound_file = PROMPT_PATH . $sound_file ; 
  } 
} elsif ($type =~/^prompt/ && $id) {
  if ($session->param('permission_id') !~ /^SUPER/ && $session->param('permission_id') !~/^ADMIN/) {
     ## non-admins shouldn't be listening to these...
     &do_invalid; exit;
  }
  my $sql = qq{SELECT sound_file
     FROM sound_files WHERE file_id = $id };
                                                                                                                             
  my $sth = $dbh->prepare($sql);
  $sth->execute();
  $sound_file = $sth->fetchrow() ;
  $sth->finish();
  if (!$sound_file) {
     &do_invalid; exit;
  }  else {
     $sound_file =  PROMPT_PATH . $sound_file ;
  }

} elsif ($type =~/^new/) {
 if ($session->param('permission_id') !~ /^SUPER/ && $session->param('permission_id') !~/^ADMIN/) {
     ## non-admins shouldn't be listening to these...
     &do_invalid; exit;
  }
  $sound_file = $cgi->param('file'); 
  if (!$sound_file) {
     &do_invalid; exit;
  } else {  
     $sound_file = BASE_PATH . PROMPT_PATH . $sound_file ;
  } 
  
}  else { 
  &do_invalid ;  
  exit ;
  
}

  print STDERR "Gonna send the user $sound_file\n"; 

  open (WAV, $sound_file) or
    die "Can't open $sound_file: $!\n";
  binmode(WAV);
  print "Content-type: audio/x-wav\n\n";
  print <WAV>;
  

sub do_invalid {
  my $tmpl = HTML::Template->new(filename => 'templates/user.html');
  my $tmpl_det = HTML::Template->new(filename => 'templates/invalid.html'); 
  $tmpl->param('RIGHT_COL', $tmpl_det->output() ) ;
  print $cgi->header (); 
  print $tmpl->output() ; 


}





