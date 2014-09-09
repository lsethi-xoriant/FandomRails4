module Fandom
  class Application < Rails::Application
    register_fandom_site(
      id: 'ballando', 
      title: 'Ballando',
      domains: ['ballando.fandom.localdomain'],
      share_db: 'fandom',
      assets_precompile: ['ballando_application.css', 'ballando_application.js']
    )
  end
end
