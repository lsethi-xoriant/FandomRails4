require "open3"

module FandomUtils

  # These are mostly used by the event logging system
  def init_global_variables
    $pid = Process.pid
    $site = nil
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
    $context_root = nil
  end
  
  # This method change the user_id stored in a global variable, especially useful for the logging system
  def change_global_user_id(user_id)
    $user_id = user_id
  end

  # Deprecated: tenant information can now be obtained by the global variable $site
  def get_site_from_request(request)
    $site
  end
  
  # A filter that shall be included in all top-level controllers; it handles the uri hostname to site mapping,
  # showing a message to the user if the hostname has not been recognized
  def fandom_before_filter
    # Deprecated: tenant information can now be obtained by the global variable $site
    def request.site
      $site
    end

    if $site.nil?
      render template: 'application/url_mistyped'
      return
    end
    
    save_utm(params)

    unless fandom_domain?
      cookies[:initial_http_referrer] = request.referrer
    end

    if $site.id == "disney" && request.present? && request.referrer.present? && request.referrer.include?("https://www.facebook.com")
      session[:from_facebook] = true
    end

    unless $site.x_frame_options_header.nil?
      response.headers['X-Frame-Options'] = $site.x_frame_options_header
    end

    if session[:redirect_path]
      session_redirect_path = session[:redirect_path]
      session.delete(:redirect_path)
      redirect_to session_redirect_path
    else
      may_redirect_to_landing if $site.force_landing
    end

  end

  def save_utm(params)
    cookies[:utm_source] = params[:utm_source] if params[:utm_source].present?
    cookies[:utm_medium] = params[:utm_medium] if params[:utm_medium].present?
    cookies[:utm_content] = params[:utm_content] if params[:utm_content].present?
    cookies[:utm_campaign] = params[:utm_campaign] if params[:utm_campaign].present?
  end

  def fandom_domain?
    result = false
    if request.present? && request.referrer.present? && !self.is_a?(DeviseController)
      $site.domains.each do |domain|
        if request.referrer.include?(domain)
          result = true
          break
        end
      end
    else
      result = true
    end
    result
  end

  def may_redirect_to_landing
    if !current_user && !((self.is_a? DeviseController) || ("application#facebook_app").include?("#{params[:controller]}##{params[:action]}") || (self.is_a? LandingController) || ("application#user_cookies").include?("#{params[:controller]}##{params[:action]}") || ("application#redirect_into_iframe_path").include?("#{params[:controller]}##{params[:action]}") || request.site.public_pages.include?("#{params[:controller]}##{params[:action]}"))
      redirect_to "/landing"
    end
  end

  # Can be used as a constrains in routes.rb to define site-specific routes.
  class SiteMatcher
    include FandomUtils
    
    def initialize(*site_ids)
      @site_ids = site_ids
    end
    
    def matches?(request)
      @site_ids.include?($site.id)  
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
  
  
  def switch_tenant(tenant)
    init_global_variables
    $site = Rails.configuration.id_to_site[tenant]
    Apartment::Tenant.switch!(tenant);
    FandomMiddleware.configure_all_mailers_for_site($site)
    FandomMiddleware.configure_paperclip_for_site($site)
    # this is only shown when the method is called from rails console    
    "The Apartment gem and the $site global variable have been set to tenant #{tenant}"
  end

  def all_site_ids_with_db
    Rails.configuration.sites.select {|s| s.share_db.nil? }.map { |s| s.id }
  end

  def apply_all_sites(&block)
    site_ids = all_site_ids_with_db
    site_ids.each do |site_id|
      yield(site_id)
    end
  end
  
  # This method can be used from rails console to reset the schema_migrations table.
  def reset_migrations_table
    reset_migrations_table_for_tenant()
    all_site_ids_with_db.each do |tenant_id|
      reset_migrations_table_for_tenant(tenant_id)
    end
  end    
  
  def reset_migrations_table_for_tenant(tenant_id = nil)
    schema = tenant_id.nil? ? '' : tenant_id + '.'
    ActiveRecord::Base.connection.execute("DELETE FROM #{schema}schema_migrations")
    Dir.open('db/migrate').each do |fname|
       i = fname.split('_').first.to_i
       next if i == 0
       ActiveRecord::Base.connection.execute("INSERT INTO #{schema}schema_migrations (version) VALUES(#{i})")
    end
  end    
  
end