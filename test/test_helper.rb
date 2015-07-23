ENV["RAILS_ENV"] ||= "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  ActiveRecord::Migration.check_pending!

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  # Add more helper methods to be used by all tests here...

  def get_random_property
    random_property_name = $site.allowed_context_roots.sample
    Tag.find(random_property_name)
  end

  def get_default_property
    Tag.find($site.default_property)
  end

  def current_user
    User.offset(rand(User.count)).first
  end

  def initialize_tenant
    switch_tenant("fandom")
  end
end