require "#{File.dirname(__FILE__)}/../lib/fandom_utils"

# Set environment to development unless something else is specified
env = ENV["RAILS_ENV"] || "development"

core_number = FandomUtils::get_number_of_cores()
worker_number = core_number * 3
worker_processes worker_number

preload_app true

listen 3000
listen "/tmp/Fandom.socket", :backlog => 64

# nuke workers after 30 seconds instead of 60 seconds (the default)
timeout 30

pid "/tmp/unicorn.Fandom.pid"
old_pid = "/tmp/unicorn.Fandom.pid.oldbin"

# Production specific settings
if env == "production"
  begin
    # production paths can be overridden in development 
    working_directory = Rails.configuration.deploy_settings['development']['unicorn_working_directory']
    shared_path = working_directory
  rescue
    working_directory "/home/app/railsapps/Fandom/current"
    shared_path = "/home/app/railsapps/Fandom/shared"
    user 'app', 'app'
  end
  
  stderr_path "#{shared_path}/log/unicorn.stderr.log"
  stdout_path "#{shared_path}/log/unicorn.stdout.log"

  unless Dir.exists?("#{shared_path}/log")
    require 'fileutils'
    FileUtils::mkdir_p "#{shared_path}/log"
  end

end

before_fork do |server, worker|
  # Disconnect since the database connection will not carry over
  if defined? ActiveRecord::Base
    ActiveRecord::Base.connection.disconnect!
  end

  if defined?(Resque)
    Resque.redis.quit
    Rails.logger.info('Disconnected from Redis')
  end
  
  # Before forking, kill the master process that belongs to the .oldbin PID.
  # This enables 0 downtime deploys.
  if File.exists?(old_pid) && server.pid != old_pid
    begin
      Process.kill("QUIT", File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
      # someone else did our job for us
    end
  end
end

after_fork do |server, worker|
  # Start up the database connection again in the worker
  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.establish_connection
  end

  Rails.cache.reset

  if defined?(Resque)
    Resque.redis = ENV['REDIS_URI']
    Rails.logger.info('Connected to Redis')
  end
  
  # if preload_app is true, then you may also want to check and
  # restart any other shared sockets/descriptors such as Memcached,
  # and Redis.  TokyoCabinet file handles are safe to reuse
  # between any number of forked children (assuming your kernel
  # correctly implements pread()/pwrite() system calls)
end
