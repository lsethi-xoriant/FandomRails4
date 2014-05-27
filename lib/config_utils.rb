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

=begin
  def register_omniauth_for_site(site)
    Rails.application.config.middleware.use OmniAuth::Builder do
      config =  Rails.configuration
      debugger
      begin
        provider "twitter_#{site.id}".to_sym, config.deploy_settings["sites"]["#{site.id}"]["twitter"]["app_id"], config.deploy_settings["sites"]["#{site.id}"]["twitter"]["app_secret"]
      rescue Exception => e
        puts('twitter integration disabled')
      end
      begin
        provider "facebook_#{site.id}".to_sym, config.deploy_settings["sites"]["#{site.id}"]["facebook"]["app_id"], config.deploy_settings["sites"]["#{site.id}"]["facebook"]["app_secret"], :scope => 'email, user_birthday, read_stream, publish_stream', :display => 'popup'
      rescue Exception => e
        puts('facebook integration disabled')
      end
    end

    OmniAuth.config.on_failure = Proc.new { |env| [302, { 'Location' => "/auth/failure", 'Content-Type'=> 'text/html' }, []] }
  end
=end
  
  # Load Fandom sites configurations from the config/sites directory
  #  enabled_sites - consider only sites listed in this array. If empty, take all sites
  def load_site_configs(enabled_sites)
    enabled_site_set = Set.new(enabled_sites) 
    
    dir = Rails.root.join('config', 'sites')
    dir.entries.find_all { |f| site_config_file?(f, enabled_site_set) }.each { |p| 
      require(dir.join(p)) }
  end
  def site_config_file?(file, enabled_site_set)
    filename = file.to_s
    filename.end_with?('.rb') && (enabled_site_set.empty? || enabled_site_set.include?(filename[0..-4]))
  end
  
end