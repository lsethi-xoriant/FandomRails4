# This middleware is a dirty workaround to implement cookie forwarding, i.e. to obtain
# a cookie from another site and forward it to the client's browser; the problem is that
# rails insist to url encode any cookie, while in this case the cookie should be sent as is
class SetRawCookieMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    status, headers, body = @app.call(env)
    if headers.key? 'raw-set-cookie'
      if headers.key? 'Set-Cookie'
        headers['Set-Cookie'] = [headers['Set-Cookie'], headers['raw-set-cookie']]
      else
        headers['Set-Cookie'] = headers['raw-set-cookie']
      end 
      headers.delete 'raw-set-cookie'
    end
    [status, headers, body]
  end
end    