require "open3"

module FandomUtils

  # These are mostly used by the event logging system
  def init_global_variables
    $pid = Process.pid
    $request_uri = "unknown"
    $method = "unknown"
    $http_referer = "unknown"
    $session_id = "unknown"
    $remote_ip = "unknown"
    $tenant = "no_tenant"
    $user_id = -1
    $cache_hits = 0
    $cache_misses = 0    
    $process_file_size = 0
    $process_file_path = nil
    $process_file_descriptor = nil
    $db_time = nil
    $view_time = nil
  end

  # Returns the Site class defined for the requested domain. 
  # The request variable is taken by dynamic scoping, and the Site is set in the request itself.
  def get_site_from_request!
    site = Rails.configuration.domain_to_site[request.host]
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
    Rails.configuration.domain_to_site[request.host]
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

    if session[:redirect_path]
      session_redirect_path = session[:redirect_path]
      session.delete(:redirect_path)
      redirect_to session_redirect_path
    else
      # TODO: may redirect to landing if this feature is indicated in site configuration.
      # may_redirect_to_landing
    end

  end

  def may_redirect_to_landing
    if !current_user && !((self.is_a? DeviseController) || (self.is_a? LandingController) || (self.is_a? YoutubeWidgetController) || ("application#redirect_into_iframe_path").include?("#{params[:controller]}##{params[:action]}") || request.site.public_pages.include?("#{params[:controller]}##{params[:action]}"))
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

=begin
  # Returns true if the request comes from a mobile device.
  def request_is_from_mobile_device?(request)
    iphone = request_is_from_apple_mobile_device?(request)
    ipad = request.user_agent =~ /iPad/ 
    mobile = request.user_agent =~ /Mobile/
    android = request.user_agent =~ /Android/  

    # Mobile and Android identifica il MOBILE di tipo Android, altrimenti con solo Android abbiamo il TABLET.
    return ((iphone && !ipad) || (mobile && android))
  end
=end

  def request_is_from_mobile_device?(request)
    iphone = request.user_agent =~ /iPhone/ 
    ipad = request.user_agent =~ /iPad/ 
    mobile = request.user_agent =~ /Mobile/
    android = request.user_agent =~ /Android/  

    # Mobile and Android identifica il MOBILE di tipo Android, altrimenti con solo Android abbiamo il TABLET.
    return ((iphone || ipad) || android)
  end

  def request_is_from_small_mobile_device?(request)
    iphone = request.user_agent =~ /iPhone/ 
    ipad = request.user_agent =~ /iPad/ 
    mobile = request.user_agent =~ /Mobile/
    android = request.user_agent =~ /Android/  

    # Mobile and Android identifica il MOBILE di tipo Android, altrimenti con solo Android abbiamo il TABLET.
    return ((iphone && !ipad) || (mobile && android))
  end

  def request_is_from_apple_mobile_device?(request)
    iphone = request.user_agent =~ /iPhone/ 
    ipad = request.user_agent =~ /iPad/
    iphone || ipad
  end
  
  # Returns the number of cores in the machine. It requires the command line utility nproc
  def self.get_number_of_cores
    begin
      stdin, stdout, stderr, wait_thr = Open3.popen3('nproc')
      exit_code = wait_thr.value.exitstatus
      if exit_code != 0
        raise Exception.new("nproc exit code: #{exit_code}; stderr: #{stderr.gets(nil)}")
      else
        return stdout.gets(nil).to_i
      end
    rescue Exception => e
      raise Exception.new("could not execute 'nproc', the number of the machine cores cannot be determined: #{e.inspect}")
    end
  end
  
end