require 'rubygems'
require 'active_record'
require 'yaml'
require 'logger'
require 'sys/proctable'

def main

  loop_delay = ARGV[2].to_i
  puts "Daemon start with loop_delay #{loop_delay}s"

  app_root_path = ARGV[1]
  database_yaml_path = "#{app_root_path}/config/database.yml"
  env = ARGV[0] ? ARGV[0] : "production"
  base_db_connection = establish_connection_with_db(database_yaml_path, env)

  event_logs_path = "#{app_root_path}/log/events"
  event_directory_exist = File.directory?(event_logs_path)

  logger = Logger.new("#{app_root_path}/log/log_daemon.log")

  loop do
    # If directory does not exist perhaps rails as not been started yet. Waiting not it.
    if event_directory_exist
      close_orphan_files(event_logs_path, logger)

      closed_event_log_files(event_logs_path).each do |process_file_path|
        
        insert_values_for_event = generate_sql_insert_values_for_event(process_file_path)
        pid, timestamp = extract_pid_and_timestamp_from_path(process_file_path)
      
        begin
          sql_query = generate_sql_insert_query(insert_values_for_event, pid, timestamp)

          base_db_connection.connection.execute(sql_query)        

          delete_process_file(process_file_path)
        rescue ActiveRecord::RecordNotUnique => exception      
          # if the file that contains log events has already been saved, an exception RecordNotUnique is raised.
          # In this case the file will be deleted, because it means that it does  already saved in the past.
          base_db_connection.connection.execute("ROLLBACK;")
          delete_process_file(process_file_path)        
          logger.error exception
        rescue Exception => exception
          base_db_connection.connection.execute("ROLLBACK;")
          mark_file_with_errors(event_logs_path, process_file_path)        
          logger.error exception
        end

      end
    end

    sleep(loop_delay)
  end
end

def close_orphan_files(event_logs_path, logger)
  active_pids = Sys::ProcTable.ps.map { |process| process.pid }

  opened_event_log_files(event_logs_path).each do |log_file_name|
    pid, timestamp = extract_pid_and_timestamp_from_path(log_file_name)
    if !active_pids.include?(pid)
      destination_log_file_name = "#{event_logs_path}/#{pid}-#{timestamp}-close.log"

      begin
        File.rename(log_file_name, destination_log_file_name)
      rescue Exception => exception
        # it may be that rails closed the same file at the same time. This error condition can safely be ignored.
        logger.error exception
      end

    end
  end
end

def mark_file_with_errors(event_logs_path, process_file_path)
  pid, timestamp = extract_pid_and_timestamp_from_path(process_file_path)
  destination_log_file_name = "#{event_logs_path}/#{pid}-#{timestamp}-error.log"

  begin
    File.rename(process_file_path, destination_log_file_name)
  rescue Exception => exception
    # it may be that rails closed the same file at the same time. This error condition can safely be ignored.
    logger.error exception
  end
end

def extract_pid_and_timestamp_from_path(process_file_path)
  process_file_name = process_file_path.sub(".log", "").split("/").last
  pid, timestamp, status = process_file_name.split("-")

  [pid.to_i, timestamp]
end

def generate_sql_insert_values_for_event(process_file_path)
  insert_values_for_event = Hash.new

  process_file_descriptor = File.open(process_file_path,'r')
  
  values_for_event = Array.new
  tenant = nil
  process_file_descriptor.each_line do |event_log_line|
    event_log_line_json = JSON.parse(event_log_line)

    unless event_log_line_json["data"]["already_synced"]
      tenant = event_log_line_json["tenant"]
      values_for_event << "(#{generate_values_for_event_log_line(event_log_line_json)})"
    end

  end

  if values_for_event.any? && tenant.present?
    insert_values_for_event[tenant] = values_for_event.join(", ")
  end

  insert_values_for_event

end

def generate_values_for_event_log_line(event_log_line_json)
  values_for_event_log_line = Array.new
  event_log_line_json.each do |key, value|
    case key
    when "data"
      values_for_event_log_line << ActiveRecord::Base.connection.quote(value.to_json)
    when "pid", "user_id"
      values_for_event_log_line << value
    else
      values_for_event_log_line << ActiveRecord::Base.connection.quote(value.to_s[0..244])
    end
  end
  values_for_event_log_line.join(', ')
end

def generate_sql_insert_query(insert_values_for_event, pid, timestamp)
  insert_columns_for_event = "user_id, tenant, message, level, data, pid, session_id, request_uri, line_number, file_name, method_name, timestamp"
  insert_columns_for_synced_log_files = "pid, server_hostname, timestamp"

  sql_query = "BEGIN;"
  insert_values_for_event.each do |tenant, value| 
    if tenant != "no_tenant"
      timestamp_quote = ActiveRecord::Base.connection.quote(Time.parse(timestamp).utc)
      tenant_quote = ActiveRecord::Base.connection.quote(tenant)
      pid_quote = ActiveRecord::Base.connection.quote(pid)
  
      insert_values_for_synced_log_files = "#{pid_quote}, #{tenant_quote}, #{timestamp_quote}"
  
      sql_query << "INSERT INTO #{tenant}.synced_log_files (#{insert_columns_for_synced_log_files}) VALUES (#{insert_values_for_synced_log_files});"
      sql_query << "INSERT INTO #{tenant}.events (#{insert_columns_for_event}) VALUES #{value};"
    end
  end
  sql_query << "COMMIT;"

  sql_query
end

def closed_event_log_files(event_logs_path)
  Dir["#{event_logs_path}/*-*-close.log"]
end

def opened_event_log_files(event_logs_path)
  Dir["#{event_logs_path}/*-*-open.log"]
end

def delete_process_file(process_file_path)
  File.delete(process_file_path)
end

def establish_connection_with_db(database_yaml_path, env)
  dbconfig = YAML::load(File.open(database_yaml_path))  
  ActiveRecord::Base.establish_connection(dbconfig[env])
end

main()