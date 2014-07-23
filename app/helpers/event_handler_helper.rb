module EventHandlerHelper

  def log_event(msg, level, force_saving_in_db, data)
    caller_data = caller[0]

    timestamp = Time.new.utc.strftime("%Y-%m-%d %H:%M:%S.%L")

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
      file_name, line_number, method_name = parse_caller_data(caller_data)
      Rails.logger.error("[EventHandlerError] Exception: #{e}")
    end
    
  end

  # TODO:
  def log_system_event()
  end

  private

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

    if data[:middleware]
      session_id = data[:session_id]
      data.delete(:session_id)

      params = data[:params] 
      data.delete(:params)

      request_uri = data[:request_uri]
      data.delete(:request_uri)
    else
      params = request.params
      request_uri = request.url
      session_id = request.session["session_id"]
    end

    hash = Digest::MD5.hexdigest("#{msg}#{level}#{data}#{pid}#{session_id}#{params}#{request_uri}#{request_uri}#{line_number}#{file_name}#{method_name}#{timestamp}")[0..8]

    logger_production = Hash.new
    logger_production = {
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
      "timestamp" => timestamp,
      "event_hash" => hash
    }

    if force_saving_in_db
      Event.create(session_id: session_id, pid: pid, message: msg, request_uri: request_uri, file_name: file_name, 
        method_name: method_name, line_number: line_number, params: params.to_json, data: data.to_json, timestamp: timestamp, 
        level: level, event_hash: hash)
    end

    log_directory = "log/events"
    log_file_name = "#{log_directory}/#{pid}.log"

    if !File.directory?(log_directory)
      FileUtils.mkdir_p(log_directory)
    end

    if File.exist?(log_file_name) && File.size(log_file_name) > LOGGER_PROCESS_FILE_SIZE
      File.rename(log_file_name, "#{log_directory}/#{pid}-#{Time.new.utc.strftime("%Y%m%d%H%M%S")}.log")
    end

    File.open(log_file_name, "a+") do |f|
      f.write("#{logger_production.to_json}\n")
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