module Fandom
  class Application < Rails::Application
    register_fandom_site(
      id: 'disney', 
      domains: ['disney.fandom.localdomain', 'disney.stage.fandomlab.com', 'disney.live.fandomlab.com', 'disney.dev.fandomlab.com'],
      assets_precompile: ['disney_application.css', 'disney_application.js'],
      twitter_integration: true,
      allowed_context_roots: ["violetta"]
    )      
  end
end

