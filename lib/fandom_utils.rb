module FandomUtils

  # Returns the Site class defined for the requested domain. The request variable is taken by dynamic scoping
  def get_site_from_request!
    Rails.configuration.domain_by_site[request.host]
  end

  # Returns the Site class defined for the requested domain.
  def get_site_from_request(request)
    Rails.configuration.domain_by_site[request.host]
  end
  
  # A filter that shall be included in all top-level controllers; it handles the uri hostname to site mapping,
  # showing a message to the user if the hostname has not been recognized
  def fandom_before_filter
    site = get_site_from_request!
    if site.nil?
      render template: 'application/url_mistyped'
    elsif not site.unbranded?
      prepend_view_path "#{Rails.root}/site/#{site.id}/views"
    end
  end
  
  # Enable browser caching. is_public set to false instruct any intermediary cache (such as web proxies) 
  # to not share the content for multiple users  
  def browser_caching(seconds, is_public=true)
    if request.method == 'GET' || request.method == 'HEAD' 
      # this would be useful for akamai
      #headers['Edge-control'] = "!no-store, max-age=#{seconds/60}"
      
      expires_in seconds, :public => is_public, 'max-stale' => 0, 'must-revalidate' => true
    end
  end

  # Handle headers in the response to allow frontend caching. Warning: it removes the session cookie, so this 
  # method should be called only from controller actions that does not require it  
  def edge_caching(seconds)
    if current_user.nil?
      env['rack.session.options'][:skip] = true
      
      # this tells nginx to ignore the Cache-Control header, used by browsers, and cache the resource for X seconds  
      response.headers["X-Accel-Expires"] = seconds
    end
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

end