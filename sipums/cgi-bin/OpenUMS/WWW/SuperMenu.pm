package OpenUMS::WWW::SuperMenu;
### $Id: SuperMenu.pm,v 1.1 2004/07/20 03:14:53 richardz Exp $
#
# WWW/SuperMenu.pm
#
# Superuser interface
#
# Copyright (C) 2003 Integrated Comtel Inc.

## this is the User Module for the web interface : ) 

use strict; 
use lib '/usr/local/openums/lib'; 

## always use the web tools
use OpenUMS::WWW::WebTools;

use HTML::Template; 
use OpenUMS::DbQuery; 
use OpenUMS::DbUtils; 
use OpenUMS::Common; 
use OpenUMS::Config; 

use OpenUMS::WWW::Menu; 
use vars qw( @ISA) ; 

my @STD_OPTS = ('1','2','3','4','5','6','7','8','9','0','*','#','DEFAULT','EXT');
my @ALL_OPTS = ('1','2','3','4','5','6','7','8','9','0','*','#','DEFAULT','EXT', '??','???','????','?????','??????' );

@ISA = ("OpenUMS::WWW::Menu") ; 
#use base ("OpenUMS::WWW::Menu"); 

my $MODULE = 'SuperMenu';
#################################
## sub module
#################################
sub module {
  return "SuperMenu"; 
}


################################################3
## sub main: 
##   template used : templates/menu_main.html
##   function : prints Menu Summary, Auto Attendant menus and transfer menus  
##    but no user menus
#######

sub main {
  my $self = shift ; 
  return unless (defined($self))  ; 
  my $wu = $self->{WEBUSER}; 
  my $session = $wu->cgi_session(); 
  my $cgi = $wu->cgi (); 
  my $dbh = $wu->dbh (); 

  print STDERR " Got the session: id=" . $session->id() . "ext=" . $session->param('extension') . "\n" if (WEB_DEBUG);

  my $tmpl = new HTML::Template(filename =>  'templates/sm_main.html');  
  my $menus = OpenUMS::DbQuery::menu_data($dbh); 
#  my @user_menu_data  ; 
  my @menu_data  ; 
  
  my $count = 1;
   
  foreach my $id (sort keys %{$menus} ) {
    my $row ;
    my $menu_hr = $menus->{$id} ;
    $row->{menu_id} = $id ; 
    $row->{title} = $menu_hr->{title} ; 
    $row->{menu_type_code} = $menu_hr->{menu_type_code} ;
    $row->{odd_row} = $count%2; 
    $row->{menu_sounds} =  $self->get_menu_sounds($id);
#    my ($menu_sound_id,$sound_file) = $self->get_menu_sounds($id);
#    $row->{menu_sound_id} = $menu_sound_id; 
#    $row->{sound_file} = $sound_file; 
    $row->{param1} = $menu_hr->{param1}; 
    $row->{param2} = $menu_hr->{param2}; 
    
       push @menu_data, $row;

    $count++;
  }
 
  $tmpl->param(MSG => $cgi->param('msg') ) ;
#  $tmpl->param(USER_MENU_DATA => \@user_menu_data);
  $tmpl->param(MENU_DATA => \@menu_data);

  return $tmpl ; 
} 

################################################
## sub edit_menu : 
##   template used : templates/sm_menu_form.html
##   function :      Edits a Menu
#################################################

sub edit_menu {
  my $self = shift ;
     return unless (defined($self))  ;

  my $wu = $self->{WEBUSER};
  my $cgi = $wu->cgi ();
  my $dbh = $wu->dbh ();

  my $tmpl = new HTML::Template(filename => 'templates/sm_menu_form.html'); 


  $tmpl->param('mod' => $MODULE ) ;
  $tmpl->param('func' => 'save_menu' ) ;
  $tmpl->param('type' => 'edit' ) ;
  $tmpl->param('edit_form' => 1 ) ;
  ## set the stuff for the menu...

  my $menu_id = $cgi->param('menu_id'); 

  ## set the error message if they screwed up .....
  $tmpl->param(error_message => $self->{error_message} );
  
  $tmpl->param('menu_id' => $menu_id ) ;

  my $menu_type_code ; 
  if (!$self->{error_message} ) {
    ## we get it from the db....
    my $menu = OpenUMS::DbQuery::menu_data($dbh,$menu_id); 
    $tmpl->param('title' => $menu->{$menu_id}->{title} ) ;
    $tmpl->param('max_attempts' => $menu->{$menu_id}->{max_attempts} ) ;
    $tmpl->param('collect_time' => $menu->{$menu_id}->{collect_time} ) ;
    $tmpl->param('param1' => $menu->{$menu_id}->{param1} ) ;
    $tmpl->param('param2' => $menu->{$menu_id}->{param2} ) ;
    $tmpl->param('param3' => $menu->{$menu_id}->{param3} ) ;
    $tmpl->param('param4' => $menu->{$menu_id}->{param4} ) ;
    my $menu_permissions = $self->get_permission_opts($menu->{$menu_id}->{'permission_id'}) ; 
    $tmpl->param('menu_permissions' => $menu_permissions) ;
    $tmpl->param('old_menu_type_code' => $menu->{$menu_id}->{menu_type_code} ) ;
    $menu_type_code = $menu->{$menu_id}->{menu_type_code}; 
  }  else {
    $tmpl->param('title' => $cgi->param('title') )  ;
    $tmpl->param('max_attempts' => $cgi->param('max_attempts') ); 
    $tmpl->param('collect_time' => $cgi->param('collect_time') ); 
    $tmpl->param('param1' => $cgi->param('param1') ); 
    $tmpl->param('param2' => $cgi->param('param2') ); 
    $tmpl->param('param3' => $cgi->param('param3') ); 
    $tmpl->param('param4' => $cgi->param('param4') ); 
    my $menu_permissions = $self->get_permission_opts($cgi->param('permission_id')) ; 
    $tmpl->param('menu_permissions' => $menu_permissions ) ;
    $tmpl->param('old_menu_type_code' => $cgi->param('old_menu_type_code') ) ;
    $menu_type_code = $cgi->param('menu_type_code'); 
  }
  ## this is for the menu_type drop down...
  my $menu_types = OpenUMS::DbQuery::menu_types($dbh); 
  my @rows ; 
  foreach  my $mtype (sort keys  %{$menu_types} ) {
    my %row_hash; 
    $row_hash{menu_type_code} = $mtype; 
    $row_hash{menu_type_code_descr} = $menu_types->{$mtype}->{menu_type_code_descr} ; 
    if ($mtype eq $menu_type_code ) { 
      $row_hash{sel} =  1; 
    } 
    push @rows, \%row_hash; 
  } 

  $tmpl->param('menu_type_opts' => \@rows ) ;
  

  return $tmpl;  
}

################################################
## sub add_aam :
##   template used : templates/sm_menu_form.html 
##
##   function :   Deletes a menu item for the user
#################################################
                                                                                                                             

sub add_menu {
  my $self = shift ;
     return unless (defined($self))  ;
     
  my $wu = $self->{WEBUSER};
  my $cgi = $wu->cgi ();
  my $dbh = $wu->dbh ();

  my $tmpl = new HTML::Template(filename => 'templates/sm_menu_form.html'); 

  $tmpl->param('mod' => $self->module() ) ;
  $tmpl->param('func' => 'save_new_menu' ) ;
  $tmpl->param('type' => 'add_menu' ) ;
  $tmpl->param('add_form' => 1 ) ;
  $tmpl->param('error_message' => $self->{error_message} ) ;
  ## set the stuff for the menu...


  my $new_menu_id = OpenUMS::DbQuery::get_next_aam_id($dbh); 
  my $max_attempts = $cgi->param('max_attempts') ||  3  ; 
  my $collect_time = $cgi->param('collect_time') ||  ''  ; 

  print STDERR "def =  " . defined($cgi->param('max_attempts') )  . " $max_attempts  \n" if (WEB_DEBUG); 
  
  my %hash = ('200'=>'User Menus', '600' => 'AA Menus', '800' => 'Xfers' ); 
  my @menu_id_begins; 
  foreach my $key (sort keys %hash) {
     my %data ; 
     $data{menu_id_begin_name} = $hash{$key}; 
     $data{menu_id_begin} =  $key ;
     push @menu_id_begins, \%data ; 
  } 
 $tmpl->param('menu_id_begins' => \@menu_id_begins) ;
  
  my $menu_type_opts = $self->get_menu_type_opts($cgi->param('menu_type_code')) ; 
  $tmpl->param('menu_type_opts' => $menu_type_opts ) ;
  my $menu_permissions = $self->get_permission_opts($cgi->param('permission_id')) ; 
  $tmpl->param('menu_permissions' => $menu_permissions ) ;
  $tmpl->param('max_attempts' => $max_attempts ) ;
  $tmpl->param('collect_time' => $collect_time ) ;
  $tmpl->param('param1' => $cgi->param('param1') ) ;
  $tmpl->param('param2' => $cgi->param('param2') ) ;
  $tmpl->param('param3' => $cgi->param('param3') ) ;


  $tmpl->param('title' => $cgi->param('title') ) ;
  return $tmpl; 
}

################################################
## sub get_menu_type_opts :
##   template used : n/a
##
##   function : returns an array ref with valid meny_type codes
#################################################

sub get_menu_type_opts {
  my $self = shift; 
  my $cur_menu_type_code = shift; 

  my $wu = $self->{WEBUSER};
  my $dbh = $wu->dbh ();

  my $menu_types = OpenUMS::DbQuery::menu_types($dbh);
  my @rows ;
  my $menu_type_code ; 
  foreach  my $mtype (sort keys  %{$menu_types} ) {
    my %row_hash;
    $row_hash{menu_type_code} = $mtype;
    $row_hash{menu_type_code_descr} = $menu_types->{$mtype}->{menu_type_code_descr} ;
    if ($cur_menu_type_code eq $mtype ) {
      $row_hash{sel} =  1;
    }
    push @rows, \%row_hash;
  }
  return \@rows ; 
}

################################################
## sub get_permission_opts :
##   template used : n/a
##
##   function : returns an array ref with valid permission_ids
#################################################
                                                                                                                             
sub get_permission_opts {
  my $self = shift;
  my $cur_permission_id = shift;
                                                                                                                             
  my $wu = $self->{WEBUSER};
  my $dbh = $wu->dbh ();
                                                                                                                             
  my $perms = OpenUMS::DbQuery::get_permission_ids($dbh);
  my @rows ;
  my $menu_type_code ;
  foreach my $permission_id (@{$perms} ) {
    my %row_hash;
    $row_hash{permission_id} = $permission_id;
    if ($permission_id eq $cur_permission_id ) {
      $row_hash{sel} =  1;
    }
    print STDERR "permission_id=$permission_id \n" if (WEB_DEBUG)  ;
    push @rows, \%row_hash;
  }
  return \@rows ;
}




################################################
## sub save_new_menu : 
##   template used : none, redirect to main
##
##   function :   Saves a new Menu
#################################################

sub save_new_menu {
  ## this is used to save transfers
  my $self = shift ;
     return unless (defined($self))  ;
                                                                                                                             
  my $wu = $self->{WEBUSER};
  my $cgi = $wu->cgi ();
  my $dbh = $wu->dbh ();
                                                                                                                             
  print STDERR "called save_new_aam : " . $cgi->param('type') . " " . $cgi->param('menu_id') ."\n" if (WEB_DEBUG) ;
  if (!($cgi->param('title')) ) {
     $self->{error_message} = "MENU OPTION CAN NOT BE BLANK  ";
     return $self->add_menu();
  }
  if ($cgi->param('max_attempts') < 1  ) {
     $self->{error_message} = "Max Attempts must not be black and must be greated than 0 ";
     return $self->add_menu();
  }
  
  my $ext = $cgi->param('param1');
  print STDERR "called save_new_xfer ext =  $ext --" . OpenUMS::DbQuery::validate_mailbox($dbh,$ext)  . "-- \n"  if (WEB_DEBUG) ;
  my %data ;
  
  $data{menu_id} = OpenUMS::DbQuery::get_next_menu_id($dbh, $cgi->param('menu_id_begin')) ; 
  $data{title} = $cgi->param('title');

  $data{menu_type_code} = $cgi->param('menu_type_code');
  $data{max_attempts} = $cgi->param('max_attempts') ;
  $data{permission_id} = $cgi->param('permission_id') ;
  $data{param1} = $cgi->param('param1') ;
  $data{param2} = $cgi->param('param2') ;
  $data{param3} = $cgi->param('param3') ;
  $data{param4} = $cgi->param('param4') ;

  OpenUMS::DbUtils::generic_insert( $dbh, "menu", \%data);

  my $msg = "Added new Auto Attendant Menu, menu id : " . $data{menu_id}  ; 
  print $cgi->redirect("admin.cgi?mod=" . $self->module() . "&msg=$msg");
  exit ;

}

#################################
## sub get_menu_opts
#################################

sub get_menu_opts {
                                                                                                                                               
  my $self = shift ;
  my $dest_menu_id = shift ;
  my $allow_dbnmres = shift ;

  my $wu = $self->{WEBUSER};
  my $dbh = $wu->dbh ();
  ## now, get a list of all the menus,  their titles and menu_ids
  my $menus = OpenUMS::DbQuery::menu_data($dbh,undef,"menu_id","title","menu_type_code");
  my @menu_opts;
  ## loop thru the list and  populate the drop down
  print STDERR "cgi dest_id   = = $dest_menu_id  \n" if (WEB_DEBUG);
  foreach my $menu_id (sort keys %{$menus} ) {
     my %data;
     #if ($menus->{$menu_id}->{menu_type_code} =~ /^AAM|^XFER|^LOGIN|^DBNM/ ) {
       $data{menu_id} = $menu_id;
       $data{title} = $menus->{$menu_id}->{title};
       if ($dest_menu_id  eq $menu_id ) {
         $data{sel} = 1;
        }
        push @menu_opts, \%data;
     #}
     if ($allow_dbnmres && $menus->{$menu_id}->{menu_type_code} =~ /^DBNMRES/) {
       $data{menu_id} = $menu_id;
       $data{title} = $menus->{$menu_id}->{title};
       if ($dest_menu_id  eq $menu_id ) {
         $data{sel} = 1;
        }
        push @menu_opts, \%data;
     }
  }
  return \@menu_opts;
                                                                                                                                               
}



################################################
## sub menu_items :  a back up of an old way of doing it
##   template used : templates/menu_items.html, 
##   function : This is used to display the MDarnell  style aa menu editor
## 
#################################################

#sub menu_items {
#  my $self = shift ; 
#  return unless (defined($self))  ; 
#  my $menu_id = 503; 
#
#  my $wu = $self->{WEBUSER}; 
#  my $session = $wu->cgi_session(); 
#  my $cgi = $wu->cgi (); 
#  my $dbh = $wu->dbh (); 
#
#  if ($cgi->param('menu_id') ) { 
#      $menu_id = $cgi->param('menu_id') ; 
#  } 
###  my $perm = $wu->
#  my $perm = $wu->permissions();
#
#  if (!$perm->is_web_authorized($menu_id, $wu->permission_id() ) )  {
#     return $self->no_access();
#  }
#
#
#  my $menu = OpenUMS::DbQuery::menu_data($dbh, $menu_id); 
#  my $tmpl_file = "sm_items.html"; 
#  my $tmpl; 
#  $tmpl = new HTML::Template(filename =>  'templates/' . $tmpl_file);  
#  $tmpl->param(MSG => $cgi->param('msg') );
#  $tmpl->param(MOD => $self->module() );
#  $tmpl->param(SRC => "menu_items" ) ; 
#
#  print STDERR "MENU_ID = $menu_id\n" if (WEB_DEBUG); 
#
#  $tmpl->param(MENU_ID => $menu_id );
#  print STDERR "TITLE = $menu->{$menu_id}->{title} \n" if (WEB_DEBUG); 
#
#  $tmpl->param(TITLE => $menu->{$menu_id}->{title} );
#  $tmpl->param(MENU_TYPE_CODE => $menu->{$menu_id}->{menu_type_code} );
##  $tmpl->param(PARAM1 => $menu->{$menu_id}->{param1} );
##  $tmpl->param(PARAM2 => $menu->{$menu_id}->{param2} );
##  $tmpl->param(PARAM3 => $menu->{$menu_id}->{param3} );
#
##   my ($menu_sound_id,$sound_file) = $self->get_menu_sound($id);
#
#  my @others  ; 
#   
#  my $sql = qq{SELECT menu_item_id , menu_item_option , dest_menu_id, 
#       menu_item_action, menu_item_title, m2.title dest_title 
#     FROM menu_items mi, menu m2
#     WHERE mi.menu_id = ?  and mi.dest_menu_id = m2.menu_id };
#
#  my $sth = $dbh->prepare($sql) ;
#  $sth->execute($menu_id);
#  my $menuOptions;
#  use CGI::Enurl; 
#
#  while (my ($menu_item_id , $menu_item_option , $dest_menu_id,
#             $menu_item_action,$menu_item_title, $dest_title) 
#               = $sth->fetchrow_array() ) {
#     $menuOptions->{$menu_item_option}->{menu_item_id} = $menu_item_id ;
#     $menuOptions->{$menu_item_option}->{dest_id} = $dest_menu_id ;
#     $menuOptions->{$menu_item_option}->{dest_title} = $dest_title ;
#     $menuOptions->{$menu_item_option}->{menu_item_action} = $menu_item_action ;
#     $menuOptions->{$menu_item_option}->{title} = $menu_item_title ;
#     print STDERR "menu_item_option=$menu_item_option $menu_item_title $dest_menu_id  $dest_title\n" if (WEB_DEBUG); 
#      
#  }
#     print STDERR "\n\n" if (WEB_DEBUG); 
#  my @local_opts   = keys %{$menuOptions} ; 
#  my @tmpl_opts ; 
#  my $count = 1; 
#  foreach my $opt (@STD_OPTS ) {
###     my  %data ; 
##
##     $data{opt} = $opt; 
##     $data{opt_enc} = enurl($opt); 
##     $data{menu_id} = $menu_id; 
##     $data{menu_item_id} = $menuOptions->{$opt}->{menu_item_id} ; 
##     $data{menu_item_title} = $menuOptions->{$opt}->{title} ; 
##     $data{menu_dest_id} = $menuOptions->{$opt}->{dest_id} ; 
##     $data{menu_dest_title} = $menuOptions->{$opt}->{dest_title} ; 
##     $data{menu_item_action} = $menuOptions->{$opt}->{menu_item_action} ; 
##     $data{MOD}  = $self->module();
##
##     if (!$data{menu_item_title} ) { 
##        print STDERR " $opt " . $menuOptions->{$opt}->{title} . "\n" if (WEB_DEBUG); 
##        my @arr =();
##        if ($opt eq '*') {
##            #ok, the star really screws us..
##          @arr = grep { /^\*/ } @local_opts; 
##        } else {
##          @arr = grep { /^$opt/ } @local_opts; 
##        }
##        if (scalar(@arr) ) { 
##           print STDERR "after grep " . scalar(@arr) . " \n" if (WEB_DEBUG); 
##           $data{menu_item_id} = $menuOptions->{$arr[0]}->{menu_item_id} ; 
##           $data{menu_item_title} = $menuOptions->{$arr[0]}->{title} ; 
##           $data{menu_dest_id} = $menuOptions->{$arr[0]}->{dest_id} ; 
##           if (length($arr[0]) > 1 ) {
##              my $input = substr($arr[0],1); 
##              $data{input} = $input; 
##           } 
##           delete ${%{$menuOptions}}{$arr[0]};
##        }  
##     } 
##     push @tmpl_opts, \%data; 
##     $data{odd_row} = $count%2; 
##     
##     $count++; 
##     delete ${%{$menuOptions}}{$opt}; 
##  }
##  ## if there are any other options that do not appear....
##  foreach my $opt (keys %{$menuOptions} ) {
##     my  %data ;
##     print STDERR "optleft $opt \n"  if (WEB_DEBUG) ; 
##     $data{opt} = $opt;
##     $data{menu_id} = $menu_id;
##     $data{menu_item_id} = $menuOptions->{$opt}->{menu_item_id} ;
##     $data{menu_item_title} = $menuOptions->{$opt}->{title} ;
##     $data{menu_dest_id} = $menuOptions->{$opt}->{dest_id} ;
##     $data{menu_dest_title} = $menuOptions->{$opt}->{dest_title} ;
##     $data{menu_item_action} = $menuOptions->{$opt}->{menu_item_action} ;
##     $data{MOD}  = $self->module();
##
##     push @tmpl_opts, \%data; 
##     $data{odd_row} = $count%2; 
##     $count++; 
##
##     
##  } 
##  
##
##  $tmpl->param(MAIN_OPTS => \@tmpl_opts); 
##
##  return $tmpl ; 
##
##  ## it's it's not a transfer menu, we'll print out all the menu items...
##  if ($menu->{$menu_id}->{menu_type_code} !~ /^XFER/) { 
##     my $menu_items = $menu->{$menu_id}->{menu_items} ; 
##     print STDERR "MENU_ID = $menu_id\n" if (WEB_DEBUG); 
##  
##     my @menu_items_data ; 
##     
##     my @sorted_id = sort {
##            $menu_items->{$a}->{menu_item_option} <=>
##            $menu_items->{$b}->{menu_item_option}
##          } keys %{$menu_items} ;
##
##     my $count =1 ;  
##     if (scalar(@sorted_id) )  {  
##       foreach my $menu_item_id (@sorted_id  ) {
##         print STDERR "MENU_ITEM_ID = $menu_item_id\n" if (WEB_DEBUG); 
##         my %row ; 
##         $row{odd_row} = $count%2; 
##         $row{menu_id} = $menu_id ; 
##         $row{menu_item_id} = $menu_item_id ; 
##         $row{dest_menu_id} = $menu_items->{$menu_item_id}->{dest_menu_id} ; 
##         $row{menu_item_option} = $menu_items->{$menu_item_id}->{menu_item_option} ; 
##         $row{menu_item_title} = $menu_items->{$menu_item_id}->{menu_item_title} ; 
##         $row{menu_item_action} = $menu_items->{$menu_item_id}->{menu_item_action} ; 
##         push @menu_items_data, \%row ; 
##         $count++ ;
##       } 
##       $tmpl->param(MENU_ITEM_DATA => \@menu_items_data );
##     }
##  }
##  return $tmpl ; 
##}

################################################
## sub save_menu_item: 
##   template used : none (redirects to edit_menu_item on failure and to main on success...
##       
##   function :  Validates and if valid, saves new or edited menu item
#################################################

sub save_menu_item  {
  my $self = shift ;
     return unless (defined($self))  ;

  my $wu = $self->{WEBUSER};
  my $cgi = $wu->cgi ();
  my $dbh = $wu->dbh ();

  print STDERR "called save_menu_item type : " . $cgi->param('type') . " " . $cgi->param('menu_item_id') ."\n"  if (WEB_DEBUG); 

  my $sub_on_error ; 
  if ($cgi->param('type') =~ /^add_aa/ ) {
     $sub_on_error = sub { return $self->add_menu_item() }  ; 
  } elsif ($cgi->param('type') =~ /^add/ ) {
     $sub_on_error = sub { return $self->add_menu_item() }  ; 
  }  elsif ($cgi->param('type') =~ /^edit_aa/)  { 
     $sub_on_error = sub { return $self->edit_menu_item() }  ; 
  }  elsif ($cgi->param('type') =~ /^edit/)  { 
     $sub_on_error = sub { return $self->edit_menu_item() }  ; 
  } 
                                                                                                                             

  if (length($cgi->param('menu_item_option') ) == 0 ) { 
     $self->{error_message} = "MENU OPTION CAN NOT BE BLANK  "; 
     return $sub_on_error->();  
  } 

  if (length($cgi->param('menu_item_title') ) == 0 ) { 
     $self->{error_message} = "MENU OPTION TITLE CAN NOT BE BLANK, ANY NAME WILL DO"; 
     return $sub_on_error->();  
  } 

  if ($cgi->param('type') =~ /add/) { 
    if (OpenUMS::DbQuery::is_menu_item_option($dbh, $cgi->param('menu_id'), $cgi->param('menu_item_option') ) )  {
       $self->{error_message} = "THERE IS ALREADY AN OPTION IN THIS MENU FOR '" . $cgi->param('menu_item_option') . 
           "'"; 
       return $sub_on_error->();  
    }  
  }  elsif ($cgi->param('type') =~ /edit/) {
#    if (OpenUMS::DbQuery::is_menu_item_option($dbh, $cgi->param('menu_id'), $cgi->param('menu_item_option'),$cgi->param('menu_item_id' ) ))   {
#       $self->{error_message} = "THERE IS ALREADY AN OPTION IN THIS MENU FOR '" . $cgi->param('menu_item_option') .
#           "'";
#       return $sub_on_error->();
#    }
  } 

  


  if ($cgi->param('type') =~ /^add/) {
    my @fields = qw(menu_id menu_item_option dest_menu_id  menu_item_action menu_item_title) ; 
    my %data;
    foreach my $f (@fields) {
      $data{$f} = $cgi->param($f); 
    } 
    OpenUMS::DbUtils::generic_insert( $dbh, "menu_items", \%data);
  } elsif ($cgi->param('type') =~ /^edit/) { 
    my @fields = qw(menu_item_option dest_menu_id  menu_item_action menu_item_id menu_item_title) ; 
    my %data;
    foreach my $f (@fields) {
      $data{$f} = $cgi->param($f); 
    } 
    print STDERR "It's edit....\n" if (WEB_DEBUG); 
    OpenUMS::DbUtils::generic_update($dbh, "menu_items", \%data, "menu_item_id");
  } 

  if ($cgi->param('type') =~ /^add_aa|^edit_aa/) {
     my $msg   ;
     if ($cgi->param('type') =~ /^add_aa/){ 
       $msg = "Added Option " . $cgi->param('menu_item_option') ;
       $msg .= " entitled '" . $cgi->param('menu_item_title') . "'"; 
       $msg .= " to " . $cgi->param('menu_id') . '.'; 
     } elsif ($cgi->param('type') =~ /^edit_aa/)  {
       $msg = "Saved Changes to Option " . $cgi->param('menu_item_option') ;
       $msg .= " entitled '" . $cgi->param('menu_item_title') . "'"; 
       $msg .= " of  " . $cgi->param('menu_id') . '.'; 
      
     } 
     print $cgi->redirect("admin.cgi?mod=" . $self->module() . "&func=menu_items&menu_id=" . $cgi->param('menu_id') . "&msg=$msg" ); 
     exit ; 
  } else {
     print $cgi->redirect("admin.cgi?mod=" . $self->module() . "&func=menu_items&menu_id=" . $cgi->param('menu_id') ); 
     exit ; 
  } 
  return $self->menu_items() ; 
}

################################################
## sub save_add_aam : 
##   template used : none, redirect to main
##
##   function :   Saves a new Auto Attendant Menu
#################################################

sub save_new_aam {
  ## this is used to save transfers
  my $self = shift ;
     return unless (defined($self))  ;
                                                                                                                             
  my $wu = $self->{WEBUSER};
  my $cgi = $wu->cgi ();
  my $dbh = $wu->dbh ();
                                                                                                                             
  print STDERR "called save_new_aam : " . $cgi->param('type') . " " . $cgi->param('menu_id') ."\n" if (WEB_DEBUG) ;
  if (!($cgi->param('title')) ) {
     $self->{error_message} = "MENU OPTION CAN NOT BE BLANK  ";
     return $self->add_aam();
  }
  if ($cgi->param('max_attempts') < 1  ) {
     $self->{error_message} = "Max Attempts must not be black and must be greated than 0 ";
     return $self->add_aam();
  }
  
  my $ext = $cgi->param('param1');
  print STDERR "called save_new_xfer ext =  $ext --" . OpenUMS::DbQuery::validate_mailbox($dbh,$ext)  . "-- \n"  if (WEB_DEBUG) ;
  my %data ;
  $data{menu_id} = $cgi->param('menu_id'); 
  $data{menu_type_code} = "AAM";
  $data{max_attempts} = $cgi->param('max_attempts') ;
  $data{title} = $cgi->param('title');
  $data{permission_id} = 'ANON' ;

  OpenUMS::DbUtils::generic_insert( $dbh, "menu", \%data);

  my $msg = "Added new Auto Attendant Menu, menu id : " . $data{menu_id}  ; 
  print $cgi->redirect("admin.cgi?mod=' . $self->module() . '&msg=$msg");
  exit ;

}


################################################
## sub save_menu : 
##   template used : none, redirects to main
##   function      : This is used to save new transfer
#################################################

sub save_menu {
  my $self = shift ;
     return unless (defined($self))  ;

  my $wu = $self->{WEBUSER};
  my $cgi = $wu->cgi ();
  my $dbh = $wu->dbh ();
                                                                                                                             
  print STDERR "called save_menu : " . $cgi->param('type') . " " . $cgi->param('menu_id') ."\n" if (WEB_DEBUG) ;
                                                                                                                             
  my $sub_on_error ;
  if ($cgi->param('type') =~ /^edit_dbnm/ ) {
     $sub_on_error = sub { return $self->edit_dbnm() }  ;
  } elsif ($cgi->param('type') =~ /^edit_xfer/ ) {
     $sub_on_error = sub { return $self->edit_xfer() }  ;
  } elsif ($cgi->param('type') =~ /^edit_aam/ ) {
     $sub_on_error = sub { return $self->edit_aam() }  ;
  }  else { 
     $sub_on_error = sub { return $self->edit_menu() }  ;
  }

  if (!($cgi->param('title')) ) { 
     $self->{error_message} = "MENU TITLE CAN NOT BE BLANK  ";
     return $sub_on_error->(); 
  }

#  if ($cgi->param('menu_type_code') ne  $cgi->param('old_menu_type_code' ) ) { 
#     $self->{error_message} = "MENU TYPE CODE HAS CHANGED!";
#     return $sub_on_error->(); 
#  } 
  if (($cgi->param('type') =~ /^edit_aam/) && ($cgi->param('max_attempts') < 1 )  ) { 
     $self->{error_message} = "Max Attempts must not be black and must be greated than 0 ";
     return $sub_on_error->(); 
  } 
  
  $self->{error_message} = "All Good baby ";

  my @fields = qw(menu_id title permission_id menu_type_code collect_time max_attempts param1 param2 param3 param4) ; 
  my %data;
  foreach my $f (@fields) {
    if ($f eq 'collect_time') {
      if ($cgi->param($f) =~ /[0-9]+/) {
         $data{$f} = $cgi->param($f);
      }  else {
         $data{$f} = "NULL" ;
      }
    } else {
      $data{$f} = $cgi->param($f);
    }
  } 

  OpenUMS::DbUtils::generic_update($dbh, "menu", \%data, "menu_id");
  my $msg = "Updated Menu " . $data{menu_id}  ; 
  my $mod = $self->module() ; 
  print STDERR "mod = $mod \n" if (WEB_DEBUG);  

  print $cgi->redirect("admin.cgi?mod=" . $mod . "&msg=$msg");
  exit ;

}


################################################
## sub add_menu_item : 
##   template used : menu_item_aa_form.html
##   function      : This is used add a new menu option for an Auto Attendand Menu
#################################################

sub add_menu_item {
  my $self = shift ; 
  return unless (defined($self))  ; 

  my $wu = $self->{WEBUSER}; 
  my $session = $wu->cgi_session(); 
  my $cgi = $wu->cgi (); 
  my $dbh = $wu->dbh (); 
  if (!$cgi->param('menu_id') ) { 
     return ;
  } 
  my $menu_id  = $cgi->param('menu_id'); 

  my $tmpl = new HTML::Template(filename => 'templates/sm_item_form.html'); 
  my $menu = OpenUMS::DbQuery::menu_data($dbh,$menu_id); 

  $tmpl->param('mod' =>  $self->module()  ) ;
  $tmpl->param('func' => 'save_menu_item' ) ;
  $tmpl->param('type' => 'add_aa' ) ;
  $tmpl->param('add_form' => 1 ) ;
  ## set the stuff for the menu... none of thise stuff gets edited
  $tmpl->param(MENU_ID => $menu_id );
  $tmpl->param(TITLE => $menu->{$menu_id}->{title} );
  $tmpl->param(MENU_TYPE_CODE => $menu->{$menu_id}->{menu_type_code} );

  $tmpl->param(PARAM1 => $menu->{$menu_id}->{param1} );
  $tmpl->param(PARAM2 => $menu->{$menu_id}->{param2} );
  $tmpl->param(PARAM3 => $menu->{$menu_id}->{param3} );
  ## if the menu type is DBNMRES then we need to give them the NEXTNAME option
  if ($menu->{$menu_id}->{menu_type_code} =~ /DBNMRES/ ) { 
     $tmpl->param(DBNMRES => 1);
  }

  ## set the error message if they screwed up .....
  $tmpl->param(error_message => $self->{error_message} );
                                                                                                                             
  ## set the stuff for the menu items, that is if it's there..
  $tmpl->param(MENU_ITEM_OPTIONS  => $self->get_menu_item_options($cgi->param('menu_item_option') ) )  ; 
#  $tmpl->param(menu_item_option => $cgi->param('menu_item_option') ) ;

  $tmpl->param(menu_item_title  => $cgi->param('menu_item_title') ) ;
  $tmpl->param(menu_item_action  => $cgi->param('menu_item_action') ) ;
  my $dest_menu_id = $cgi->param('dest_menu_id'); 

  ## set the stuff for the menu items, that is if it's there..
     
  ## now, get a list of all the menus,  their titles and menu_ids
  my $menu_opts = $self->get_menu_opts($dest_menu_id); 
  $tmpl->param(MENU_OPTS => $menu_opts);
  return $tmpl ; 


}

################################################
## sub edit_menu_item : 
##   template used : menu_item_aa_form.html
##   function      : This is used add a new menu option for an Auto Attendand Menu
#################################################

sub edit_menu_item {
  my $self = shift ; 
  return unless (defined($self))  ; 

  my $wu = $self->{WEBUSER}; 
  my $session = $wu->cgi_session(); 
  my $cgi = $wu->cgi (); 
  my $dbh = $wu->dbh (); 
  if (!$cgi->param('menu_id') ) { 
     return ;
  } 
  my $menu_id  = $cgi->param('menu_id'); 

  my $tmpl = new HTML::Template(filename => 'templates/sm_item_form.html'); 
  my $menu = OpenUMS::DbQuery::menu_data($dbh,$menu_id); 

  $tmpl->param('mod' =>  $self->module()  ) ;
  $tmpl->param('func' => 'save_menu_item' ) ;
  $tmpl->param('type' => 'edit_aa' ) ;
  $tmpl->param('edit_form' => 1 ) ;

  ## set the stuff for the menu... none of thise stuff gets edited
  $tmpl->param(MENU_ID => $menu_id );
  $tmpl->param(TITLE => $menu->{$menu_id}->{title} );
  $tmpl->param(MENU_TYPE_CODE => $menu->{$menu_id}->{menu_type_code} );

  $tmpl->param(PARAM1 => $menu->{$menu_id}->{param1} );
  $tmpl->param(PARAM2 => $menu->{$menu_id}->{param2} );
  $tmpl->param(PARAM3 => $menu->{$menu_id}->{param3} );

  ## this iz for the dial by name menu...
  if ($menu->{$menu_id}->{menu_type_code} =~ /DBNMRES/ ) { 
     $tmpl->param(DBNMRES => 1);
  }

  ## set the error message if they screwed up .....
  $tmpl->param(error_message => $self->{error_message} );



  my $menu_item_id  = $cgi->param('menu_item_id'); 

  $tmpl->param(menu_item_id => $menu_item_id ) ;

  my $dest_menu_id;
  my $menu_item_action ; 
  my $menu_items  ; 
  if (!$self->{error_message} ) {
    my $these_menu_items = OpenUMS::DbQuery::get_menu_item($dbh,$menu_item_id )  ;
    $menu_items = $these_menu_items->{$menu_item_id} ; 
    
  } else {
    $menu_items = $cgi->Vars(); 
  } 
    print STDERR "menu_item_option = $menu_items->{menu_item_option} \n" if (WEB_DEBUG) ; 
  $tmpl->param(menu_item_options => $self->get_menu_item_options($menu_items->{menu_item_option} ) ) ;
  $tmpl->param(menu_item_title  => $menu_items->{menu_item_title} );
  $tmpl->param(menu_item_action  => $menu_items->{menu_item_action} ) ;
  $dest_menu_id = $menu_items->{dest_menu_id};
  $menu_item_action = $menu_items->{menu_item_action}; 

  ## set the stuff for the menu items, that is if it's there..
     
  ## now, get a list of all the menus,  their titles and menu_ids
  my $menu_opts = $self->get_menu_opts($dest_menu_id); 
  if ($menu_item_action =~ /^NEXTNAME/) {
      $tmpl->param(action_next_name => 1) ; 
  } 
  

  $tmpl->param(MENU_OPTS => $menu_opts);
  return $tmpl ; 
}
#################################
## sub menu_sounds
#################################
sub menu_sounds {
 my $self = shift ;
  return unless (defined($self))  ;
                                                                                                                             
  my $wu = $self->{WEBUSER};
  my $session = $wu->cgi_session();
  my $cgi = $wu->cgi ();
  my $dbh = $wu->dbh ();

  if (!$cgi->param('menu_id') ) {
     return ;
  }
  my $menu_id  = $cgi->param('menu_id');
  my $tmpl = new HTML::Template(filename => 'templates/sm_menu_sounds.html'); 
  my $sql = qq{ SELECT menu_sound_id, menu_id, sound_title, var_name, sound_file, order_no 
        FROM menu_sounds WHERE menu_id = $menu_id AND sound_type ='M' ORDER by order_no }; 

  my @rows ; 
  my $sth = $dbh->prepare($sql); 

  $sth->execute();
  while (my $hr = $sth->fetchrow_hashref() ) {
     push @rows, $hr; 
  } 
  $sth->finish();

  $tmpl->param(MENU_SOUNDS => \@rows ); 

   $sql = qq{ SELECT menu_sound_id, menu_id, sound_title, var_name, sound_file, order_no 
        FROM menu_sounds WHERE menu_id = $menu_id AND sound_type ='I' ORDER by order_no }; 
   @rows =() ; 
   $sth = $dbh->prepare($sql); 
   while (my $hr = $sth->fetchrow_hashref() ) {
     push @rows, $hr; 
   } 
  return $tmpl; 
}

#################################
## sub get_menu_item_options
#################################
sub get_menu_item_options {
  my $self = shift ;
  my $sel = shift ;

  my @mi_opts ;
  foreach my $opt (@ALL_OPTS) { 
    my $row ;
    $row->{menu_item_option} = $opt;
    print STDERR "$row->{menu_item_option}  == $sel \n" if (WEB_DEBUG); 
    if ($sel eq $row->{menu_item_option} ) {
       print STDERR "YEAAAAAAAAAAAAH $row->{menu_item_option}  == $sel \n" if (WEB_DEBUG); 
       $row->{sel} = 1;
    }
    push @mi_opts, $row ;
  }
  return \@mi_opts;

} 

1; 
