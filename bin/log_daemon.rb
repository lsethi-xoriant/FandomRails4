require 'daemons'

def main

  daemon_argv_from_index = ARGV.rindex("--") ? (ARGV.rindex("--") + 1) : ARGV.size
  daemon_argv =  ARGV.slice(daemon_argv_from_index, ARGV.size)

  if daemon_argv.count < 3
    puts daemon_help
    exit
  else
    app_root_path = daemon_argv[1] ? daemon_argv[1] : ""
  end

  options = {
    app_name: "log_daemon",
    dir_mode: :normal,
    dir: "#{app_root_path}/tmp/pids",
    monitor: true
  }

  d = Daemons.run("#{app_root_path}/bin/log_daemon_impl.rb", options)
  result = d.applications.length > 0 ? 0 : 1
  exit result
end

def daemon_help
  puts <<-EOF
    Usage: #{$0} [start|stop|status] -- <env> <rails_root_project> <loop_delay>
      <env> is the environment for database configuration set in <rails_root_project>/config/database.yml.
      <rails_root_project> is used also for find log files that are stored in <rails_root_project>/log/events.
      <loop_delay> is the daemon loop time in seconds.
    EOF
end

main()

