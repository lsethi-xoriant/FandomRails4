# config valid only for Capistrano 3.1
lock '3.1.0'

config = YAML.load_file('config/deploy_settings.yml')
hostname = config['capistrano']['server_hostname']
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
set :linked_dirs, %w{log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

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
    on roles(:app), in: :sequence, wait: 5 do
      # execute :touch, release_path.join('tmp/restart.txt')
      puts "restarting unicorn..."
      execute "/etc/init.d/railsweb restart"
      sleep 5
      puts "is unicorn running? Look at this ps!"
      execute "ps aux | grep unicorn"
      #puts "making an archive of the current release (for AWS)"
      #execute "cd #{deploy_to} ; tar chzf current.tgz releases/$(basename $(readlink current))"
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
