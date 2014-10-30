# config valid only for Capistrano 3.1
lock '3.1.0'

config = YAML.load_file('config/deploy_settings.yml')
hostname = config['capistrano']['server_hostname']
local_precompile = config['capistrano'].fetch('local_precompile', false)
role :app, hostname
role :web, hostname
role :db,  hostname, :primary => true
set :repo_url, config['capistrano']['repo_url']
set :ssh_options, { port: config['capistrano']['server_sshport'], forward_agent: true }

set :application, 'Fandom'

set :user, 'app'

set :rails_env, 'production'

# Default branch is :master
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }
set :branch, 'master'

# Default deploy_to directory is /var/www/my_app
deploy_to = '/home/app/railsapps/Fandom'
set :deploy_to, deploy_to 

# run as normal user
set :use_sudo, true

# change this to make the deploy quicker by only coping diffs
set :deploy_via, :copy

# the number of releases to keep on the server, useful for reverts
set :keep_releases, 5

# Default value for :scm is :git
set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
set :pty, true

# Default value for :linked_files is []
set :linked_files, %w{config/database.yml config/deploy_settings.yml}

# Default value for linked_dirs is []
set :linked_dirs, %w{log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system public/assets}

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

namespace :deploy do

  # This is an example of how to run a task before everything else 
  #before :starting, :test do
  #  on roles(:app), in: :groups do
  #    puts "Starting!"
  #  end
  #end
  
  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 0 do
      puts "restarting unicorn..."
      #execute :touch, release_path.join('tmp/restart.txt') # this only works with phusion passenger
      execute "/etc/init.d/railsweb restart"
      
      puts "restarting log daemon..."
      #execute "/etc/init.d/log_daemon restart" # this does not work for an mysterious problem
      run_locally do
        execute "ssh #{hostname} /etc/init.d/log_daemon restart"
      end
      sleep 1
      puts "are they running? Look at this ps!"
      execute "ps aux | grep -e 'unicorn\\|log_daemon'"
      puts "making an archive of the current release (for AWS)"
      execute "cd #{deploy_to} ; tar -czf current.tgz releases/$(basename $(readlink current))"
      execute "cd #{deploy_to} ; tar -czf current_assets.tgz shared/public/assets/"
    end
  end

  after :publishing, :restart

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

end

# overrides the precompile task so that precompilation is performed in the machine running capistrano, 
# instead of on the server
if local_precompile
  namespace :deploy do
    namespace :assets do
  
      Rake::Task['deploy:assets:precompile'].clear_actions
  
      desc 'Precompile assets locally and upload to servers'
      task :precompile do
        on roles(fetch(:assets_roles)) do
          puts 'Precompile assets locally and upload to servers'
          run_locally do
            with rails_env: fetch(:rails_env) do
              execute 'rake assets:precompile'
            end
          end
  
          run_locally do
            execute 'cd public ; tar czf assets.tgz assets/'
          end
  
          within release_path do
            with rails_env: fetch(:rails_env) do
              upload!('./public/assets.tgz', "#{shared_path}/public/") do |channel, name, sent, total|
              end
              execute "cd #{shared_path}/public/; tar zxf assets.tgz; rm assets.tgz"
            end
          end
  
          run_locally do
            execute 'rm public/assets.tgz'
          end
  
          #run_locally do 
          #  execute 'rm -rf public/assets' 
          #end
        end
      end
  
    end
  end
end
