module Fandom
  class Application < Rails::Application
    register_fandom_site(
      id: 'tpl-fullscreen', 
      title: 'TPL Fullscreen',
      domains: ['tpl-fullscreen.fandom.localdomain', 'tpl-fullscreen.shado.tv', 'tpl-fullscreen.stage.fandomlab.com'],
      share_db: 'fandom',
      assets_precompile: ['tpl-fullscreen_application.css', 'tpl-fullscreen_application.js'],
    )
  end
end
