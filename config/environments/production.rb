Fandom::Application.configure do

  # Settings specified here will take precedence over those in config/application.rb
  
  puts "disabling standard production logs, logs are redirected to the event directory"
  config.log_level = :error
  #config.logger = Logger.new('/dev/null')

  # Code is not reloaded between requests
  config.cache_classes = true

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Disable Rails's static asset server (Apache or nginx will already do this)
  config.serve_static_assets = false

  # Compress JavaScripts and CSS
  config.assets.compress = true

  # Don't fallback to assets pipeline if a precompiled asset is missed
  config.assets.compile = false

  # Generate digests for assets URLs
  config.assets.digest = true

  # Defaults to nil and saved in location specified by config.assets.prefix
  # config.assets.manifest = YOUR_PATH

  # Specifies the header that your server uses for sending files
  # config.action_dispatch.x_sendfile_header = "X-Sendfile" # for apache
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for nginx

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  # config.force_ssl = true


  # Prepend all log lines with the following tags
  # config.log_tags = [ :subdomain, :uuid ]

  # Use a different logger for distributed setups
  # config.logger = ActiveSupport::TaggedLogging.new(SyslogLogger.new)

  # Use a different cache store in production
  # config.cache_store = :mem_cache_store

  # Enable serving of images, stylesheets, and JavaScripts from an asset server
  if config.deploy_settings.key?('asset_host')
    puts "using asset_host: #{config.deploy_settings['asset_host']}"
    config.action_controller.asset_host = config.deploy_settings['asset_host']
  end

  # Precompile additional assets (application.js, application.css, and all non-JS/CSS are already added)
  config.assets.precompile += ['application.css.scss', 'easyadmin.css', 'easyadmin.js', 'jquery.jcarousel.js', 'jcarousel.responsive.js']

    # Enable threaded mode
  # config.threadsafe!

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify
  Paperclip.options[:command_path] = "/usr/local/bin"

  # config/environments/production.rb
  if config.deploy_settings.key?('paperclip')
    config.paperclip_defaults = config.deploy_settings['paperclip']
  end
end
