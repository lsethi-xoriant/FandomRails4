module Fandom
  class Application < Rails::Application
    register_fandom_site(
      id: 'disney', 
      domains: ['disney.fandom.localdomain'],
      twitter: true
    )      
  end
end

