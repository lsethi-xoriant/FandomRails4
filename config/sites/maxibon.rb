module Fandom
  class Application < Rails::Application
    register_fandom_site(
      id: 'maxibon', 
      domains: ['maxibon.fandom.localdomain', 'maxibon.shado.tv', 'maxibon.stage.fandomlab.com'],
      assets_precompile: ['maxibon_application.css', 'maxibon_application.js'],
      environment: { 
        'EMAIL_ADDRESS' => 'noreply@maxibon.it', 
        'FACEBOOK_APP_ID' => '1480351255532528', 
        'FACEBOOK_APP_SECRET' => '4399a5a802c95ac8ed7b2ed812e5c55a' }
    )
  end
end

