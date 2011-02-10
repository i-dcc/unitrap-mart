#! /software/bin/perl

##
## Script to load in the SQL file from MartBuilder and 
## recreate our Mart database.
##

use strict;
use warnings;
use Getopt::Long;
use YAML;
use DateTime;

##
## Get the options for the program...
##

my $production;
GetOptions(
  'production|p' => \$production,
);

my $ENVIRONMENT = 'test';
$ENVIRONMENT = 'production' if $production;

##
## Read in configuration
##

my $MARTDB_CONF = YAML::LoadFile('settings.yml') or die "Unable to read settings.yml";
my $CURRENT_DB_CONF = YAML::LoadFile('current_db.yml') or die "Unable to read current_db.yml";
my $DB_TO_USE = $CURRENT_DB_CONF->{$ENVIRONMENT};

# NB: this is the database that the current server is looking at...
# DO NOT DELETE IT!!!!  Instead, use the other database...
if ( $DB_TO_USE eq 'standard' ) { $DB_TO_USE = 'alt'; } 
else                            { $DB_TO_USE = 'standard'; }

##
## Read in SQL code and modify if we're looking at 'alt'
##

my $sql = '';

open(FILE,"martbuilder.sql");
while (<FILE>) { $sql .= $_; }
close(FILE);

if ( $ENVIRONMENT eq "production" ) {
  $sql =~ s/ikmc_unitrap/biomart_unitrap/g;
}

if ( $DB_TO_USE eq "alt" ) {
  my $standard_db = $MARTDB_CONF->{$ENVIRONMENT}->{'databases'}->[0]->{'standard'}->{'database'};
  my $alt_db      = $MARTDB_CONF->{$ENVIRONMENT}->{'databases'}->[0]->{'alt'}->{'database'};
  $sql =~ s/$standard_db\./$alt_db\./g;
}

open(OUT,">martbuilder_run.sql");
print OUT $sql;
close(OUT);

##
## Run the SQL - use the MySQL client as the SQL generated is too big 
## for DBI to handle.
##

my $host = $MARTDB_CONF->{$ENVIRONMENT}->{'databases'}->[0]->{'host'};
my $port = $MARTDB_CONF->{$ENVIRONMENT}->{'databases'}->[0]->{'port'};
my $db   = $MARTDB_CONF->{$ENVIRONMENT}->{'databases'}->[0]->{$DB_TO_USE}->{'database'};
my $user = $MARTDB_CONF->{$ENVIRONMENT}->{'databases'}->[0]->{'user'};
my $pass = $MARTDB_CONF->{$ENVIRONMENT}->{'databases'}->[0]->{'password'};

print "Creating mart tables...\n";
my $cmd = "/usr/bin/env mysql -u $pass --password=$pass -h $host -P $port < martbuilder_run.sql";
system($cmd) == 0 or die "system command '$cmd' failed: $?";

##
## If we get this far add the timestamp for the current environment, and dump this to the file...
##

my $dt = DateTime->now;
$CURRENT_DB_CONF->{ $ENVIRONMENT . '_timestamp' } = {
    year   => $dt->year,
    month  => $dt->month,
    day    => $dt->day,
    hour   => $dt->hour,
    minute => $dt->minute,
    second => $dt->second,
    offset => $dt->offset
};

YAML::DumpFile( 'current_db.yml', $CURRENT_DB_CONF );
