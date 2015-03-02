module Fandom
  class Application < Rails::Application
    register_fandom_site(
      id: 'orzoro', 
      domains: ['orzoro.fandom.localdomain', 'orzoro.stage.fandomlab.com', 'orzoro.live.fandomlab.com', 'orzoro.dev.fandomlab.com', 'preprod.orzoro.it'],
      assets_precompile: ['orzoro_application.css', 'orzoro_application.js', 'ie9.css'],
      anonymous_interaction: true,
      periodicity_kinds: [PERIOD_KIND_DAILY],
      free_provider_share: true,
      init_ctas: 3,
      x_frame_options_header: X_FRAME_OPTIONS_HEADER_SAME_ORIGIN
    )      
  end
end

