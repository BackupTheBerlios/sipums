package OpenUMS::Permissions;

### $Id: Permissions.pm,v 1.1 2004/07/20 02:52:15 richardz Exp $
#
# Permissions.pm
#
# Copyright (C) 2003 Integrated Comtel Inc.
#
# This library is free software; you can redistribute it and/or modify it
# under the terms of the GNU Lesser General Public License as published by the
# Free Software Foundation; either version 2.1 of the license, or (at your
# option) any later version.
#
# This library is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public License for more
# details.
#
# You should have received a copy of the GNU Lesser General Public License 
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

=pod
=head1 NAME
                                                                                                                             
OpenUMS::Menu - Master Control Class for Openums menu system
                                                                                                                             
=head1 SYNOPSIS
                                                                                                                             
  use OpenUMS::Permissions;
  use OpenUMS::Permissions;
  use Telephony::CTPort;

  my $ctport = new Telephoney::CTPort($port); 
  my $dbh = OpenUMS::Common::get_dbh();
  my $menu = new OpenUMS::Menu($dbh, $ctport); 
  ## query the database for the latest menu structure...
  $menu->create_menu (); 
  ## RUN THAT BAD DOG 
  $menu->run_menu($extension_to, $caller_id ) ;     
                                                                                                                             
=head1 DESCRIPTION 

This module implements an Object-Oriented interface to User Permissions for
the OpenUMS Voicemail System.
                                                                                                                             
=head1 AUTHOR
                                                                                                                             
Kevin English, kenglish@comtelhi.com
Matt Darnell , mdarnell@comtelhi.com
Dean Takemori, dtakemore@comtelhi.com
                                                                                                                             
=cut
                                                                                                                             



use strict ; 

use OpenUMS::Config ; 
use OpenUMS::Log;

sub new {
  ## this your standard 'new', it intializes the hash and blesses it
  ## expected parametes:
  ##  $dbh = a valid database handle. Should already be connected to a database
  ## containing an instance of our standard voicemail database   
  ##  $ctport = a valid instance of the Telephony::CTPort object. 
  my $proto = shift;
  my $dbh = shift;

  my $class = ref($proto) || $proto;
  my $self = {}; ## self is a hash ref

  ## we add the parameters to the hash ref..
  $self->{DBH} = $dbh;
  ## bless that puppy, ie, make it an object ref
  

  bless($self, $class);
  $self->_get_data();
  return $self;
}
sub _get_data {
  my $self = shift ;
  my $dbh = $self->{DBH};
  my $sql = qq{SELECT  permission_id,permission_level FROM VM_Permissions };
  my $sth = $dbh->prepare($sql); 
  $sth->execute();
  my %PERMISSIONS;
  while (my ($perm_id,$perm_level) = $sth->fetchrow_array() ) { 
    $PERMISSIONS{$perm_id} = $perm_level ; 
  } 
  $self->{PERMISSIONS} = \%PERMISSIONS; 
  $sth->finish();
  return ;
}
##########3
##  sub is_authorized($object_permission, $user_permsssion); 
##    based on the permissions, determines if user it authorized to acces the object    
## 
##########3
sub is_authorized {
  my $self = shift; 

  my $object_permission = shift; 
  my $user_permission = shift; 

  if (!$user_permission || !$object_permission){
     return 0; 
  } 
  ## so, it the object has a higher permission level the user
  my $PERMISSIONS = $self->{PERMISSIONS} ; 

  ## if the objects permission level is higher than the users, they are not valid

  if ( int($PERMISSIONS->{$object_permission}) <= int($PERMISSIONS->{$user_permission}) ) {  
     return 1;   
  } else {
     $log->normal("OpenUMS::Permissions: permission denied "); 
#           $PERMISSIONS->{$user_permission} . ",ob=" . $object_permission . " " . $PERMISSIONS->{$object_permission}); 
#     $log->debug("OpenUMS::Permissions: regime = $PERMISSIONS->{$user_permission} <= $PERMISSIONS->{$object_permission} " . ($PERMISSIONS->{$user_permission} <= $PERMISSIONS->{$object_permission}) );   
     return 0; 
  } 

}

sub is_web_authorized {
  my $self = shift; 

  my $menu_id = shift; 
  my $user_permission = shift; 
  if (!$menu_id) {
     return 0 ; 
  } 
  if ($user_permission =~ /^SUPER/) {
     return 1 ; 
  } 

  my $dbh = $self->{DBH}; 
  my $sql = qq{SELECT permission_id, menu_type_code FROM menu WHERE  menu_id = $menu_id };
  my $sth = $dbh->prepare($sql);
  $sth->execute();
  
  my ($permission_id, $menu_type) =$sth->fetchrow_array();  
  $sth->finish() ; 

  print STDERR "object_permission=$permission_id menu_type $menu_type  user_permission = $user_permission\n"; 

  if ($user_permission =~ /^ADMIN/) {
     if ($permission_id =~ /^USER|^ADMIN|^SUPER/  ) {
        return 0; 
     }  else  {
       if ($menu_type =~ /^LOGIN|^PASSWD|^DBMN$/ ) { 
          return 0 ; 
       } else {
          return 1; 
       }
     } 
  } 
  return  0; 
}
sub get_array_ref {
  my $self = shift ; 
  my $perm = $self->{PERMISSIONS}  ; 
  my @arr ; 
  foreach my $key (keys %{$perm} ) { 
    push @arr, $key ; 
  } 
  return \@arr ; 
}
1;
