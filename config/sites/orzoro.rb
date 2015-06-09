module Fandom
  class Application < Rails::Application
    register_fandom_site(
      id: 'orzoro', 
      domains: ['orzoro.fandom.localdomain', 'orzoro.stage.fandomlab.com', 'orzoro.live.fandomlab.com', 'orzoro.dev.fandomlab.com', 'preprod.orzoro.it', 'www.orzoro.it'],
      assets_precompile: ['orzoro_application.css', 'orzoro_application.js', 'orzoro_ie9.css'],
      interactions_for_anonymous: ["quiz", "vote", "download"],
      periodicity_kinds: [PERIOD_KIND_DAILY],
      free_provider_share: true,
      init_ctas: 3,
      force_ssl: true,
      x_frame_options_header: X_FRAME_OPTIONS_HEADER_SAME_ORIGIN
    )      
  end
end

