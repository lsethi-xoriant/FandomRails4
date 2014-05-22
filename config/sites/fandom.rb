module Fandom
  class Application < Rails::Application
    register_fandom_site(
      id: 'fandom',
      domains: ['fandom.shado.tv', 'fandom.localdomain'],
      twitter_integration: true
    )
  end
end

