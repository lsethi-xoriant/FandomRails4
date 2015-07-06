module Fandom
  class Application < Rails::Application
    register_fandom_site(
      id: 'fandom',
      title: 'Fandom',
      domains: ['localhost', 'fandom.shado.tv', 'fandom.localdomain', 'stage.fandomlab.com', 'dev.fandomlab.com', 'live.fandomlab.com', 'demo.fandomlab.com', 'demo2.fandomlab.com'],
      twitter_integration: true,
      interactions_for_anonymous: ["quiz", "check", "play", "share", "vote", "like", 'pin'],
      #interactions_for_anonymous_limit: 5,
      free_provider_share: true,
      default_property: "all",
      allowed_context_roots: ["all", "sport", "series", "talent", "music", "branded"],
      init_ctas: 6,
      environment: { 'EMAIL_ADDRESS' => 'noreply@shado.tv' }
    )
  end
end

