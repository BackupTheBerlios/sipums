package OpenUMS::PhoneSystem; 
### $Id: PhoneSystem.pm,v 1.1 2004/07/20 02:52:15 richardz Exp $
#
## this will be a template for functions that 

sub new {
  my $proto = shift;
  my $ctport = shift ; 
  my $dbh = shift ; 

  my $class = ref($proto) || $proto;
  my $self = {}; ## self is a hash ref
  $self->{CTPORT} = $ctport; 
  $self->{DBH} = $dbh; 

  ## we add the parameters to the hash ref..
  ## bless that puppy, ie, make it an object ref


  bless($self, $class);
  return $self;
}
sub intergration_digits {
  ## stub...
  return 0; 
} 

1; 
