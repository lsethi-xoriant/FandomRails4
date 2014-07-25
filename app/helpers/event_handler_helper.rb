module EventHandlerHelper

  @@process_file_descriptor = nil

  def log_synced(msg, data) 
    caller_data = caller[0]
    log_event(msg, "audit", true, data, caller_data)
  end

  def log_audit(msg, data)
    caller_data = caller[0]
    log_event(msg, "audit", false, data, caller_data)
  end

  def log_info(msg, data)
    caller_data = caller[0]
    log_event(msg, "info", false, data, caller_data)
  end

  private

  def calculate_event_timestamp()
    Time.new.utc.strftime("%Y-%m-%d %H:%M:%S.%L")
  end

  def log_event(msg, level, force_saving_in_db, data, caller_data)
    
    timestamp = calculate_event_timestamp()

    begin 

      case Rails.env  
      when "production"
          generate_log_string_for_production(msg, data, caller_data, timestamp, force_saving_in_db, level)
      when "development"
        Rails.logger.info(generate_log_string_for_development(msg, data, caller_data, timestamp))
      else
        # Nothing to do
      end

    rescue Exception => e
      Rails.logger.error("[EventHandlerError] Exception: #{e}")
    end
    
  end

  def generate_log_string_for_development(msg, data, caller_data, timestamp)
    file_name, line_number, method_name = parse_caller_data(caller_data)

    if data[:middleware]
      data.delete(:http_referer)
      data.delete(:remote_ip) 
      data.delete(:session_id)
    end

    data_to_string = data.map { |key, value| "#{key}: #{value}" }
    data_to_string = data_to_string.join(", ")

    logger_development = "message: #{msg}, #{data_to_string}, line_number: #{line_number}, file_name: #{file_name}, method_name: #{method_name}"
  end

  def generate_log_string_for_production(msg, data, caller_data, timestamp, force_saving_in_db, level)
    pid = Process.pid
    file_name, line_number, method_name = parse_caller_data(caller_data)
    params, request_uri, session_id, tenant, user_id = catch_main_attributes_from_data(data)

    logger_production = Hash.new
    logger_production = {
      "user_id" => user_id,
      "tenant" => tenant,
      "message" => msg,
      "level" => level,
      "data" => data,
      "pid" => pid,
      "session_id" => session_id,
      "params" => params,
      "request_uri" => request_uri,
      "line_number" => line_number,
      "file_name" => file_name,
      "method_name" => method_name,
      "timestamp" => timestamp
    }

    if force_saving_in_db
      Event.create(session_id: session_id, pid: pid, message: msg, request_uri: request_uri, file_name: file_name, 
        method_name: method_name, line_number: line_number, params: params.to_json, data: data.to_json, timestamp: timestamp, 
        level: level, tenant: tenant, user_id: user_id)
    else

      may_move_and_open_new_process_log_file(pid, timestamp)
      update_process_log_file(logger_production.to_json)
  
    end

  end  

  def catch_main_attributes_from_data(data)
    if data[:middleware]

      session_id = data[:session_id]
      data.delete(:session_id)

      params = data[:params] 
      data.delete(:params)

      request_uri = data[:request_uri]
      data.delete(:request_uri)

      tenant = data[:tenant] 
      data.delete(:tenant)

      user_id = data[:user_id] 
      data.delete(:user_id)

    else

      params = request.params
      request_uri = request.url
      session_id = request.session["session_id"]
      tenant = get_site_from_request(request).try(:id)
      user_id = current_or_anonymous_user.id

    end

    [params, request_uri, session_id, tenant, user_id]
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
      
      for i in 0..9
        destination_log_file_timestamp = Time.new.utc.strftime("%Y%m%d%H%M%S")
        destination_log_file_name = "#{log_directory}/#{pid}-#{destination_log_file_timestamp}-close.log"
        if !File.exist?(destination_log_file_name)
          File.rename(log_file_name, destination_log_file_name)
          break
        end
      end

    end

    if @@process_file_descriptor.nil?
      @@process_file_descriptor = File.open(log_file_name, "a+")    
    end
  end

  def parse_caller_data(caller_data)
    caller_data_parsed = caller_data.match(/^(.+?):(\d+)(|:in `(.+)')$/);

    file_name = caller_data_parsed[1].split("/").last
    line_number = caller_data_parsed[2]
    method_name = caller_data_parsed[4]

    [file_name, line_number, method_name]
  end

end