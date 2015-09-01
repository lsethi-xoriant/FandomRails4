require 'yaml'
require 'logger'
require 'pg'
require 'set'

require_relative "../lib/cli_utils"
include CliUtils

SOURCE_DB_EVENT_CHUNK_SIZE = 10000
DEST_DB_INSERT_CHUNK_SIZE = 1000

def help_and_die
  puts <<-EOF
    Usage: #{$0} <source_environment> <dest_environment> <rails_project_root> <events_up_to>
      <events_up_to> determines the moment up to which events are processed; possible values are: yesterday|now
    EOF
  exit
end  

def main
  if ARGV.size != 4
    help_and_die
  end

  source_environment = ARGV[0]
  dest_environment = ARGV[1]
  rails_project_root = ARGV[2]
  events_up_to = ARGV[3]

  case events_up_to
  when 'yesterday'
    max_timestamp = Date.today.strftime("%Y-%m-%d %H:%M:%S")
  when 'now'
    max_timestamp = Time.now.utc.strftime("%Y-%m-%d %H:%M:%S")
  else
    help_and_die
  end

  database_yaml_path = "#{rails_project_root}/config/database.yml"

  logger = Logger.new("#{rails_project_root}/log/log_archiver.log")

  begin 
    logger.info("archiving process started...")
    db_config = YAML::load(File.open(database_yaml_path))  
    
    source_db_conn = db_connect(db_config[source_environment])
    dest_db_conn = db_connect(db_config[dest_environment])

    tenants = get_tenants(source_db_conn)
    tenants.each do |tenant|
      logger.info("processing tenant #{tenant}... ")
      inserted_count = 0
      fail_count = 0
      start_time = Time.now
      loop do
        events = get_events(tenant, source_db_conn, max_timestamp)
        if events.empty? 
          break
        else
          not_archived_events, already_moved_ids = filter_events_not_already_archived(events, tenant, dest_db_conn)
          if already_moved_ids.any?
            logger.info("cleaning #{already_moved_ids.count} events that have already been stored")
            delete_events_from_db(tenant, already_moved_ids, source_db_conn)
          end
          event_chunks = not_archived_events.each_slice(DEST_DB_INSERT_CHUNK_SIZE)
          event_chunks.each do |event_chunk|
            begin
              columns, values, ids = generate_data_for_sql_insert_query(dest_db_conn, event_chunk)
              insert_events_in_db(columns, values, dest_db_conn, logger)
              inserted_count += event_chunk.count
              delete_events_from_db(tenant, ids, source_db_conn)
              
            rescue Exception => exception
              fail_count += 1
              logger.error("exception in chunk processing: #{exception} - #{exception.backtrace}")
              exit
            end
          end
        end
      end
      logger.info("moved #{inserted_count} events; there were #{fail_count} failures; time: #{Time.now - start_time} s")
    end
    logger.info("archiving process ended.")
  rescue Exception => exception
    logger.error("toplevel exception: #{exception} - #{exception.backtrace}")
  end
end

def get_tenants(db_conn)
  tenants = db_conn.exec("select table_schema from information_schema.tables where table_name = 'events'").map do |row|
    row['table_schema']
  end
  tenants.select { |t| t != 'public' }
end

def get_events(tenant, db_conn, max_timestamp)
  sql_query = 
    "SELECT * FROM #{tenant}.events " +
    "WHERE timestamp < '#{max_timestamp}' " + 
    "ORDER BY id ASC " +
    "LIMIT #{SOURCE_DB_EVENT_CHUNK_SIZE};"
  db_conn.exec(sql_query).to_a
end

def filter_events_not_already_archived(events, tenant, dest_db_conn)
  event_ids = events.map { |event| event['id'] }
  event_ids_str = event_ids.join(', ')
  sql_query = 
    "SELECT orig_id FROM events " +
    "WHERE tenant = '#{tenant}' AND orig_id IN (#{event_ids_str})"
  rows = dest_db_conn.exec(sql_query)
  already_moved = Set.new(rows.map { |row| row['orig_id'] })
  
  not_archived_events = []
  already_moved_ids = []
  events.each do |event| 
    if already_moved.include?(event['id'])
      already_moved_ids << event['id']
    else
      not_archived_events << event
    end
  end
  [not_archived_events, already_moved_ids]
end

def delete_events_from_db(tenant, ids, source_db_conn)
  sql_query = "DELETE FROM #{tenant}.events WHERE id IN (#{ids.join(', ')});"
  source_db_conn.exec(sql_query)
end

def insert_events_in_db(columns, values, dest_db_conn, logger)
  sql_query = "INSERT INTO events (#{columns.join(', ')}) VALUES #{values};"
  dest_db_conn.exec(sql_query)
end

def generate_data_for_sql_insert_query(db_conn, events)
  columns = events.first.map{ |key, value| key == "id" ? "orig_id" : key }
  ids = events.map { |e| e['id'] }
  # values are produced in the same order as columns
  values = events.map do |e| 
    tuple = columns.map do |column|
      key = column == 'orig_id'? 'id' : column
      e[key].nil? ? "null" : "'#{db_conn.escape_string(e[key])}'"      
    end  
    "(#{tuple.join(', ')})"
  end
  [columns, values.join(', '), ids]
end

main()