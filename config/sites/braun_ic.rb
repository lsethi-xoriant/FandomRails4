module Fandom
  class Application < Rails::Application
    register_fandom_site(
      id: 'braun_ic',
      title: 'BraunIc',
      domains: ['braun-ic.fandom.localdomain', 'braun-ic.stage.fandomlab.com', 'braun-ic.dev.fandomlab.com', 'braun-ic.live.fandomlab.com', 'www.braun-ic.live.fandomlab.com', 'www.wellnessmachine.it'],
      assets_precompile: ['braun_ic_application.css', 'braun_ic_application.js', 'FileAPI.js'],
      required_attrs: ["privacy"],
      free_provider_share: true,
      interactions_for_anonymous: ["quiz", "share"],
      init_ctas: 3,
      main_reward_name: "credit",
      instantwin_ticket_name: "credit",
      periodicity_kinds: [PERIOD_KIND_DAILY],
      environment: { 'EMAIL_ADDRESS' => 'noreply@shado.tv' }
    )
  end
end

