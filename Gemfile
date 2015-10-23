source 'https://rubygems.org'

gem 'rails', '4.2.1'

gem 'protected_attributes' # https://github.com/rails/protected_attributes
# gem 'active_resource' # https://github.com/rails/activeresource
gem 'actionpack-action_caching' # https://github.com/rails/actionpack-action_caching
gem 'activerecord-session_store' # https://github.com/rails/activerecord-session_store
gem 'rails-observers' # https://github.com/rails/rails-observers
# Note that there might be more functionalities that were extracted

gem 'jquery-rails'
gem 'pg'
gem 'devise'
gem 'devise_invitable'
gem 'oauth2'
gem 'omniauth'
gem 'omniauth-twitter'
gem 'omniauth-facebook'
gem 'omniauth-instagram'
gem "omniauth-google-oauth2"
gem 'omniauth-linkedin-oauth2'
gem 'koala'
gem 'twitter'
gem 'twitter-text'
gem 'hirb'
gem 'httparty'
gem 'htmlentities', '~> 4.3.4'

# gem 'doorkeeper'

gem 'angularjs-rails', "1.2.16"

gem "paperclip" #, "3.4.2"
gem 'paperclip-watermark'
gem "simple_form"

gem "hamster"

gem 'fastclick-rails' #, '~> 1.0.1'
gem 'icalendar'
gem 'ckeditor'

# group :assets do
# gem 'turbo-sprockets-rails3'
gem 'sprockets-rails'
# gem 'coffee-rails' #, '~> 3.2.1'
gem 'uglifier' #, '>= 1.0.3'
gem 'compass-rails' #, '>= 1.0.3'
gem 'sass-rails' #, '~> 3.2.3'
gem 'bootstrap-sass'
gem 'sass-globbing'
# end
 
gem 'ejs'

gem 'prerender_rails'

group :development do
  gem 'letter_opener'
  gem 'quiet_assets'
  gem 'better_errors' #, '>= 0.7.2'
  gem 'binding_of_caller'#, '>= 0.7.1', :platforms => [:mri_19, :rbx]
  
  # the debugger gem does not work from an ide debugger

  #  unless Kernel::caller.find { |x| x.match(/ruby-debug-ide/) }
  #    gem 'debugger'
  #  end
  
  # needed for deployment
  gem 'capistrano-rvm'
  gem 'capistrano'
  gem 'capistrano-rails'
  
  gem 'bullet'
  gem 'byebug'
end

group :production do
  gem 'unicorn' # high performance web server
  gem 'rack-handlers' # needed by unicorn
end

group :test do
  gem 'capybara'
  gem 'selenium-webdriver'
  gem 'capybara-angular'
end

gem 'rails_admin' #, '0.4.9'
gem 'safe_yaml'
gem 'psych' #, '1.3.4'
gem 'ancestry'
gem 'rails_admin_nestable'

gem 'gon'
gem 'rmagick', :require => false
gem 'carrierwave'
gem 'fog'

gem 'kaminari'

gem 'friendly_id'
gem 'inherited_resources'
gem 'cancan'

ENV['NOKOGIRI_USE_SYSTEM_LIBRARIES'] = "true"
gem 'nokogiri'

gem 'aws-sdk-v1'
gem 'aws-sdk', '~> 2'

gem 'figaro'
gem 'execjs'
gem 'therubyracer'

# this gem can be used to define models not bound to a database
gem 'active_attr'

gem 'apartment'

# cache store
gem 'dalli'
gem 'dalli-elasticache'

gem 'spring'

# aws simple email service
gem "aws-ses" #, "~> 0.5.0", :require => 'aws/ses'

gem 'sys-proctable'

# used to prevent BREACH attacks when the HTTP compression is active
gem 'breach-mitigation-rails'
gem "font-awesome-rails"
gem 'flexslider'
gem 'simple_token_authentication', '~> 1.0'