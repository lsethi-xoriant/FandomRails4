module EventHandlerHelper

  @@process_file_descriptor = nil

  def log_synced(msg, data) 
    log_event(msg, "audit", true, data)
  end

  def log_audit(msg, data)
    log_event(msg, "audit", false, data)
  end

  def log_info(msg, data)
    log_event(msg, "info", false, data)
  end

  def log_error(msg, data)
    log_event(msg, "error", false, data)
  end

  def log_warn(msg, data)
    log_event(msg, "warn", false, data)
  end

  def log_debug(msg, data)
    log_event(msg, "debug", false, data)
  end

  private

  def calculate_event_timestamp()
    Time.new.utc.strftime("%Y-%m-%d %H:%M:%S.%L")
  end

  def log_event(msg, level, force_saving_in_db, data)
    caller_data = caller[1]
    
    timestamp = calculate_event_timestamp()

    begin 

      case Rails.env  
      when "production"
        log_string_for_production(msg, data, caller_data, timestamp, force_saving_in_db, level)
      when "development"
        log_string_for_development = generate_log_string_for_development(msg, data, caller_data, level, timestamp)
        logger_method = level == "audit" ? "info" : level
        Rails.logger.send(logger_method, log_string_for_development)
      else
        # Nothing to do
      end

    rescue Exception => e
      Rails.logger.error("[EventHandlerError] Exception: #{e} - full backtrace:\n#{e.backtrace.join("\n")}")
    end
    
  end

  def generate_log_string_for_development(msg, data, caller_data, level, timestamp)
    file_name, line_number, method_name = parse_caller_data(caller_data)

    if data[:middleware]
      data.delete(:http_referer)
      data.delete(:remote_ip) 
      data.delete(:session_id)
    end

    data_to_string = data.map { |key, value| "#{key}: #{value}" }
    data_to_string = data_to_string.join(", ")

    logger_development = "#{timestamp} [#{level.upcase}] #{file_name}:#{line_number} #{msg} -- #{data_to_string}"
  end

  def log_string_for_production(msg, data, caller_data, timestamp, force_saving_in_db, level)
    pid = Process.pid
    file_name, line_number, method_name = parse_caller_data(caller_data)
    request_uri, session_id, tenant, user_id = catch_top_level_attributes_from_data(data)

    logger_production = Hash.new
    logger_production = {
      "user_id" => user_id,
      "tenant" => tenant,
      "message" => msg,
      "level" => level,
      "data" => data,
      "pid" => pid,
      "session_id" => session_id,
      "request_uri" => request_uri,
      "line_number" => line_number,
      "file_name" => file_name,
      "method_name" => method_name,
      "timestamp" => timestamp
    }

    if force_saving_in_db
      Event.create(session_id: session_id, pid: pid, message: msg, request_uri: request_uri, file_name: file_name, 
        method_name: method_name, line_number: line_number, data: data.to_json, timestamp: timestamp, 
        level: level, tenant: tenant, user_id: user_id)
    else

      may_move_and_open_new_process_log_file(pid, timestamp)
      update_process_log_file(logger_production.to_json)
  
    end

  end  

  def catch_top_level_attributes_from_data(data)
    if data[:middleware]

      session_id = data[:session_id]
      data.delete(:session_id)

      request_uri = data[:request_uri]
      data.delete(:request_uri)

      tenant = data[:tenant] 
      data.delete(:tenant)

      user_id = data[:user_id] 
      data.delete(:user_id)

    else

      request_uri = request.url
      session_id = request.session["session_id"]
      tenant = get_site_from_request(request).try(:id)
      user_id = current_or_anonymous_user.id

    end

    [request_uri, session_id, tenant, user_id]
  end

  def update_process_log_file(log_to_append) 
    @@process_file_descriptor.write(log_to_append)
    @@process_file_descriptor.write("\n")
    @@process_file_descriptor.flush
  end

  def may_move_and_open_new_process_log_file(pid, timestamp)
    log_file_timestamp = Time.parse(timestamp).utc.strftime("%Y%m%d%H%M%S")

    log_directory = "log/events"
    log_file_name = "#{log_directory}/#{pid}-#{log_file_timestamp}-open.log"

    if !File.directory?(log_directory)
      FileUtils.mkdir_p(log_directory)
    end

    if File.exist?(log_file_name) && File.size(log_file_name) > LOGGER_PROCESS_FILE_SIZE
      
      destination_log_file_name = "#{log_directory}/#{pid}-#{timestamp}-close.log"
      File.rename(log_file_name, destination_log_file_name)

    end

    if @@process_file_descriptor.nil?
      close_orphan_files_with_same_current_pid(pid, log_directory)
      @@process_file_descriptor = File.open(log_file_name, "a+")    
    end

  end

  def close_orphan_files_with_same_current_pid(pid, log_directory)
    # check if a file assigned to an old precess with the same pid of current process aready exists.
    # In this case it must be close.
    Dir["#{log_directory}/#{pid}-*-open.log"].each do |orphan_log_file_name|
      begin
        orphan_log_file_pid, orphan_log_file_timestamp = extract_pid_and_timestamp_from_path(orphan_log_file_name)
        destination_log_file_name = "#{log_directory}/#{orphan_log_file_pid}-#{orphan_log_file_timestamp}-close.log"
        File.rename(orphan_log_file_name, destination_log_file_name)
      rescue Exception => exception
        # it may be that backgrund daemon closed the same file at the same time.
      end
    end
  end

  def parse_caller_data(caller_data)
    caller_data_parsed = caller_data.match(/^(.+?):(\d+)(|:in `(.+)')$/);

    file_name = caller_data_parsed[1].split("/").last
    line_number = caller_data_parsed[2]
    method_name = caller_data_parsed[4]

    [file_name, line_number, method_name]
  end

  def extract_pid_and_timestamp_from_path(process_file_path)
    process_file_name = process_file_path.sub(".log", "").split("/").last
    pid, timestamp, status = process_file_name.split("-")

    [pid, timestamp]
  end

end