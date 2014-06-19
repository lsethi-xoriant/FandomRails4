source 'https://rubygems.org'

gem 'rails', '3.2.14'

gem 'jquery-rails'
gem 'pg'
gem 'devise', '3.1.1'
gem 'devise_invitable'
gem 'oauth2'
gem 'omniauth'
gem 'omniauth-twitter'
gem 'omniauth-facebook'
gem 'koala'
gem 'twitter'
gem 'hirb'
gem 'httparty'

gem 'doorkeeper'

gem 'angularjs-rails'

gem "paperclip", "3.4.2"
gem "simple_form"

group :assets do
  gem 'turbo-sprockets-rails3'
  gem 'sprockets'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'uglifier', '>= 1.0.3'
  gem 'compass-rails', '>= 1.0.3'
  gem 'sass-rails', '~> 3.2.3'
end

gem 'ejs'

group :development do
  gem 'letter_opener'
  gem 'quiet_assets'
  gem 'better_errors', '>= 0.7.2'
  gem 'binding_of_caller'#, '>= 0.7.1', :platforms => [:mri_19, :rbx]
  
  # the debugger gem does not work from an ide debugger
  unless Kernel::caller.find { |x| x.match(/ruby-debug-ide/) }
    gem 'debugger'
  end
  
  # needed for deployment
  gem 'capistrano-rvm'
  gem 'capistrano'
  gem 'capistrano-rails'
  
  gem 'colorize'
end

group :production do
  gem 'dalli-elasticache'
  gem 'unicorn' # high performance web server
  gem 'rack-handlers' # needed by unicorn
end

gem 'rails_admin', '0.4.9'
gem 'safe_yaml'
gem 'psych'#, '1.3.4'
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

gem 'aws-sdk', '~> 1.0'

gem 'figaro'
gem 'execjs'
gem 'therubyracer'

# this gem can be used to define models not bound to a database
gem 'active_attr'

gem 'apartment'

# cache store
gem 'dalli'

gem 'spring'