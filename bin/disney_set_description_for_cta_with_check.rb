# 
# This thrown-away script has been used to fix the launch of disney channel site on January 30th 2015
# It just set a couple of fields in the DB according to some JSON file
#

require 'yaml'
require 'json'
require 'pg'

def help_message
  <<-EOF
  Usage: #{$0} <configuration_file_path> <json_file> <dryrun>
  EOF
end

def main

  if ARGV.count < 3
    puts help_message
    exit
  end

  config = YAML.load_file(ARGV[0].to_s)
  json_object = JSON.parse(File.open(ARGV[1]).read)
  dryrun = ARGV[2] != "false"

  msg = dryrun ? 'dryrun' : 'for real'
  puts "starting: #{msg}"

  conn = PG::Connection.open(config['db'])

  count = 0
  json_object.each do |obj|
    title =  obj['title']
    description = obj['description']
    if dryrun
      result = execute_query(conn, "SELECT id FROM disney.call_to_actions WHERE title ilike '%#{nullify_or_escape_string(conn, title)}%'")
      if result.cmd_tuples == 0
        count += 1
      end
    else 
      query = "UPDATE disney.call_to_actions SET description = '#{nullify_or_escape_string(conn, description)}' WHERE title == '%#{nullify_or_escape_string(conn, title)}%'"
      execute_query(conn, query)
      puts query
    end
  end

  if dryrun
    puts "#{count} titles have not been found"
  end
end

def execute_query(connection, query)
  connection.exec(query)        
end

def nullify_or_escape_string(conn, str)
  if str.nil?
    "NULL"
  else
    conn.escape_string(str)
  end
end


main()
