# Be sure to restart your server when you modify this file.

#Holden::Application.config.session_store :cookie_store, key: '_holden_session'

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rails generate session_migration")
# Happy::Application.config.session_store :active_record_store

if get_deploy_setting('memcache_sessions', false)
  require 'action_dispatch/middleware/session/dalli_store'
  servers = get_deploy_setting('memcache/servers', '127.0.0.1:11211').split(',')
  Rails.application.config.session_store :dalli_store, :memcache_server => servers, :namespace => 'f:sessions', :key => '_session_id' #, :expire_after => 24.hours
end