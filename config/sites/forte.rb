module Fandom
  class Application < Rails::Application
    register_fandom_site(
      id: 'forte', 
      title: 'Forte forte forte',
      domains: ['forte.fandom.localdomain', 'forte.shado.tv', 'forte.stage.fandomlab.com', 'forte.live.fandomlab.com', 'forte.dev.fandomlab.com', 'www.stage.community.forte.rai.it', 'www.live.community.forte.rai.it'],
      assets_precompile: ['forte_application.css', 'forte_application.js', 'forte_application_light.js'],
      periodicity_kinds: [PERIOD_KIND_WEEKLY],
      required_attrs: ["username"],
      environment: { 
        'EMAIL_ADDRESS' => 'noreply@forte.it', 
      }
    )
  end
end
