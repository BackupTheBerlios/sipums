package OpenUMS::WWW::WebUser;
### $Id: WebUser.pm,v 1.1 2004/07/20 03:14:53 richardz Exp $
#
# WebUser.pm
#
# This object is used to manipulate and retrieve information about user's of the Voicemail system
#
# Copyright (C) 2003 Integrated Comtel Inc.

=pod
=head1 NAME
                                                                                                                             
OpenUMS::WebUser - User object for the OpenUMS Web Interface system 
                                                                                                                             
=head1 SYNOPSIS
                                                                                                                             
                                                                                                                             
=head1 DESCRIPTION
                                                                                                                             
This module implements an Object-Oriented interface to User data for 
OpenUMS database. 
                                                                                                                             
=head1 AUTHOR
                                                                                                                             
Kevin English, kenglish@comtelhi.com
Matt Darnell , mdarnell@comtelhi.com
Dean Takemori, dtakemore@comtelhi.com
                                                                                                                             
=cut

use strict ; 

use OpenUMS::WWW::WebTools;



#################################
## sub new
#################################
sub new {
  ## this your standard 'new', it intializes the hash and blesses it
  ## expected parametes:
  ##  $dbh = a valid database handle. Should already be connected to a database
  ## containing an instance of our standard voicemail database   
  my $proto = shift;
  my $dbh     = shift;
  my $cgi     = shift;
  my $session = shift;
  my $perms = shift;

  my $class = ref($proto) || $proto;
  my $self = {}; ## self is a hash ref

  ## we add the parameters to the hash ref..
  $self->{DBH} = $dbh;
  $self->{CGI} = $cgi ;
  $self->{CGI_SESSION} = $session ;
  $self->{PERMISSIONS} = $perms ;
  
   
  bless($self, $class);
  $self->permission_id($session->param('permission_id') ); 
  return $self;
}


#################################
## sub cgi
#################################
sub cgi {
  my $self  = shift ; 
  return $self->{CGI} ; 
} 


#################################
## sub cgi_session
#################################
sub cgi_session {
  my $self  = shift ; 
  return $self->{CGI_SESSION} ; 
} 


#################################
## sub dbh
#################################
sub dbh {
  my $self  = shift ; 
  return $self->{DBH} ; 
} 

#################################
## sub permission_id
#################################
sub permission_id {
  my $self = shift ; 
  if (@_ ) {
     $self->{PERMISSION_ID}  = shift ; 
  } 
  return $self->{PERMISSION_ID}; 
}

#################################
## sub permissions
#################################
sub permissions {
  my $self = shift ; 
  return $self->{PERMISSIONS}; 
}
1; 
1; 
