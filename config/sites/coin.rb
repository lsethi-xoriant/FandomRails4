module Fandom
  class Application < Rails::Application
    register_fandom_site(
      id: 'coin', 
      title: 'Coin Gift Machine',
      domains: ['coin.fandom.localdomain', 'coin.dev.fandomlab.com', 'coin.stage.fandomlab.com', 'coin.live.fandomlab.com', 'concorsi.coin.it', 'www.concorsi.coin.it'],
      assets_precompile: ['coin_application.css', 'coin_application.js'],
      periodicity_kinds: [PERIOD_KIND_DAILY],
      required_attrs: ["first_name", "last_name", "province", "newsletter", "privacy"],
      init_ctas: 1,
      public_pages: Set.new(["sites/coin/application#show_privacy_policy", "sites/coin/application#show_cookies_policy", "sites/coin/application#show_stores"]),
      force_landing: true,
      environment: { 
        'EMAIL_ADDRESS' => 'noreply@coin.it'
      }
    )      
  end
end

