module LogHelper
  
  def log_call_to_action_viewed(id)
    begin
      id_as_int = Integer(id) # Integer() is used instead of to_i() to raise an exception if id is not a number
      log_audit(LOG_MESSAGE_CONTENT_VIEWED, { type: 'cta', id: id_as_int }) 
    rescue
      log_error('attempt to log a cta viewed with a wrong id', { id: id })
    end      
  end

end