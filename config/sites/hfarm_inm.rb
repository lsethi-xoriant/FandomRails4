module Fandom
  class Application < Rails::Application
    register_fandom_site(
      id: 'hfarm_inm', 
      domains: ['ilnostromomento.fandom.localdomain', 'ilnostromomento.live.fandomlab.com', 'ilnostromomento.dev.fandomlab.com', 'ilnostromomento.stage.fandomlab.com'],
      assets_precompile: ['hfarm_inm_application.css', 'hfarm_inm_application.js'],
      periodicity_kinds: [PERIOD_KIND_DAILY],
      free_provider_share: true,
      init_ctas: 16
    )      
  end
end

