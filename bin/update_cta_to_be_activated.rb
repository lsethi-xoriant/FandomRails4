require 'yaml'
require 'pg'

def help_message
  <<-EOF
  Usage: #{$0} <configuration_file_path>
  EOF
end

def main

  if ARGV.count < 1
    puts help_message
    exit
  end

  now = Time.now
  puts "Call to action update activated_at started at #{now}"

  config = YAML.load_file(ARGV[0].to_s)
  conn = PG::Connection.open(config["db"])
  now_in_utc = now.utc

  tenants = []
  conn.exec("SELECT nspname FROM pg_namespace").each do |value|
    unless (value["nspname"].start_with?("pg_") or value["nspname"] == "public" or value["nspname"] == "information_schema")
      tenants << value["nspname"]
    end
  end
  puts "Updating call to actions to be activated for the following tenants: #{tenants.join(",")}"

  tenants.each do |tenant|
    puts "Start #{tenant} call to actions updating"
    start_time = Time.now
    res = conn.exec(
      "UPDATE #{tenant}.call_to_actions 
      SET updated_at = '#{now_in_utc}' 
      WHERE activated_at < '#{now_in_utc}' 
      AND updated_at < activated_at"
    )
    puts "#{res.cmd_tuples()} #{tenant} call to actions updated in #{Time.now - start_time} seconds"
    sleep(1)
  end

  puts "All tenants call to actions updated"

end

main()