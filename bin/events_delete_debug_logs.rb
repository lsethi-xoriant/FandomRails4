require "pg"
require "yaml"
require "logger"

def main

  if ARGV.size != 1
    puts <<-EOF
      This script deletes debug logs from log archive, processing them by chunks.
      Usage: #{$0} <config.yml>
      config.yml file must define events_db, rails_app_dir, events_chunk_size and starting_timestamp (optional)
    EOF
    exit
  end

  config = YAML.load_file(ARGV[0].to_s)

  rails_app_dir = config["rails_app_dir"]
  events_chunk_size = config["events_chunk_size"]
  timestamps_lower_limit = config["starting_timestamp"]

  events_conn = PG::Connection.open(config["events_db"])

  logger = Logger.new("#{rails_app_dir}/log/events_delete_debug_logs.log")

  if !timestamps_lower_limit
    logger.info("retrieving first event timestamp...")
    start_time = Time.now

    timestamps_lower_limit = events_conn.exec(
      "SELECT timestamp
      FROM events
      WHERE level = 'debug' 
      ORDER BY timestamp ASC
      LIMIT 1"
    ).first["timestamp"]

    logger.info("first event timestamp achieved in #{Time.now - start_time} seconds (#{timestamps_lower_limit})")
  end

  logger.info("debug events deletion process starting...")

  begin
    logger.info("starting a new chunk deletion")
    timestamps_lower_limit = delete_events_chunk(events_conn, timestamps_lower_limit, events_chunk_size, logger)
  rescue => e
    logger.info("exception rescued: #{e.inspect}\n#{e.backtrace}")
  end

end

def delete_events_chunk(events_conn, timestamps_lower_limit, events_chunk_size, logger)

  start_time = Time.now
  logger.info("retrieving chunk timestamps interval")

  chunk_timestamps = events_conn.exec(
    "SELECT timestamp 
    FROM events 
    WHERE timestamp >= '#{timestamps_lower_limit}' 
    AND level = 'debug' 
    ORDER BY timestamp ASC 
    LIMIT #{events_chunk_size}"
  ).to_a

  logger.info("chunk timestamps interval gained in #{Time.now - start_time} seconds")

  if chunk_timestamps.any?
    min_chunck_timestamp = chunk_timestamps.first["timestamp"]
    max_chunck_timestamp = chunk_timestamps.last["timestamp"]

    logger.info("deleting events between #{min_chunck_timestamp} and #{max_chunck_timestamp}")
    start_time = Time.now

    delete = events_conn.exec(
      "DELETE FROM events 
      WHERE level = 'debug' 
      AND timestamp BETWEEN '#{min_chunck_timestamp}' AND '#{max_chunck_timestamp}'"
    )

    logger.info("#{delete.cmd_tuples()} rows successfully deleted in #{Time.now - start_time} seconds")
  else
    logger.info("no events found, now exit")
    exit
  end

  return max_chunck_timestamp

end

main()