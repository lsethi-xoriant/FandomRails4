# Require whichever elevator you're using below here...
#
require 'apartment/elevators/generic'
#require 'apartment/elevators/domain'
#require 'apartment/elevators/subdomain'
#require 'apartment/elevators/host_hash'

#
# Apartment Configuration
#
Apartment.configure do |config|

  # These models will not be multi-tenanted,
  # but remain in the global (public) namespace
  #
  # An example might be a Customer or Tenant model that stores each tenant information
  # ex:
  #
  # config.excluded_models = %w{Tenant}
  #
  config.excluded_models = %w{}

  # use postgres schemas?
  config.use_schemas = true
  config.use_sql = true  
  
  # configure persistent schemas (E.g. hstore )
  # config.persistent_schemas = %w{ hstore }

  # add the Rails environment to database names?
  config.prepend_environment = false
  config.append_environment = false

  # supply list of database names for migrations to run on
  config.tenant_names = Rails.application.config.sites.select { |site| site.share_db.nil? }.map { |site| site.id }.uniq
end

##
# Elevator Configuration

module Fandom
  class Application < Rails::Application    
    config.middleware.use 'Apartment::Elevators::Generic', Proc.new { |request| 
      site = config.domain_to_site.fetch(request.host, config.unbranded_site)
      if site.share_db.nil?
        site.id
      else
        site.share_db
      end
    }
  end
end



