package OpenUMS::WWW::User;
### $Id: User.pm,v 1.1 2004/07/20 03:14:53 richardz Exp $
#
# WWW/User.pm
#
# this is the User Module for the web interface : )
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
  my $dbh = $wu->dbh (); 
  my $cgi = $wu->cgi (); 

  my $extension = $session->param('extension') ; 
  ## setup the template 
  my $tmpl = new HTML::Template(filename =>  'templates/user_main.html');  
  $tmpl->param(MOD => $self->module() ); 
  $tmpl->param(EXTENSION => $extension); 

  ## get user info and set it onto template
  my $u = OpenUMS::DbQuery::get_user_info($dbh,$extension);
  $tmpl->param(MSG => $cgi->param('msg')  ); 
  $tmpl->param(FIRST_NAME => $u->{first_name} ); 
  $tmpl->param(LAST_NAME => $u->{last_name} ); 
  $tmpl->param(TRANSFER => $u->{transfer} ); 
  $tmpl->param(EMAIL_STORE => ($u->{store_flag} eq 'E') ); 
  $tmpl->param(VM_STORE => ($u->{store_flag} eq 'V') ); 

    $tmpl->param(email_address => $u->{'email_address'}  );
    $tmpl->param(email_server_address => $u->{'email_server_address'} ) ;
    $tmpl->param(email_user_name => $u->{'email_user_name'} ) ;
#    $tmpl->param(email_password => $u->{'email_password'} ) ;

  $tmpl->param(MOBILE_EMAIL_FLAG => $u->{mobile_email_flag} ); 
  $tmpl->param(MOBILE_EMAIL => $u->{mobile_email} ); 
  $tmpl->param(MOBILE_EMAIL => $u->{mobile_email} ); 

  ## this for the email_delivery field and the vstore_email field

  my $tvar =  'email_delivery_' . $u->{email_delivery}; 
  $tmpl->param($tvar => 1); 
  $tvar =  'vstore_email_' . $u->{vstore_email}; 
  $tmpl->param($tvar => 1); 

  return $tmpl; 
} 

#######################
## sub edit_mobile
#######################

sub edit_mobile {
  my $self = shift ; 
  return unless (defined($self))  ; 
  my $wu = $self->{WEBUSER}; 
  my $session = $wu->cgi_session(); 
  my $dbh = $wu->dbh (); 
  my $cgi = $wu->cgi (); 

  my $extension = $session->param('extension') ; 
  ## setup the template 
  my $tmpl = new HTML::Template(filename =>  'templates/user_mobile_edit.html');  
  $tmpl->param(ERROR_MESSAGE => $self->{error_message} ) ; 
  $tmpl->param(MOD => $self->module() ); 
  $tmpl->param(FUNC => "save_mobile") ; 
  
  $tmpl->param(EXTENSION => $extension); 
  ## get the user info
  if ($self->{error_message} ) { 
    $tmpl->param(MOBILE_EMAIL => $cgi->param('mobile_email')  ); 
    $tmpl->param(MOBILE_EMAIL_FLAG => $cgi->param('mobile_email_flag') ) ;
  } else {
    my $u = OpenUMS::DbQuery::get_user_info($dbh,$extension);
    $tmpl->param(MOBILE_EMAIL => $u->{mobile_email} ); 
    $tmpl->param(MOBILE_EMAIL_FLAG => $u->{mobile_email_flag} ); 
  } 


  return $tmpl ; 

}
#################################
## sub save_mobile
#################################
sub save_mobile {
  my $self = shift ; 
  return unless (defined($self))  ; 
  my $wu = $self->{WEBUSER}; 
  my $session = $wu->cgi_session(); 
  my $dbh = $wu->dbh (); 
  my $cgi = $wu->cgi (); 

  my $extension = $session->param('extension') ; 
  ## setup the template 
  my ($mobile_email, $mobile_email_flag) = ($cgi->param('mobile_email'), $cgi->param('mobile_email_flag') ); 
  if ($mobile_email_flag) {
     if (!$mobile_email) {
       $self->{error_message} = "You did not provide an e-mail address."; 
       return $self->edit_mobile() ; 
     } else {
        use Email::Valid;
        if (Email::Valid->address($mobile_email) ) { 
           my $sql = qq{UPDATE VM_Users 
                     SET mobile_email_flag = 1,
                         mobile_email = '$mobile_email' 
                     WHERE extension = $extension } ; 
           print STDERR "sql = $sql\n" if (WEB_DEBUG); 
           $dbh->do($sql); 
        } else {
           $self->{error_message} = "That is an invalid e-mail address."; 
           return $self->edit_mobile() ; 
        } 

     } 
    my $sql = qq{UPDATE VM_Users set mobile_email_flag = 1 WHERE extension = $extension } ; 
    print STDERR "sql = $sql\n" if (WEB_DEBUG); 
    $dbh->do($sql); 

  }  else {
    my $sql = qq{UPDATE VM_Users set mobile_email_flag = 0 WHERE extension = $extension } ; 
    $dbh->do($sql); 
  } 
  my $msg = "Mobile Notification Settings updated."; 
  print $cgi->redirect('user.cgi?mod=' . $self->module() . "&msg=$msg"); 
  exit ;
}

#######################
## sub edit_email
#######################
                                                                                                                             
sub edit_email {
  my $self = shift ;
  return unless (defined($self))  ;
  my $wu = $self->{WEBUSER};
  my $session = $wu->cgi_session();
  my $dbh = $wu->dbh ();
  my $cgi = $wu->cgi ();
                                                                                                                             
  my $extension = $session->param('extension') ;
  ## setup the template
  my $tmpl = new HTML::Template(filename =>  'templates/user_email_edit.html');
  $tmpl->param(ERROR_MESSAGE => $self->{error_message} ) ;
  $tmpl->param(MOD => $self->module() );
  $tmpl->param(FUNC => "save_email") ;
                                                                                                                             
  $tmpl->param(EXTENSION => $extension);
  ## get the user info
  if ($self->{error_message} ) {
    $tmpl->param(email_address => $cgi->param('email_address')  );
    $tmpl->param(email_server_address => $cgi->param('email_server_address') ) ;
    $tmpl->param(email_user_name => $cgi->param('email_user_name') ) ;
#    $tmpl->param(email_password => $cgi->param('email_password') ) ;
    $tmpl->param(EMAIL_STORE =>  ($cgi->param('store_flag') eq 'E' ) ) ; 
    $tmpl->param(VM_STORE => ($cgi->param('store_flag') eq 'V') ); 
    my $tmpl_var = "vstore_email_" . $cgi->param('vstore_email') ; 
    $tmpl->param($tmpl_var => 1); 
  } else  { 
    my $u = OpenUMS::DbQuery::get_user_info($dbh,$extension);
    $tmpl->param(email_address => $u->{'email_address'}  );
    $tmpl->param(email_server_address => $u->{'email_server_address'} ) ;
    $tmpl->param(email_user_name => $u->{'email_user_name'} ) ;
#    $tmpl->param(email_password => $u->{'email_password'} ) ;
    $tmpl->param(EMAIL_STORE => ($u->{store_flag} eq 'E') ); 
    $tmpl->param(VM_STORE => ($u->{store_flag} eq 'V') ); 
    my $tmpl_var = "vstore_email_" . $u->{'vstore_email'} ; 
    $tmpl->param($tmpl_var => 1); 
    $tmpl_var = "email_delivery_" . $u->{'email_delivery'} ; 
    $tmpl->param($tmpl_var => 1); 
  }
                                                                                                                             
                                                                                                                             
  return $tmpl ;
}
#######################
## sub save_email
#######################
sub save_email {
  my $self = shift ;
  return unless (defined($self))  ;
  my $wu = $self->{WEBUSER};
  my $session = $wu->cgi_session();
  my $dbh = $wu->dbh ();
  my $cgi = $wu->cgi ();
                                                                                                                             
  my $extension = $session->param('extension') ;
  ## setup the template
  my $email_address = $cgi->param('email_address'); 
  my $email_server_address = $cgi->param('email_server_address'); 
  my $email_user_name = $cgi->param('email_user_name'); 
  
  my $email_password = $cgi->param('email_password'); 
  my $email_password_confirm = $cgi->param('email_password_confirm'); 

  my $store_flag = $cgi->param('store_flag'); 
  my $email_delivery = $cgi->param('email_delivery'); 
  my $msg ; 
  if ($email_address) {
        use Email::Valid;
        ## validate e-mail
        if (!Email::Valid->address($email_address) ) {
          $self->{error_message} = "That is not a valid e-mail address.";
          return $self->edit_email() ;
        } 
  } 

  if ($store_flag eq 'E') { 
     if ($email_address) {
        ## validate e-mail server
        if (!$email_server_address) { 
          $self->{error_message} = "Email Server address is blank. If you do not know this, ask your systems administrator.";
          return $self->edit_email() ;
        } 

        ## validate e-mail user
        if (!$email_user_name) { 
          $self->{error_message} = "Email User Name is blank.";  
          return $self->edit_email() ;
        } 

        my $sql = "UPDATE VM_Users set " ;
        $sql .= " email_address = " . $dbh->quote($email_address);
        $sql .= ", email_server_address = " . $dbh->quote($email_server_address);
        $sql .= ", email_user_name = " . $dbh->quote($email_user_name);
        $sql .= ", store_flag = " . $dbh->quote($store_flag );
        $sql .= ", email_delivery = " . $dbh->quote($email_delivery );
        $sql .= " WHERE extension = $extension "; 
        print STDERR "update email settings = $sql\n" if (WEB_DEBUG); 
        $dbh->do($sql); 
        $msg = "Email Settings updated successfully.";    
        if ($email_password) { 
            if ($email_password ne $email_password_confirm) {
               $self->{error_message} = "Passwords do not match, please try again.";
               return $self->edit_email() ;
            } 
            $sql = "UPDATE VM_Users set " ;
            $sql .= " email_password = " . $dbh->quote($email_password);
            $sql .= " WHERE extension = $extension "; 
            print STDERR "update password = $sql\n" if (WEB_DEBUG); 
            $dbh->do($sql); 
            $msg .= " Password changed.";    
            ## now, we do the extra check to make sure we can open their e-mail...
            use OpenUMS::IMAP; 
            my $imap =  OpenUMS::IMAP::open_imap_connection($dbh, $extension);
            if (defined($imap) ) {
               $imap->close ; 
               print STDERR "Imap password changed success, sending unsent\n" if (WEB_DEBUG);
               OpenUMS::Common::signal_delivermail; 
            } else {
               print STDERR "Imap connection could not be establish, sending user to page to change password\n" if (WEB_DEBUG);
               my $uri = "user.cgi?mod=User&func=edit_email_password";
               print $cgi->redirect(-uri=>$uri) ; 
               exit ;
            }

        } 
     } else {
        $self->{error_message} = "If you select E-mail store, you must provide an e-mail address.";
        return $self->edit_email() ;
   
     } 
     
  } else {
      my $vstore_email = $cgi->param('vstore_email'); 
      if (($vstore_email eq 'C' || $vstore_email eq 'S' )  && (!$email_address) ) { 
        $self->{error_message} = "The option that you have selected requires you enter an e-mail address.";
        return $self->edit_email() ;

      }
      print STDERR "vstore_email = $vstore_email and email_address = $email_address \n " if (WEB_DEBUG);
 
      my $sql = "UPDATE VM_Users set " ;
      $sql .= " store_flag = " . $dbh->quote($store_flag);
      $sql .= ", vstore_email = " . $dbh->quote($vstore_email);
      $sql .= ", email_address = " . $dbh->quote($email_address);
        $sql .= " WHERE extension = $extension "; 
        print STDERR "update = $sql\n" if (WEB_DEBUG); 
        $dbh->do($sql); 
        $msg = "Email Settings Updated: Storage option changed to Voicemail Store.";    
  } 
     print $cgi->redirect('user.cgi?mod=' . $self->module() . "&msg=$msg"); 
     exit ;

}

#######################
## sub edit_basic
#######################
                                                                                                                             
sub edit_basic {
  my $self = shift ;
  return unless (defined($self))  ;
  my $wu = $self->{WEBUSER};
  my $session = $wu->cgi_session();
  my $dbh = $wu->dbh ();
  my $cgi = $wu->cgi ();
                                                                                                                             
  my $extension = $session->param('extension') ;
  ## setup the template
  my $tmpl = new HTML::Template(filename =>  'templates/user_basic_edit.html');
  $tmpl->param(ERROR_MESSAGE => $self->{error_message} ) ;
  $tmpl->param(MOD => $self->module() );
  $tmpl->param(FUNC => "save_basic") ;
                                                                                                                             
  $tmpl->param(EXTENSION => $extension);
  ## get the user info
  if ($self->{error_message} ) {
     $tmpl->param(FIRST_NAME => $cgi->param('first_name')  );
     $tmpl->param(LAST_NAME => $cgi->param('last_name') );
     $tmpl->param(TRANSFER => $cgi->param('transfer') );

  } else {
    my $u = OpenUMS::DbQuery::get_user_info($dbh,$extension);
     $tmpl->param(FIRST_NAME => $u->{first_name} ); 
     $tmpl->param(LAST_NAME => $u->{last_name} ); 
     $tmpl->param(TRANSFER => $u->{transfer} ); 
  }
                                                                                                                             
                                                                                                                             
  return $tmpl ;
}
#######################
## sub save_basic
#######################
sub save_basic {
  my $self = shift ;
  return unless (defined($self))  ;
  my $wu = $self->{WEBUSER};
  my $session = $wu->cgi_session();
  my $dbh = $wu->dbh ();
  my $cgi = $wu->cgi ();
                                                                                                                             
  my $extension = $session->param('extension') ;
  ## setup the template
  my $first_name = $cgi->param('first_name'); 
  my $last_name = $cgi->param('last_name'); 
  my $mi = $cgi->param('mi'); 
  my $transfer = $cgi->param('transfer'); 

  if (!$first_name) {
    $self->{error_message} = "First Name is a required field.";
    return $self->edit_basic() ;
  } 

  if (!$last_name) {
    $self->{error_message} = "Last Name is a required field.";
    return $self->edit_basic() ;
  } 
  my $sql = "UPDATE VM_Users set " ;
  $sql .= " first_name = " . $dbh->quote($first_name);
     $sql .= ", last_name = " . $dbh->quote($last_name);
     $sql .= ", mi = " . $dbh->quote($mi);
     $sql .= ", transfer = $transfer " ; 
     $sql .= " WHERE extension = $extension "; 
     print STDERR "update = $sql\n" if (WEB_DEBUG); 
     $dbh->do($sql); 
  ## update their phone keys, just in case...
  OpenUMS::DbUtils::update_phone_keys($dbh,$extension) ; 
  my $msg = "User Info updated."; 
  print $cgi->redirect('user.cgi?mod=' . $self->module() . "&msg=$msg"); 
  exit ;

}

#################################
## sub edit_email_password
#################################
sub edit_email_password {
  my $self = shift ;
  return unless (defined($self))  ;
  my $wu = $self->{WEBUSER};
  my $session = $wu->cgi_session();
  my $dbh = $wu->dbh ();
  my $cgi = $wu->cgi ();
                                                                                                                             
  my $extension = $session->param('extension') ;
  ## setup the template
  my $tmpl = new HTML::Template(filename =>  'templates/user_email_passwd_edit.html');
  $tmpl->param(ERROR_MESSAGE => $self->{error_message} ) ;
  $tmpl->param(MOD => $self->module() );
  $tmpl->param(FUNC => "save_email") ;
  $tmpl->param(extension => "$extension") ;

 my $u = OpenUMS::DbQuery::get_user_info($dbh,$extension);
  $tmpl->param(email_address => $u->{'email_address'}  );
  $tmpl->param(email_server_address => $u->{'email_server_address'} ) ;
  $tmpl->param(email_user_name => $u->{'email_user_name'} ) ;
#    $tmpl->param(email_password => $u->{'email_password'} ) ;
  $tmpl->param(STORE_FLAG => $u->{store_flag}  );

  return $tmpl; 
}

#################################
## sub module
#################################
sub module {
  return "User"; 
}
1; 
