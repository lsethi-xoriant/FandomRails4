require 'yaml'
require 'logger'
require 'pg'
require 'set'
require "aws-sdk-v1"

require_relative "../lib/cli_utils"
include CliUtils

def help_and_die
  puts <<-EOF
    Usage: #{$0} <rails_project_root> <config_yaml_path>
      This script saves each entry of an events table into a big json file (1 json object per line), gzip it and store it into
      a remote S3 folder. It is typically used to store contests data in an italian server.  
    EOF
  exit
end  

def main
  if ARGV.size != 2
    help_and_die
  end

  rails_project_root = ARGV[0]
  config_yaml_path = ARGV[1]

  logger = Logger.new("#{rails_project_root}/log/log_archiver_json.log")

  begin 
    logger.info("archiving process started...")
    config = YAML::load(File.open(config_yaml_path))  
    
    db_conn = db_connect(config['events_database'])
    bucket = get_s3_bucket(config['s3_settings'])
    tenant = config['tenant']
    
    while true
      last_timestamp = bucket.objects["last_timestamp"].read()
      events = get_events(db_conn, last_timestamp)
      if events.empty?
        logger.info("no more events to archive.")
        break
      else
        buffer = StringIO.new
        new_timestamp = events[0]['timestamp']
        new_timestamp_file_postfix = new_timestamp.gsub(' ', '__').gsub(':', '-').gsub('.', '__')
        dir = new_timestamp.split(" ")[0]
              
        count = 0 
        events.each do |event|
          if event['tenant'] == tenant
            count += 1
            event['data'] = JSON.load(event['data'])
            buffer.write(JSON.dump(event))
            buffer.write("\n")
          end
        end
        
        bucket.objects["#{dir}/log__#{new_timestamp_file_postfix}.gz"].write(gzip_string(buffer.string), :sigle_request => true)
        bucket.objects["last_timestamp"].write(new_timestamp, :sigle_request => true)
        logger.info("archived #{count} events.")
      end
    end
  rescue Exception => exception
    logger.error("toplevel exception: #{exception} - #{exception.backtrace}")
  end
end

def gzip_string(string)
  StringIO.open do |f|
    gz = Zlib::GzipWriter.new(f)
    gz.write(string)
    gz.close
    f.string
  end
end

def get_events(db_conn, max_timestamp)
  sql_query = 
    "SELECT * FROM events WHERE 
    timestamp > '#{max_timestamp}' AND timestamp < ( ('#{max_timestamp}'::timestamp) + ('1 hour'::interval))
    ORDER BY timestamp DESC"
  db_conn.exec(sql_query).to_a
end

main()