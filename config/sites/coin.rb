module Fandom
  class Application < Rails::Application
    register_fandom_site(
      id: 'coin', 
      title: 'Coin Gift Machine',
      domains: ['coin.fandom.localdomain', 'coin.dev.fandomlab.com', 'coin.stage.fandomlab.com', 'coin.live.fandomlab.com'],
      assets_precompile: ['coin_application.css', 'coin_application.js'],
      environment: { 
        'EMAIL_ADDRESS' => 'noreply@ballando.it'
      }
    )      
  end
end

