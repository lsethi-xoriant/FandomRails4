module FandomUtils

  # Returns the Site class defined for the requested domain. The request variable is taken by dynamic scoping
  def get_site_from_request!
    Rails.configuration.domain_by_site[request.host]
  end

  # Returns the Site class defined for the requested domain.
  def get_site_from_request(request)
    Rails.configuration.domain_by_site[request.host]
  end
  
  # A filter that shall be included in all top-level controllers.
  def fandom_before_filter
    site = get_site_from_request!
    unless site.unbranded?
      prepend_view_path "#{Rails.root}/site/#{site.id}/views"
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