#!/usr/bin/perl
#

&usage() if (@ARGV < 2);
 
my $database = $ARGV[0];
my $new_dir = $ARGV[1];

if (!(-e "/var/spool/openums/$new_dir") ) {
  die "new_dir does not exists, you must create it first \n" ;
} 

use lib '/usr/local/openums/lib'; 

print "$database $dir\n"; 


use OpenUMS::Common;
my $dbh = OpenUMS::Common::get_dbh($database); 

use OpenUMS::GlobalSettings;
$CONF->load_settings($database);

print "OLD VOICEMAIL DB : " . $CONF->get_var('VOICEMAIL_DB') . "\n"; 
print "OLD OPENUMS DIR  : " . $CONF->get_var('VM_PATH') . "\n"; 



$dbh->do("UPDATE global_settings SET  var_value = '$database' WHERE var_name='VOICEMAIL_DB'"); 
$dbh->do("UPDATE global_settings SET  var_value = '$new_dir' WHERE var_name='VM_PATH'"); 
## reload 'em
$CONF->load_settings($database);

print "NEW VOICEMAIL DB : " . $CONF->get_var('VOICEMAIL_DB') . "\n"; 
print "NEW OPENUMS DIR  : " . $CONF->get_var('VM_PATH') . "\n"; 





sub usage() {
  die "Usage: fixGlobalSettings.pl \"database_name\ \"directory name\"\n"; 
}
