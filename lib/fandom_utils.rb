module FandomUtils

  # Returns the Site class defined for the requested domain. 
  # The request variable is taken by dynamic scoping, and the Site is set in the request itself.
  def get_site_from_request!
    site = Rails.configuration.domain_by_site[request.host]
    def request.site=(site)
      @site = site
    end
    def request.site
      @site
    end
    request.site = site
    return site
  end

  # Returns the Site class defined for the requested domain.
  def get_site_from_request(request)
    Rails.configuration.domain_by_site[request.host]
  end
  
  # A filter that shall be included in all top-level controllers; it handles the uri hostname to site mapping,
  # showing a message to the user if the hostname has not been recognized
  def fandom_before_filter
    site = get_site_from_request!
    if site.nil?
      render template: 'application/url_mistyped'
    elsif not site.unbranded?
      prepend_view_path "#{Rails.root}/site/#{site.id}/views"
      ActionMailer::Base.prepend_view_path "#{Rails.root}/site/#{site.id}/views"
    end
    configure_environment_for_site(site)
    configure_omniauth_for_site(site)

    unless site.enable_x_frame_options_header
      response.headers.except! 'X-Frame-Options'      
    end
    if site.force_ssl
      force_ssl()
    end

    may_redirect_to_landing

  end

  def may_redirect_to_landing
    if !current_user && !((self.is_a? DeviseController) || (self.is_a? LandingController)|| (self.is_a? YoutubeWidgetController) || request.site.public_pages.include?("#{params[:controller]}##{params[:action]}"))
      redirect_to "/landing"
    end
  end

  def configure_environment_for_site(site)
    ENV.update(site.environment)
    begin
      ENV.update(Rails.configuration.deploy_settings['development']['sites'][site.id]['environment'])
    rescue
      # pass
    end
  end
  
  def configure_omniauth_for_site(site)
    # TODO: 
  end 

  
  # Enable browser caching. is_public set to false instruct any intermediary cache (such as web proxies) 
  # to not share the content for multiple users  
  def browser_caching(seconds, is_public=true)
    if request.method == 'GET' || request.method == 'HEAD' 
      # this would be useful for akamai
      #headers['Edge-control'] = "!no-store, max-age=#{seconds/60}"
      
      expires_in seconds, :public => is_public, 'max-stale' => 0, 'must-revalidate' => true
    end
  end

  # Handle headers in the response to allow frontend caching. Warning: it removes the session cookie, so this 
  # method should be called only from controller actions that does not require it  
  def edge_caching(seconds)
    if current_user.nil?
      env['rack.session.options'][:skip] = true
      
      # this tells nginx to ignore the Cache-Control header, used by browsers, and cache the resource for X seconds  
      response.headers["X-Accel-Expires"] = seconds
    end
  end

  def get_cache_key(key = nil)
    site = get_site_from_request!
    if key.nil?
      parts = caller[1].split(':')
      key = "#{parts[0]}:#{parts[1]}"
    end
    result = "#{site.id}:#{key}"
    logger.info("caching with key: #{result}")
    result
  end

  # cache a block for a set amount of time
  def cache_short(key = nil, &block)
    Rails.cache.fetch(get_cache_key(key), :expires_in => 1.minute, :race_condition_ttl => 30, &block)
  end
  def cache_medium(key = nil, &block)
    Rails.cache.fetch(get_cache_key(key), :expires_in => 5.minute, :race_condition_ttl => 1.minute, &block)
  end
  def cache_long(key = nil, &block)
    Rails.cache.fetch(get_cache_key(key), :expires_in => 1.hour, :race_condition_ttl => 5.minute, &block)
  end
  def cache_huge(key = nil, &block)
    Rails.cache.fetch(get_cache_key(key), :expires_in => 1.day, :race_condition_ttl => 1.hour, &block)
  end

  # Can be used as a constrains in routes.rb to define site-specific routes.
  class SiteMatcher
    include FandomUtils
    
    def initialize(*site_ids)
      @site_ids = site_ids
    end
    
    def matches?(request)
      site = get_site_from_request(request)
      @site_ids.include?(site.id)  
    end
  end
  
  def get_model_from_name(name)
    return name.singularize.classify.constantize
  end

  # Returns true if the request comes from a mobile device.
  def request_is_from_mobile_device?(request)
    iphone = request.user_agent =~ /iPhone/ 
    ipad = request.user_agent =~ /iPad/ 
    mobile = request.user_agent =~ /Mobile/
    android = request.user_agent =~ /Android/  

    # Mobile and Android identifica il MOBILE di tipo Android, altrimenti con solo Android abbiamo il TABLET.
    return ((iphone && !ipad) || (mobile && android))
  end
  
end