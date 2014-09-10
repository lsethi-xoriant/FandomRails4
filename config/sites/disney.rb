module Fandom
  class Application < Rails::Application
    register_fandom_site(
      id: 'disney', 
      domains: ['disney.fandom.localdomain', 'disney.stage.fandomlab.com', 'disney.live.fandomlab.com', 'disney.dev.fandomlab.com'],
      twitter_integration: true
    )      
  end
end

