# Be sure to restart your server when you modify this file.

#Holden::Application.config.session_store :cookie_store, key: '_holden_session'

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rails generate session_migration")
# Happy::Application.config.session_store :active_record_store
secure_cookies = get_deploy_setting('secure_cookies', false)
if get_deploy_setting('memcache_sessions', false)
  require 'action_dispatch/middleware/session/dalli_store'
  servers = get_deploy_setting('memcache/servers', '127.0.0.1:11211').split(',')
  Rails.application.config.session_store :dalli_store, 
    :memcache_server => servers, 
    :key => '_session_id',
    :namespace => 'f:sessions', 
    :secure => secure_cookies
    #, :expire_after => 24.hours
else
  Rails.application.config.session_store :cookie_store, 
    :key => '_session_id',
    :secure => secure_cookies
end