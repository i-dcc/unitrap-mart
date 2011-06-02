#!/usr/bin/env ruby

#
# Script to run an arbitrary sql script on the 'spare' BioMart database
#

require 'optparse'
require 'yaml'
require 'time'

##
## Check for arguments and environment variables
##

@options = {
  :environment      => nil,
  :file             => nil,
  :update_timestamp => false
}

OptionParser.new do |opts|
  opts.banner = 'Usage: run_sql_script.rb [options]'
  opts.on('--environment', '-e [ENV]', String, 'Environment config to run sql into')  { |arg| @options[:environment] = arg }
  opts.on('--file','-f [FILE]', String, 'SQL file to run')                            { |arg| @options[:file] = arg }
  opts.on('--update_timestamp', 'Update the refresh timestamp on the mart')           { |arg| @options[:update_timestamp] = arg }
end.parse!

raise ArgumentError, 'You must specify an --environment option!' if @options[:environment].nil?
raise ArgumentError, 'You must specify an --file option!' if @options[:file].nil?

MART_CONFIG       = YAML.load_file("settings.yml")[@options[:environment]]
CURRENT_DB_CONFIG = YAML.load_file('current_db.yml')
@db_to_use        = CURRENT_DB_CONFIG[@options[:environment]]

raise ArgumentError, "We can't find an environment config '#{@options[:environment]}'!" if MART_CONFIG.nil?
raise ArgumentError, "We can't find an current_db config '#{@options[:environment]}'!"  if @db_to_use.nil?

# NB: regarding @db_to_use - this is the database that the current server is looking at...
# We need to use the spare we've just rebuilt...
if @db_to_use == 'standard'
  @db_to_use = 'alt'
else
  @db_to_use = 'standard'
end

##
## Read in SQL code and modify if we're looking at 'alt' - the convention in the 
## SQL scripts we use is if we have to specify a database name, ALWAYS use the 
## 'standard' name and let the runner scripts cope with switching them to 'alt'.
##

sql         = File.open( @options[:file], 'rb' ).read
standard_db = MART_CONFIG['databases'][0]['standard']['database']
alt_db      = MART_CONFIG['databases'][0]['alt']['database']

if @options[:environment] == 'unitrap_mart_helmholtz_production'
  sql.gsub!( 'ikmc_unitrapcore.', "#{MART_CONFIG['databases'][0]['staging_db']}." )
  sql.gsub!( 'ikmc_unitrap_mart.', "#{standard_db}." )
end

if @db_to_use == 'alt'
  sql.gsub!( Regexp.new( "#{standard_db}\\.", Regexp::IGNORECASE ), "#{alt_db}." )
end

File.open( 'sql_to_run.sql', 'w' ) { |file| file.write( sql ) }

host = MART_CONFIG['databases'][0]['host']
port = MART_CONFIG['databases'][0]['port']
db   = MART_CONFIG['databases'][0][@db_to_use]['database']
user = MART_CONFIG['databases'][0]['user']
pass = MART_CONFIG['databases'][0]['password']

command = "/usr/bin/env mysql -u #{user} --password=#{pass} -h #{host} -P #{port} #{db} < sql_to_run.sql"

puts "Running: '#{command}'"
system(command)

##
## Finally, do we need to update the timestamp on the mart?
##

if @options[:update_timestamp]
  puts "Updating the timestamp on mart"
  
  dt        = Time.now
  timestamp = {
    'year'   => dt.year,
    'month'  => dt.month,
    'day'    => dt.day,
    'hour'   => dt.hour,
    'minute' => dt.min,
    'second' => dt.sec,
    'offset' => dt.utc_offset
  }
  
  File.open( 'rebuild_timestamp.yml', 'w' ) { |file| file.write( YAML::dump( timestamp ) ) }
end
