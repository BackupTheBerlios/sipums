package OpenUMS::WWW::UserAdmin;
### $Id: UserAdmin.pm,v 1.1 2004/07/20 03:14:53 richardz Exp $
#
# WWW/UserAdmin.pm
#
# User adminstration web interface
#
# Copyright (C) 2003 Integrated Comtel Inc.
use strict; 

use lib '/usr/local/openums/lib'; 
## always use the web tools
use OpenUMS::WWW::WebTools; 

use HTML::Template; 
use OpenUMS::DbQuery; 
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
  my $cgi = $wu->cgi (); 
  my $dbh = $wu->dbh (); 

  print STDERR " Got the session: id=" . $session->id() . "ext=" . $session->param('extension') . "\n" if (WEB_DEBUG); 
#  my $session_id = $session->session_id() ; 
  my $active = 1 ; 
  if ($cgi->param('all') ) { 
    $active = 0 ; 
  } 

  my $tmpl = new HTML::Template(filename =>  'templates/ua_main.html');  
  $tmpl->param(mod => $self->module() ); 
  $tmpl->param(all => !($active)); 
  $tmpl->param(msg => $cgi->param('msg') ); 
  my $sortby = $cgi->param('sb1'); 
  my $sortby2 = $cgi->param('sb2'); 
  print STDERR " sortby = $sortby , sortby2 = $sortby2 \n" if (WEB_DEBUG); 
  #  tmpl->param(msg => $cgi->param('msg') ); 
  my $users =  OpenUMS::DbQuery::all_users($dbh,$active,$sortby,$sortby2); 
  my @user_data ; 
  my $count = 1; 
  
  my @sorted_keys ; 
  if ($sortby ) { 
    if ($sortby2) { 
       @sorted_keys = reverse sort {
            $users->{$a}->{$sortby} cmp
            $users->{$b}->{$sortby}
          } keys %{$users} ;

     } else { 
       @sorted_keys = sort {
            $users->{$a}->{$sortby} cmp
            $users->{$b}->{$sortby}
          } keys %{$users} ;
       $tmpl->param($sortby."_sb" => 1); 
     } 
  } else {
     @sorted_keys = sort keys %{$users}; 
     $tmpl->param('extension_sb' => 1); 
  } 

  
  foreach my $ext (@sorted_keys) {
    my $row ;
    my $user_hr = $users->{$ext} ; 
    $row->{extension} = $user_hr->{extension} ; 
    $row->{full_name} =  $user_hr->{last_name} . 
                 ", " . $user_hr->{first_name} . 
                 " " . $user_hr->{mi} ; 
    $row->{email_address} =  $user_hr->{email_address}  ; 
    $row->{email_user_name} =  $user_hr->{email_user_name}  ; 
    $row->{transfer} =  $user_hr->{transfer}  ; 
    $row->{active} =  $user_hr->{active}  ; 
    $row->{store_flag} =  $user_hr->{store_flag}  ; 
    $row->{new_user_flag} =  $user_hr->{new_user_flag}  ; 
    $row->{permission_id} =  $user_hr->{permission_id}  ; 
    print STDERR "Permissino is $user_hr->{permission_id}\n" if (WEB_DEBUG) ; 
    $row->{mwi_flag} =  $user_hr->{mwi_flag}  ; 
    $row->{auto_login_flag} =  $user_hr->{auto_login_flag}  ; 
    $row->{auto_new_messages_flag} =  $user_hr->{auto_new_messages_flag}  ; 
    print STDERR "auto_login_flag $user_hr->{auto_login_flag}  \n" ; 
    if ($row->{store_flag} eq 'V' ) { 
      $row->{vstore_email} =  $user_hr->{vstore_email}  ; 
    } elsif ($row->{store_flag} eq 'E' ) {
      $row->{email_delivery} =  $user_hr->{email_delivery}  ; 
    } 
    
    $row->{odd_row} =  ($count % 2 )  ; 
        
     push @user_data, $row;
     $count++; 
  } 
  $tmpl->param(USER_DATA => \@user_data); 

#  $tmpl->param('ext',"assmunch " ) ; 
  return $tmpl ;  
} 
sub delete_user_conf {
  my $self = shift ;
     return unless (defined($self))  ;
  
  my $wu = $self->{WEBUSER}; 
  my $cgi = $wu->cgi (); 
  my $tmpl = new HTML::Template(filename =>  'templates/ua_delete_conf.html');
  $tmpl->param('extension' => $cgi->param('ext') ) ; 
  $tmpl->param('mod' => $self->module() ) ; 
  $tmpl->param('func' => 'delete_user' ) ; 
  return $tmpl ; 
}

#################################
## sub delete_user
#################################
sub delete_user {
  my $self = shift ;
     return unless (defined($self))  ;
  my $wu = $self->{WEBUSER}; 
  my $cgi = $wu->cgi (); 
  my $dbh = $wu->dbh (); 

  my $extension = $cgi->param('extension'); 
  my $msg ;  
  if ($extension) { 
    if ($cgi->param('delete_opt') eq 'I') {  
       
       OpenUMS::DbUtils::set_user_inactive($dbh,$extension); 
      $msg = "User at extension $extension set to inactive, to reactivate select 'edit user'"; 
    } elsif ($cgi->param('delete_opt') eq 'D') {
       print STDERR "GOnna delete User!\n" if (WEB_DEBUG); 
       OpenUMS::DbUtils::delete_user($dbh,$extension,1); 
      $msg = "User at extension $extension has been completely removed from the system"; 
      
    } 
 } 
  print $cgi->redirect("admin.cgi?mod=" . $self->module() . "&msg=" . $msg); 
  exit ;
} 


#################################
## sub edit_user
#################################
sub edit_user {
  my $self = shift ; 
     return unless (defined($self))  ;
  my $wu = $self->{WEBUSER}; 
  my $cgi = $wu->cgi (); 
  my $dbh = $wu->dbh (); 

  my $extension = $cgi->param('ext'); 
  my $tmpl = new HTML::Template(filename =>  'templates/ua_form.html');

  $tmpl->param( 'extension'=>$extension ); 
  $tmpl->param('mod' => $self->module() ) ; 
  $tmpl->param('func' => 'save_user' ) ; 
  $tmpl->param('type' => 'edit' ) ; 
  $tmpl->param('edit_form' => 1 ) ; 
  my $u ; ## = OpenUMS::DbQuery::get_user_info($dbh,$extension); 
  if ($self->{error_message} ) {
     print STDERR "getting user info from CGI\n" if (WEB_DEBUG) ; 
     $u = $cgi->Vars(); 
  } else { 
      print STDERR "getting user info from DB\n" if (WEB_DEBUG) ; 
      $u = OpenUMS::DbQuery::get_user_info($dbh,$extension); 
  }

  if ($extension ) { 
    my @fields = qw(first_name last_name mi transfer email_address 
            email_server_address email_user_name email_password mobile_email 
            new_user_flag active mobile_email_flag mwi_flag auto_login_flag auto_new_messages_flag email_delivery vstore_email ); 
    foreach my $f (@fields) { 
      $tmpl->param( $f => $u->{$f} ); 
    }
    my $tmpl_var = 'email_delivery_' . $u->{email_delivery}; 
    $tmpl->param($tmpl_var => 1 ); 
    print STDERR "setting $tmpl_var to 1\n" if (WEB_DEBUG) ; 

    $tmpl_var = 'vstore_email_' . $u->{vstore_email}; 
    print STDERR "--setting $tmpl_var to 1\n" if (WEB_DEBUG) ; 
    $tmpl->param($tmpl_var => 1 ); 
    
    print STDERR "--store_flag = $u->{store_flag} \n" if (WEB_DEBUG); 
    if ($u->{store_flag} eq 'V') {
      $tmpl->param( 'vm_store' => 1 ); 
    } elsif ($u->{store_flag} eq 'E') {
      $tmpl->param( 'email_store' => 1 ); 
    } 
  } 

  return $tmpl ; 
} 


#################################
## sub add_user
#################################
sub add_user()  {

  my $self = shift ;
     return unless (defined($self))  ;

  my $wu = $self->{WEBUSER};
  my $cgi = $wu->cgi ();
  my $dbh = $wu->dbh ();

  my $tmpl = new HTML::Template(filename =>  'templates/ua_form.html');
  $tmpl->param('mod' => $self->module() ) ;
  $tmpl->param('func' => 'save_user' ) ;
  $tmpl->param('type' => 'add' ) ;
  $tmpl->param('add_form' => 1 ) ;
  $tmpl->param('email_server_address' => DEFAULT_EMAIL_SERVER ) ;
  $tmpl->param('email_password' => DEFAULT_EMAIL_PASSWORD ) ;
  $tmpl->param('error_message' => $self->{error_message} ) ;
  if ($self->{error_message} ) {
     print STDERR "error_message gonna set fields....\n" if (WEB_DEBUG); 
     my @fields = qw(extension first_name last_name mi transfer email_address
            email_server_address email_user_name email_password mobile_email
            new_user_flag active mobile_email_flag mwi_flag email_delivery);
    foreach my $f (@fields) {
     print STDERR "set $f...." .  $cgi->param($f)  . "\n" if (WEB_DEBUG); 
      $tmpl->param( $f => $cgi->param($f) );
    }
    if ($cgi->param('store_flag') eq 'V') {
      $tmpl->param( 'vm_store' => 1 );
    } elsif ($cgi->param('store_flag') eq 'E') {
      $tmpl->param( 'email_store' => 1 );
    }
    my $email_delivery = 'email_delivery_' . $cgi->param('email_delivery');
    $tmpl->param($email_delivery => 1 ); 
  } else {
     ## set the defaults...
     $tmpl->param('active' => 1); 
     $tmpl->param('transfer' => 1); 
     $tmpl->param('new_user_flag' => 1); 
     $tmpl->param( 'vm_store' => 1 );
     my $email_delivery = 'email_delivery_I'; 
     $tmpl->param($email_delivery => 1 ); 
  } 

  # my @perms  = ('USER', 'ADMIN'); 
  # my @permission_ids; 
  # foreach my $perm_id (@perms ) {
  #   my %data ; 
  #   $data{permission_id} = $perm_id ; 
  #   push @permission_ids, \%data ; 
  # }
  # $tmpl->param('permission_ids', \@permission_ids); 


  return $tmpl ; 

}

#################################
## sub save_user
#################################
sub save_user { 
  my $self = shift ;
     return unless (defined($self))  ;

  my $wu = $self->{WEBUSER};
  my $cgi = $wu->cgi ();
  my $dbh = $wu->dbh ();
  my @fields = qw(extension first_name last_name mi transfer email_address 
          email_server_address email_user_name email_password mobile_email 
          active new_user_flag store_flag mobile_email_flag mwi_flag auto_login_flag auto_new_messages_flag email_delivery vstore_email); 

  my $sub_on_error ;
  if ($cgi->param('type') =~ /^edit/ ) {
     $sub_on_error = sub { return $self->edit_user() }  ;
  } elsif ($cgi->param('type') =~ /^add/ ) {
     $sub_on_error = sub { return $self->add_user() }  ;
  }
  my %data;
  foreach my $f ( @fields ) {
    $data{$f} = $cgi->param($f); 
  } 

  print STDERR "store_flag = $data{store_flag} \n" if (WEB_DEBUG); 

  my ($success,$msg) ; 
  ## business rules here...
  if ($data{email_address} ) {
        use Email::Valid;
        ## validate e-mail
        if (!Email::Valid->address($data{email_address}) ) {
          $self->{error_message} = "That is not a valid e-mail address.";
          return $sub_on_error->()  ;
     }
  }
  ## the business rules
  if ($data{store_flag} eq 'E') {
     if ($data{email_address}) {
        ## validate e-mail server
        if (!$data{email_server_address}) {
          $self->{error_message} = "Email Server address is blank. If you do not know this, ask your systems administrator.";
          return $sub_on_error->() ;
        }
                                                                                                                                               
        ## validate e-mail user
        if (!$data{email_user_name}) {
          $self->{error_message} = "Email User Name is blank.";
          return $sub_on_error->() ; 
        }
     } else {
       $self->{error_message} = "Email Address is required for E-mail Store.";
       return $sub_on_error->() ; 
     } 
  } 



  if ($cgi->param('type') eq 'edit') {
    OpenUMS::DbUtils::generic_update($dbh, "VM_Users", \%data,"extension" ); 

    ## we need to update the phone keys too..
    OpenUMS::DbUtils::update_phone_keys($dbh, $data{extension}) ; 
    $success = 1 ; 
  } elsif ($cgi->param('type') eq 'add') {


    ($success, $msg) = OpenUMS::Common::create_user($dbh, \%data ); 

    ## we need to update the phone keys too..
    OpenUMS::DbUtils::update_phone_keys($dbh, $data{extension}) ; 
    print STDERR "I added = $success \n" if (WEB_DEBUG); 
  } 
  ## send them back to the main...
  
  if ($cgi->param('type') eq 'edit') {
     $msg = "Changes saved for extension " . $data{extension}; 
  } else {
    if ($success) { 
       $msg = "SUCCESS: $msg "; 
    } else {
       $msg = "FAILURE: $msg "; 
    } 
  } 
  
  print STDERR "$msg ... Redirecting....\n" if (WEB_DEBUG); 
  if ($success) { 
    print $cgi->redirect("admin.cgi?mod=" . $self->module() . "&msg=$msg");  
    exit ; 
  } else {
    $self->{error_message} = $msg ; 
    return $sub_on_error->(); 
  }
}

#################################
## sub password
#################################
sub password {
  my $self = shift ;
     return unless (defined($self))  ;

  my $wu = $self->{WEBUSER};
  my $cgi = $wu->cgi ();
  my $dbh = $wu->dbh ();
  my $ext = $cgi->param('ext');
  
  my $u = OpenUMS::DbQuery::get_user_info($dbh,$ext ); 

  my $tmpl = new HTML::Template(filename =>  'templates/ua_password.html');
  $tmpl->param('error_message' => $self->{error_message} ); 
  $tmpl->param('mod' => $self->module() ); 
  $tmpl->param('func' => 'save_password'); 
  $tmpl->param('ext' => $ext); 
  $tmpl->param('full_name' =>  $u->{last_name} .  
           ", " . $u->{first_name} .  
           " "  . $u->{mi} ) ; 
  return $tmpl ; 
}

#################################
## sub save_password
#################################
sub save_password {
  my $self = shift ;
     return unless (defined($self))  ;
  my $wu = $self->{WEBUSER};
  my $cgi = $wu->cgi ();
  my $dbh = $wu->dbh ();
  my $extension = $cgi->param('ext');
  my $p = $cgi->param('password');
  my $pc = $cgi->param('password_confirm');
  ## check that neither are blank
  if (!($pc) && !($p)) {
     $self->{error_message} = "Passwords can not be blank."; 
     return $self->password(); 
  } 

  ## check that passwords match
  if ($pc ne $p) {
     $self->{error_message} = "Passwords do not match."; 
     return $self->password(); 
  } 
  ## they match so we only deal with $p
  ##  check that it's a number
  if ($p !~ /[0-9]/ ) {
     $self->{error_message} = "Password must be a number."; 
     return $self->password(); 
  } 
  if (length($p) > 4 || length($p) < 2) { 
     $self->{error_message} = "Password can not be longer than 4 or less the 2 digits in length."; 
     return $self->password(); 
  }

  ## block out the 9's
  if ($p =~ /999/ )  { 
     $self->{error_message} = "Sorry, we do not want passwords to have '999' in them."; 
     return $self->password(); 
  }

  OpenUMS::DbUtils::change_password($dbh, $extension, $p )  ; 
  
  my $msg =  "Password changed for extension $extension" ; 
  print STDERR "$msg ... Redirecting....\n" if (WEB_DEBUG); 
  print $cgi->redirect("admin.cgi?mod=" . $self->module() . "&msg=$msg");  
  
  exit ;
  return 0; 

}


#################################
## sub edit_permission
#################################
sub edit_permission {
  my $self = shift ;
     return unless (defined($self))  ;
  my $wu = $self->{WEBUSER};
  my $session = $wu->cgi_session();
  my $cgi = $wu->cgi ();
  my $dbh = $wu->dbh ();
  my $ext = $cgi->param('ext');
  my $u = OpenUMS::DbQuery::get_user_info($dbh,$ext ); 
  my $tmpl = new HTML::Template(filename =>  'templates/ua_permission.html');
  my $perm = new OpenUMS::Permissions($dbh);

  $tmpl->param('error_message' => $self->{error_message} ); 
  $tmpl->param('mod' => $self->module()); 
  $tmpl->param('func' => 'save_permission'); 
  $tmpl->param('ext' => $ext); 
  $tmpl->param('full_name' =>  $u->{last_name} .  
           ", " . $u->{first_name} .  
           " "  . $u->{mi} ) ; 
  $tmpl->param('permission_id' => $u->{permission_id} ); 

  if ($perm->is_authorized($u->{permission_id}, $session->param('permission_id')) ) {
    $tmpl->param('edit_allowed' => 1); 
    my @perms = ('USER', 'ADMIN', 'SUPER'); 
    my @arr ; 
    foreach my $perm_id (@perms ) { 
       my %data ;
       if ($perm->is_authorized($perm_id, $session->param('permission_id') ) )  { 
          $data{permission_id} = $perm_id ; 
          if ($u->{permission_id}  eq $perm_id) {
             $data{sel} = 1; 
          } 
          push @arr, \%data ; 
       } 
    }  
    $tmpl->param('permission_opts' => \@arr ); 
  } 
 

  return $tmpl ; 
  
}

#################################
## sub save_permission
#################################
sub save_permission {
  my $self = shift ; 
     return unless (defined($self))  ;
  my $wu = $self->{WEBUSER};
  my $session = $wu->cgi_session();
  my $cgi = $wu->cgi ();
  my $dbh = $wu->dbh ();
  my $ext = $cgi->param('ext');
  my $msg ; 
  if ($cgi->param('permission_id') =~ /^USER|^ADMIN|^SUPER/) { 
    my $upd = "UPDATE VM_Users SET permission_id = " . $dbh->quote($cgi->param('permission_id') ) .
        " WHERE extension = $ext ";  
    print STDERR "update = $upd\n" if (WEB_DEBUG); 
    $dbh->do($upd); 
    $msg = "Permission updated for extension $ext "; 
  } 
  print $cgi->redirect("admin.cgi?mod=" . $self->module() ."&msg=$msg");  
  exit ;
  

}

#################################
## sub module
#################################
sub module() {
  return "UserAdmin"; 
}
1; 
