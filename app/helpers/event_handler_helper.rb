module EventHandlerHelper

  def log_info_event(msg, data)
    caller_data = caller[0]

    timestamp = Time.new.utc.strftime("%Y-%m-%d %H:%M:%S.%L")
    pid = Process.pid
    file_name, line_number, method_name = parse_caller_data(caller_data)

    case Rails.env
    when "development"
      Rails.logger.info(generate_log_string_for_development(msg, data, timestamp, pid, file_name, line_number, method_name))
    when "production"
      Rails.logger.info(generate_log_string_for_production(msg, data, timestamp, pid, file_name, line_number, method_name))      
    else
      # Nothing to do
    end
  end

  # TODO:
  def log_system_event()
  end

  private

  def generate_log_string_for_development(msg, data, timestamp, pid, file_name, line_number, method_name)
    if msg == "HttpRequestDebugger"
      data.delete(:HTTP_REFERER)
      data.delete(:REMOTE_IP)
      data.delete(:SESSION_ID)
    end

    data_to_string = data.map { |key, value| "#{key}: #{value}" }
    data_to_string = data_to_string.join(", ")

    logger_info_development = "EVENT: #{msg}, #{data_to_string}, LINE_NUMBER: #{line_number}, FILE_NAME: #{file_name}, METHOD_NAME: #{method_name}"
  end

  def generate_log_string_for_production(msg, data, timestamp, pid, file_name, line_number, method_name)
    logger_info_production = Hash.new
    logger_info_production = {
      "EVENT" => msg,
      "DATA" => data,
      "LINE_NUMBER" => line_number,
      "FILE_NAME" => file_name,
      "METHOD_NAME" => method_name
    }

    logger_info_development = logger_info_production.to_json
  end  

  def parse_caller_data(caller_data)
    caller_data_parsed = caller_data.match(/^(.+?):(\d+)(|:in `(.+)')$/);

    file_name = caller_data_parsed[1].split("/").last
    line_number = caller_data_parsed[2]
    method_name = caller_data_parsed[4]

    [file_name, line_number, method_name]
  end

end