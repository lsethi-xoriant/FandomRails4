module Fandom
  class Application < Rails::Application
    register_fandom_site(
      id: 'coin', 
      title: 'Coin Gift Machine',
      domains: ['coin.fandom.localdomain', 'coin.dev.fandomlab.com', 'coin.stage.fandomlab.com', 'coin.live.fandomlab.com'],
      assets_precompile: ['coin_application.css', 'coin_application.js'],
      periodicity_kinds: [PERIOD_KIND_DAILY],
      init_ctas: 1,
      force_landing: true,
      environment: { 
        'EMAIL_ADDRESS' => 'noreply@coin.it'
      }
    )      
  end
end

