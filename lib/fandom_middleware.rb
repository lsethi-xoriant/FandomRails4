include EventHandlerHelper
include ApplicationHelper

# This middleware handles:
#
# - Multi tenancy, by setting a global variable $site that is used by many services
# - Logging of all requests made by the application
# - Interacts with the event handler helper, by defining several global variables used there
# - A dirty workaround to implement cookie forwarding, i.e. to obtain
#   a cookie from another site and forward it to the client's browser; the problem is that
#   rails insist to url encode any cookie, while in this case the cookie should be sent as is
#
# The usage of global variables is safe, provided this rails the application is run on servers with process-only concurrency. 
class FandomMiddleware

  LOG_DIRECTORY = "log/events"
  TIMESTAMP_FMT = "%Y%m%d_%H%M%S_%N"
  # this constant cannot be put in fandom_consts because Devise::Mailer is not available there
  ALL_MAILERS = [Devise::Mailer, SystemMailer]

  def initialize(app)
    @app = app
    $pid = Process.pid
    @controller_view_paths = ActionController::Base.view_paths
    @mailer_view_paths = ActionMailer::Base.view_paths
  end
  
  # main method
  def call(env)
    log_data = init_data(env)
    
    if Rails.env == "production"
      open_process_log_file()
    end
    
    log_info(
      "http request start",
      log_data
    )

    handle_multi_tenancy(env)
    
    msg = "http request end"
    begin
      start = Time.now
      
      call_result = @app.call(env)
      status, headers, response = handle_raw_cookie_forwarding(call_result)

      log_data[:status] = status
      log_data[:cache_hits] = $cache_hits
      log_data[:cache_misses] = $cache_misses
      log_data[:db_time] = $db_time
      log_data[:view_time] = $view_time
      log_data[:time] = (Time.now - start).to_s
      unless $context_root.nil?
        log_data[:context_root] = $context_root
      end
      log_info(msg, log_data)
      close_process_log_file()
      [status, headers, response]
    rescue Exception => ex
      log_data[:exception] = ex.to_s
      log_data[:backtrace] = ex.backtrace[0, 5]
      log_data[:time] = (Time.now - start).to_s
      log_info(msg, log_data)
      close_process_log_file()
      raise ex
    end 
  end

  #####################################################################
  #
  # Global variables and log data
  #

  def init_data(env)
    http_host = (env["HTTP_HOST"]).split(":").first

    if env["rack.session"]["warden.user.user.key"].present? && env["rack.session"]["warden.user.user.key"][0].present?
      user_id = env["rack.session"]["warden.user.user.key"][0][0] 
    else
      user_id = -1
    end
    
    if Rails.configuration.domain_to_site.key?(http_host)
      $site = Rails.configuration.domain_to_site[http_host]
      $tenant = $site.id
      share_db = $site.share_db
    else
      $site = nil
      $tenant = "no_tenant"
    end
    
    $request_uri = "#{env["REQUEST_URI"]}"
    $method = "#{env["REQUEST_METHOD"]}"
    $http_referer = "#{env["HTTP_REFERER"]}"
    user_agent = "#{env["HTTP_USER_AGENT"]}"
    lang = "#{env["HTTP_ACCEPT_LANGUAGE"]}"
    app_server = Socket.gethostname 
    $session_id = "#{env["rack.session"]["session_id"]}"
    $remote_ip = "#{env["action_dispatch.remote_ip"]}"
    $user_id = user_id
    $cache_hits = 0
    $cache_misses = 0

    log_data = {
      request_uri: $request_uri,
      method: $method,
      http_referer: $http_referer,
      user_agent: user_agent,
      lang: lang,
      app_server: app_server,
      session_id: $session_id,
      remote_ip: $remote_ip,
      tenant: $tenant,
      user_id: $user_id,
      pid: $pid
    }
    
    unless share_db.nil?
      log_data[:share_db] = share_db
    end

    log_data
  end

  #####################################################################
  #
  # Multi tenancy
  #

  def handle_multi_tenancy(env)
    unless $site.nil?
      configure_context_root($site, env)
      configure_view_paths_for_site($site)
      self.class.configure_all_mailers_for_site($site)
      configure_environment_for_site($site)
      configure_omniauth_for_site($site)
      configure_paperclip_for_site($site)
    end
  end

  # Configures a $context_root global variable if the client called the tenant through one of the allowed context roots
  def configure_context_root(site, env)
    parts = env['PATH_INFO'].split('/')
    expected_context_root = parts[1]
    if site.allowed_context_roots.include? expected_context_root
      $context_root = expected_context_root
      env['PATH_INFO'].sub!(/^\/#{$context_root}/, '')
      env['REQUEST_PATH'].sub!(/^\/#{$context_root}/, '')
      env['ORIGINAL_FULLPATH'].sub!(/^\/#{$context_root}/, '')
      env['REQUEST_URI'].sub!(/(\w+:\/+[^\/]+)\/#{$context_root}/, '\1')
    else
      $context_root = nil
    end
  end

  def configure_view_paths_for_site(site)
    if site.unbranded?
      ActionController::Base.view_paths = @controller_view_paths
      ActionMailer::Base.view_paths = @mailer_view_paths
    else
      site_path = "#{Rails.root}/site/#{site.id}/views"
      ActionController::Base.view_paths = ActionView::PathSet.new([site_path] + @controller_view_paths)
      ActionMailer::Base.view_paths = ActionView::PathSet.new([site_path] + @mailer_view_paths)
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
  
  def self.configure_all_mailers_for_site(site)
    ALL_MAILERS.each do |mailer|
      configure_mailer_for_site(mailer, site)
    end
  end

  def self.configure_mailer_for_site(mailer, site)
    mailer_conf = get_deploy_setting("sites/#{site.id}/mailer", nil)
    if mailer_conf.nil?
      #log_error("missing mailer configuration for tenant", {})
      mailer.perform_deliveries = false
    else
      mailer.default from: mailer_conf.fetch("default_from", MAILER_DEFAULT_FROM)
      mailer.default_url_options = { :host => mailer_conf.fetch("devise_host", true) }
      mailer.raise_delivery_errors = mailer_conf.fetch("raise_delivery_errors", false)
      configuration_count = 0
      if mailer_conf.key?("ses")
        mailer.delivery_method = :ses
        ses_conf = mailer_conf["ses"]
        # test that a delivery method is not added at every call
        ActionMailer::Base.add_delivery_method :ses, AWS::SES::Base, ses_conf
        configuration_count += 1
      end
      if mailer_conf.key?("smtp")
        configuration_count += 1
        mailer.delivery_method = :smtp
        smtp_conf = mailer_conf["smtp"] 
        mailer.smtp_settings = smtp_conf
      end
      if configuration_count == 0
        log_error("missing delivery method configuration for ActionMailer", {})
        mailer.perform_deliveries = false
      elsif configuration_count > 1
        log_error("multiple delivery method configurations for ActionMailer, the last one overwrite the others!", {})
      end
      
      if configuration_count > 0
        mailer.perform_deliveries = mailer_conf.fetch("perform_deliveries", true)
      end

    end
  end
  
  def configure_omniauth_for_site(site)
    # TODO: 
  end 

  def configure_paperclip_for_site(site)
    if $original_paperclip_s3_settings.nil?
      $original_paperclip_s3_settings = { 
        :s3_host_alias => Paperclip::Attachment.default_options[:s3_host_alias], 
        :url => Paperclip::Attachment.default_options[:url],
        :path => Paperclip::Attachment.default_options[:path] 
      } 
    end
    config = Rails.configuration
    if config.deploy_settings.key?('paperclip')
      bucket_name = get_deploy_setting("sites/#{$site.id}/paperclip/:bucket", nil)
      if bucket_name.nil?
        log_error("missing paperclip bucket configuration for tenant", { site: $site.id })
      end
      Paperclip::Attachment.default_options.merge!(:bucket => bucket_name)
      
      s3_host_alias = get_deploy_setting("sites/#{$site.id}/paperclip/:s3_host_alias", nil)
      if s3_host_alias.nil?
        s3_host_alias = $original_paperclip_s3_settings[:s3_host_alias]
        url = $original_paperclip_s3_settings[:url]
        path = $original_paperclip_s3_settings[:path]
      else 
        url = ':s3_alias_url'
        path = '/:class/:attachment/:id_partition/:style/:filename'
      end
      Paperclip::Attachment.default_options.merge!(s3_host_alias: s3_host_alias, url: url, path: path)
    end
  end

  #####################################################################
  #
  # Cookie forwarding
  #

  def handle_raw_cookie_forwarding(call_result)
    if Rails.configuration.fandom_play_enabled
      status, headers, body = call_result
      if headers.key? 'raw-set-cookie'
        if headers.key? 'Set-Cookie'
          headers['Set-Cookie'] = [headers['Set-Cookie'], headers['raw-set-cookie']]
        else
          headers['Set-Cookie'] = headers['raw-set-cookie']
        end 
        headers.delete 'raw-set-cookie'
      end
      [status, headers, body]
    else
      call_result
    end
  end

  #####################################################################
  #
  # Event logging
  #

  # Opens a new file to log data for this request. The file has the pid of the process and a timestamp.
  # It is very unlikely that a file with the same name already exists (it means that within the clock resolution, 
  # let's within 1 millinsecond, the current process died and respawned); however, to handle this case, the
  # file creation is attempted multiple times, with 1 ms pause in between (so the timestamp changes)
  def open_process_log_file()
    if !File.directory?(LOG_DIRECTORY)
      FileUtils.mkdir_p(LOG_DIRECTORY)
    end
    success = false
    3.times do |i|
      begin
        $process_file_path = get_open_process_log_filename()
        $process_file_descriptor = File.open($process_file_path, File::WRONLY|File::CREAT|File::EXCL)
        success = true
        break
      rescue Errno::EEXIST => exception  
        sleep(0.01)
      end
    end
    unless success
      raise Exception.new('log file creation failed') # this exception should be captured by the standard rails production log
    end
    $process_file_size = 0 # incremented in event handler  
  end
  
  def get_open_process_log_filename()
    timestamp = Time.now.utc.strftime(TIMESTAMP_FMT)
    "#{LOG_DIRECTORY}/#{$pid}-#{timestamp}-open.log"
  end
  
  def close_process_log_file()
    unless $process_file_descriptor.nil?
      $process_file_descriptor.close()
      $process_file_descriptor = nil
    end
    begin
      rename_open_to_closed($process_file_path)
    rescue Exception => ex
      # might have been removed by the background daemon
    end
  end
  
  def rename_open_to_closed(file_path)
    parts = file_path.split('/')
    parts[-1] = parts[-1].sub("open", "closed")
    dest_path = parts.join('/')
    File.rename(file_path, dest_path)
  end

end

