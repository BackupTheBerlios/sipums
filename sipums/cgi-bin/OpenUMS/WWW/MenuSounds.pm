package OpenUMS::WWW::MenuSounds;
### $Id: MenuSounds.pm,v 1.1 2004/07/20 03:14:53 richardz Exp $
#
# WWW/MenuSounds.pm
#
# Web interface for 
#
# Copyright (C) 2003 Integrated Comtel Inc.
use strict; 

use lib '/usr/local/openums/lib'; 

use HTML::Template; 
use OpenUMS::DbQuery; 
use OpenUMS::DbUtils; 
use OpenUMS::Common; 
use OpenUMS::Config; 


use OpenUMS::WWW::WebTools ; 
use base ("OpenUMS::WWW::WebModuleBase"); 

################################################3
## sub main: 
##   template used : templates/menu_main.html
##   function : prints Menu Summary, Auto Attendant menus and transfer menus  
##    but no user menus
#######

sub module {
  return "MenuSounds"; 

}

#################################
## sub view
#################################
sub view {
  my $self = shift ; 
  return unless (defined($self))  ; 
  my $wu = $self->{WEBUSER}; 
  my $session = $wu->cgi_session(); 
  my $cgi = $wu->cgi (); 
  my $dbh = $wu->dbh (); 

  my $tmpl = new HTML::Template(filename =>  'templates/ms_view.html');  
  print STDERR "Going to open dir " . BASE_PATH . PROMPT_PATH  . "\n" if (WEB_DEBUG); 
  opendir(DIR,BASE_PATH . PROMPT_PATH); 
  my @files = readdir(DIR);
  closedir(DIR); 
  my $count = 0; 
  my $per_row =  6 ; 
  my @SOUND_FILES; 
  foreach my $file (@files) {
    next if ($file eq '.' || $file eq '..' ); 
    my %data ; 
    $data{COUNT} = ($count +1); 
    $data{FILE_NAME} = $file; 
    $data{odd_row} = $count%(2 * $per_row )  ; 
    $data{NEW_ROW} = !($count%$per_row); 
    push @SOUND_FILES, \%data; 
    $count++; 
  } 
  $tmpl->param(SOUND_FILES => \@SOUND_FILES); 
  return $tmpl  ; 

} 
#################################
## sub edit
#################################
sub edit {
  my $self = shift ; 
  return unless (defined($self))  ; 
  my $wu = $self->{WEBUSER}; 
  my $session = $wu->cgi_session(); 
  my $cgi = $wu->cgi (); 
  my $dbh = $wu->dbh (); 

  my $menu_id = $cgi->param('menu_id');
  my $perm = new OpenUMS::Permissions($dbh);

  if (!$perm->is_web_authorized($menu_id, $wu->permission_id() ) )  {
    return ;
  }

  my $tmpl = new HTML::Template(filename =>  'templates/ms_edit.html');  
  $tmpl->param(menu_id => $menu_id); 
  $tmpl->param(mod => $self->module() ); 
  $tmpl->param(SRC => "edit" ); 

  my $sql = qq{SELECT  m.title, sound_file, menu_sound_id ,var_name, order_no
      FROM menu m, menu_sounds ms
      WHERE m.menu_id = ms.menu_id
      and m.menu_id = $menu_id AND sound_type = 'M' ORDER by order_no};
  my $sth = $dbh->prepare($sql);
  $sth->execute(); 

#  my $sound_files = $self->get_sound_file_dd($sound_file); 
  my @sound_opts; 
  my ($menu_title, $sound_file,
         $menu_sound_id,$var_name, $order_no) ; 
  while (my (@data)  = $sth->fetchrow_array() ) {
     my %row ;        
      ($menu_title, $sound_file, $menu_sound_id, $var_name, $order_no) = @data ; 
     if ($sound_file) {  
        $row{file_flag} = 1 ; 
        $row{sound_files} = $self->get_sound_file_dd($sound_file); 
        $row{menu_sound_id}  = $menu_sound_id ; 
     }  else {
        $row{file_flag} = 0 ; 
        $row{var_name} = $var_name ; 
     } 
     $row{order_no} = $order_no ; 
     push @sound_opts, \%row; 
  } 
  if (!$menu_title )  {
     ## prolly no records returned but we still want to display the title...
     my $sql1 = qq{SELECT title from menu where menu_id = $menu_id};
     my $ary_ref = $dbh->selectcol_arrayref($sql1);
     print STDERR "menu title = $menu_title\n"  if (WEB_DEBUG) ; 
     $menu_title = $ary_ref->[0]; 
  } 

  $sth->finish(); 

  $tmpl->param(sound_opts => \@sound_opts); 
  print STDERR "$menu_id, $menu_title, \n"   if (WEB_DEBUG) ; 

  $tmpl->param(msg => $cgi->param('msg') ); 
  $tmpl->param(func => "save_sound_file" ); 
  $tmpl->param(menu_id => $menu_id); 
  $tmpl->param(menu_title => $menu_title); 

#  $tmpl->param(menu_sound_id => $menu_sound_id); 
  return $tmpl  ; 
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

#################################
## sub save_sound_file
#################################
sub save_sound_file {
  my $self = shift ;
  my $sel = shift ;
                                                                                                                             
  my $wu = $self->{WEBUSER};
  my $dbh = $wu->dbh ();
  my $cgi = $wu->cgi (); 

#  my $menu_sound_id = $cgi->param('menu_sound_id'); 
  my $menu_id  = $cgi->param('menu_id'); 
  my $file_id = $cgi->param('file_id'); 
  my $msg ; 

  my $sql = qq{SELECT  menu_sound_id, var_name 
      FROM menu m, menu_sounds ms
      WHERE m.menu_id = ms.menu_id
      and m.menu_id = $menu_id AND sound_type = 'M' ORDER by order_no};
  my $sth = $dbh->prepare($sql);
  $sth->execute();
                                                                                                                             
#  my $sound_files = $self->get_sound_file_dd($sound_file);
  my @sound_opts;
  while (my ($menu_sound_id,$var_name) = $sth->fetchrow_array() ) {
     next if ($var_name); 
     my $file_id  = $cgi->param("file_id_$menu_sound_id") ; 

     my $sql1 =  "SELECT sound_file FROM sound_files WHERE file_id  = $file_id" ; 
     my $ary_ref = $dbh->selectcol_arrayref($sql1);
     my $new_sound_file = $ary_ref->[0]; 
     if ($new_sound_file ) {     
        my $upd = "UPDATE menu_sounds SET sound_file = " . $dbh->quote($new_sound_file) 
              . " WHERE menu_sound_id = " .  $menu_sound_id ; 
        print STDERR "update = $upd\n"  if (WEB_DEBUG) ; 
        $dbh->do($upd); 
        $msg = "Menu Sound changed for menu $menu_id "; 
     }  else { 
        $msg = "Invalid Menu Sound"; 
        print $cgi->redirect("admin.cgi?mod=MenuSounds&func=edit&menu_id=" . $menu_id . "&msg=$msg" );  
        exit ;
     } 
  }

  print $cgi->redirect("admin.cgi?mod=MenuSounds&func=edit&menu_id=" . $menu_id . "&msg=$msg" );  
  exit ;

}
#################################
## sub add
#################################
sub add {
  my $self = shift ; 
  return unless (defined($self))  ; 
  my $wu = $self->{WEBUSER}; 
  my $session = $wu->cgi_session(); 
  my $cgi = $wu->cgi (); 
  my $dbh = $wu->dbh (); 

  my $menu_id = $cgi->param('menu_id');

  my $tmpl = new HTML::Template(filename =>  'templates/ms_add.html');  
  $tmpl->param(menu_id => $menu_id); 
  $tmpl->param(mod => $self->module() ); 
  $tmpl->param(func => 'save_add' ); 
  $tmpl->param(SRC => "edit" ); 

  my $sound_files = $self->get_sound_file_dd();
  $tmpl->param(SOUND_FILES =>  $sound_files ); 
  my $menu = OpenUMS::DbQuery::menu_data($dbh, $menu_id);
  my @counts = (1,2,3,4,5,6,7,8,9) ; 
  my @order_nos; 
  my $sql = qq{SELECT max(order_no) + 1 FROM menu_sounds WHERE menu_id =  ? and sound_type ='M' } ; 
  my $sth = $dbh->prepare($sql);
  $sth->execute($menu_id); 
  my ($next_order_no) = $sth->fetchrow();
  $sth->finish(); 
  foreach my $i (@counts) {
     my %data ; 
     $data{num} = $i; 
     if ($next_order_no == $i) {
       $data{sel} = 1; 
     } 
     push @order_nos, \%data ; 
  } 
  $tmpl->param(order_nos =>  \@order_nos); 
  if ($wu->permission_id() =~ /^SUPER/) {
     $tmpl->param(show_variable =>  1); 
  } 
                                                                                                                             
  $tmpl->param(MENU_TITLE => $menu->{$menu_id}->{title} );
  return $tmpl  ; 
} 
#################################
## sub save_add
#################################
sub save_add {
  my $self = shift ;
  my $sel = shift ;
                                                                                                                             
  my $wu = $self->{WEBUSER};
  my $dbh = $wu->dbh ();
  my $cgi = $wu->cgi ();
                                                                                                                             
#  my $menu_sound_id = $cgi->param('menu_sound_id');
  my $menu_id  = $cgi->param('menu_id');
  my $file_id = $cgi->param('file_id');
  my $msg ;
  my $order_no =  $cgi->param('order_no'); 
  my $sound_title =  $cgi->param('sound_title') ; 
  if ($cgi->param('var_or_sound') eq 'var' && $cgi->param('var_name') ) {
     print STDERR "add VAR\n" if (WEB_DEBUG) ; 
    my $var_name =  $cgi->param('var_name') ; 
    my $sql = qq{INSERT INTO menu_sounds (menu_id,sound_title, var_name, order_no, sound_type)
       VALUES ($menu_id, '$sound_title', '$var_name', $order_no,'M') }; 
    $msg = "New Variable added"; 
    $dbh->do($sql); 
  } elsif ($cgi->param('var_or_sound') eq 'sound' && $cgi->param('file_id')  ) { 
     my $sql1 =  "SELECT sound_file FROM sound_files WHERE file_id  = $file_id" ;
     my $ary_ref = $dbh->selectcol_arrayref($sql1);
     my $new_sound_file = $ary_ref->[0];
    my $sql = qq{INSERT INTO menu_sounds (menu_id, sound_title, sound_file, order_no, sound_type)
       VALUES ($menu_id, '$sound_title', '$new_sound_file', $order_no,'M') }; 
    $msg = "New Sound File added"; 
    $dbh->do($sql); 
  }

  print $cgi->redirect("admin.cgi?mod=MenuSounds&func=edit&menu_id=" . $menu_id . "&msg=$msg" );  
  exit ;
}
#################################
## sub delete_view
#################################
sub delete_view { 

  my $self = shift ; 
  return unless (defined($self))  ; 
  my $wu = $self->{WEBUSER}; 
  my $session = $wu->cgi_session(); 
  my $cgi = $wu->cgi (); 
  my $dbh = $wu->dbh (); 

  my $menu_id = $cgi->param('menu_id');

  my $tmpl = new HTML::Template(filename =>  'templates/ms_delete_view.html');  
  $tmpl->param(menu_id => $menu_id); 
  $tmpl->param(mod => $self->module() ); 
  $tmpl->param(SRC => "edit" ); 

  my $sql = qq{SELECT  m.title, ms.sound_file, menu_sound_id ,var_name, order_no
      FROM menu m, menu_sounds ms
      WHERE m.menu_id = ms.menu_id
      AND m.menu_id = $menu_id AND sound_type = 'M' ORDER by order_no};
  my $sth = $dbh->prepare($sql);
  $sth->execute(); 
 
  print STDERR "sql = $sql\n" if (WEB_DEBUG); 

#  my $sound_files = $self->get_sound_file_dd($sound_file); 
  my @sound_opts; 
  my ($menu_title, $sound_file,
         $menu_sound_id,$var_name, $order_no) ; 
  while (my (@data)  = $sth->fetchrow_array() ) {
     my %row ;        
      ($menu_title, $sound_file, $menu_sound_id, $var_name, $order_no) = @data ; 
      $row{mod} = $self->module() ; 
     $row{menu_sound_id}  = $menu_sound_id ; 
     $row{menu_id}  = $menu_id ; 
     if ($sound_file) {  
        $row{file_flag} = 1 ; 
#        $row{sound_files} = $self->get_sound_file_dd($sound_file); 
        $row{file_id}  = $self->get_file_id($menu_sound_id)  ; 
        $row{sound_file}  = $sound_file ; 
     }  else {
        $row{file_flag} = 0 ; 
        $row{var_name} = $var_name ; 
     } 
     $row{order_no} = $order_no ; 
     push @sound_opts, \%row; 
  } 
  if (!$menu_title )  {
     ## prolly no records returned but we still want to display the title...
     my $sql1 = qq{SELECT title from menu where menu_id = $menu_id};
     my $ary_ref = $dbh->selectcol_arrayref($sql1);
     print STDERR "menu title = $menu_title\n"  if (WEB_DEBUG) ; 
     $menu_title = $ary_ref->[0]; 
  } 

  $sth->finish(); 

  $tmpl->param(sound_opts => \@sound_opts); 
  print STDERR "$menu_id, $menu_title, \n"   if (WEB_DEBUG) ; 

  $tmpl->param(msg => $cgi->param('msg') ); 
  $tmpl->param(func => "save_sound_file" ); 
  $tmpl->param(menu_id => $menu_id); 
  $tmpl->param(menu_title => $menu_title); 

#  $tmpl->param(menu_sound_id => $menu_sound_id); 
  return $tmpl  ; 

}
sub delete {
  my $self = shift ; 

  my $wu = $self->{WEBUSER};
  my $session = $wu->cgi_session();
  my $cgi = $wu->cgi ();
  my $dbh = $wu->dbh ();
  my $menu_sound_id = $cgi->param('menu_sound_id'); 
  my $menu_id = $cgi->param('menu_id'); 

  my $sql = qq{DELETE FROM menu_sounds WHERE menu_sound_id = $menu_sound_id }; 
  $dbh->do($sql); 
  my $msg = "menu sound deleted"; 
  print $cgi->redirect("admin.cgi?mod=MenuSounds&func=delete_view&menu_id=" . $menu_id . "&msg=$msg" );  
  exit ;

}
#################################
## sub get_file_id
#################################
sub get_file_id {
  my $self = shift ; 
  my $menu_sound_id = shift; 

  my $wu = $self->{WEBUSER}; 
  my $session = $wu->cgi_session(); 
  my $cgi = $wu->cgi (); 
  my $dbh = $wu->dbh (); 
  my $sql1 = qq{SELECT file_id FROM menu_sounds ms, sound_files sf 
      WHERE ms.sound_file = sf.sound_file 
      AND ms.menu_sound_id = $menu_sound_id };
  
  my $ary_ref = $dbh->selectcol_arrayref($sql1);
  my $file_id = $ary_ref->[0]; 
  return $file_id ; 

}
1;
