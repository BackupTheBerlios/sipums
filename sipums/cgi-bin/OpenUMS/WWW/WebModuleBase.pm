package OpenUMS::WWW::WebModuleBase;
### $Id: WebModuleBase.pm,v 1.1 2004/07/20 03:14:53 richardz Exp $
#
# WWW/WebModuleBase.pm
#
# Base for the web modules (I guess)
#
# Copyright (C) 2003 Integrated Comtel Inc.
use OpenUMS::WWW::WebTools;

use HTML::Template; 

#################################
## sub new
#################################
sub new {

  ## this your standard 'new', it intializes the hash and blesses it
  my $proto = shift;
  my $webUser = shift ; 
 
  my $class = ref($proto) || $proto;
  my $self = {}; ## self is a hash ref
  ## we'll add the parameters to the hash ref..
  $self->{WEBUSER} = $webUser ;

  bless($self, $class);
  return $self;
} 

#################################
## sub goto_prev_menu_item
#################################
sub goto_prev_menu_item {
 my $self = shift ;
  return unless (defined($self))  ;
  my $wu = $self->{WEBUSER};
  my $session = $wu->cgi_session();
  my $cgi = $wu->cgi ();
  my $dbh = $wu->dbh ();
  my $id = $cgi->param("menu_id")  || "202";
  my $sql = qq{SELECT MAX(menu_id) FROM menu where menu_id < $id };
  print STDERR "looking for prev : $sql\n" if (WEB_DEBUG);
  my $ary_ref = $dbh->selectcol_arrayref($sql);
  my $prev_id = $ary_ref->[0];
  if (!$prev_id ) {
     $prev_id = $id;
  }
  print STDERR "prev_id : $prev_id\n" if (WEB_DEBUG);
  $self->goto_menu_item($prev_id);
}
#################################
## sub goto_next_menu_item
#################################
sub goto_next_menu_item {
 my $self = shift ;
  return unless (defined($self))  ;
  my $wu = $self->{WEBUSER};
  my $session = $wu->cgi_session();
  my $cgi = $wu->cgi ();
  my $dbh = $wu->dbh ();
  my $id = $cgi->param("menu_id")  || "200";
  my $sql = qq{SELECT min(menu_id) FROM menu where menu_id > $id };
  my $ary_ref = $dbh->selectcol_arrayref($sql);
  my $next_id = $ary_ref->[0];
  if (!$next_id ) {
     $next_id = $id;
  }
  $self->goto_menu_item($next_id);
}
                                                                                                                             
#################################
## sub goto_menu_item
#################################
sub goto_menu_item {
   my $self = shift ;
   my $next_id = shift ;
                                                                                                                             
  my $wu = $self->{WEBUSER};
  my $cgi = $wu->cgi ();
  my $src = $cgi->param('src');                                                                                                                               
  print $cgi->redirect("admin.cgi?mod=" . $self->module() . "&func=$src&menu_id=$next_id") ;
  exit ;

}
sub get_sound_file_dd {
  my $self = shift ;
  my $sel = shift ;
                                                                                                                                               
  my $wu = $self->{WEBUSER};
  my $dbh = $wu->dbh ();
  my $sql = qq{SELECT file_id, sound_file FROM sound_files ORDER BY sound_file};
  my $sth = $dbh->prepare($sql);
  $sth->execute();
  my @sound_files ;
  while (my ($file_id, $file) = $sth->fetchrow() ) {
    my $row ;
    $row->{sound_file} = $file;
    $row->{file_id} = $file_id;
    if ($sel eq $row->{sound_file} ) {
       $row->{sel} = 1;
    }
    push @sound_files, $row ;
  }
  return \@sound_files;
}



1;
