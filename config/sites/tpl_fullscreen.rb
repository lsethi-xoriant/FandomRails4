module Fandom
  class Application < Rails::Application
    register_fandom_site(
      id: 'tpl_fullscreen', 
      title: 'TPL Fullscreen',
      domains: ['tpl_fullscreen.fandom.localdomain', 'tpl_fullscreen.shado.tv'],
      assets_precompile: ['tpl_fullscreen_application.css', 'tpl_fullscreen_application.js'],
    )
  end
end
