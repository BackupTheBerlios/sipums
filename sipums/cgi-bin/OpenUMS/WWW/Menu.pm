package OpenUMS::WWW::Menu;
### $Id: Menu.pm,v 1.1 2004/07/20 03:14:53 richardz Exp $
#
# WWW/Menu.pm
#
# Main menu for web interface
#
# Copyright (C) 2003 Integrated Comtel Inc.
use strict; 

use lib '/usr/local/openums/lib'; 

## always use the web tools
use OpenUMS::WWW::WebTools;

use HTML::Template; 
use OpenUMS::DbQuery; 
use OpenUMS::Holidays; 
use OpenUMS::DbUtils; 
use OpenUMS::Common; 
use OpenUMS::Config; 


use base ("OpenUMS::WWW::WebModuleBase"); 

my @STD_OPTS = ('1','2','3','4','5','6','7','8','9','0','*','#','DEFAULT','EXT');
my @ALL_OPTS = ('1','2','3','4','5','6','7','8','9','0','*','#','DEFAULT','EXT', '??','???','????','?????','??????' );



################################################3
## sub main: 
##   template used : templates/menu_main.html
##   function : prints Menu Summary, Auto Attendant menus and transfer menus  
##    but no user menus
#######
my $MODULE = 'Menu'; 

sub main {
  my $self = shift ; 
  return unless (defined($self))  ; 
  my $wu = $self->{WEBUSER}; 
  my $session = $wu->cgi_session(); 
  my $cgi = $wu->cgi (); 
  my $dbh = $wu->dbh (); 

  print STDERR " Got the session: id=" . $session->id() . "ext=" . $session->param('extension') . "\n" if (WEB_DEBUG) ;

  my ($current_menu_id,$holiday_name) = OpenUMS::Holidays::get_holiday_menu_id($dbh);

  if (!defined($current_menu_id) ) {
     $current_menu_id = OpenUMS::DbQuery::get_current_aa_menu_id($dbh);
  } 
  print STDERR "current_menu_id menu id = $current_menu_id \n" if (WEB_DEBUG); 


  my $tmpl = new HTML::Template(filename =>  'templates/menu_main.html');  
  my $menus = OpenUMS::DbQuery::menu_data($dbh); 
#  my @user_menu_data  ; 
  my @aa_menu_data  ; 
  my @xfer_menu_data  ; 
  my @dbnm_menu_data  ; 
  my @recmsg_menu_data  ; 
  
  my $count = 1;
   
  foreach my $id (sort keys %{$menus} ) {
    my $row ;
    my $menu_hr = $menus->{$id} ;
    $row->{menu_id} = $id ; 
    $row->{title} = $menu_hr->{title} ; 
    $row->{menu_type_code} = $menu_hr->{menu_type_code} ;
    $row->{odd_row} = $count%2; 
    if ($menu_hr->{permission_id} =~ /^ANON/  ) { 
      ## transfers...
      if ($row->{menu_type_code} =~ /^XFER/) { 
         ## we exclude the very first transfers..
         $row->{extension} = $menu_hr->{param1}; 
         if ($id ne '801' && $id ne '802') { 
            push @xfer_menu_data, $row;
         } 
      } 
      if ($row->{menu_type_code} =~ /^RECMSG/) {
         ## we exclude the very first transfers..
         $row->{extension} = $menu_hr->{param1};
         if ($id ne '801' && $id ne '802') {
            push @recmsg_menu_data, $row;
         }
      }
 

      if ($row->{menu_type_code} =~ /^AA|^UINFO/) { 
        $row->{menu_sounds} =  $self->get_menu_sounds($id); 
#        $row->{max_attempts} = $menu_hr->{max_attempts} ;
        if ($row->{menu_id} eq $current_menu_id) { 
           $row->{current_aa} = 1;   
        } 
        if ($row->{menu_id} eq HOLIDAY_MENU_ID ) {
           $row->{holiday_menu} = 1;   
           
        } 
        push @aa_menu_data, $row;
      } 

      if ($row->{menu_type_code} =~ /^DBNM/) { 
         ## this is the auto attendant
         if ($row->{menu_type_code} =~ /^DBNMRES/) {
            ## for the results, they can edit it...
              $row->{ITEMS_EDIT} = 1; 
         } 
         push @dbnm_menu_data, $row;
      } 
   }
    $count++;
  }
 
  $tmpl->param(MSG => $cgi->param('msg') ) ;
#  $tmpl->param(USER_MENU_DATA => \@user_menu_data);
  $tmpl->param(AA_MENU_DATA => \@aa_menu_data);
  $tmpl->param(XFER_MENU_DATA => \@xfer_menu_data);
  $tmpl->param(DBNM_MENU_DATA => \@dbnm_menu_data);
  $tmpl->param(RECMSG_MENU_DATA => \@recmsg_menu_data);

  return $tmpl ; 
} 

################################################
## sub menu_items: 
##   template used : templates/menu_items.html, 
##       templates/menu_items_xfer.html (used when showing transfer menus) 
##   function : prints Menu Options for a given menu
##      user may click on links to add or edit the menu items
#################################################

## sub menu_items {
##   my $self = shift ; 
##   return unless (defined($self))  ; 
##   my $menu_id = 503; 
## 
##   my $wu = $self->{WEBUSER}; 
##   my $session = $wu->cgi_session(); 
##   my $cgi = $wu->cgi (); 
##   my $dbh = $wu->dbh (); 
## 
##   if ($cgi->param('menu_id') ) { 
##       $menu_id = $cgi->param('menu_id') ; 
##   } 
## 
##   ## verify user's access, if not send the to NO ACCESS Zone
##   my $perm = $wu->permissions(); 
##   if (!$perm->is_web_authorized($menu_id, $wu->permission_id() ) )  { 
##      return $self->no_access();
##   }
##   ## end verify permissions
## 
## 
##   my $menu = OpenUMS::DbQuery::menu_item_data($dbh, $menu_id); 
##   my $tmpl_file = "menu_items.html"; 
##   my $tmpl; 
##   
##   ## verify user's access, if not send the to NO ACCESS Zone
## 
##   if ($menu->{$menu_id}->{menu_type_code}  =~ /^XFER/) { 
##       $tmpl_file = 'menu_items_xfer.html' ;  
##   } 
##   $tmpl = new HTML::Template(filename =>  'templates/' . $tmpl_file);  
## 
##   print STDERR "MENU_ID = $menu_id\n" if (WEB_DEBUG); 
## 
##   $tmpl->param(MENU_ID => $menu_id );
## 
##   print STDERR "TITLE = $menu->{$menu_id}->{title} \n" if (WEB_DEBUG); 
##   $tmpl->param(TITLE => $menu->{$menu_id}->{title} );
##   $tmpl->param(MENU_TYPE_CODE => $menu->{$menu_id}->{menu_type_code} );
## 
##   $tmpl->param(PARAM1 => $menu->{$menu_id}->{param1} );
##   $tmpl->param(PARAM2 => $menu->{$menu_id}->{param2} );
##   $tmpl->param(PARAM3 => $menu->{$menu_id}->{param3} );
## 
##   ## it's it's not a transfer menu, we'll print out all the menu items...
##   if ($menu->{$menu_id}->{menu_type_code} !~ /^XFER/) { 
##      my $menu_items = $menu->{$menu_id}->{menu_items} ; 
##   
##      my @menu_items_data ; 
##      
##      my @sorted_id = sort {
##             $menu_items->{$a}->{menu_item_option} <=>
##             $menu_items->{$b}->{menu_item_option}
##           } keys %{$menu_items} ;
## 
##      my $count =1 ;  
##      if (scalar(@sorted_id) )  {  
##        foreach my $menu_item_id (@sorted_id  ) {
##          my %row ; 
##          $row{odd_row} = $count%2; 
##          $row{menu_id} = $menu_id ; 
##          $row{menu_item_id} = $menu_item_id ; 
##          $row{dest_menu_id} = $menu_items->{$menu_item_id}->{dest_menu_id} ; 
##          $row{menu_item_option} = $menu_items->{$menu_item_id}->{menu_item_option} ; 
##          $row{menu_item_title} = $menu_items->{$menu_item_id}->{menu_item_title} ; 
##          $row{menu_item_action} = $menu_items->{$menu_item_id}->{menu_item_action} ; 
##          push @menu_items_data, \%row ; 
##          $count++ ;
##        } 
##        $tmpl->param(MENU_ITEM_DATA => \@menu_items_data );
##      }
##   }
##   return $tmpl ; 
## }

################################################
## sub edit_menu_item: 
##   template used : templates/menu_item_form.html
##       
##   function : Allows a specific menu item/option to be editted
##     displays a list of menu_ids to edit
#################################################

sub edit_menu_item {

  my $self = shift ; 
  return unless (defined($self))  ; 

  my $wu = $self->{WEBUSER}; 
  my $session = $wu->cgi_session(); 
  my $cgi = $wu->cgi (); 
  my $dbh = $wu->dbh (); 
  if (!$cgi->param('menu_id') && !$cgi->param('menu_item_id') ) { 
     return ;
  } 
  my $menu_id  = $cgi->param('menu_id'); 

  ## verify user's access, if not send the to NO ACCESS Zone
  my $perm = $wu->permissions(); 
  if (!$perm->is_web_authorized($menu_id, $wu->permission_id() ) )  { 
     return $self->no_access();
  }
  ## end verify permissions

  my $menu_item_id  = $cgi->param('menu_item_id'); 
  if (!$menu_item_id ) {
     return $self->menu_items(); 
  } 

  my $tmpl = new HTML::Template(filename => 'templates/menu_item_form.html'); 
  
  my $menu = OpenUMS::DbQuery::menu_data($dbh,$menu_id); 

  $tmpl->param('mod' => $MODULE ) ;
  $tmpl->param('func' => 'save_menu_item' ) ;
  $tmpl->param('type' => 'edit' ) ;
  $tmpl->param('edit_form' => 1 ) ;
  ## set the stuff for the menu...
  $tmpl->param(MENU_ID => $menu_id );
  $tmpl->param(TITLE => $menu->{$menu_id}->{title} );
  $tmpl->param(MENU_TYPE_CODE => $menu->{$menu_id}->{menu_type_code} );
  $tmpl->param(PARAM1 => $menu->{$menu_id}->{param1} );
  $tmpl->param(PARAM2 => $menu->{$menu_id}->{param2} );
  $tmpl->param(PARAM3 => $menu->{$menu_id}->{param3} );
                                                                                                                             
  ## set the error message if they screwed up .....
  $tmpl->param(error_message => $self->{error_message} );
                                                                                                                             
  ## set the menu_item_id
  $tmpl->param(menu_item_id => $menu_item_id ) ;
                                                                                                                             
  my $dest_menu_id; 
  if (!$self->{error_message} ) {
    my $menu_items = OpenUMS::DbQuery::get_menu_item($dbh,$menu_item_id )  ; 

    return if (!defined( $menu_items ) )  ; 

    $tmpl->param(menu_item_option => $menu_items->{$menu_item_id}->{menu_item_option} ) ;   
    $tmpl->param(menu_item_title  => $menu_items->{$menu_item_id}->{menu_item_title} ); 
    $tmpl->param(menu_item_action  => $menu_items->{$menu_item_id}->{menu_item_action} ) ; 
    $dest_menu_id = $menu_items->{$menu_item_id}->{dest_menu_id}; 

  }  else {
    $tmpl->param(menu_item_option => $cgi->param('menu_item_option') ) ;
    $tmpl->param(menu_item_title  => $cgi->param('menu_item_title') ) ;
    $tmpl->param(menu_item_action  => $cgi->param('menu_item_action') ) ;
    $dest_menu_id = $cgi->param('dest_menu_id'); 
                                                                                                                             
  }

  ## now, get a list of all the menus,  their titles and menu_ids
  my $menus = OpenUMS::DbQuery::menu_data($dbh,undef,"menu_id","title");
  my @menu_opts; 
  ## loop thru the list and  populate the drop down
  print STDERR "cgi dest_id   = = " . $cgi->param('dest_menu_id') . " \n" if (WEB_DEBUG); 
  foreach my $menu_id (sort keys %{$menus} ) {
    my %data;
    $data{menu_id} = $menu_id; 
    $data{title} = $menus->{$menu_id}->{title}; 
    if ($dest_menu_id eq $menu_id ) { 
       $data{sel} = 1; 
    }  
    push @menu_opts, \%data; 
  } 

  $tmpl->param(MENU_OPTS => \@menu_opts);
  return $tmpl ; 

}

################################################
## sub add_menu_item: 
##   template used : templates/menu_item_form.html
##       
##   function : Allows u to add a specific menu item/option 
##     displays a list of menu_ids to use for a destination
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

  ## verify user's access, if not send the to NO ACCESS Zone
  my $perm = $wu->permissions(); 
  if (!$perm->is_web_authorized($menu_id, $wu->permission_id() ) )  { 
     return $self->no_access();
  }
  ## end verify permissions

  my $tmpl = new HTML::Template(filename => 'templates/menu_item_form.html'); 
  my $menu = OpenUMS::DbQuery::menu_data($dbh,$menu_id); 

  $tmpl->param('mod' => $self->module() ) ;
  $tmpl->param('func' => 'save_menu_item' ) ;
  $tmpl->param('type' => 'add' ) ;
  $tmpl->param('add_form' => 1 ) ;
  ## set the stuff for the menu... none of thise stuff gets edited
  $tmpl->param(MENU_ID => $menu_id );
  $tmpl->param(TITLE => $menu->{$menu_id}->{title} );
  $tmpl->param(MENU_TYPE_CODE => $menu->{$menu_id}->{menu_type_code} );

  $tmpl->param(PARAM1 => $menu->{$menu_id}->{param1} );
  $tmpl->param(PARAM2 => $menu->{$menu_id}->{param2} );
  $tmpl->param(PARAM3 => $menu->{$menu_id}->{param3} );
                                                                                                                             
  ## set the error message if they screwed up .....
  $tmpl->param(error_message => $self->{error_message} );
                                                                                                                             
  ## set the stuff for the menu items, that is if it's there..
  $tmpl->param(menu_item_option => $cgi->param('menu_item_option') ) ;
  $tmpl->param(menu_item_title  => $cgi->param('menu_item_title') ) ;
  $tmpl->param(menu_item_action  => $cgi->param('menu_item_action') ) ;
  my $dest_menu_id = $cgi->param('dest_menu_id') ; 
  ## set the stuff for the menu items, that is if it's there..
     
  ## now, get a list of all the menus,  their titles and menu_ids
  my $menus = OpenUMS::DbQuery::menu_data($dbh,undef,"menu_id","title");
  my @menu_opts; 
  ## loop thru the list and  populate the drop down
  print STDERR "cgi dest_id   = = " . $cgi->param('dest_menu_id') . " \n" if (WEB_DEBUG); 
  foreach my $menu_id (sort keys %{$menus} ) {
     my %data;
     $data{menu_id} = $menu_id; 
     $data{title} = $menus->{$menu_id}->{title}; 
     if ($dest_menu_id eq $menu_id ) { 
        $data{sel} = 1; 
     }  
     push @menu_opts, \%data; 
  } 

  $tmpl->param(MENU_OPTS => \@menu_opts);
  return $tmpl ; 



}

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

  print STDERR "called save_menu_item type : " . $cgi->param('type') . " "  if (WEB_DEBUG) ;  
  print STDERR "item_id = " . $cgi->param('menu_item_id') ."\n"  if (WEB_DEBUG); 

  my $sub_on_error ; 
  if ($cgi->param('type') =~ /^add_aa/ ) {
     $sub_on_error = sub { return $self->add_menu_item_aa() }  ; 
  } elsif ($cgi->param('type') =~ /^add/ ) {
     $sub_on_error = sub { return $self->add_menu_item() }  ; 
  }  elsif ($cgi->param('type') =~ /^edit_aa/)  { 
     $sub_on_error = sub { return $self->edit_menu_item_aa() }  ; 
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
    if (OpenUMS::DbQuery::is_menu_item_option($dbh, $cgi->param('menu_id'), $cgi->param('menu_item_option'),$cgi->param('menu_item_id' ) ))   {
       $self->{error_message} = "THERE IS ALREADY AN OPTION IN THIS MENU FOR '" . $cgi->param('menu_item_option') .
           "'";
       return $sub_on_error->();
    }
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
## sub delete_menu_conf: 
##   template used : templates/menu_delete_conf.html
##   function :   Should prompt user and make sure they want to delete
#################################################

sub delete_menu_conf {
  my $self = shift ;
  return unless (defined($self))  ;

  my $wu = $self->{WEBUSER};
  my $cgi = $wu->cgi();
  my $dbh = $wu->dbh(); 
  my $menu_id = $cgi->param('menu_id'); 


  ## verify user's access, if not send the to NO ACCESS Zone
  my $perm = $wu->permissions(); 
  if (!$perm->is_web_authorized($menu_id, $wu->permission_id() ) )  { 
     return $self->no_access();
  }
  ## end verify permissions


  my $menu = OpenUMS::DbQuery::menu_data($dbh,$menu_id);
  my $tmpl = new HTML::Template(filename =>  'templates/menu_delete_conf.html');

  ## get the menu's  dependencies
  my $deps_ar = OpenUMS::DbQuery::get_menu_deps($dbh,$menu_id);

  if (defined($deps_ar)) {
     $tmpl->param('deps_exist' => 1); 
     $tmpl->param('deps' => $deps_ar); 
  } 
                                                                                                                             
  $tmpl->param('error_message' => $self->{error_message}  ) ;
  $tmpl->param('mod' => $self->module()) ;
  $tmpl->param('func' => 'delete_menu' ) ;
  ## set the stuff for the menu...
  $tmpl->param(MENU_ID => $menu_id );
  $tmpl->param(TITLE => $menu->{$menu_id}->{title} );
  $tmpl->param(MENU_TYPE_CODE => $menu->{$menu_id}->{menu_type_code} );
  $tmpl->param(PARAM1 => $menu->{$menu_id}->{param1} );
  $tmpl->param(PARAM2 => $menu->{$menu_id}->{param2} );
  $tmpl->param(PARAM3 => $menu->{$menu_id}->{param3} );
 

  return $tmpl ;

}

################################################
## sub delete_menu: 
##   template used : none, returns to main on success
#                on failure, returns to delete_menu_conf  with error message
##   function :  Deletes a menu, will not delete if menu has dependencies.
#################################################

sub delete_menu {
  my $self = shift ;
  return unless (defined($self))  ;

  my $wu = $self->{WEBUSER};
  my $cgi = $wu->cgi();
  my $dbh = $wu->dbh(); 
  my $menu_id = $cgi->param('menu_id'); 

  ## verify user's access, if not send the to NO ACCESS Zone
  my $perm = $wu->permissions(); 
  if (!$perm->is_web_authorized($menu_id, $wu->permission_id() ) )  { 
     return $self->no_access();
  }
  ## end verify permissions

  if (!$menu_id) {
     ## redirect them to the main menu page...
     print $cgi->redirect("admin.cgi?mod=" . $self->module() ); 
     exit ; 
  } 
    ## get the menu's  dependencies
  my $deps_ar = OpenUMS::DbQuery::get_menu_deps($dbh,$menu_id);

  if (defined($deps_ar)) {
     $self->{error_message} = "Can not delete, dependencies exist !";
     return $self->delete_menu_conf(); 
  } else {
     ## delete menu
     my $sql = "DELETE FROM menu WHERE menu_id = $menu_id "; 
     my $rows = $dbh->do($sql); 
     my $msg = "DELETED Menu $menu_id"; 
     ## delete menu_items
     $sql = "DELETE FROM menu_items WHERE menu_id = $menu_id "; 
     $rows = $dbh->do($sql); 
     $msg .= ", DELETED menu_items for $menu_id"; 
     ## delete menu_items
     $sql = "DELETE FROM menu_sounds WHERE menu_id = $menu_id "; 
     $rows = $dbh->do($sql); 
     $msg .= ", DELETED menu_sounds for $menu_id"; 
     print $cgi->redirect("admin.cgi?mod=" . $self->module() . "&msg=$msg");
  }

  
}

################################################
## sub delete_menu_item_conf: 
##   STUB
##   template used : templates/menu_delete_item_conf.html
##       
##   function :   Should prompt user and make sure they want 
##      to delete a menu item
#################################################

sub delete_menu_item_conf {
  my $self = shift ;
  return unless (defined($self))  ;
   
  my $wu = $self->{WEBUSER};
  my $cgi = $wu->cgi();
  my $dbh = $wu->dbh (); 

  my $menu_id  = $cgi->param('menu_id');
  my $menu_item_id  = $cgi->param('menu_item_id');
  if (!$menu_item_id && !$menu_id ) {
     return $self->menu_items();
  }


  ## verify user's access, if not send the to NO ACCESS Zone
  my $perm = $wu->permissions(); 
  if (!$perm->is_web_authorized($menu_id, $wu->permission_id() ) )  { 
     return $self->no_access();
  }
  ## end verify permissions

  my $tmpl = new HTML::Template(filename =>  'templates/menu_item_delete_conf.html');
  my $menu = OpenUMS::DbQuery::menu_data($dbh,$menu_id);

  $tmpl->param('mod' => $self->module() ) ;
  $tmpl->param('func' => 'delete_menu_item' ) ;
  if ($cgi->param('aa') ) { 
     $tmpl->param('type' => 'delete_aa_item' ) ;
  }  else { 
     $tmpl->param('type' => 'delete_item' ) ;
  } 
  $tmpl->param('func' => 'delete_menu_item' ) ;
  ## set the stuff for the menu...
  $tmpl->param(MENU_ID => $menu_id );
  $tmpl->param(TITLE => $menu->{$menu_id}->{title} );
  $tmpl->param(MENU_TYPE_CODE => $menu->{$menu_id}->{menu_type_code} );
  $tmpl->param(PARAM1 => $menu->{$menu_id}->{param1} );
  $tmpl->param(PARAM2 => $menu->{$menu_id}->{param2} );
  $tmpl->param(PARAM3 => $menu->{$menu_id}->{param3} );
                                                                                                                             
  ## set the menu_item_id
  $tmpl->param(menu_item_id => $menu_item_id ) ;

  my $menu_items = OpenUMS::DbQuery::get_menu_item($dbh,$menu_item_id )  ;
                                                                                                                           
  return if (!defined( $menu_items ) )  ;
                                                                                                                             
    $tmpl->param(menu_item_option => $menu_items->{$menu_item_id}->{menu_item_option} ) ;
    $tmpl->param(menu_item_title  => $menu_items->{$menu_item_id}->{menu_item_title} );
    $tmpl->param(menu_item_action  => $menu_items->{$menu_item_id}->{menu_item_action} ) ;
    $tmpl->param(dest_menu_id  => $menu_items->{$menu_item_id}->{dest_menu_id} ) ;

   return $tmpl ;

}

################################################
## sub delete_menu_item : 
##   template used : none, redirect to menu_items
##
##   function :   Deletes a menu item for the user
#################################################

sub delete_menu_item {
  my $self = shift ;
     return unless (defined($self))  ;
  my $wu = $self->{WEBUSER};
  my $cgi = $wu->cgi ();
  my $dbh = $wu->dbh ();

  my $menu_item_id = $cgi->param('menu_item_id');

  my $menu_items = OpenUMS::DbQuery::get_menu_item($dbh,$menu_item_id )  ;

  my $sql = "DELETE FROM menu_items where menu_item_id = $menu_item_id " ; 
  print STDERR "delete_menu_item = $sql\n" if (WEB_DEBUG); 
  if ($menu_item_id) {
    $dbh->do($sql ); 
  }
  my $msg ; 

  $msg = "DELETED  option " . $menu_items->{$menu_item_id}->{menu_item_option} ; 
  $msg .= ", titled '". $menu_items->{$menu_item_id}->{menu_item_title} . "'" ; 
  $msg .= " from ". $menu_items->{$menu_item_id}->{menu_id}  ; 
    
  if ($cgi->param('type') =~ /^delete_aa/) {
    print $cgi->redirect("admin.cgi?mod=" . $self->module() . "&func=menu_items&menu_id=" . $cgi->param('menu_id') . "&msg=$msg" );
    exit ;
  } else { 
    print $cgi->redirect("admin.cgi?mod=" . $self->module() . "&func=menu_items&menu_id=" . $cgi->param('menu_id') . "&msg=$msg"  );
    exit ;
  }
}



################################################
## sub edit_menu : 
##   template used : templates/menu_form.html
##   function :      Edits a Menu
#################################################

sub edit_menu {
  my $self = shift ;
     return unless (defined($self))  ;

  my $wu = $self->{WEBUSER};
  my $cgi = $wu->cgi ();
  my $dbh = $wu->dbh ();

  my $tmpl = new HTML::Template(filename => 'templates/menu_form.html'); 


  $tmpl->param('mod' =>  $self->module()  ) ;
  $tmpl->param('func' => 'save_menu' ) ;
  $tmpl->param('type' => 'edit' ) ;
  $tmpl->param('edit_form' => 1 ) ;
  ## set the stuff for the menu...

  my $menu_id = $cgi->param('menu_id'); 


  ## verify user's access, if not send the to NO ACCESS Zone
  my $perm = $wu->permissions(); 
  if (!$perm->is_web_authorized($menu_id, $wu->permission_id() ) )  { 
     return $self->no_access();
  }
  ## end verify permissions

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
    ##  $tmpl->param('param1' => $menu->{$menu_id}->{param1} ) ;
    ##  $tmpl->param('param2' => $menu->{$menu_id}->{param2} ) ;
    ##  $tmpl->param('param3' => $menu->{$menu_id}->{param3} ) ;
    ##  $tmpl->param('param4' => $menu->{$menu_id}->{param4} ) ;
    $tmpl->param('old_menu_type_code' => $menu->{$menu_id}->{menu_type_code} ) ;
    $menu_type_code = $menu->{$menu_id}->{menu_type_code}; 
  }  else {
    $tmpl->param('title' => $cgi->param('title') )  ;
    $tmpl->param('max_attempts' => $cgi->param('max_attempts') ); 
    $tmpl->param('collect_time' => $cgi->param('collect_time') ); 
    ##  $tmpl->param('param1' => $cgi->param('param1') ); 
    ##  $tmpl->param('param2' => $cgi->param('param2') ); 
    ##  $tmpl->param('param3' => $cgi->param('param3') ); 
    ##  $tmpl->param('param4' => $cgi->param('param4') ); 
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
## sub edit_aam : obsolete
##   template used : templates/menu_aam_form.html
##   function :      Edits a Dial By Name Menu
#################################################

# sub edit_aam {
#   my $self = shift ;
#       return unless (defined($self))  ;
#  
#    my $wu = $self->{WEBUSER};
#    my $cgi = $wu->cgi ();
#    my $dbh = $wu->dbh ();
#  
#    my $tmpl = new HTML::Template(filename => 'templates/menu_aam_form.html');
#  
#    $tmpl->param('mod' => $self->module()  ) ;
#    $tmpl->param('func' => 'save_menu' ) ;
#    $tmpl->param('type' => 'edit_aam' ) ;
#    $tmpl->param('edit_form' => 1 ) ;
  ## set the stuff for the menu...

#    my $menu_id = $cgi->param('menu_id');

  ## verify user's access, if not send the to NO ACCESS Zone
#    my $perm = $wu->permissions(); 
#    if (!$perm->is_web_authorized($menu_id, $wu->permission_id() ) )  { 
#       return $self->no_access();
#    }
  ## end verify permissions
#
#
#  ## set the error message if they screwed up .....
#    $tmpl->param(error_message => $self->{error_message} );
#    $tmpl->param('menu_id' => $menu_id ) ;
#
#    my $menu_type_code ;
#    my $param1 ;
#                                                                                                                             
#    if (!$self->{error_message} ) {
#    ## we get it from the db....
#      my $menu = OpenUMS::DbQuery::menu_data($dbh,$menu_id);
#      $tmpl->param('title' => $menu->{$menu_id}->{title} ) ;
#    #  $tmpl->param('menu_type_code' => $menu->{$menu_id}->{menu_type_code} ) ;
#      my $menu_type_code = $menu->{$menu_id}->{menu_type_code} ; 
#      $tmpl->param('menu_type_opts' => $self->get_menu_type_opts($menu_type_code ) );
#      $tmpl->param('max_attempts' => $menu->{$menu_id}->{max_attempts} ) ;
#      $param1 = $menu->{$menu_id}->{param1} ; ##### tmpl->param('param1' => $menu->{$menu_id}->{param1} ) ;
#      $menu_type_code = $menu->{$menu_id}->{menu_type_code};
#    }  else {
#      $tmpl->param('title' => $cgi->param('title') )  ;
#    #  $tmpl->param('menu_type_code' => $cgi->param('menu_type_code') ) ;
#      my $menu_type_code = $cgi->param('menu_type_code') ; 
#      $tmpl->param('menu_type_opts' => $self->get_menu_type_opts($menu_type_code ) );
#      $tmpl->param('max_attempts' => $cgi->param('max_attempts') ) ;
#      $param1 = $cgi->param('param1') ; ### $tmpl->param('param1' => $cgi->param('param1') );
#    }
#  ## should be, heh
#  #  $tmpl->param('menu_type_name' => 'Auto Attendant Menu' ) ;
#
#
##  ## set the error message if they screwed up .....
#    return $tmpl ; 
#
#
#
#  }

################################################
## sub edit_dbnm : 
##   template used : templates/menu_dbnm_form.html
##   function :      Edits a Dial By Name Menu
#################################################

sub edit_dbnm {
  my $self = shift ;
     return unless (defined($self))  ;
  ## standard objects...
  my $wu = $self->{WEBUSER};
  my $cgi = $wu->cgi ();
  my $dbh = $wu->dbh ();

  my $tmpl = new HTML::Template(filename => 'templates/menu_dbnm_form.html'); 

  $tmpl->param('mod' =>  $self->module()  ) ;
  $tmpl->param('func' => 'save_menu' ) ;
  $tmpl->param('type' => 'edit_dbnm' ) ;
  $tmpl->param('edit_form' => 1 ) ;

  my $menu_id = $cgi->param('menu_id'); 

  ## verify user's access, if not send the to NO ACCESS Zone
  my $perm = $wu->permissions(); 
  if (!$perm->is_web_authorized($menu_id, $wu->permission_id() ) )  { 
     return $self->no_access();
  }
  ## end verify permissions


  ## set the error message if they screwed up .....
  $tmpl->param(error_message => $self->{error_message} );
  $tmpl->param('menu_id' => $menu_id ) ;

  my $menu_type_code ;
  my $param1 ;
                                                                                                                             
  if (!$self->{error_message} ) {
    ## we get it from the db....
    my $menu = OpenUMS::DbQuery::menu_data($dbh,$menu_id);
    $tmpl->param('title' => $menu->{$menu_id}->{title} ) ;
    $tmpl->param('menu_type_code' => $menu->{$menu_id}->{menu_type_code} ) ;
    $tmpl->param('max_attempts' => $menu->{$menu_id}->{max_attempts} ) ;
    $param1 = $menu->{$menu_id}->{param1} ; ##### tmpl->param('param1' => $menu->{$menu_id}->{param1} ) ;
    $menu_type_code = $menu->{$menu_id}->{menu_type_code};
  }  else {
    $tmpl->param('title' => $cgi->param('title') )  ;
    $tmpl->param('menu_type_code' => $cgi->param('menu_type_code') ) ;
    $tmpl->param('max_attempts' => $cgi->param('max_attempts') ) ;
    $param1 = $cgi->param('param1') ; ### $tmpl->param('param1' => $cgi->param('param1') );
  }
  print STDERR "param1 = $param1\n" if (WEB_DEBUG);
  my $dbnm_types = OpenUMS::DbQuery::get_dbnm_types($dbh); 
  my @dbnm_opts; 
  foreach my $t ( @{$dbnm_types} ) { 
     my %h ; 
     $h{dbnm_type} = $t; 
     if ($param1 eq $t) {
        $h{SEL} = 1 ;
     } 
     push @dbnm_opts, \%h; 
  }   
  $tmpl->param('DBNM_OPTS' => \@dbnm_opts ) ;
 

  return $tmpl; 
}

################################################
## sub edit_xfer : 
##   template used : menu_xfer_form
##   function :   Edits a Transfer Menu
#################################################

sub edit_xfer {
  my $self = shift ;
     return unless (defined($self))  ;

  my $wu = $self->{WEBUSER};
  my $cgi = $wu->cgi ();
  my $dbh = $wu->dbh ();

  my $tmpl = new HTML::Template(filename => 'templates/menu_xfer_form.html'); 

  $tmpl->param('mod' =>   $self->module()  ) ;
  $tmpl->param('func' => 'save_menu' ) ;
  $tmpl->param('type' => 'edit_xfer' ) ;
  $tmpl->param('edit_form' => 1 ) ;
  ## set the stuff for the menu...

  my $menu_id = $cgi->param('menu_id'); 

  ## verify user's access, if not send the to NO ACCESS Zone
  my $perm = $wu->permissions(); 
  if (!$perm->is_web_authorized($menu_id, $wu->permission_id() ) )  { 
     return $self->no_access();
  }
  ## end verify permissions


  ## set the error message if they screwed up .....
  $tmpl->param(error_message => $self->{error_message} );
  $tmpl->param('menu_id' => $menu_id ) ;

  my $menu_type_code ; 
  my $param1 ; 

  if (!$self->{error_message} ) {
    ## we get it from the db....
    my $menu = OpenUMS::DbQuery::menu_data($dbh,$menu_id); 
    $tmpl->param('title' => $menu->{$menu_id}->{title} ) ;
    $tmpl->param('menu_type_code' => $menu->{$menu_id}->{menu_type_code} ) ;
    $param1 = $menu->{$menu_id}->{param1} ; ##### tmpl->param('param1' => $menu->{$menu_id}->{param1} ) ;
    $menu_type_code = $menu->{$menu_id}->{menu_type_code}; 
  }  else {
    $tmpl->param('title' => $cgi->param('title') )  ;
 
    $tmpl->param('menu_type_code' => $cgi->param('menu_type_code') ) ;
    $param1 = $cgi->param('param1') ; ### $tmpl->param('param1' => $cgi->param('param1') ); 
  }
  print STDERR "param1 = $param1\n" if (WEB_DEBUG); 

  ## this  stuff was moved into get_extension_name_dd
  # my $user_data = OpenUMS::DbQuery::all_users($dbh, 1); ## get all the active user's
  # my @ext_opts;
  #  foreach my $ext (sort keys %{$user_data} ) {
  #   my %opt1 ; 
  #    $opt1{extension} = $ext ; 
  #   $opt1{name} = $user_data->{$ext}->{first_name} . " " . $user_data->{$ext}->{last_name}  ; 
  #   if ($param1 eq $ext ) { 
  #     $opt1{SEL} = 1; 
  #   } 
  #   push @ext_opts, \%opt1 ; 
  #}   
  my $ext_opts = $self->get_extension_name_dd($param1); 
  $tmpl->param(EXT_OPTS => $ext_opts);  

  return $tmpl;  

}
####################################################33
## sub get_extension_name_dd : 
##   template used : menu_xfer_form
##   function :  Gets an array ref to fill the fields
##    of the drop down on the menu_xfer_form called 'EXT_OPTS'
####################
sub get_extension_name_dd {
  my $self =  shift;  
  my $param1 = shift ; 
  my $wu = $self->{WEBUSER};
  my $dbh = $wu->dbh ();
   

  ## this is for the extension/Name drop down...
  my $user_data = OpenUMS::DbQuery::all_users($dbh, 1); ## get all the active user's
  my @ext_opts;
  foreach my $ext (sort keys %{$user_data} ) {
     my %opt1 ;
     $opt1{extension} = $ext ;
     $opt1{name} = $user_data->{$ext}->{first_name} . " " . $user_data->{$ext}->{last_name}  ;
     if ($param1 eq $ext ) {
       $opt1{SEL} = 1;
     }
     push @ext_opts, \%opt1 ;
  }
  return \@ext_opts ; 

} 

################################################
## sub add_aam :
##   template used : Add form for adding an Auto Attendant Menu
##
##   function :   Deletes a menu item for the user
#################################################
                                                                                                                             
sub add_aam {
  my $self = shift ;
     return unless (defined($self))  ;
     
  my $wu = $self->{WEBUSER};
  my $cgi = $wu->cgi ();
  my $dbh = $wu->dbh ();

  my $tmpl = new HTML::Template(filename => 'templates/menu_form.html'); 

  $tmpl->param('mod' =>  $self->module()  ) ;
  $tmpl->param('func' => 'save_new_aam' ) ;
  $tmpl->param('type' => 'add_aam' ) ;
  $tmpl->param('add_form' => 1 ) ;
  $tmpl->param('error_message' => $self->{error_message} ) ;
  ## set the stuff for the menu...

  my $new_menu_id = OpenUMS::DbQuery::get_next_aam_id($dbh); 
  my $max_attempts = $cgi->param('max_attempts') ||  3  ; 
  my $collect_time = $cgi->param('collect_time') ||  ''  ; 
#  if (!$max_attempts) { 
#     $max_attempts = 3; 
#  } 
   

  print STDERR "def =  " . defined($cgi->param('max_attempts') )  . " $max_attempts  \n" if (WEB_DEBUG); 
  $tmpl->param('menu_id' => $new_menu_id ) ;
  $tmpl->param('max_attempts' => $max_attempts ) ;
  $tmpl->param('collect_time' => $collect_time ) ;
  $tmpl->param('menu_type_opts' => $self->get_menu_type_opts('AAG')) ; 
  $tmpl->param('title' => $cgi->param('title') ) ;
  #  $tmpl->param('param1' => $cgi->param('param1') ) ;
#  my $ext_opts = $self->get_extension_name_dd($cgi->param('param1')) ; 
#  $tmpl->param('EXT_OPTS', $ext_opts ); 
  return $tmpl; 
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
     $self->{error_message} = "Menu Title can not be blank.  ";
     return $self->add_aam();
  }
  if ($cgi->param('max_attempts') < 1  ) {
     $self->{error_message} = "Max Attempts must not be black and must be greated than 0 ";
     return $self->add_aam();
  }
  
  my $ext = $cgi->param('param1');
  my %data ;
  $data{menu_id} = $cgi->param('menu_id'); 
  $data{menu_type_code} = $cgi->param('menu_type_code'); 
  $data{max_attempts} = $cgi->param('max_attempts') ;
  if (defined($cgi->param('collect_time')) && $cgi->param('collect_time') =~ /^[0-9]+$/) { 
     $data{collect_time} = $cgi->param('collect_time') ;
  }  

  $data{title} = $cgi->param('title');
  $data{permission_id} = 'ANON' ;
  

  OpenUMS::DbUtils::generic_insert( $dbh, "menu", \%data);

  my $msg = "Added new Auto Attendant Menu, menu id : " . $data{menu_id}  ; 

  print $cgi->redirect("admin.cgi?mod=" . $self->module() . "&func=menu_items&menu_id=" . $data{menu_id} . "&msg=$msg");
  exit ;

}
################################################
## sub add_recmsg :
#################################################
sub add_recmsg {
  my $self = shift ;
     return unless (defined($self))  ;
  ## ok, so we're lazy ,...
  return $self->add_xfer('RECMSG');      

}


################################################
## sub add_xfer : 
#################################################

sub add_xfer {
  my $self = shift ;
     return unless (defined($self))  ;
  my $menu_type_code = shift || 'XFER';      


  my $wu = $self->{WEBUSER};
  my $cgi = $wu->cgi ();
  my $dbh = $wu->dbh ();

  my $tmpl = new HTML::Template(filename => 'templates/menu_xfer_form.html'); 

  $tmpl->param('mod' =>  $self->module()  ) ;
  $tmpl->param('func' => 'save_new_xfer' ) ;
  $tmpl->param('menu_type_code' => $menu_type_code ) ;

  $tmpl->param('add_form' => 1 ) ;
  $tmpl->param('error_message' => $self->{error_message} ) ;
  ## set the stuff for the menu...
  my $new_menu_id = OpenUMS::DbQuery::get_next_xfer_id($dbh); 
  $tmpl->param('menu_id' => $new_menu_id ) ;
  $tmpl->param('title' => $cgi->param('title') ) ;
  #  $tmpl->param('param1' => $cgi->param('param1') ) ;
  my $ext_opts = $self->get_extension_name_dd($cgi->param('param1')) ; 
  $tmpl->param('EXT_OPTS', $ext_opts ); 
  return $tmpl; 

}

################################################
## sub save_new_xfer : 
##   template used : none, redirects to main
##   function :  This is used to save new transfer
#################################################

sub save_new_xfer {
  ## this is used to save transfers  
  my $self = shift ;
     return unless (defined($self))  ;

  my $wu = $self->{WEBUSER};
  my $cgi = $wu->cgi ();
  my $dbh = $wu->dbh ();
  my $menu_type_code = $cgi->param('menu_type_code'); 

  if ($menu_type_code ne  'XFER' && $menu_type_code ne 'RECMSG') { 
     my $msg = "Not added "; 
     print $cgi->redirect("admin.cgi?mod=" . $self->module() . "&msg=$msg");
     exit ;
  } 

  print STDERR "called save_new_xfer : " . $cgi->param('menu_type_code') . " " . $cgi->param('menu_id') ."\n" if (WEB_DEBUG) ;
  if (!($cgi->param('title')) ) { 
     $self->{error_message} = "MENU OPTION CAN NOT BE BLANK  ";
     return $self->add_xfer($cgi->param('menu_type_code')); 
  }

  my $ext = $cgi->param('param1'); 
  print STDERR "called save_new_xfer ext =  $ext --" . OpenUMS::DbQuery::validate_mailbox($dbh,$ext)  . "-- \n"  if (WEB_DEBUG) ;

  if (!OpenUMS::DbQuery::validate_mailbox($dbh,$ext)  ) { 
     print STDERR "not valid mailbox\n"  if (WEB_DEBUG) ;
     $self->{error_message} = "$ext is not a valid mailbox";
     return $self->add_xfer($cgi->param('menu_type_code')); 
  } 

  my %data ;  
  $data{menu_id} = $cgi->param('menu_id'); 
  $data{menu_type_code} = $menu_type_code; 

  $data{max_attempts} = 5; 
  $data{title} = $cgi->param('title'); 
  $data{param1} = $ext; 
  $data{permission_id} = 'ANON' ;

  OpenUMS::DbUtils::generic_insert( $dbh, "menu", \%data);

  my $msg; ##  = "Added new transfer, menu id : " . $data{menu_id}  ; 
  if ($menu_type_code eq  'XFER' ) { 
     $msg  = "Added new transfer, menu id : " . $data{menu_id}  ; 
  } elsif  ($menu_type_code eq 'RECMSG') {
     $msg  = "Added new Voicemail Direct, menu id : " . $data{menu_id}  ; 
  } 
  print $cgi->redirect("admin.cgi?mod=" . $self->module() . "&msg=$msg");
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

  my @fields = qw(menu_id title menu_type_code max_attempts collect_time param1 param2 param3 param4) ; 
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
## sub edit_menu_item_aa : 
##   template used : menu_item_aa_form.html
##   function      : This is used add a new menu option for an Auto Attendand Menu
#################################################
sub edit_menu_item_aa {
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


  ## verify user's access, if not send the to NO ACCESS Zone
  my $perm = $wu->permissions(); 
  if (!$perm->is_web_authorized($menu_id, $wu->permission_id() ) )  { 
     return $self->no_access();
  }
  ## end verify permissions

  my $tmpl = new HTML::Template(filename => 'templates/menu_item_aa_form.html'); 
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
  if (!$self->{error_message} ) {
    my $menu_items = OpenUMS::DbQuery::get_menu_item($dbh,$menu_item_id )  ;
                                                                                                                             
    return if (!defined( $menu_items ) )  ;
                                                                                                                             
    $tmpl->param(menu_item_option => $menu_items->{$menu_item_id}->{menu_item_option} ) ;
    $tmpl->param(menu_item_title  => $menu_items->{$menu_item_id}->{menu_item_title} );
    $tmpl->param(menu_item_action  => $menu_items->{$menu_item_id}->{menu_item_action} ) ;
    $dest_menu_id = $menu_items->{$menu_item_id}->{dest_menu_id};
    $menu_item_action = $menu_items->{$menu_item_id}->{menu_item_action}; 
  }  else {
    $tmpl->param(menu_item_option => $cgi->param('menu_item_option') ) ;
    $tmpl->param(menu_item_title  => $cgi->param('menu_item_title') ) ;
    $tmpl->param(menu_item_action  => $cgi->param('menu_item_action') ) ;
    $dest_menu_id = $cgi->param('dest_menu_id');
    $menu_item_action = $cgi->param('menu_item_action')  ;
  }

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
## sub get_menu_opts
#################################
sub get_menu_opts {

  my $self = shift ;
  my $dest_menu_id = shift ; 
  my $allow_dbnmres = shift ; 

  my $wu = $self->{WEBUSER}; 
  my $dbh = $wu->dbh (); 
  ## now, get a list of all the menus,  their titles and menu_ids
  my $menus = OpenUMS::DbQuery::menu_data($dbh,undef,"menu_id","title","menu_type_code","permission_id","param1");
  my @menu_opts;
  ## loop thru the list and  populate the drop down
  print STDERR "cgi dest_id   = = $dest_menu_id  \n" if (WEB_DEBUG);
  foreach my $menu_id (sort keys %{$menus} ) {
     my %data;
     if ($menus->{$menu_id}->{permission_id} =~ /^ANON/) { 
       if ($menus->{$menu_id}->{menu_type_code} =~ /^AAG|^XFER|^LOGIN|^DBNM|^UINFO|^RECMSG|^EXIT/ ) {
         unless ($menus->{$menu_id}->{menu_type_code} =~/^RECMSG/  && !($menus->{$menu_id}->{param1}) ) {  
           $data{menu_id} = $menu_id;
           $data{title} = $menus->{$menu_id}->{title};
           if ($dest_menu_id  eq $menu_id ) {
             $data{sel} = 1;
            }
            push @menu_opts, \%data;
         }  else {
               print STDERR "menu_id = $menu_id menu_type_code =  " . $menus->{$menu_id}->{menu_type_code} . " " if (WEB_DEBUG); 
               print STDERR " $menus->{$menu_id}->{param1} \n" if (WEB_DEBUG);
         } 
       } 
       if ($allow_dbnmres && $menus->{$menu_id}->{menu_type_code} =~ /^DBNMRES/) {
         $data{menu_id} = $menu_id;
         $data{title} = $menus->{$menu_id}->{title};
         if ($dest_menu_id  eq $menu_id ) {
           $data{sel} = 1;
          }
          push @menu_opts, \%data;
       }
     }
  }
  return \@menu_opts; 

}

################################################
## sub add_menu_item_aa : 
##   template used : menu_item_aa_form.html
##   function      : This is used add a new menu option for an Auto Attendand Menu
#################################################

sub add_menu_item_aa {
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

  my $tmpl = new HTML::Template(filename => 'templates/menu_item_aa_form.html'); 
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
  $tmpl->param(menu_item_option => $cgi->param('menu_item_option') ) ;
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
    if ($mtype =~ /^AAG|^UINFO/) { 
      $row_hash{menu_type_code} = $mtype;
      $row_hash{menu_type_code_descr} = $menu_types->{$mtype}->{menu_type_code_descr} ;
      if ($cur_menu_type_code eq $mtype ) {
        $row_hash{sel} =  1;
      }
      push @rows, \%row_hash;
    }
  }
  return \@rows ;
}

#################################
## sub module
#################################
sub module {
  return "Menu"; 
}
#################################
## sub no_access
#################################
sub no_access {
  my $self = shift ; 
  
  my $tmpl = new HTML::Template(filename => 'templates/no_access.html'); 
  return $tmpl; 

} 

#################################
## sub get_menu_sounds
#################################
sub get_menu_sounds {
  my $self = shift ;
  my $menu_id = shift ;
  my $wu = $self->{WEBUSER}; 
  my $dbh = $wu->dbh (); 
  my $sth = $self->{STH}; 
  if (!defined($sth) ) { 
#     $sth->execute();
#     my $sound = $sth->fetchrow();
    my $sql =  " SELECT menu_sound_id,sound_file FROM menu_sounds WHERE menu_id = ? AND sound_type ='M' "; 
    print STDERR "Prepared $sql"  if (WEB_DEBUG) ; 
    $sth = $dbh->prepare($sql);
    $self->{STH} = $sth; 
  } 
  $sth->execute($menu_id);
  my @menu_sounds  ; 
  while (my ($menu_sound_id, $sound_file) = $sth->fetchrow_array()) {
    my %hash ;
    $hash{menu_sound_id} = $menu_sound_id;  
    $hash{sound_file} = $sound_file;  
    push @menu_sounds, \%hash; 
  }  
  
  return (\@menu_sounds) ; 
} 
sub edit_max_attempts {
  my $self = shift ;
  return unless (defined($self))  ;
  my $wu = $self->{WEBUSER};
  my $session = $wu->cgi_session();
  my $cgi = $wu->cgi ();
  my $dbh = $wu->dbh ();
 
                                                                                                                                               
  my $menu_id = $cgi->param('menu_id');
  my $tmpl = new HTML::Template(filename => 'templates/menu_edit_max_attempts.html');
  my $menu = OpenUMS::DbQuery::menu_data($dbh,$menu_id);
                                                                                                                                               
  $tmpl->param('mod' =>  $self->module()  ) ;
  $tmpl->param('func' => 'save_max_attempts' ) ;
  $tmpl->param('menu_id' => $menu_id ) ;
  $tmpl->param('title' => $menu->{$menu_id}->{title} ) ;
  if ($cgi->param('max_attempts') ) { 
    $tmpl->param('max_attempts' => $cgi->param('max_attempts') ) ; 
  } else {
    $tmpl->param('max_attempts' => $menu->{$menu_id}->{max_attempts} ) ;
  } 
  return $tmpl ; 

}
sub save_max_attempts { 
  my $self = shift ;
     return unless (defined($self))  ;
                                                                                                                                               
  my $wu = $self->{WEBUSER};
  my $cgi = $wu->cgi ();
  my $dbh = $wu->dbh ();
  my $menu_id = $cgi->param('menu_id'); 
  my $max_attempts = $cgi->param('max_attempts'); 
  my $msg ; 
  if ($max_attempts > 0 && $max_attempts < 10 && $menu_id ) { 
    my $sql = qq(UPDATE menu SET max_attempts =   $max_attempts  WHERE menu_id = $menu_id ); 
    $dbh->do($sql); 
    $msg = "Repeat set to $max_attempts for menu $menu_id."; 
  } else {
    $msg = "Repeat was not set for $menu_id, there was problem with your input."; 
  }  
  print $cgi->redirect( "admin.cgi?mod=" . $self->module() . "&msg=$msg" );
  exit ;


}

sub menu_items {
  my $self = shift ; 
  return unless (defined($self))  ; 
  my $menu_id = 503; 

  my $wu = $self->{WEBUSER}; 
  my $session = $wu->cgi_session(); 
  my $cgi = $wu->cgi (); 
  my $dbh = $wu->dbh (); 

  if ($cgi->param('menu_id') ) { 
      $menu_id = $cgi->param('menu_id') ; 
  } 


  my $perm = $wu->permissions(); 
  if (!$perm->is_web_authorized($menu_id, $wu->permission_id() ) )  {
     return $self->no_access();
  }


  my $menu = OpenUMS::DbQuery::menu_data($dbh, $menu_id); 
  my $tmpl_file = "sm_items.html"; 
  my $tmpl; 
  $tmpl = new HTML::Template(filename =>  'templates/' . $tmpl_file);  
  $tmpl->param(MSG => $cgi->param('msg') );
  $tmpl->param(MOD => $self->module() );
  $tmpl->param(SRC => "menu_items" ) ; 

  print STDERR "MENU_ID = $menu_id\n" if (WEB_DEBUG); 

  $tmpl->param(MENU_ID => $menu_id );
  print STDERR "TITLE = $menu->{$menu_id}->{title} \n" if (WEB_DEBUG); 

  $tmpl->param(TITLE => $menu->{$menu_id}->{title} );
  $tmpl->param(MENU_TYPE_CODE => $menu->{$menu_id}->{menu_type_code} );
  $tmpl->param(PARAM1 => $menu->{$menu_id}->{param1} );
  $tmpl->param(PARAM2 => $menu->{$menu_id}->{param2} );
  $tmpl->param(PARAM3 => $menu->{$menu_id}->{param3} );

#   my ($menu_sound_id,$sound_file) = $self->get_menu_sound($id);

  my @others  ; 
   
  my $sql = qq{SELECT menu_item_id , menu_item_option , dest_menu_id, 
       menu_item_action, menu_item_title, m2.title dest_title 
     FROM menu_items mi, menu m2
     WHERE mi.menu_id = ?  and mi.dest_menu_id = m2.menu_id };

  my $sth = $dbh->prepare($sql) ;
  $sth->execute($menu_id);
  my $menuOptions;
  use CGI::Enurl; 

  while (my ($menu_item_id , $menu_item_option , $dest_menu_id,
             $menu_item_action,$menu_item_title, $dest_title) 
               = $sth->fetchrow_array() ) {
     $menuOptions->{$menu_item_option}->{menu_item_id} = $menu_item_id ;
     $menuOptions->{$menu_item_option}->{dest_id} = $dest_menu_id ;
     $menuOptions->{$menu_item_option}->{dest_title} = $dest_title ;
     $menuOptions->{$menu_item_option}->{menu_item_action} = $menu_item_action ;
     $menuOptions->{$menu_item_option}->{title} = $menu_item_title ;
     print STDERR "menu_item_option=$menu_item_option $menu_item_title $dest_menu_id  $dest_title\n" if (WEB_DEBUG); 
      
  }
     print STDERR "\n\n" if (WEB_DEBUG); 
  my @local_opts   = keys %{$menuOptions} ; 
  my @tmpl_opts ; 
  my $count = 1; 
  foreach my $opt (@STD_OPTS ) {
     my  %data ; 

     $data{opt} = $opt; 
     $data{opt_enc} = enurl($opt); 
     $data{menu_id} = $menu_id; 
     $data{menu_item_id} = $menuOptions->{$opt}->{menu_item_id} ; 
     $data{menu_item_title} = $menuOptions->{$opt}->{title} ; 
     $data{menu_dest_id} = $menuOptions->{$opt}->{dest_id} ; 
     $data{menu_dest_title} = $menuOptions->{$opt}->{dest_title} ; 
     $data{menu_item_action} = $menuOptions->{$opt}->{menu_item_action} ; 
     $data{MOD}  = $self->module();

     if (!$data{menu_item_title} ) { 
        print STDERR " $opt " . $menuOptions->{$opt}->{title} . "\n" if (WEB_DEBUG); 
        my @arr =();
        if ($opt eq '*') {
            #ok, the star really screws us..
          @arr = grep { /^\*/ } @local_opts; 
        } else {
          @arr = grep { /^$opt/ } @local_opts; 
        }
        if (scalar(@arr) ) { 
           print STDERR "after grep " . scalar(@arr) . " \n" if (WEB_DEBUG); 
           $data{menu_item_id} = $menuOptions->{$arr[0]}->{menu_item_id} ; 
           $data{menu_item_title} = $menuOptions->{$arr[0]}->{title} ; 
           $data{menu_dest_id} = $menuOptions->{$arr[0]}->{dest_id} ; 
           if (length($arr[0]) > 1 ) {
              my $input = substr($arr[0],1); 
              $data{input} = $input; 
           } 
           delete ${%{$menuOptions}}{$arr[0]};
        }  
     } 
     push @tmpl_opts, \%data; 
     $data{odd_row} = $count%2; 
     
     $count++; 
     delete ${%{$menuOptions}}{$opt}; 
  }
  ## if there are any other options that do not appear....
  foreach my $opt (keys %{$menuOptions} ) {
     my  %data ;
     print STDERR "optleft $opt \n"  if (WEB_DEBUG) ; 
     $data{opt} = $opt;
     $data{menu_id} = $menu_id;
     $data{menu_item_id} = $menuOptions->{$opt}->{menu_item_id} ;
     $data{menu_item_title} = $menuOptions->{$opt}->{title} ;
     $data{menu_dest_id} = $menuOptions->{$opt}->{dest_id} ;
     $data{menu_dest_title} = $menuOptions->{$opt}->{dest_title} ;
     $data{menu_item_action} = $menuOptions->{$opt}->{menu_item_action} ;
     $data{MOD}  = $self->module();

     push @tmpl_opts, \%data; 
     $data{odd_row} = $count%2; 
     $count++; 

     
  } 
  

  $tmpl->param(MAIN_OPTS => \@tmpl_opts); 

  return $tmpl ; 

  ## it's it's not a transfer menu, we'll print out all the menu items...
  if ($menu->{$menu_id}->{menu_type_code} !~ /^XFER/) { 
     my $menu_items = $menu->{$menu_id}->{menu_items} ; 
     print STDERR "MENU_ID = $menu_id\n" if (WEB_DEBUG); 
  
     my @menu_items_data ; 
     
     my @sorted_id = sort {
            $menu_items->{$a}->{menu_item_option} <=>
            $menu_items->{$b}->{menu_item_option}
          } keys %{$menu_items} ;

     my $count =1 ;  
     if (scalar(@sorted_id) )  {  
       foreach my $menu_item_id (@sorted_id  ) {
         print STDERR "MENU_ITEM_ID = $menu_item_id\n" if (WEB_DEBUG); 
         my %row ; 
         $row{odd_row} = $count%2; 
         $row{menu_id} = $menu_id ; 
         $row{menu_item_id} = $menu_item_id ; 
         $row{dest_menu_id} = $menu_items->{$menu_item_id}->{dest_menu_id} ; 
         $row{menu_item_option} = $menu_items->{$menu_item_id}->{menu_item_option} ; 
         $row{menu_item_title} = $menu_items->{$menu_item_id}->{menu_item_title} ; 
         $row{menu_item_action} = $menu_items->{$menu_item_id}->{menu_item_action} ; 
         push @menu_items_data, \%row ; 
         $count++ ;
       } 
       $tmpl->param(MENU_ITEM_DATA => \@menu_items_data );
     }
  }
  return $tmpl ; 
}

################################################
## sub save_menu_item: 
##   template used : none (redirects to edit_menu_item on failure and to main on success...
##       
##   function :  Validates and if valid, saves new or edited menu item
#################################################

#sub save_menu_item  {
#  my $self = shift ;
#     return unless (defined($self))  ;
#
#  my $wu = $self->{WEBUSER};
#  my $cgi = $wu->cgi ();
#  my $dbh = $wu->dbh ();
#
#  print STDERR "called save_menu_item type : " . $cgi->param('type') . " " . $cgi->param('menu_item_id') ."\n"  if (WEB_DEBUG); 
#
#  my $sub_on_error ; 
#  if ($cgi->param('type') =~ /^add_aa/ ) {
#     $sub_on_error = sub { return $self->add_menu_item() }  ; 
#  } elsif ($cgi->param('type') =~ /^add/ ) {
#     $sub_on_error = sub { return $self->add_menu_item() }  ; 
#  }  elsif ($cgi->param('type') =~ /^edit_aa/)  { 
#     $sub_on_error = sub { return $self->edit_menu_item() }  ; 
#  }  elsif ($cgi->param('type') =~ /^edit/)  { 
#     $sub_on_error = sub { return $self->edit_menu_item() }  ; 
#  } 
#                                                                                                                             
#
#  if (length($cgi->param('menu_item_option') ) == 0 ) { 
#     $self->{error_message} = "MENU OPTION CAN NOT BE BLANK  "; 
#     return $sub_on_error->();  
#  } 
#
#  if (length($cgi->param('menu_item_title') ) == 0 ) { 
#     $self->{error_message} = "MENU OPTION TITLE CAN NOT BE BLANK, ANY NAME WILL DO"; 
#     return $sub_on_error->();  
#  } 
#
##  if ($cgi->param('type') =~ /add/) { 
#    if (OpenUMS::DbQuery::is_menu_item_option($dbh, $cgi->param('menu_id'), $cgi->param('menu_item_option') ) )  {
#       $self->{error_message} = "THERE IS ALREADY AN OPTION IN THIS MENU FOR '" . $cgi->param('menu_item_option') . 
#           "'"; 
#       return $sub_on_error->();  
#    }  
#  }  elsif ($cgi->param('type') =~ /edit/) {
#    if (OpenUMS::DbQuery::is_menu_item_option($dbh, $cgi->param('menu_id'), $cgi->param('menu_item_option'),$cgi->param('menu_item_id' ) ))   {
#       $self->{error_message} = "THERE IS ALREADY AN OPTION IN THIS MENU FOR '" . $cgi->param('menu_item_option') .
#           "'";
#       return $sub_on_error->();
#    }
#  } 
#
#  
#
#
#  if ($cgi->param('type') =~ /^add/) {
#    my @fields = qw(menu_id menu_item_option dest_menu_id  menu_item_action menu_item_title) ; 
#    my %data;
#    foreach my $f (@fields) {
#      $data{$f} = $cgi->param($f); 
#    } 
#    OpenUMS::DbUtils::generic_insert( $dbh, "menu_items", \%data);
#  } elsif ($cgi->param('type') =~ /^edit/) { 
#    my @fields = qw(menu_item_option dest_menu_id  menu_item_action menu_item_id menu_item_title) ; 
#    my %data;
#    foreach my $f (@fields) {
#      $data{$f} = $cgi->param($f); 
#    } 
#    print STDERR "It's edit....\n" if (WEB_DEBUG); 
#    OpenUMS::DbUtils::generic_update($dbh, "menu_items", \%data, "menu_item_id");
#  } 
#
#  if ($cgi->param('type') =~ /^add_aa|^edit_aa/) {
#     my $msg   ;
#     if ($cgi->param('type') =~ /^add_aa/){ 
#       $msg = "Added Option " . $cgi->param('menu_item_option') ;
#       $msg .= " entitled '" . $cgi->param('menu_item_title') . "'"; 
#       $msg .= " to " . $cgi->param('menu_id') . '.'; 
#     } elsif ($cgi->param('type') =~ /^edit_aa/)  {
#       $msg = "Saved Changes to Option " . $cgi->param('menu_item_option') ;
#       $msg .= " entitled '" . $cgi->param('menu_item_title') . "'"; 
#       $msg .= " of  " . $cgi->param('menu_id') . '.'; 
#      
#     } 
#     print $cgi->redirect("admin.cgi?mod=" . $self->module() . "&func=menu_items&menu_id=" . $cgi->param('menu_id') . "&msg=$msg" ); 
#     exit ; 
#  } else {
#     print $cgi->redirect("admin.cgi?mod=" . $self->module() . "&func=menu_items&menu_id=" . $cgi->param('menu_id') ); 
#     exit ; 
#  } 
#  return $self->menu_items() ; 
#}

1; 
