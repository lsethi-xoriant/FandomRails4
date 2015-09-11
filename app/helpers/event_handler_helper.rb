# Logs events in two formats: development and production.
# It interacts with the event logger middleware, by using several global variables defined there.
module EventHandlerHelper

  def log_synced(msg, data) 
    log_event(msg, "audit", true, (data || {}))
  end

  def log_audit(msg, data)
    log_event(msg, "audit", false, (data || {}))
  end

  def log_info(msg, data)
    log_event(msg, "info", false, (data || {}))
  end

  def log_error(msg, data)
    log_event(msg, "error", false, (data || {}))
  end

  def log_warn(msg, data)
    log_event(msg, "warn", false, (data || {}))
  end

  def log_debug(msg, data)
    log_event(msg, "debug", false, (data || {}))
  end

  private

  def calculate_event_timestamp()
    Time.new.utc.strftime("%Y-%m-%d %H:%M:%S.%L")
  end

  def log_event(msg, level, force_saving_in_db, data)
    timestamp = calculate_event_timestamp()

    begin 

      if $process_file_descriptor.nil?
        log_string_for_development = generate_log_string_for_development(msg, data, level, timestamp)
        logger_method = level == "audit" ? "info" : level
        Rails.logger.send(logger_method, log_string_for_development)
      else
        log_string_for_production(msg, data, timestamp, force_saving_in_db, level)
      end

    rescue Exception => e
      Rails.logger.error("[EventHandlerError] Exception: #{e} - full backtrace:\n#{e.backtrace.join("\n")}")
    end
    
  end

  def generate_log_string_for_development(msg, data, level, timestamp)
    caller_data = caller[2]
    
    file_name, line_number, method_name = parse_caller_data(caller_data)

    data_to_string = data.map { |key, value| "#{key}: #{value}" }
    data_to_string = data_to_string.join(", ")

    "#{timestamp} [#{level.upcase}] #{file_name}:#{line_number} #{msg} -- #{data_to_string}"
  end

  def log_string_for_production(msg, data, timestamp, force_saving_in_db, level)
    if force_saving_in_db
      # TODO: remove file_name, method_name and line_number
      Event.create(session_id: $session_id[0..254], pid: $pid, message: msg[0..254], request_uri: $request_uri[0..254], 
        data: data.to_json, timestamp: timestamp, 
        level: level, tenant: $tenant, user_id: $user_id)

      data = data.merge("already_synced" => force_saving_in_db)
    end

    logger_production = {
      "message" => msg,
      "level" => level,
      "data" => data,
      "timestamp" => timestamp,
      "pid" => $pid
    }
    update_process_log_file(logger_production.to_json)
  end  

  def update_process_log_file(log_to_append) 
    $process_file_descriptor.write(log_to_append)
    $process_file_descriptor.write("\n")
    $process_file_descriptor.flush
    $process_file_size += (log_to_append.size + 1)
  end

  def parse_caller_data(caller_data)
    caller_data_parsed = caller_data.match(/^(.+?):(\d+)(|:in `(.+)')$/);

    file_name = caller_data_parsed[1].split("/").last
    line_number = caller_data_parsed[2]
    method_name = caller_data_parsed[4]

    [file_name, line_number, method_name]
  end

end
