Fandom::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports
  config.consider_all_requests_local       = true
  # Caching is disabled by default in development, unless otherwise specified in the deploy settings
  config.action_controller.perform_caching = get_boolean(config.deploy_settings, 'development/perform_caching')
  if config.action_controller.perform_caching
    puts 'caching enabled'
  else
    config.action_controller.perform_caching = false
  end

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  # Raise exception on mass assignment protection for Active Record models
  config.active_record.mass_assignment_sanitizer = :strict

  # Log the query plan for queries taking more than this (works
  # with SQLite, MySQL, and PostgreSQL)
  config.active_record.auto_explain_threshold_in_seconds = 0.5

  # Do not compress assets
  config.assets.compress = false

  if config.deploy_settings.key?('asset_host')
    puts "using asset_host: #{config.deploy_settings['asset_host']}"
    config.action_controller.asset_host = config.deploy_settings['asset_host']
  end

end
