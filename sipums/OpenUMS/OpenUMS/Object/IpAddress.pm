package OpenUMS::Object::IpAddress; 

# IpAddress.pm
#
# Retrieve & update the ip address for the machine
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



use OpenUMS::Config;
use OpenUMS::Log;
use OpenUMS::Common;
use OpenUMS::DbQuery ;


use strict ; 

#################################
## sub new
#################################
sub new {
  ## this your standard 'new', it intializes the hash and blesses it
  my $proto = shift;

  my $class = ref($proto) || $proto;
  my $self = {}; ## self is a hash ref
  ## we'll add the parameters to the hash ref..
  bless($self, $class);
  return $self;
}

#################################
## sub get_internal_ip_address_sound
## this just returns the unique sound_file, no path, nothing....
#################################
sub get_internal_ip_address_sound {
  my $self = shift;
  my ($int_ip,$netmask)  = $self->_get_ip_and_netmask();    
  return $self->get_sound($int_ip); 
}
#################################
## sub get_internal_netmask_sound
## this just returns the unique sound_file, no path, nothing....
#################################
sub get_internal_netmask_sound {
  my $self = shift;
  my ($int_ip,$netmask)  = $self->_get_ip_and_netmask();    
  return $self->get_sound($netmask); 
}

#################################
## sub get_internal_gateway_sound
## this just returns the unique sound_file, no path, nothing....
#################################
sub get_internal_gateway_sound {
  my $self = shift;
  my $gateway = $self->_get_gateway();    
  return $self->get_sound( $gateway ); 
}




#################################
## sub _get_ip_and_netmask
#################################
sub _get_ip_and_netmask {
# path to ifconfig
  my $self = shift ;
  my $ifconfig="/sbin/ifconfig";
  my @lines=qx|$ifconfig eth0 | ; 
  my ($ip,$mask);
  foreach(@lines){
        if(/inet addr:([\d.]+)/){
                $ip = $1;
        }
        if(/Mask:([\d.]+)/){
                $mask = $1;
        }
  }
  return ($ip, $mask);
}

#################################
## sub _get_gateway
#################################
sub _get_gateway {
  my $netstat="/bin/netstat -nr";
  my @lines=qx|$netstat | ;
  my $gateway ;
  foreach(@lines){
    my $line = $_;
    if ($line =~ /eth0/ && $line =~ /UG/) {
        ## if they are talking about eth0 and the flag is  UG
       my $junk ;
       ($junk, $gateway) = split (/\s+/,$line);
    }
  }
  return $gateway ;
}


sub _get_external_ip {
  my $self  = shift ;
  use LWP::UserAgent ; 
  my $ua = LWP::UserAgent->new;
  $ua->timeout(10);
  $ua->env_proxy;

  ## replace with  an ip scraper

  my $response = $ua->get('http://www.comtelhi.com/yourip.asp');
  
  if ($response->is_success) {
     my $content = $response->content ;
     my $ip = $content;
     $ip =~ s/Your IP address is //g;
     return $ip; 
  } else {
     return undef;
  } 

}


#################################
## sub get_sound
#################################
sub get_sound  {
  my $self = shift ;
  my $IP = shift ;
  my @wavs ;
  for (my $i = 0 ;  $i < length($IP); $i++ ) {
     my $num = substr($IP,$i,1);
     if ($num =~ /[0-9]/) {
       $wavs[$i] = OpenUMS::Common::get_prompt_sound($num); 
     } else {
       $wavs[$i] = OpenUMS::Common::get_prompt_sound("dot") ; 
     }
  }
                                                                                                                                               
  my $wav_files = join (" ", @wavs)  ;
  return $wav_files;
}

#################################
## sub set_ip_address
#################################
sub set_ip_address {
  my ($self,$ip) = @_;  
  $self->{IP_ADDRESS}  = $ip; 
  return 1;
}
sub set_value {
  my ($self,$value_name, $ip) = @_;  
  $self->{$value_name} = $ip;  
  return 1 ; 
}
sub use_current {
  my ($self,$value_name) = @_ ; 
  ## figure out which one they are talking about....

  $log->debug("gonna use current for $value_name ");
  if ($value_name eq 'IPADDRESS' || $value_name eq 'IPNETMASK') { 
    my ($int_ip,$netmask)  = $self->_get_ip_and_netmask();    
    if ($value_name eq 'IPADDRESS') {
       $self->set_value($value_name, $int_ip); 
    }  else {
       $self->set_value($value_name, $netmask); 
    } 
  } elsif ($value_name eq 'IPGATEWAY') { 
      my $gateway = $self->_get_gateway();
      $self->set_value($value_name, $gateway); 
  }   else {
     $log->debug("THIS IS BAD, THEY TRIED TO USE CURRENT ON AN INVALID IP VALUE=$value_name");
     return 0; 
  }
}
sub get_external_ip_sound {

  my $self = shift;   
  my $ext_ip = $self->_get_external_ip(); 
  return $self->get_sound($ext_ip);   

}
sub get_value_sound {
  my ($self,$value_name) = @_;  
  my $value =  $self->{$value_name} ; 
  return $self->get_sound($value); 
}


sub save_ip {
  my $self = shift ;

  $log->debug("going to save IP");

  ### Untaint these for configurenetwork call
  unless ( $self->{IPADDRESS} =~ /^(\d{1,3}).(\d{1,3}).(\d{1,3}).(\d{1,3})$/ )
    {
      $log->err("Invalid IPADDRESS $self->{IPADDRESS}"); 
      return 0;
    }
  my $address = "$1.$2.$3.$4";
  unless ( $self->{IPGATEWAY} =~ /^(\d{1,3}).(\d{1,3}).(\d{1,3}).(\d{1,3})$/ )
    {
      $log->err("Invalid IPGATEWAY $self->{IPGATEWAY}");
      return 0;
    }
  my $gateway = "$1.$2.$3.$4";
  unless ( $self->{IPNETMASK} =~ /^(\d{1,3}).(\d{1,3}).(\d{1,3}).(\d{1,3})$/ )
    {
      $log->err("Invalid IPNETMASK $self->{IPNETMASK}");
      return 0;
    }
  my $netmask = "$1.$2.$3.$4";

  $log->debug("IP ADDRESS   = " . $address );
  $log->debug("IP GATEWAY   = " . $gateway );
  $log->debug("IP NETMASK   = " . $netmask );
  my $cmd = "sudo /usr/local/openums/configurenetwork $address $gateway $netmask"; 
  open(CONFIGURENETWORK, "$cmd|" );
  while(<CONFIGURENETWORK>)
    { $log->debug($_); }
  close(CONFIGURENETWORK);

  if ($_ =~ /IP CHANGED/ ) { 
    return 1;  
  }  else {
    return 0 ; 
  } 
}


1; 
