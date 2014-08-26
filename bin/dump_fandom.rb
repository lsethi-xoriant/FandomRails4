# Dump a fandom DB and the related attachments into a tar.gz archive in /tmp with the specified name

require("yaml")

def main
  if ARGV.size < 3
    puts <<-EOF
Usage: #{$0} <environment> <fandom_path> <archive_name>
  Dump a fandom DB and the related attachments into a tar.gz archive in /tmp with the specified name 
EOF
    exit
  end
  
  environment = ARGV[0]
  fandom_path = ARGV[1]
  archive_name = ARGV[2]
  
  db = YAML.load_file("#{fandom_path}/config/database.yml")[environment]
  username = db.key?('username')? "-U #{db['username']}" : "" 
  host = db.key?('host')? "-h #{db['host']}" : "" 
  
  run_or_die("mkdir /tmp/#{archive_name}")
  run_or_die("pg_dump #{username} #{host} #{db['database']} > /tmp/#{archive_name}/db.sql")
  run_or_die("cp -a #{fandom_path}/public/system /tmp/#{archive_name}/")
  run_or_die("cd /tmp ; tar czf #{archive_name}.tgz #{archive_name}")
  run_or_die("rm -rf /tmp/#{archive_name}")
    
end

def run_or_die(cmd)
  result = system(cmd)
  unless result
    raise "command failed: #{cmd}"
  end
end

main()