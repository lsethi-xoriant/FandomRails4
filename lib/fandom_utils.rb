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
  
  # set browser and frontend caching; the page is cached by the reverse proxy if it's public and it's not authenticated; 
  # beware: in this case the cookies (hence the session) are completely unset
  # pages with form should never be cached, as they contain the CSRF token that should match with the user session   
  def cache_control(seconds, is_public=false)
    if request.method == 'GET' || request.method == 'HEAD' 
      # this would be useful for akamai
      #headers['Edge-control'] = "!no-store, max-age=#{seconds/60}"
      
      # this sets the Cache-Control header, that drives browser caching
      expires_in seconds, :public => is_public, 'max-stale' => 0
      
      if is_public && current_user.nil?
        env['rack.session.options'][:skip] = true
        response.headers.delete('Set-Cookie')
      end
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