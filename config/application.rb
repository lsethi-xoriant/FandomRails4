require File.expand_path('../boot', __FILE__)

require 'rails/all'
require_relative '../lib/raw_cookie_middleware'
require_relative '../lib/config_utils'
include ConfigUtils

if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require(*Rails.groups(:assets => %w(development test)))
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end

module Fandom
  class Application < Rails::Application
    
    VERSION = '0.1'
    
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
     #config.autoload_paths += %W(#{config.root}/vendor/engines/fandom/experience/app/models)

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    config.i18n.default_locale = :it

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    # Enable escaping HTML in JSON.
    config.active_support.escape_html_entities_in_json = true

    # Use SQL instead of Active Record's schema dumper when creating the database.
    # This is necessary if your schema can't be completely dumped by the schema dumper,
    # like if you have constraints or database-specific column types
    # config.active_record.schema_format = :sql

    # Enforce whitelist mode for mass assignment.
    # This will create an empty whitelist of attributes available for mass-assignment for all models
    # in your app. As such, your models will need to explicitly whitelist or blacklist accessible
    # parameters by using an attr_accessible or attr_protected declaration.
    config.active_record.whitelist_attributes = true

    # Enable the asset pipeline
    config.assets.enabled = true
    config.assets.initialize_on_precompile = false

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'

    # Permette di ignorare i campi di errore generati in seguito all'inserimento di campi errati nella registrazione.
    config.action_view.field_error_proc = Proc.new { |html_tag, instance|
      "#{html_tag}".html_safe
    }

    # This setting allows to handle error pages (404 etc.) in the router  
    config.exceptions_app = self.routes

    # Deploy settings are server/installation specific, and so they should not be "versioned". 
    # Loading should be done the earliest in the boot process.
    config.deploy_settings = YAML.load_file("config/deploy_settings.yml")

    # the IP address has to be used instead of 'localhost' because of a defect in dalli
    servers = get_deploy_setting('memcache/servers', '127.0.0.1:11211')
    config.cache_store = :dalli_store, *servers.split(','), {
      :namespace => 'f',
      :expires_in => 120,
      # If a cache expires and due to heavy load several different processes will try
      # to read data natively and then they all will try to write to cache. To avoid
      # that case the first process to find an expired cache entry will bump the cache
      # expiration time by the value set in this property
      :race_condition_ttl => 120,
      :compress => true,
      #:serializer => Oj # this serializer can be enabled to share the cache with other technologies using the JSON format
    }

    # TODO: this is needed to suppress a deprecation warning, but it should be further investigated
    config.i18n.enforce_available_locales = true
    I18n.config.enforce_available_locales = true

    config.sites = []
    config.domain_to_site = {}
    config.domain_to_site_id = {}
    
    enabled_sites = config.deploy_settings['enabled_sites'].split(',').map { |s| s.strip }
    load_site_configs(enabled_sites)
    
    config.fandom_play_enabled = config.deploy_settings.key? 'fandom_play'
    if config.fandom_play_enabled
      config.middleware.insert_before "ActionDispatch::Static", SetRawCookieMiddleware
    end

  end
end
