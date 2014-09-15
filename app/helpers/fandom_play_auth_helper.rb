module FandomPlayAuthHelper
  
  # Calls a FandomPlay service to automatically log the user there as well. 
  # Sets the cookie to be sent to the client. 
  def fandom_play_login(user)
    if Rails.configuration.fandom_play_enabled
      token = Digest::MD5.hexdigest(user.email + Rails.configuration.secret_token)
      host, port = Rails.configuration.deploy_settings['fandom_play']['server'].split(':')
      web_context = Rails.configuration.deploy_settings['fandom_play']['web_context']
      url = "http://#{host}:#{port}#{web_context}/login/#{URI.encode(user.email)}/#{token}"
      logger.info("FandomPlay single sign on: #{url}...")
      begin
        post_result = HTTParty.post(url)
        logger.info("FandomPlay response: #{post_result}")
        set_play_cookie(post_result)
      rescue Exception => ex 
        logger.info("couldn't not connect to FandomPlay: #{ex}")
      end
    else
      logger.info("no FandomPlay configuration, skipping login syncronization")
    end
  end
  
  def set_play_cookie(post_result)
    if post_result.body == 'authorized'
      cookie_header = post_result.headers['Set-Cookie']
      logger.info("Setting FandomPlay cookie: #{cookie_header}")
      # this header is merged into 'set-cookie' by a middleware; 
      # it's a workaround to avoid rails encoding on cookies
      response.headers["raw-set-cookie"] = cookie_header
    end
  end
  
  # Calls a FandomPlay service to automatically log out the user there as well. 
  # Sets the cookie to be sent to the client accordingly. 
  def fandom_play_logout
    if Rails.configuration.fandom_play_enabled
      session_cookie_name = Rails.configuration.deploy_settings['fandom_play']['session_cookie_name']
      web_context = Rails.configuration.deploy_settings['fandom_play']['web_context']
      cookies.delete(session_cookie_name.to_sym, path: '/play')
    else
      logger.info("no FandomPlay configuration, skipping logout syncronization")
    end    
  end
  
end