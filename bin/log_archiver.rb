require 'rubygems'
require 'active_record'
require 'yaml'
require 'logger'

SOURCE_DB_EVENT_CHUNK_SIZE = 1000
DEST_DB_INSERT_CHUNK_SIZE = 100

def main

  if ARGV.size != 3
    puts <<-EOF
      Usage: #{$0} <source_environment> <dest_environment> <rails_project_root>
        <tenant> is the database schema that will be used for the current job.
      EOF
    exit
  end

  source_environment = ARGV[0]
  dest_environment = ARGV[1]
  rails_project_root = ARGV[2]

  database_yaml_path = "#{rails_project_root}/config/database.yml"

  logger = Logger.new("#{rails_project_root}/log/log_archiver.log")

  today_timestamp = Date.today.strftime("%Y-%m-%d %H:%M:%S")

  begin 

    db_conn = establish_connection_with_db(database_yaml_path, "source")
    
    tenants = get_tenants(db_conn)
    puts tenants

    exit
    sql_query = 
      "SELECT * FROM #{tenant}.events " +
      "WHERE timestamp<'#{today_timestamp}' " + 
      "ORDER BY timestamp ASC " +
      "LIMIT #{SOURCE_DB_EVENT_CHUNK_SIZE};"

    events = db_conn.connection.execute(sql_query)

=begin
    events = filter_events_not_already_archived(events, database_yaml_path, tenant)
    event_chunks = make_chunks(events, MAX_INSERT_NUMBER_IN_DB)
    event_chunks.each do |event_chunk|
      columns, values = generate_data_for_sql_insert_query(events)
      store_events_in_db(database_yaml_path, tenant, columns, values_for_next_insert, ids, logger)
      puts "\t#{values_for_next_insert.count} INSERT in destination database"
    end
=end

    if events.any?

      columns, values, ids = generate_data_for_sql_insert_query(events)
      ids_stored = events_ids_stored(database_yaml_path, ids, tenant)

      puts "#{values.count} TO INSERT in destination database"

      index = 0
      values_for_next_insert = Array.new
      values.each do |value|
        
        unless ids_stored.include?(value["id"])
          values_for_next_insert << "(#{value.map{ |key, value| generate_insert_single_value_quote(value) }.join(', ')})" 
          index += 1
        end

        if (index != 0 && index % DEST_DB_INSERT_CHUNK_SIZE == 0) || value["id"] == values.last["id"]
          store_events_in_db(database_yaml_path, tenant, columns, values_for_next_insert, ids, logger)
          puts "\t#{values_for_next_insert.count} INSERT in destination database"
          values_for_next_insert.clear
        end

      end

    end

  end while events.present? && events.any?

end

def get_tenants(db_conn)
  db_conn.connection.execute("select table_schema from information_schema.tables where table_name = 'events'").map do |row|
    row['table_schema']
  end
end


def events_ids_stored(database_yaml_path, current_events_ids, tenant)
  db_conn = establish_connection_with_db(database_yaml_path, "destination")
  sql_query = "SELECT orig_id FROM #{tenant}.events WHERE orig_id IN (#{current_events_ids.join(', ')}) AND tenant=#{ActiveRecord::Base.connection.quote(tenant)}"
  ids_stored = db_conn.connection.execute(sql_query).map{ |result| result["orig_id"] }
end

def store_events_in_db(database_yaml_path, tenant, columns, values_for_next_insert, events_to_insert_ids, logger)
  db_conn = establish_connection_with_db(database_yaml_path, "destination")
  insert_events_in_db(tenant, columns, values_for_next_insert, db_conn, logger)

  db_conn = establish_connection_with_db(database_yaml_path, "source")
  delete_events_from_db(tenant, events_to_insert_ids, db_conn)
end

def delete_events_from_db(tenant, ids, db_conn)
  sql_query = "DELETE FROM #{tenant}.events WHERE id IN (#{ids.join(', ')});"
  db_conn.connection.execute(sql_query)
end

def insert_events_in_db(tenant, columns, values, db_conn, logger)
  sql_query = "INSERT INTO #{tenant}.events (#{columns.join(', ')}) VALUES #{values.join(', ')};"
  begin
    db_conn.connection.execute(sql_query)
  rescue Exception => exception
    logger.error "#{exception}"
  end

end

def generate_data_for_sql_insert_query(events)
  columns = events.first.map{ |key, value| key == "id" ? "orig_id" : key }

  ids = Array.new
  values = Array.new
  events.each do |event|
    ids << event["id"]
    values << event
  end

  [columns, values, ids]
end

def generate_insert_single_value_quote(value)
  value.present? ? ActiveRecord::Base.connection.quote(value.to_s) : "null"
end

def establish_connection_with_db(database_yaml_path, database)
  dbconfig = YAML::load(File.open(database_yaml_path))  
  ActiveRecord::Base.establish_connection(dbconfig[database])
end

main()