package OpenUMS::WWW::Settings;
### $Id: Settings.pm,v 1.1 2004/07/20 03:14:53 richardz Exp $
#
# WWW/Settings.pm
#
# Web interface settings
#
# Copyright (C) 2003 Integrated Comtel Inc.
use strict; 

use lib '/usr/local/openums/lib'; 

## always use the web tools
use OpenUMS::WWW::WebTools; 

use HTML::Template; 
use OpenUMS::DbQuery; 

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

  ## setup the template 


  my $tmpl = new HTML::Template(filename =>  'templates/settings_main.html');  
  #$tmpl->param(msg => $cgi->param('msg') ) ; 
  $tmpl->param(MOD => $self->module() ); 
  $tmpl->param(MSG => $cgi->param('msg')); 
  $tmpl->param(ERROR_MESSAGE => $cgi->param('error_message')); 
  my @fields = qw(var_name var_value var_display_name var_type var_min_value var_max_value); 
  my $db_fields = join(',',@fields); 
  my $sql = qq{SELECT $db_fields FROM global_settings};
  my $sth  = $dbh->prepare($sql);
  $sth->execute();
  my @rows ; 
  my $count=1; 
  while (my $hr = $sth->fetchrow_hashref() ) {
    $hr->{mod} = $self->module(); 
    $hr->{func} = "save_settings" ; 
    $hr->{odd_row} = $count%2;
    if ($hr->{var_name} eq $cgi->param('var_name')) {
        $hr->{new_var_value} = $cgi->param('var_value'); 
    }  else {
        $hr->{new_var_value} = $hr->{var_value}; 
    } 
    push @rows, $hr; 
    $count++;
  } 
  $tmpl->param('SETTINGS' => \@rows); 
  return $tmpl; 

} 

#################################
## sub save_settings
#################################
sub save_settings {
  
  my $self = shift ;
   use CGI::Enurl; 
  return unless (defined($self))  ;
  print STDERR "Saving settings ..."; 
  my $wu = $self->{WEBUSER};
  my $session = $wu->cgi_session();
  my $dbh = $wu->dbh ();
  my $cgi = $wu->cgi ();
  my ($old_var_value ,$var_value , $var_display_name , $var_name , $var_type , $var_min_value , $var_max_value); 
  $old_var_value = $cgi->param('old_var_value'); 
  $var_value = $cgi->param('var_value'); 
  $var_display_name = $cgi->param('var_display_name'); 
  $var_name = $cgi->param('var_name'); 
  $var_type = $cgi->param('var_type'); 
  $var_min_value = $cgi->param('var_min_value'); 
  $var_max_value = $cgi->param('var_max_value'); 
  my $msg ; 
  my $error_message ; 
  my $extra_url =''; 
  ##print $cgi->header();
  ##print "hi";
  if ($old_var_value eq $var_value ) { 
     $error_message =  "Setting <B>'$var_display_name'</b> value was not changed. Setting not saved."; 
  }  else { 
     if ($var_type eq 'INTEGER' && $var_value !~ /^\d+$/) {
       ## must be an int...
       $error_message =  "Setting <B>'$var_display_name'</b> must be an Integer. Setting not saved." ; 
       $extra_url ="&var_name=$var_name&var_value=$var_value" ; 
     } else {  
        if ($var_value < $var_min_value) {
           $error_message =  "Setting <B>'$var_display_name'</b> is too small. Minimum value is $var_min_value." ; 
           $extra_url ="&var_name=$var_name&var_value=$var_value" ; 
        } elsif ($var_value  > $var_max_value) {
           $error_message =  "Setting <B>'$var_display_name'</b> is too large. Maximum value is $var_max_value." ; 
           $extra_url ="&var_name=$var_name&var_value=$var_value" ; 
        }  else { 
           ## everything looks ok, let's save it and cross our fingers ....
           my $upd = qq{UPDATE global_settings SET var_value = '$var_value' WHERE var_name = '$var_name'}; 
           $dbh->do($upd); 
           $msg =  "Setting <B>'$var_display_name'</b> changed from <B>$old_var_value</b> to <b>$var_value</b>"; 
        } 
     }  
      
  } 
  print $cgi->redirect("admin.cgi?mod=" . $self->module() . "&msg=" . enurl($msg) . "&error_message=" . enurl($error_message) . $extra_url); 
  exit ;
}

#################################
## sub module
#################################
sub module() {
  return "Settings"; 

}
1; 
