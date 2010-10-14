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

my $production;
my $dryrun;

GetOptions(
    'production|p' => \$production,
    'dryrun'       => \$dryrun
);

my $ENVIRONMENT = 'test';
$ENVIRONMENT = 'production' if $production;

##
## Set-up the options for the program...
##

my $INSTALL_LOCATION = {
    production => '/opt/biomart',
    test       => '/nfs/team87/services/biomart/unitrap_mart/test'
};

my $MARTDB_CONF = YAML::LoadFile($INSTALL_LOCATION->{$ENVIRONMENT}.'/rebuild/settings.yml')->{$ENVIRONMENT} or die "Unable to read settings.yml";
my $host        = $MARTDB_CONF->{'databases'}->[0]->{'host'};
my $port        = $MARTDB_CONF->{'databases'}->[0]->{'port'};
my $staging_db  = $MARTDB_CONF->{'databases'}->[0]->{'staging_db'};
my $user        = $MARTDB_CONF->{'databases'}->[0]->{'user'};
my $pass        = $MARTDB_CONF->{'databases'}->[0]->{'password'};

my $REBUILD_COMMANDS = [
    "/usr/bin/env mysql -u $user --password=$pass -h $host -P $port $staging_db < support/create_or_replace_index_procedure.sql",
    "/usr/bin/env mysql -u $user --password=$pass -h $host -P $port $staging_db < support/staging_area_additions.sql",
    'perl run_martbuilder_sql.pl'
];
my $SERVER_COMMANDS  = [ 'ruby server.rb --stop --reconfigure --switch_conf --start' ];

##
## Run the rebuild...
##

my $rebuild_dir = $INSTALL_LOCATION->{$ENVIRONMENT} . '/rebuild';
my $server_dir  = $INSTALL_LOCATION->{$ENVIRONMENT} . '/server';

print "Rebuilding into $ENVIRONMENT environment...\n";

print " - moving to $rebuild_dir \n";
chdir $rebuild_dir or die "[ERROR] Unable to chdir to $rebuild_dir - $! \n";
run_jobs( $REBUILD_COMMANDS, $production, $dryrun );

print " - moving to $server_dir \n";
chdir $server_dir or die "[ERROR] Unable to chdir to $server_dir - $! \n";
run_jobs( $SERVER_COMMANDS, $production, $dryrun );

sub run_jobs {
    my ( $jobs, $production, $dryrun ) = @_;
    
    foreach my $job ( @{$jobs} ) {
        unless ( $job =~ m|^/usr/bin/env mysql| or $job =~ /^mysql/ ) {
            $job .= ' --production' if $production;
        }
        print " - running '$job'\n";
        
        unless ( $dryrun ) {
            system($job) == 0
                or die "[ERROR] - process failed: '$job' (process id: $?) \n";
        }
    }
}
