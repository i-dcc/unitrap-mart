
set :project,             'unitrap-mart'
set :repository,          'svn+ssh://svn.internal.sanger.ac.uk/repos/svn/htgt/projects/biomart/unitrap-mart/trunk'
set :umask,               '002'
set :service_user,        'team87'
set :service_group,       'team87'
set :biomart_env,         nil
set :custom_env_setup,    'exec /software/bin/perl -I/software/team87/brave_new_world/lib/perl5 -I/software/team87/brave_new_world/lib/perl5/x86_64-linux-thread-multi /software/team87/brave_new_world/bin/htgt-env.pl --live' 

# usage: rake ENVIRONMENT vlad:TASK

##
## Our environments
##

task :unitrap_mart_htgt_test do
  set :biomart_env,         'unitrap_mart_htgt_test'
  set :domain,              'htgt.internal.sanger.ac.uk'
  set :deploy_to,           '/nfs/team87/services/biomart/unitrap-mart/test/rebuild'
  set :serverdir,           "#{deploy_to.gsub('/rebuild','/server')}/current"
end

task :unitrap_mart_helmholtz_production do
  set :biomart_env,         'unitrap_mart_helmholtz_production'
  set :ssh_flags,           '-p 54321'
  set :rsync_flags,         ["-e 'ssh -p 54321'", '-azP', '--delete']
  set :custom_env_setup,    nil
  set :service_user,        nil
  set :service_group,       nil
  set :domain,              'biomart@idcc-devel.helmholtz-muenchen.de'
  set :deploy_to,           '/opt/biomart/rebuild'
  set :serverdir,           "#{deploy_to.gsub('/rebuild','/server')}/current"
end

##
## Tasks
##

namespace :vlad do
  Rake.clear_tasks('vlad:setup','vlad:setup_app')
  Rake.clear_tasks('vlad:migrate','vlad:update','vlad:rollback')
  Rake.clear_tasks('vlad:start','vlad:start_app','vlad:start_web')
  Rake.clear_tasks('vlad:stop','vlad:stop_web')
  
  ##
  ## Deployment
  ##
  
  desc "Deploy the latest version of the #{project} codebase"
  task :deploy => [
    'vlad:export_code',
    'vlad:update_permissions_and_symlinks',
    'vlad:cleanup'
  ]
  
  task :export_code do
    begin
      Dir.mktmpdir do |dir|
        Dir.mkdir("#{dir}/export")
        `#{svn_cmd} export --force #{repository} #{dir}/export`
        `#{rsync_cmd} #{rsync_flags.join(' ')} #{dir}/export/. #{domain}:#{release_path}`
      end
    rescue => e
      raise e
    end
  end
  
  remote_task :update_permissions_and_symlinks, :roles => :app do
    symlink = false
    begin
      commands = [ "umask #{umask}" ]
      commands << "cp #{current_path}/current_db.yml #{latest_release}/current_db.yml" if File.exists?("#{current_path}/current_db.yml")
      commands << "cp #{current_path}/rebuild_timestamp.yml #{latest_release}/rebuild_timestamp.yml" if File.exists?("#{current_path}/rebuild_timestamp.yml")
      commands << "chmod -R g+w #{latest_release}"
      commands << "chmod 02775 #{latest_release}"
      
      run commands.join(" && ")
      
      symlink = true
      commands = [
        "umask #{umask}",
        "rm -f #{current_path}",
        "ln -s #{latest_release} #{current_path}",
        "echo #{now} $USER #{revision} #{File.basename(release_path)} >> #{deploy_to}/revisions.log"
      ]
      
      run commands.join(' && ')
    rescue => e
      run "rm -f #{current_path} && ln -s #{previous_release} #{current_path}" if symlink
      run "rm -rf #{release_path}"
      raise e
    end
  end
  
  remote_task :rollback do
    if releases.length < 2 then
      abort "could not rollback the code because there is no prior release"
    else
      run "rm -f #{current_path}; ln -s #{previous_release} #{current_path} && rm -rf #{current_release}"
    end
  end
  
  ##
  ## Stop/Start/Restart
  ##
  
  desc "Stop a BioMart server"
  remote_task :stop, :roles => :app do
    cmd = custom_env_setup ? "#{custom_env_setup}" : "bash -l -c"
    cmd << " \"ruby server.rb --environment #{biomart_env} --rebuilddir #{current_path} --stop"
    cmd << " --service_user #{service_user}" if service_user
    cmd << "\""
    
    commands = [ "cd #{serverdir}", cmd ]
    run commands.join(' && ')
  end
  
  desc "Reconfigure a BioMart server"
  remote_task :reconfigure, :roles => :app do
    cmd = custom_env_setup ? "#{custom_env_setup}" : "bash -l -c"
    cmd << " \"ruby server.rb --environment #{biomart_env} --rebuilddir #{current_path} --reconfigure"
    cmd << " --service_user #{service_user}" if service_user
    cmd << "\""
    
    commands = [ "cd #{serverdir}", cmd ]
    run commands.join(' && ')
  end
  
  desc "Start a BioMart server"
  remote_task :start, :roles => :app do
    cmd = custom_env_setup ? "#{custom_env_setup}" : "bash -l -c"
    cmd << " \"ruby server.rb --environment #{biomart_env} --rebuilddir #{current_path} --start"
    cmd << " --service_user #{service_user}" if service_user
    cmd << "\""
    
    commands = [ "cd #{serverdir}", cmd ]
    run commands.join(' && ')
  end
  
  desc "Restart a BioMart server (stop/reconfigure/start)"
  task :restart => [
    'vlad:stop',
    'vlad:reconfigure',
    'vlad:start'
  ]
  
  desc "Switch the BioMart server configuration (stop/switch_conf/reconfigure/start)"
  remote_task :switch_conf, :roles => :app do
    cmd = custom_env_setup ? "#{custom_env_setup}" : "bash -l -c"
    cmd << " \"ruby server.rb --environment #{biomart_env} --rebuilddir #{current_path} --stop --switch_conf --reconfigure --start"
    cmd << " --service_user #{service_user}" if service_user
    cmd << "\""
    
    commands = [ "cd #{serverdir}", cmd ]
    run commands.join(' && ')
  end
  
  ##
  ## Setup/Utility
  ##
  
  remote_task :setup, :roles => :app do
    dirs     = [deploy_to, releases_path]
    dirs     = dirs.join(' ')
    commands = [ "umask #{umask}", "mkdir -p #{dirs}" ]
    run commands.join(' && ')
  end
  
  remote_task :invoke_in_current_path do
    command = ENV["COMMAND"]
    abort "Please specify a command to execute on the remote servers (via the COMMAND environment variable)" unless command
    run("cd #{current_path} && #{command}")
  end
end
