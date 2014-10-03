include EventHandlerHelper
include ApplicationHelper

# Logs any requests received by the application.
# It interacts with the event handler helper, by defining several global variables used there.
# The global variables are safe, provided this rails application is run on servers with process-only concurrency. 
class EventLoggerMiddleware
  LOG_DIRECTORY = "log/events"

  def initialize(app)
    @app = app
    $pid = Process.pid
  end
  
  def call(env)
    if Rails.env == "production"
      open_or_rotate_process_log_file()
    end
    
    http_host = (env["HTTP_HOST"]).split(":").first

    if env["rack.session"]["warden.user.user.key"].present? && env["rack.session"]["warden.user.user.key"][0].present?
      user_id = env["rack.session"]["warden.user.user.key"][0][0] 
    else
      user_id = -1
    end

    if Rails.configuration.domain_to_site.key?(http_host)
      tenant = Rails.configuration.domain_to_site[http_host].id
    else
      tenant = "no_tenant"
    end
    
    $request_uri = "#{env["REQUEST_URI"]}"
    $method = "#{env["REQUEST_METHOD"]}"
    $http_params = env["action_dispatch.request.parameters"]
    $http_referer = "#{env["HTTP_REFERER"]}"
    $session_id = "#{env["rack.session"]["session_id"]}"
    $remote_ip = "#{env["action_dispatch.remote_ip"]}"
    $tenant = tenant
    $user_id = user_id
    $cache_hits = 0
    $cache_misses = 0

    data = {
      request_uri: $request_uri,
      method: $method,
      params: $http_params,
      http_referer: $http_referer,
      session_id: $session_id,
      remote_ip: $remote_ip,
      tenant: $tenant,
      user_id: $user_id,
      pid: $pid
    }

    log_info(
      "http request start",
      data
    )

    msg = "http request end"
    begin
      start = Time.now
      status, headers, response = @app.call(env)
      data[:status] = status
      data[:cache_hits] = $cache_hits
      data[:cache_misses] = $cache_misses
      data[:time] = (Time.now - start).to_s
      log_info(msg, data)
      [status, headers, response]
    rescue Exception => ex
      data[:exception] = ex.to_s
      data[:backtrace] = ex.backtrace[0, 5]
      data[:time] = (Time.now - start).to_s
      log_info(msg, data)
      raise ex
    end 

  end
  
  def open_or_rotate_process_log_file()
    if $process_file_size && $process_file_size > LOGGER_PROCESS_FILE_SIZE
      unless $process_file_descriptor.nil?
        $process_file_descriptor.close()
        $process_file_descriptor = nil
      end
      begin
        close_process_file($process_file_path)
      rescue Exception => ex
        # might have been removed by the background daemon
      end
    end
    
    if $process_file_descriptor.nil?
      close_orphan_files_with_same_current_pid()
      open_process_log_file()
    end
  end
  
  def close_process_file(file_path)
    parts = file_path.split('/')
    parts[-1] = parts[-1].sub("open", "closed")
    dest_path = parts.join('/')
    File.rename(file_path, dest_path)
  end

  def close_orphan_files_with_same_current_pid()
    # check if a file assigned to an old precess with the same pid of current process already exists.
    # In this case it must be closed.
    Dir["#{LOG_DIRECTORY}/#{$pid}-*-open.log"].each do |orphan_log_file_path|
      begin
        close_process_file(orphan_log_file_path)
      rescue Exception => ex
        # might have been removed by the background daemon
      end
    end
  end

  def open_process_log_file()
    if !File.directory?(LOG_DIRECTORY)
      FileUtils.mkdir_p(LOG_DIRECTORY)
    end
    process_file_timestamp = Time.now.utc.strftime("%Y%m%d%H%M%S")
    $process_file_path = "#{LOG_DIRECTORY}/#{$pid}-#{process_file_timestamp}-open.log"  
    $process_file_descriptor = File.open($process_file_path, "a+")
    $process_file_size = 0 # incremented in event handler  
  end
  
end

