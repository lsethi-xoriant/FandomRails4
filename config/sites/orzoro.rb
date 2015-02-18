module Fandom
  class Application < Rails::Application
    register_fandom_site(
      id: 'orzoro', 
      domains: ['orzoro.fandom.localdomain', 'orzoro.stage.fandomlab.com', 'orzoro.live.fandomlab.com', 'orzoro.dev.fandomlab.com', 'preprod.orzoro.it'],
      assets_precompile: ['orzoro_application.css', 'orzoro_application.js', 'ie9.css'],
      anonymous_interaction: true,
      free_provider_share: true
    )      
  end
end

