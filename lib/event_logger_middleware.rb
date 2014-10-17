include EventHandlerHelper
include ApplicationHelper

# Logs any requests received by the application.
# It interacts with the event handler helper, by defining several global variables used there.
# The global variables are safe, provided this rails application is run on servers with process-only concurrency. 
class EventLoggerMiddleware
  LOG_DIRECTORY = "log/events"
  TIMESTAMP_FMT = "%Y%m%d_%H%M%S_%N"
  def initialize(app)
    @app = app
    $pid = Process.pid
  end

  def init_data(env)
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
    $http_referer = "#{env["HTTP_REFERER"]}"
    user_agent = "#{env["HTTP_USER_AGENT"]}"
    lang = "#{env["HTTP_ACCEPT_LANGUAGE"]}"
    app_server = Socket.gethostname 
    $session_id = "#{env["rack.session"]["session_id"]}"
    $remote_ip = "#{env["action_dispatch.remote_ip"]}"
    $tenant = tenant
    $user_id = user_id
    $cache_hits = 0
    $cache_misses = 0

    data = {
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

    data    
  end
  
  def call(env)
    data = init_data(env)

    if Rails.env == "production"
      open_process_log_file()
    end
    
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
      data[:active_record_time] = $active_record_time
      data[:view_time] = $view_time
      data[:time] = (Time.now - start).to_s
      log_info(msg, data)
      close_process_log_file()
      [status, headers, response]
    rescue Exception => ex
      data[:exception] = ex.to_s
      data[:backtrace] = ex.backtrace[0, 5]
      data[:time] = (Time.now - start).to_s
      log_info(msg, data)
      close_process_log_file()
      raise ex
    end 

  end

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

