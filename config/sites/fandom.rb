module Fandom
  class Application < Rails::Application
    register_fandom_site(
      id: 'fandom',
      domains: ['fandom.shado.tv', 'fandom.localdomain', 'stage.fandomlab.com', 'live.fandomlab.com'],
      twitter_integration: true,
      environment: { 'EMAIL_ADDRESS' => 'noreply@shado.tv' }
    )
  end
end

