# Initializer for Fandom specific settings. Most notably, client-specific configurations are set here.
module Fandom
  class Application < Rails::Application
    
    class FandomSite
      include ActiveAttr::TypecastedAttributes
      include ActiveAttr::MassAssignment

      attribute :id, type: String
      attribute :domains
      
      def unbranded?
        self.id == 'fandom'
      end
    end
    
    # Registers some new site, with client-specific configuration data and options, in Fandom.
    #
    # id      - The unique identifier used to reference the site. 
    # domains - The list of domains handled by the site. 
    def register_fandom_site(params)
      site = FandomSite.new(params)
      site.domains.each do |domain|
        config.sites << site
        config.domain_by_site[domain] = site
        config.domain_by_site_id[domain] = site.id 
      end
      unless site.unbranded?
        ['stylesheets', 'javascripts', 'fonts'].each do |leaf|
          config.assets.paths << Rails.root.join('site', site.id, 'assets', leaf)
        end
      end      
    end

    config.sites = []
    config.domain_by_site = {}
    config.domain_by_site_id = {}
    register_fandom_site(
      id: 'fandom', 
      domains: ['fandom.shado.tv', 'fandom.localdomain']
    )      
  end
end

