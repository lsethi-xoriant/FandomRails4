require 'daemons'

app_root_path = ARGV[3] ? ARGV[3] : ""

options = {
  app_name: "log_daemon",
  dir_mode: :normal,
  dir: "#{app_root_path}/tmp/pids",
  monitor: true
}

Daemons.run('log_daemon_impl.rb', options)

