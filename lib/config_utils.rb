require 'active_attr'
require_relative '../config/initializers/fandom_consts'

module ConfigUtils

  # Get a deploy setting.
  #   key     - a "path", i.e. a sequence of words separated by a slash, to index the configuration file; 
  #             if a word starts with ":", the word is treated as a symbol
  #   default - the value to return in case the key has not been defined
  def get_deploy_setting(key, default)
    get_from_hash_by_path(Rails.configuration.deploy_settings, key, default)
  end
  
  def get_from_hash_by_path(hash, key, default)
    x = hash
    begin
      key_parts = key.split('/')
      key_parts.each do |part|
        if part.start_with? ':'
          part = part[1..-1].to_sym
        end 
        x = x.fetch(part)
      end
      x
    rescue
      default
    end
  end 
  
  # Options and configurations related to a specific Fandom site. They are initialized at startup.
  class FandomSite
    include ActiveAttr::TypecastedAttributes
    include ActiveAttr::MassAssignment
    include ActiveAttr::AttributeDefaults

    attribute :id, type: String
    attribute :title, type: String
    attribute :domains
    attribute :share_db, type: String, :default => nil
    attribute :twitter_integration, type: Boolean, :default => false
    attribute :assets_precompile, :default => []
    attribute :environment, :default => {}
    # this option shall be set to false to have the site working under facebook, but it's a security hazard!
    attribute :x_frame_options_header, :default => nil
    # if the site is reached through HTTP redirects to HTTPS, and every other redirect will be set to HTTPS as well
    # TODO: currenty force_ssl is unused because it doesn't work with multi-tenancy! The deploy setting "secure_cookies" is used instead
    attribute :force_ssl, :default => false
    attribute :force_facebook_tab, type: String
    attribute :public_pages, :default => Set.new([])
    attribute :periodicity_kinds, :default => [PERIOD_KIND_DAILY, PERIOD_KIND_WEEKLY, PERIOD_KIND_MONTHLY]
    attribute :required_attrs, :default => []
    attribute :interactions_for_anonymous, :default => nil
    attribute :interactions_for_anonymous_limit, :default => nil
    attribute :init_ctas, :default => 3
    attribute :force_landing, :default => false
    attribute :search_results_per_page, :default => 5
    attribute :allowed_context_roots, :default => []
    attribute :default_property, :default => nil
    attribute :timezone, type: String, :default => "Europe/Rome"
    attribute :assets, :default => { "anon_avatar" => "anon.png", "community_logo" => nil }
    attribute :free_provider_share, :default => false
    attribute :aws_transcoding, :default => false
    attribute :main_reward_name, :default => "point"
    attribute :instantwin_ticket_name, :default => nil
    attribute :is_tag_filter_exclusive, :default => false
    attribute :galleries_split_by_property, :default => true

    def unbranded?
      self.id == 'fandom'
    end
  end
  
  # this can be used to initialize $site in rails console
  TEST_SITE = FandomSite.new(
    id: 'test-tenant', 
    title: 'Test Tenant',
    domains: 'test.fandomlab.com')

  # Registers some new site, with client-specific configuration data and options, in Fandom.
  #
  # id      - The unique identifier used to reference the site.
  # domains - The list of domains handled by the site.
  def register_fandom_site(params)
    site = FandomSite.new(params)
    config.sites << site
    config.id_to_site[site.id] = site
    site.domains.each do |domain|
      config.domain_to_site[domain] = site
      config.domain_to_site_id[domain] = site.id
    end
    if site.unbranded?
      config.unbranded_site = site
    else
      ['stylesheets', 'javascripts', 'fonts', 'images', 'media'].each do |leaf|
        config.assets.paths << Rails.root.join('site', site.id, 'assets', leaf)
      end
    end
    config.assets.precompile += site.assets_precompile
    #register_omniauth_for_site(site)
  end

=begin
  def register_omniauth_for_site(site)
    Rails.application.config.middleware.use OmniAuth::Builder do
      config =  Rails.configuration
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
  
  
  STRING_TO_BOOL = {
    'true' => true,
    true => true,
    'y' => true,
    'yes' => true,
    '1' => true,
    1 => true,
    'false' => false,
    false => false,
    'n' => false,
    'no' => false,
    '0' => false,
    0 => false
  }
  # get a boolean from a hash obtained by parsing a YAML file.
  def get_boolean(deploy_settings, path, default = false)
    begin
      result = deploy_settings
      path.split("/").each do |x|
        result = result[x]  
      end
      result = STRING_TO_BOOL[result]
      if result.nil?
        throw Exception.new("boolean expected in configuration file, got: #{result}")
      end
      result
    rescue
      default
    end
  end
  
end