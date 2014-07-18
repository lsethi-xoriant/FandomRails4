include EventHandlerHelper

class HttpRequestDebugger
  def initialize(app)
    @app = app
  end
  
  def call(env)
    start = Time.now
    status, headers, response = @app.call(env)
    stop = Time.now    

    msg = "HttpRequestDebugger"

    EventHandlerHelper.log_info_event(
        msg, 
        REQUEST_URI: "#{env["REQUEST_URI"]}",
        METHOD: "#{env["REQUEST_METHOD"]}",
        STATUS: status,
        PARAMS: env["action_dispatch.request.parameters"],
        HTTP_REFERER: "#{env["HTTP_REFERER"]}",
        SESSION_ID: "#{env["rack.session"]["session_id"]}",
        REMOTE_IP: "#{env["action_dispatch.remote_ip"]}",
        TIME: "#{(stop - start)}"
      )

    [status, headers, response]
  end
end

