package OpenUMS::WWW::Greetings;
### $Id: Greetings.pm,v 1.1 2004/07/20 03:14:53 richardz Exp $
#
# WWW/Greetings.pm
#
# Web interface for administering the Greetings
#
# Copyright (C) 2003 Integrated Comtel Inc.
use strict; 

use lib '/usr/local/openums/lib'; 

## always use the web tools
use OpenUMS::WWW::WebTools; 

use HTML::Template; 
use OpenUMS::DbQuery; 
use OpenUMS::Greeting; 
use OpenUMS::DbUtils; 

use OpenUMS::Common; 
use OpenUMS::Config; 
use OpenUMS::Permissions; 


use base ("OpenUMS::WWW::WebModuleBase"); 


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

  my $extension = $session->param('extension') ; 
  ## setup the template 
  my $tmpl = new HTML::Template(filename =>  'templates/greetings_main.html');  
  $tmpl->param(msg => $cgi->param('msg') ) ; 
  $tmpl->param(MOD => $self->module() ); 

  my $on_vacation =  OpenUMS::Greeting::user_is_on_vacation($dbh,$extension) ; 
  $tmpl->param(on_vacation => $on_vacation ) ; 
  my ($begin_date, $dayback_date) = $self->vacation_q(); 
  my $has_vacation =  defined($dayback_date) ; 
  $tmpl->param(has_vacation => $has_vacation ) ; 
  if ($has_vacation) {
    $tmpl->param(begin_date => $begin_date ) ; 
    $tmpl->param(dayback_date => $dayback_date ) ; 
    print STDERR "gonna get vacation greeting   \n" if (WEB_DEBUG); 
    #my $val = $self->get_vacation_greeting(); 
    #$tmpl->param(out_of_office_links => $val ) ; 
#    print STDERR "val returned = $val \n" if (WEB_DEBUG); 
  }

  my $gr_arr =  OpenUMS::Greeting::user_greetings($dbh,$extension) ; 
  print STDERR " gonna process greeting_arr = " . scalar (@{$gr_arr}) . " \n" if (WEB_DEBUG); 
  if (scalar (@{$gr_arr} ) ) { 
    $tmpl->param(greeting_id => $gr_arr->[0]->{greeting_id} ) ; 
    $tmpl->param(greeting_wav_file => $gr_arr->[0]->{greeting_wav_file} ) ; 
    $tmpl->param(last_updated_formatted => $gr_arr->[0]->{last_updated_formatted} ) ; 
    $tmpl->param(professional => $gr_arr->[0]->{professional} ) ; 
  } else {
    my $greet_msg = "You do not have a greeting recorded"; 
    $tmpl->param(greeting_wav_file => $greet_msg) ; 
  } 

  return $tmpl; 
} 

#################################
## sub edit_vacation
#################################
sub edit_vacation {
  my $self = shift ;
  return unless (defined($self))  ;

  my $wu = $self->{WEBUSER};
  my $session = $wu->cgi_session();
  my $dbh = $wu->dbh ();
  my $cgi = $wu->cgi ();
                                                                                                                             
  my $extension = $session->param('extension') ;
  my ($begin_date, $dayback_date) = ($cgi->param('begin_date'), $cgi->param('dayback_date')  ) ; 
  if (!$self->{error_message} ) {
    my ($b, $e) =  $self->vacation_q(); 
    if (defined($b) ) {
      ($begin_date, $dayback_date) = ($b, $e ) ; 
      $self->{error_message} = "You currently already have a vacation defined."
    }    
  }  
  my $tmpl = new HTML::Template(filename =>  'templates/greetings_vacation.html');  
  $tmpl->param(MOD => $self->module() ); 
  $tmpl->param(func => 'save_vacation'); 
  $tmpl->param(BEGIN_DATE => $begin_date ); 
  $tmpl->param(DAYBACK_DATE => $dayback_date ); 
  $tmpl->param(error_message => $self->{error_message}); 
  return $tmpl; 
}


#################################
## sub vacation_q
#################################
sub vacation_q {
  my $self = shift ;
  return unless (defined($self))  ;
                                                                                                                             
  my $wu = $self->{WEBUSER};
  my $session = $wu->cgi_session();
  my $dbh = $wu->dbh ();

  my $extension = $session->param('extension') ;
  my ($bdatedb, $edatedb) = OpenUMS::Greeting::vacation_dates($dbh,$extension); 
#  my $sql = qq{SELECT begin_date, dayback_date FROM vacations where extension = ? }; 
#  my $sth = $dbh->prepare($sql); 
#  $sth->execute($extension) ; 
#  my ($bdatedb, $edatedb) = $sth->fetchrow_array(); 
  print STDERR "$bdatedb, $edatedb\n  "  if (WEB_DEBUG) ; 
  
  #$sth->finish()  ; 

  if (!$bdatedb &&  !$edatedb) {
      return (undef,undef); 
  } 

  my ($byear,$bmon,$bday) = split(/-/, $bdatedb) ;
  my ($eyear,$emon,$eday) = split(/-/, $edatedb) ;

  my $bdate = sprintf("%02d/%02d/%04d", $bmon, $bday, $byear)  ; 
  my $edate = sprintf("%02d/%02d/%04d",$emon, $eday, $eyear)  ; 
  print STDERR "Returning ($bdate, $edate) \n  "  if (WEB_DEBUG) ; 
   
  return ($bdate, $edate) ; 
   

} 

#################################
## sub save_vacation
#################################
sub save_vacation {
  my $self = shift ;
  return unless (defined($self))  ;

  my $wu = $self->{WEBUSER};
  my $session = $wu->cgi_session();
  my $dbh = $wu->dbh ();
  my $cgi = $wu->cgi ();

  my $extension = $session->param('extension') ;
  my $msg ; 
  if ($cgi->param('delete') )  { 
     $msg = "Vacation Deleted"; 
    my $sql = qq{DELETE FROM vacations where extension = $extension} ;
    $dbh->do($sql); 
  } elsif ($cgi->param('save') ) {
    ## get the dates
    my ($bmon,$bday,$byear) = split(/\//, $cgi->param('begin_date')) ; 
    my ($emon,$eday,$eyear) = split(/\//, $cgi->param('dayback_date')) ; 

    use Date::Calc; 

    my $bool = Date::Calc::check_date($byear,$bmon,$bday);
    if (!$bool)  { 
       $self->{error_message} = "The Begin Date (" . $cgi->param('begin_date') . ") is an invalid date"; 
       return $self->edit_vacation(); 
    }

    $bool = Date::Calc::check_date($eyear,$emon,$eday);
    if (!$bool)  { 
       $self->{error_message} = "The Day Back Date (" . $cgi->param('dayback_date') . ") is an invalid date"; 
       return $self->edit_vacation(); 
    }
    my $bdatedb = sprintf("%04d-%02d-%02d",$byear, $bmon, $bday)  ; 
    my $edatedb = sprintf("%04d-%02d-%02d",$eyear, $emon, $eday)  ; 
  
    print STDERR "bdate = $bdatedb\n"  if (WEB_DEBUG) ;  
    print STDERR "edate = $edatedb\n" if (WEB_DEBUG)  ;  
    my $sql = qq{REPLACE INTO  vacations (extension, begin_date , dayback_date) 
           VALUES ($extension, '$bdatedb', '$edatedb') }; 
    $dbh->do($sql); 
    $msg = "Vacation Setting Changed."; 
  }
  print $cgi->redirect("user.cgi?mod=" . $self->module() ."&msg=$msg");
} 

#################################
## sub module
#################################
sub get_vacation_greeting {
  my $self = shift ; 
  my $ext = shift ; 
  my $wu = $self->{WEBUSER};
  my $session = $wu->cgi_session();
  my $dbh = $wu->dbh ();
  my $cgi = $wu->cgi ();
  my $extension = $session->param('extension') ; 
  my $files = ""; 
  ##OpenUMS::Greeting::get_greeting_sound($dbh, $extension); 
  $files = OpenUMS::Greeting::get_greeting_sound($dbh, $extension); 
  print STDERR "got this files...$files\n" if (WEB_DEBUG) ; 
  my @file_arr = split(/ /, $files);   
  my $sth = $dbh->prepare("SELECT file_id FROM sound_files WHERE sound_file = ? ");
  my $url = '<a href="send_wav.cgi?type=prompt&id=file_id">file_name</a>&nbsp;'; 
  my $link_string ; 
  foreach my $file (@file_arr) {
    $file =~ s/prompts\///g;
    $sth->execute($file); 
    my $file_id = $sth->fetchrow(); 
    print STDERR "got this files...$file_id $file\n" if (WEB_DEBUG) ;
    my $url2 = $url;
    $url2 =~ s/file_id/$file_id/;
    $url2 =~ s/file_name/$file/;
    $link_string .= $url2;  
    print STDERR "url2 = $url2\n" if (WEB_DEBUG)  ; 
    $sth->finish();
  }
  return $link_string; 

#  foreach (@files ) { 
#    print STDERR $_ if (WEB_DEBUG); 
#    print STDERR "\n" if (WEB_DEBUG) ; 
#  }

}
sub module {
  return "Greetings"; 
}
1; 
