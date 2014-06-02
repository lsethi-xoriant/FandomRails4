module Fandom
  class Application < Rails::Application
    register_fandom_site(
      id: 'maxibon', 
      domains: ['maxibon.fandom.localdomain', 'maxibon.shado.tv', 'maxibon.stage.fandomlab.com', 'maxibon.live.fandomlab.com', 'www.maxibon.it', 'maxibon.it'],
      assets_precompile: ['maxibon_application.css', 'maxibon_application.js'],
      environment: { 
        'EMAIL_ADDRESS' => 'noreply@maxibon.it', 
      },
      enable_x_frame_options_header: false,
      force_facebook_tab: 'https://www.facebook.com/testshado/app_597403706967732' 
    )
  end
end

