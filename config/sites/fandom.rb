module Fandom
  class Application < Rails::Application
    register_fandom_site(
      id: 'fandom',
      title: 'Fandom',
      domains: ['fandom.shado.tv', 'fandom.localdomain', 'stage.fandomlab.com', 'dev.fandomlab.com', 'live.fandomlab.com', 'demo.fandomlab.com', 'demo2.fandomlab.com', 'ballando.shado.tv'],
      twitter_integration: true,
      environment: { 'EMAIL_ADDRESS' => 'noreply@shado.tv' }
    )
  end
end

