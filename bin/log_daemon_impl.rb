require 'rubygems'
require 'active_record'
require 'yaml'
require 'logger'
require 'sys/proctable'
require 'socket'

EVENTS_COLUMNS = ['user_id', 'tenant', 'message', 'level', 'data', 'pid', 'session_id', 'request_uri', 'timestamp']
EVENTS_COLUMNS_STRING = EVENTS_COLUMNS.join(', ') 
TIMESTAMP_FMT = "%Y%m%d_%H%M%S_%N"

def main
  begin
    app_root_path = ARGV[1]
    raise "ciao"
    loop_delay = ARGV[2].to_i
    puts "Daemon start with loop_delay #{loop_delay}s"

    database_yaml_path = "#{app_root_path}/config/database.yml"
    env = ARGV[0] ? ARGV[0] : "production"
    base_db_connection = establish_connection_with_db(database_yaml_path, env)

    event_logs_path = "#{app_root_path}/log/events"

    logger = Logger.new("#{app_root_path}/log/log_daemon.log")

    loop do
      begin
        # If directory does not exist perhaps rails as not been started yet. Waiting not it.
        close_orphan_files(event_logs_path, logger)
        closed_event_log_files(event_logs_path).each do |process_file_path|
          pid, timestamp = extract_pid_and_timestamp_from_path(process_file_path)
          insert_values_for_event = generate_sql_insert_values_for_event(process_file_path, pid)
          begin
            sql_query = generate_sql_insert_query(insert_values_for_event, pid, timestamp)

            base_db_connection.connection.execute(sql_query)        

            delete_process_file(process_file_path)
          rescue ActiveRecord::RecordNotUnique => exception      
            # if the file that contains log events has already been saved, an exception RecordNotUnique is raised.
            # In this case the file will be deleted, because it means that it has already been saved in the past.
            base_db_connection.connection.execute("ROLLBACK;")
            delete_process_file(process_file_path)        
            logger.error exception
          rescue Exception => exception
            base_db_connection.connection.execute("ROLLBACK;")
            rename_file_path_part(process_file_path, 'closed', 'error', logger)        
            logger.error("exception: #{exception} - #{exception.backtrace[0, 5]}")
          end
        end
      rescue Exception => exception
        logger.error("exception in main loop: #{exception} - #{exception.backtrace[0, 5]}")
      end

      sleep(loop_delay)
    end
  rescue Exception => ex
    File.open("#{app_root_path}/log/log_daemon.log", 'a') do |f|
      f.puts("daemons died unexpectedly: #{ex.to_s} - #{ex.backtrace[0, 5]}")
      f.flush
    end
  end
end

# Returns all open files in a hash indexed by pid, where the related file names are sorted lexicographically
# (since all filenames with the same pid have the same length, this is the same as numeric sorting)
def get_pid_to_sorted_file_names(event_logs_path)
  result = {}
  opened_event_log_files(event_logs_path).each do |log_file_name|
    pid, timestamp = extract_pid_and_timestamp_from_path(log_file_name)
    (result[pid] ||= []) << log_file_name
  end
  result.each do |pid, file_name|
    result[pid].sort!    
  end
  result
end

def close_orphan_files(event_logs_path, logger)
  active_pids = Set.new(Sys::ProcTable.ps.map { |process| process.pid })
  get_pid_to_sorted_file_names(event_logs_path).each do |pid, log_file_names|
    # in the rare chance (if possible at all) of a process that dies and another respawn with the same pid, 
    # there could be two log files with the same pid and different timestamps; only the most recent should be kept,
    # all others should be collected as orphans
    if active_pids.include?(pid)
      log_file_names = log_file_names[0..-2]
    end

    log_file_names.each do |log_file_name|
      logger.info "closing orphan file: #{log_file_name}"
      rename_file_path_part(log_file_name, 'open', 'closed', logger)
    end  
  end
end

def rename_file_path_part(file_path, from, to, logger)
  begin
    parts = file_path.split('/')
    parts[-1] = parts[-1].sub(from, to)
    dest_path = parts.join('/')
    File.rename(file_path, dest_path)
  rescue Exception => exception
    logger.error exception
  end
end

def extract_pid_and_timestamp_from_path(process_file_path)
  process_file_name = process_file_path.sub(".log", "").split("/").last
  pid, timestamp, status = process_file_name.split("-")

  [pid.to_i, timestamp]
end

def generate_sql_insert_values_for_event(process_file_path, pid)
  tenant_to_insert_values = Hash.new

  process_file_descriptor = File.open(process_file_path, 'r')
  
  request_data = init_request_data(pid)
  process_file_descriptor.each_line do |event_log_line|
    event_values = JSON.parse(event_log_line)

    unless event_values["data"]["already_synced"]
      if event_values['message'] == 'http request start'
        request_data = get_request_data(event_values, pid)
      end
      event_values.merge!(request_data)
      
      tenant = event_values["tenant"]
      (tenant_to_insert_values[tenant] ||= []) << "(#{generate_values_for_event_log_line(event_values)})" 
    end
  end

  result = {}
  tenant_to_insert_values.each do |k, vs|
    result[k] = vs.join(", ")
  end
  
  result  
end

def init_request_data(pid)
  { 'request_uri' => 'unknown',
    'method' => 'unknown',
    'params' => '{}',
    'http_referer' => 'unknown',
    'session_id' => 'unknown',
    'remote_ip' => 'unknown',
    'tenant' => 'no_tenant',
    'user_id' => 'unknown',
    'pid' => pid
  }  
end

def get_request_data(event_values, pid)
  { 'request_uri' => event_values['data']['request_uri'],
    'method' => event_values['data']['method'],
    'params' => event_values['data']['params'],
    'http_referer' => event_values['data']['http_referer'],
    'session_id' => event_values['data']['session_id'],
    'remote_ip' => event_values['data']['remote_ip'],
    'tenant' => event_values['data']['tenant'],
    'user_id' => event_values['data']['user_id'],
    'pid' => pid
  }  
end

def generate_values_for_event_log_line(event_values)
  values_for_event_log_line = Array.new
  EVENTS_COLUMNS.each do |column|
    value = event_values[column]
    case column
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
  insert_columns_for_event = EVENTS_COLUMNS_STRING
  insert_columns_for_synced_log_files = "pid, server_hostname, timestamp"

  sql_query = "BEGIN;"
  insert_values_for_event.each do |tenant, value| 
    if tenant != "no_tenant"
      timestamp_db = Time.strptime(timestamp, TIMESTAMP_FMT).strftime("%Y-%m-%d %H:%M:%S.%N")
      server_hostname = ActiveRecord::Base.connection.quote(Socket.gethostname)
      pid_quote = ActiveRecord::Base.connection.quote(pid)
  
      insert_values_for_synced_log_files = "#{pid_quote}, #{server_hostname}, '#{timestamp_db}'"
  
      sql_query << "INSERT INTO #{tenant}.synced_log_files (#{insert_columns_for_synced_log_files}) VALUES (#{insert_values_for_synced_log_files});"
      sql_query << "INSERT INTO #{tenant}.events (#{insert_columns_for_event}) VALUES #{value};"
    end
  end
  sql_query << "COMMIT;"

  sql_query
end

def closed_event_log_files(event_logs_path)
  Dir["#{event_logs_path}/*-*-close*.log"]
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