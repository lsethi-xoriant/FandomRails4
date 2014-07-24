include EventHandlerHelper

class HttpRequestDebugger
  def initialize(app)
    @app = app
  end
  
  def call(env)
    start = Time.now
    status, headers, response = @app.call(env)
    stop = Time.now    

    msg = "http request in middleware"
    http_host = (env["HTTP_HOST"]).split(":").first

    if env["rack.session"]["warden.user.user.key"].present?
      user_id = env["rack.session"]["warden.user.user.key"][0][0] 
    else
      user_id = anonymous_user.id
    end

    EventHandlerHelper.log_info(
        msg, 
        request_uri: "#{env["REQUEST_URI"]}",
        method: "#{env["REQUEST_METHOD"]}",
        status: status,
        params: env["action_dispatch.request.parameters"],
        http_referer: "#{env["HTTP_REFERER"]}",
        session_id: "#{env["rack.session"]["session_id"]}",
        remote_ip: "#{env["action_dispatch.remote_ip"]}",
        time: "#{(stop - start)}",
        tenant: Rails.configuration.domain_to_site[http_host].id,
        user_id: user_id,
        middleware: true
      )

    [status, headers, response]
  end
end

