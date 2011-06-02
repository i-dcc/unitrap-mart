#! /software/bin/perl

##
## Simple wrapper script to run the biomart rebuild processes.
##

use strict;
use warnings FATAL => 'all';
use Getopt::Long;
use YAML;

##
## Get command-line args...
##

my $ENVIRONMENT = undef;
my $DRYRUN      = undef;

GetOptions(
    'environment|e=s' => \$ENVIRONMENT,
    'dryrun'          => \$DRYRUN
);

die "You must specify an --environment option to determine which mart database to write to!" unless $ENVIRONMENT;

##
## Set-up the options for the program...
##

my $INSTALL_LOCATION = {
    unitrap_mart_helmholtz_production => '/opt/biomart',
    unitrap_mart_htgt_test            => '/nfs/team87/services/biomart/unitrap-mart/test'
};
my $rebuild_dir = $INSTALL_LOCATION->{$ENVIRONMENT} . '/rebuild/current';
my $server_dir  = $INSTALL_LOCATION->{$ENVIRONMENT} . '/server/current';

my $MARTDB_CONF = YAML::LoadFile("$rebuild_dir/settings.yml")->{$ENVIRONMENT} or die "Unable to read settings.yml";
my $host        = $MARTDB_CONF->{'databases'}->[0]->{'host'};
my $port        = $MARTDB_CONF->{'databases'}->[0]->{'port'};
my $staging_db  = $MARTDB_CONF->{'databases'}->[0]->{'staging_db'};
my $user        = $MARTDB_CONF->{'databases'}->[0]->{'user'};
my $pass        = $MARTDB_CONF->{'databases'}->[0]->{'password'};

my $REBUILD_COMMANDS = [
    "/usr/bin/env mysql -u $user --password=$pass -h $host -P $port $staging_db < support/create_or_replace_index_procedure.sql",
    "/usr/bin/env mysql -u $user --password=$pass -h $host -P $port $staging_db < support/staging_area_additions.sql",
    "ruby run_sql_script.rb --environment $ENVIRONMENT --file martbuilder.sql --update_timestamp"
];
my $SERVER_COMMANDS  = [
  "ruby server.rb --environment $ENVIRONMENT --rebuilddir $rebuild_dir --stop --switch_conf --reconfigure --start"
];

##
## Run the rebuild...
##

print "Rebuilding into $ENVIRONMENT environment...\n";

print " - moving to $rebuild_dir \n";
chdir $rebuild_dir or die "[ERROR] Unable to chdir to $rebuild_dir - $! \n";
run_jobs( $REBUILD_COMMANDS, $DRYRUN );

print " - moving to $server_dir \n";
chdir $server_dir or die "[ERROR] Unable to chdir to $server_dir - $! \n";
run_jobs( $SERVER_COMMANDS, $DRYRUN );

sub run_jobs {
    my ( $jobs, $dryrun ) = @_;
    
    foreach my $job ( @{$jobs} ) {
        print " - running '$job'\n";
        
        unless ( $dryrun ) {
            system($job) == 0
                or die "[ERROR] - process failed: '$job' (process id: $?) \n";
        }
    }
}
