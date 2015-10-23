module Fandom
  class Application < Rails::Application
    register_fandom_site(
      id: 'hfarm_inm', 
      domains: ['hfarm-inm.fandom.localdomain', 'hfarm-inm.live.fandomlab.com', 'hfarm-inm.dev.fandomlab.com', 'hfarm-inm.stage.fandomlab.com'],
      assets_precompile: ['hfarm_inm_application.css', 'hfarm_inm_application.js'],
      periodicity_kinds: [PERIOD_KIND_DAILY],
      free_provider_share: true,
      init_ctas: 16
    )      
  end
end

