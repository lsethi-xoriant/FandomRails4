module Fandom
  class Application < Rails::Application
    register_fandom_site(
      id: 'maxibon', 
      domains: ['maxibon.fandom.localdomain']
    )
  end
end

