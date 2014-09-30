include EventHandlerHelper
include ApplicationHelper

class HttpRequestDebugger
  def initialize(app)
    @app = app
  end
  
  def call(env)
    start = Time.now
    status, headers, response = @app.call(env)
    [status, headers, response]
  ensure
    stop = Time.now    
    msg = "http request in middleware"
    http_host = (env["HTTP_HOST"]).split(":").first

    if env["rack.session"]["warden.user.user.key"].present?
      user_id = env["rack.session"]["warden.user.user.key"][0][0] 
    else
      user_id = -1
    end

    if Rails.configuration.domain_to_site.key?(http_host)
      tenant = Rails.configuration.domain_to_site[http_host].id
    else
      tenant = "no_tenant"
    end

    EventHandlerHelper.log_info(
        msg, 
        request_uri: "#{env["REQUEST_URI"]}",
        method: "#{env["REQUEST_METHOD"]}",
        status: status.nil? ? -1 : status,
        params: env["action_dispatch.request.parameters"],
        http_referer: "#{env["HTTP_REFERER"]}",
        session_id: "#{env["rack.session"]["session_id"]}",
        remote_ip: "#{env["action_dispatch.remote_ip"]}",
        time: "#{(stop - start)}",
        tenant: tenant,
        user_id: user_id,
        middleware: true
      )
  end
end

