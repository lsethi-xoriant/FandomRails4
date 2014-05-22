module Fandom
  class Application < Rails::Application
    register_fandom_site(
      id: 'maxibon', 
      domains: ['maxibon.fandom.localdomain', 'maxibon.shado.tv'],
      assets_precompile: ['maxibon_application.css', 'maxibon_application.js']
    )
  end
end

