module LogHelper
  
  def log_call_to_action_viewed(cta)
    log_audit(LOG_MESSAGE_CONTENT_VIEWED, { type: 'cta', id: cta.id }) 
  end

end