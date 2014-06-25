module EventHandlerHelper

  # TODO: to be implemented
  def log_event(msg, data)
    logger.info("event: #{msg}; data: #{data}")
  end

  def log_system_event()
  end

end