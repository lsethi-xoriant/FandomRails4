require "pg"
require "yaml"
require 'logger'

def main

  if ARGV.size != 1
    puts <<-EOF
      This script deletes debug logs from log archive, processing them by chunks.
      Usage: #{$0} <config.yml>
      config.yml file must define events_db, rails_app_dir, tenant, events_chunk_size and sleep_time
    EOF
    exit
  end

  config = YAML.load_file(ARGV[0].to_s)

  rails_app_dir = config["rails_app_dir"]
  tenant = config["tenant"]
  events_chunk_size = config["events_chunk_size"]
  sleep_time = config["sleep_time"]

  events_conn = PG::Connection.open(config["events_db"])

  logger = Logger.new("#{rails_app_dir}/log/events_delete_debug_logs.log")

  logger.info("deleting debug logs process starting...")

  loop do
    begin
      logger.info("starting a new chunk deletion")
      delete_events_chunk(events_conn, tenant, events_chunk_size, logger)
      logger.info("now taking a #{sleep_time} seconds nap...")
      sleep(sleep_time)
    rescue => e
      logger.info("exception rescued: #{e.inspect}\n#{e.backtrace}")
    end
  end

end

def delete_events_chunk(events_conn, tenant, events_chunk_size, logger)

  logger.info("retrieving chunk timestamps interval")

  chunk_timestamps = events_conn.exec(
    "SELECT timestamp 
    FROM events 
    WHERE tenant = '#{tenant}' 
    AND level = 'debug' 
    ORDER BY timestamp ASC 
    LIMIT #{events_chunk_size}"
  ).to_a

  min_chunck_timestamp = chunk_timestamps.last["timestamp"]
  max_chunck_timestamp = chunk_timestamps.first["timestamp"]

  logger.info("deleting events between #{min_chunck_timestamp} and #{max_chunck_timestamp}")
  start_time = Time.now

  delete = events_conn.exec(
    "DELETE FROM events
    WHERE tenant = '#{tenant}' 
    AND level = 'debug' 
    AND timestamp BETWEEN '#{min_chunck_timestamp}' AND '#{max_chunck_timestamp}'"
  )

  logger.info("#{delete.cmd_tuples()} rows successfully deleted in #{Time.now - start_time} seconds")

end

main()