module EventHandlerHelper

  def log_info_event(msg, data)
    caller_data = caller[0].match(/^(.+?):(\d+)(|:in `(.+)')$/);

    file_name = caller_data[1]
    line_number = caller_data[2]
    method_name = caller_data[4]

    logger.info("event: #{msg}; data: #{data}; line_number: #{line_number}; file_name: #{file_name}; method_name: #{method_name}")
  end

  def log_system_event()
  end

end