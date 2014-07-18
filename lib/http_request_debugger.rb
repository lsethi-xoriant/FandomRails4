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

    EventHandlerHelper.log_event(
        msg, 
        "info",
        false,
        request_uri: "#{env["REQUEST_URI"]}",
        method: "#{env["REQUEST_METHOD"]}",
        status: status,
        params: env["action_dispatch.request.parameters"],
        http_referer: "#{env["HTTP_REFERER"]}",
        session_id: "#{env["rack.session"]["session_id"]}",
        remote_ip: "#{env["action_dispatch.remote_ip"]}",
        time: "#{(stop - start)}",
        middleware: true
      )

    [status, headers, response]
  end
end

