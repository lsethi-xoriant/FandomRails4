#
# This module implements a long running process (that should be "demonized" with a tool such as supervisord) 
# that scan the log/events directory for new log entries and save them in a specific table in 
# the rails application db.
# 

require 'rubygems'
require 'active_record'
require 'yaml'
require 'logger'
require 'sys/proctable'
require 'socket'

EVENTS_COLUMNS = ['user_id', 'tenant', 'message', 'level', 'data', 'pid', 'session_id', 'request_uri', 'timestamp']
EVENTS_COLUMNS_STRING = EVENTS_COLUMNS.join(', ') 
TIMESTAMP_FMT = "%Y%m%d_%H%M%S_%N"

def help_message
  <<-EOF
Usage: #{$0} <env> <rails_root_project> <loop_delay>
  <env> is the environment for database configuration set in <rails_root_project>/config/database.yml.
  <rails_root_project> is used also for find log files that are stored in <rails_root_project>/log/events.
  <loop_delay> is the daemon loop time in seconds.
  EOF
end

$GOT_SIGTERM = false

def main
  if ARGV.count < 3
    puts help_message
    exit
  end
    
  env = ARGV[0]
  app_root_path = ARGV[1]
  logger = Logger.new("#{app_root_path}/log/log_daemon.log")
  loop_delay = ARGV[2].to_i

  begin
    logger.info "Daemon start with loop_delay #{loop_delay}s"

    database_yaml_path = "#{app_root_path}/config/database.yml"
    base_db_connection = establish_connection_with_db(database_yaml_path, env)

    event_logs_path = "#{app_root_path}/log/events"
    loop do
      begin
        # If directory does not exist perhaps rails as not been started yet. Waiting not it.
        close_orphan_files(event_logs_path, logger)
        closed_event_log_files(event_logs_path).each do |process_file_path|
          begin
            pid, timestamp = extract_pid_and_timestamp_from_path(process_file_path)
            tenant_to_insert_values, tenant_to_content_type_to_id_to_views = get_query_data(process_file_path, pid)
            sql_queries = generate_sql_insert_queries(tenant_to_insert_values, pid, timestamp)

            conn = base_db_connection.connection
            execute_query(conn, 'BEGIN')
            execute_query(conn, sql_queries)
            execute_update_counters(conn, tenant_to_content_type_to_id_to_views)
            execute_query(conn, 'COMMIT')
            
            delete_process_file(process_file_path)
          rescue ActiveRecord::RecordNotUnique => exception      
            # if the file that contains log events has already been saved, an exception RecordNotUnique is raised.
            # In this case the file will be deleted, because it means that it has already been saved in the past.
            delete_process_file(process_file_path)        
            logger.error("file '#{process_file_path}' has already been saved; deleting it")
          rescue Exception => exception
            rename_file_path_part(process_file_path, 'closed', 'error', logger)        
            logger.error("exception while processing file '#{process_file_path}': #{exception} - #{exception.backtrace[0, 5]}")
          end
        end
      rescue Exception => exception
        logger.error("exception in main loop: #{exception} - #{exception.backtrace[0, 5]}")
      end

      if $GOT_SIGTERM
        logger.info("got SIGTERM, exiting gracefully")
        break
      else
        sleep(loop_delay)
      end
    end
  rescue Exception => exception
    logger.error("exception in main loop: #{exception} - #{exception.backtrace[0, 5]}")
  end
end

def execute_query(connection, query)
  begin
    connection.execute(query)        
  rescue Exception => exception
    connection.execute("ROLLBACK;")
    raise
  end
end

Signal.trap("TERM") {
  $GOT_SIGTERM = true
}

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

def get_query_data(process_file_path, pid)
  tenant_to_insert_values = Hash.new
  tenant_to_content_type_to_id_to_views = Hash.new

  process_file_descriptor = File.open(process_file_path, 'r')
  
  request_data = init_request_data(pid)
  process_file_descriptor.each_line do |event_log_line|
    event_values = JSON.parse(event_log_line)

    unless event_values["data"]["already_synced"]
      if event_values['message'] == 'http request start'
        request_data = get_request_data(event_values, pid)
      end
      event_values.merge!(request_data)
      
      tenant = event_values["share_db"].nil? ? event_values["tenant"] : event_values["share_db"]
      (tenant_to_insert_values[tenant] ||= []) << "(#{get_values_for_event_log_line(event_values)})" 

      if event_values['message'] == 'content viewed' # the related constant is not accessible in this source file
        content_id = event_values['data']['id']
        content_type = event_values['data']['type']
        ((tenant_to_content_type_to_id_to_views[tenant] ||= {})[content_type] ||= {})[content_id] ||= 0
        tenant_to_content_type_to_id_to_views[tenant][content_type][content_id] += 1
      end
    end
  end

  tenant_to_insert_values.each do |k, vs|
    tenant_to_insert_values[k] = vs.join(", ")
  end
  
  [tenant_to_insert_values, tenant_to_content_type_to_id_to_views]  
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
    'share_db' => event_values['data']['share_db'],
    'user_id' => event_values['data']['user_id'],
    'pid' => pid
  }  
end

def get_values_for_event_log_line(event_values)
  values_for_event_log_line = Array.new
  EVENTS_COLUMNS.each do |column|
    value = event_values[column]
    case column
    when "data"
      values_for_event_log_line << ActiveRecord::Base.connection.quote(value.to_json)
    when "pid", "user_id"
      values_for_event_log_line << value
    else
      values_for_event_log_line << ActiveRecord::Base.connection.quote(value.to_s[0..254])
    end
  end
  values_for_event_log_line.join(', ')
end

def generate_sql_insert_queries(tenant_to_insert_values, pid, timestamp)  
  insert_columns_for_event = EVENTS_COLUMNS_STRING
  insert_columns_for_synced_log_files = "pid, server_hostname, timestamp"

  sql_queries = []
  tenant_to_insert_values.each do |tenant, value| 
    if tenant != "no_tenant"
      timestamp_db = Time.strptime(timestamp, TIMESTAMP_FMT).strftime("%Y-%m-%d %H:%M:%S.%N")
      server_hostname = ActiveRecord::Base.connection.quote(Socket.gethostname)
      pid_quote = ActiveRecord::Base.connection.quote(pid)
  
      insert_values_for_synced_log_files = "#{pid_quote}, #{server_hostname}, '#{timestamp_db}'"
  
      sql_queries << "INSERT INTO #{tenant}.synced_log_files (#{insert_columns_for_synced_log_files}) VALUES (#{insert_values_for_synced_log_files});"
      sql_queries << "INSERT INTO #{tenant}.events (#{insert_columns_for_event}) VALUES #{value};"
    end
  end
  
  sql_queries.join(' ')
end

def execute_update_counters(connection, tenant_to_content_type_to_id_to_views)
  tenant_to_content_type_to_id_to_views.each do |tenant, content_type_to_id_to_views|
    content_type_to_id_to_views.each do |type, id_to_views|
      id_to_views.each do |ref_id, view_count|
        query = "UPDATE #{tenant}.view_counters SET counter = counter + #{view_count}, updated_at = now() WHERE ref_type = '#{type}' AND ref_id = #{ref_id};"
        result = execute_query(connection, query)
        if result.cmd_tuples == 0
          query = "INSERT INTO #{tenant}.view_counters (ref_type, ref_id, counter, created_at, updated_at) VALUES ('#{type}', #{ref_id}, #{view_count}, now(), now())"
          execute_query(connection, query)
        end
      end
    end
  end
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