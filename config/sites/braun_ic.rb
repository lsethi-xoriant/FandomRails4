module Fandom
  class Application < Rails::Application
    register_fandom_site(
      id: 'braun_ic',
      title: 'BraunIc',
      domains: ['braun-ic.fandom.localdomain', 'braun-ic.stage.fandomlab.com', 'braun-ic.dev.fandomlab.com', 'braun-ic.live.fandomlab.com'],
      assets_precompile: ['braun_ic_application.css', 'braun_ic_application.js'],
      free_provider_share: true,
      interactions_for_anonymous: ["quiz", "share"],
      init_ctas: 3,
      main_reward_name: "credit",
      periodicity_kinds: [],
      environment: { 'EMAIL_ADDRESS' => 'noreply@shado.tv' }
    )
  end
end

