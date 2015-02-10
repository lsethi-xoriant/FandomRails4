module Fandom
  class Application < Rails::Application
    register_fandom_site(
      id: 'orzoro', 
      domains: ['orzoro.fandom.localdomain', 'orzoro.stage.fandomlab.com', 'orzoro.live.fandomlab.com', 'orzoro.dev.fandomlab.com', 'disney.fandom.disneychannel.it'],
      assets_precompile: ['application.css', 'application.js', 'ie9.css'],
      anonymous_interaction: true
    )      
  end
end

