module LogHelper
  
  def log_call_to_action_viewed(id)
    log_audit(LOG_MESSAGE_CONTENT_VIEWED, { type: 'cta', id: id })
  end

end