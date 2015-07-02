module Fandom
  class Application < Rails::Application
    register_fandom_site(
      id: 'braun_ic',
      title: 'BraunIc',
      domains: ['braun-ic.fandom.localdomain', 'braun-ic.stage.fandomlab.com', 'braun-ic.dev.fandomlab.com', 'braun-ic.live.fandomlab.com'],
      free_provider_share: true,
      interactions_for_anonymous: ["quiz", "share"],
      init_ctas: 3,
      periodicity_kinds: [],
      environment: { 'EMAIL_ADDRESS' => 'noreply@shado.tv' }
    )
  end
end

