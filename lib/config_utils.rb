module ConfigUtils

  # Get a deploy setting.
  # key     - a "path", i.e. a sequence of words separated by a slash, to index the configuration file
  # default - the value to return in case the key has not been defined
  def get_deploy_setting(key, default)
    d = Rails.configuration.deploy_settings
    begin
      key_parts = key.split('/')
      key_parts.each do |part| 
        d = d[part]
      end
      d    
    rescue
      puts('deploy settings #{key} not found, using a default value')
    end
  end
  
  # Options and configurations related to a specific Fandom site. They are initialized at startup.
  class FandomSite
    include ActiveAttr::TypecastedAttributes
    include ActiveAttr::MassAssignment
    include ActiveAttr::AttributeDefaults

    attribute :id, type: String
    attribute :domains
    attribute :twitter_integration, type: Boolean, :default => false
    attribute :assets_precompile, :default => []
    attribute :environment, :default => {}

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
    if site.unbranded?
      config.unbranded_site = site
    else
      ['stylesheets', 'javascripts', 'fonts', 'images'].each do |leaf|
        config.assets.paths << Rails.root.join('site', site.id, 'assets', leaf)
      end
    end
    config.assets.precompile += site.assets_precompile
  end
  
  # Load Fandom sites configurations from the config/sites directory
  def load_site_configs
    dir = Rails.root.join('config', 'sites')
    dir.entries.find_all { |p| p.to_s.end_with?('.rb') }.each { |p| 
      require(dir.join(p)) }
  end
  
end