package OpenUMS::WWW::Sounds;
### $Id: Sounds.pm,v 1.1 2004/07/20 03:14:53 richardz Exp $
#
# WWW/Sounds.pm
#
# Web interface for sounds
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
  return $self->view_sounds();

  my $wu = $self->{WEBUSER}; 
  my $session = $wu->cgi_session(); 
  my $dbh = $wu->dbh (); 
  my $cgi = $wu->cgi (); 

  ## setup the template 

  my $tmpl = new HTML::Template(filename =>  'templates/sounds_main.html');  
  $tmpl->param(msg => $cgi->param('msg') ) ; 
  $tmpl->param(MOD => $self->module() ); 
  return $tmpl; 

} 


#################################
## sub view_sounds
#################################
sub view_sounds {
  my $self = shift ; 
  return unless (defined($self))  ; 
  my $wu = $self->{WEBUSER}; 
  my $session = $wu->cgi_session(); 
  my $dbh = $wu->dbh (); 
  my $cgi = $wu->cgi (); 

  ## setup the template 
  my $tmpl = new HTML::Template(filename =>  'templates/sounds_view.html');  
  $tmpl->param(MSG => $cgi->param("msg")) ;
  $tmpl->param(MOD => $self->module()) ;
  $tmpl->param(FUNC => "view_sounds") ;


  ## get the sort by option...
  my $sortby = $cgi->param('sb1');
  my $sortby2 = $cgi->param('sb2');
  print STDERR " sortby = $sortby , sortby2 = $sortby2 \n"  if (WEB_DEBUG); 

  if ($sortby ) {
    if (!$sortby2)  { 
       $tmpl->param($sortby."_sb" => 1);
    } 
  }
  my $orderby = " file_id desc  "; 
  if ($sortby ) { 
     if (!$sortby2) {
       $orderby = " $sortby DESC "; 
     }  else {
       $orderby = " $sortby"; 
     } 

  } 
  my $where =""; 
  if ($cgi->param('filter') ) { 
     my $filter_term = $cgi->param('filter') ; 
     $where = " WHERE sound_file like '$filter_term%' "; 
  } 
  my $sql = qq{SELECT * FROM sound_files $where ORDER BY $orderby };
  print STDERR " sql = $sql ldw..sortby = $sortby , sortby2 = $sortby2 \n"  if (WEB_DEBUG);
  
  my $sth = $dbh->prepare($sql);
  $sth->execute();
  my @sound_files ; 

  my @fields = qw(file_id  sound_file professional); 
  
  while (my $data = $sth->fetchrow_hashref() ) {
    my $row; 
    foreach my $f (@fields) { 
      $row->{$f} = $data->{$f}; 
    } 
    $row->{MOD} = $self->module(); 
    push @sound_files, $row;  
  } 
  $tmpl->param(SOUND_FILES => \@sound_files) ; 
  
  return $tmpl; 

}

#################################
## sub toggle_prof
#################################
sub toggle_prof {
  my $self = shift ;
  return unless (defined($self))  ;
  my $wu = $self->{WEBUSER};
  my $session = $wu->cgi_session();
  my $dbh = $wu->dbh ();
  my $cgi = $wu->cgi ();

  my $id = $cgi->param("id"); 
  my $msg ; 
  if (!$id) {  
    $msg= "NO file to Toggle "; 
  }  else {
     my $upd = qq{UPDATE sound_files SET professional = !(professional) WHERE file_id  = $id}; 
     $dbh->do($upd); 
     $msg= "Toggled profession bit for file $id "; 
  } 
   
  
  print $cgi->redirect("admin.cgi?mod=" . $self->module() ."&func=view_sounds&msg=$msg");

}


#################################
## sub view_new_sounds
#################################
sub view_new_sounds {
  my $self = shift ;
  my $sel = shift ;
                                                                                                                             
  my $wu = $self->{WEBUSER};
  my $dbh = $wu->dbh ();
  my $cgi = $wu->cgi ();
                                                                                                                             
  my $tmpl = new HTML::Template(filename =>  'templates/sounds_view_new.html');
#  $tmpl->param(mod => $self->module() );
                                                                                                                             
#  $tmpl->param(SRC => "edit" );
#  my $menu_sound_id = $cgi->param('menu_sound_id');
                                                                                                                             
  opendir DIR, "/var/spool/openums/prompts";
  my @files = grep {$_ ne '.' and $_ ne '..' && ($_ =~ /wav$/ || $_ =~ /au$/ ) } readdir DIR;
  closedir (DIR);
  my $sql = "SELECT count(*) FROM sound_files WHERE sound_file = ? "; 
  my $sth = $dbh->prepare($sql); 
  my $count=0; 
  my @new_files; 
  foreach my $f (@files) {
    $sth->execute($f) ; 
    my $exists = $sth->fetchrow(); 
    if (!$exists) {
      my %data ; 
      $count++; 
      $data{count} = $count ; 
      $data{file_name} = $f; 
      $data{odd_row} = $count%2 ; 
      $data{mod} =  $self->module() ; 

      push  @new_files, \%data;       
    } 
    $sth->finish();   
  } 
  $tmpl->param(NEW_FILES => \@new_files ) ; 
  $tmpl->param(NEW_FILES_SIZE => scalar(@new_files) ) ; 
  $tmpl->param(mod =>$self->module()) ; 
  $tmpl->param(func =>'add_new_multi') ; 
  my $msg ;

  return $tmpl; 

}

#################################
## sub add_new
#################################
sub add_new {

  my $self = shift ;
  my $sel = shift ;
                                                                                                                             
  my $wu = $self->{WEBUSER};
  my $dbh = $wu->dbh ();
  my $cgi = $wu->cgi ();
  my $file_name = $cgi->param('file_name')  ; 
  if ($file_name ) { 
    my $sql = qq{INSERT INTO sound_files (sound_file) VALUES ('$file_name') } ;  
    $dbh->do($sql); 
  } 


  my $msg ; 
  print $cgi->redirect("admin.cgi?mod=" . $self->module() ."&func=view_new_sounds&msg=$msg");
  exit ; 
                                                                                                                             
} 

sub add_new_multi {
  my $self = shift ;
  my $wu = $self->{WEBUSER};
  my $dbh = $wu->dbh ();
  my $cgi = $wu->cgi ();
  
  my @files = $cgi->param('sound_file');
  print STDERR "got files = " . scalar( @files ) . "\n";
  my $sth = $dbh->prepare("INSERT INTO sound_files (sound_file) VALUES (?) ");   
   
  foreach my $file (@files) {
     print STDERR "file=$file\n";
     $sth->execute($file); 
  } 
  $sth->finish(); 

  my $msg = "hi"; 
  print $cgi->redirect("admin.cgi?mod=" . $self->module() ."&func=view_new_sounds&msg=$msg");
  exit; 
}


sub rename {
  my $self = shift ;
  my $wu = $self->{WEBUSER};
  my $dbh = $wu->dbh ();
  my $cgi = $wu->cgi ();

  my $file_id = $cgi->param('file_id')  ; 
  my $sql = "SELECT sound_file,professional FROM sound_files WHERE file_id = $file_id "; 

  my $sth = $dbh->prepare($sql);
  $sth->execute() ;
  my ($sound_file,$prof)  = $sth->fetchrow_array();

#  if ($prof) {
#     ## don't let anyone edit professionally recorded sounds...
#     print $cgi->redirect("admin.cgi?mod=" . $self->module() );
#     exit ; 
#  } 


  my $tmpl = new HTML::Template(filename =>  'templates/sounds_rename.html');

  $tmpl->param(mod => "Sounds"); 
  $tmpl->param(func => "rename_save"); 

  $tmpl->param(old_sound_file => $sound_file); 
  $tmpl->param(file_id => $file_id); 
  $tmpl->param(old_sound_file => $sound_file); 
  if ($cgi->param('sound_file') ) { 
    $tmpl->param(sound_file => $cgi->param('sound_file') ); 
  } else { 
    $tmpl->param(sound_file => $sound_file); 
  } 
  return $tmpl; 

}

sub rename_save {
  my $self = shift ;
  my $wu = $self->{WEBUSER};
  my $dbh = $wu->dbh ();
  my $cgi = $wu->cgi ();
 
  my $file_id = $cgi->param('file_id')  ; 
  my $sql = "SELECT professional FROM sound_files WHERE file_id = $file_id ";
                                                                                                                                               
  my $sth = $dbh->prepare($sql);
  $sth->execute() ;
  my ($prof)  = $sth->fetchrow_array();
#  if ($prof) {
     ## don't let anyone edit professionally recorded sounds...
#     print $cgi->redirect("admin.cgi?mod=" . $self->module() );
#     exit ;
#  }
  ## make sure it don't exist...

  my $sound_file = $cgi->param('sound_file')  ; 
  my $old_sound_file = $cgi->param('old_sound_file')  ; 

  if (-e BASE_PATH . PROMPT_PATH . $sound_file ) {  
     my $msg = "There is already a sound file named $sound_file. Cannot move $old_sound_file to $sound_file "; 
     print $cgi->redirect("admin.cgi?mod=" . $self->module() ."&func=view_sounds&msg=$msg");
     exit ;
  } 


  $sql = "UPDATE sound_files set sound_file = '$sound_file' WHERE file_id = $file_id "; 
  my $updated = $dbh->do($sql); 
  if ($updated) { 
     print STDERR "rename_worked moving file, updated menu_sounds \n" if (WEB_DEBUG); 
     $sql = "UPDATE  menu_sounds set sound_file = '$sound_file'  WHERE sound_file ='$old_sound_file' " ; 
     my $updated = $dbh->do($sql); 

     print STDERR "updated $updated menu_sounds, moving $old_sound_file to $sound_file \n" if (WEB_DEBUG); 
     my $path = BASE_PATH . PROMPT_PATH ; 
     use File::Copy ; 
     my $moved = move("$path$old_sound_file", BASE_PATH . PROMPT_PATH ."$sound_file"); 
  } 

  my $msg = "Sound file $old_sound_file renamed to $sound_file "; 
  print $cgi->redirect("admin.cgi?mod=" . $self->module() ."&func=view_sounds&msg=$msg");
  exit; 

}

#################################
## sub module
#################################
sub module {
  return "Sounds"; 
}
1; 
