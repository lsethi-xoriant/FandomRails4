module Fandom
  class Application < Rails::Application
    register_fandom_site(
      id: 'ballando', 
      title: 'Ballando con le stelle',
      domains: ['ballando.localdomain', 'ballando.fandom.localdomain', 'ballando.shado.tv', 'ballando.stage.fandomlab.com', 'ballando.live.fandomlab.com', 'ballando.dev.fandomlab.com', 'www.stage.community.ballando.rai.it'],
      assets_precompile: ['ballando_application.css', 'ballando_application.js', 'ballando_application_light.js'],
      environment: { 
        'EMAIL_ADDRESS' => 'noreply@ballando.it', 
      }
    )
  end
end
