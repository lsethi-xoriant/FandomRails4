module Fandom
  class Application < Rails::Application
    register_fandom_site(
      id: 'disney', 
      domains: ['disney.fandom.localdomain', 'disney.stage.fandomlab.com', 'disney.live.fandomlab.com', 'disney.dev.fandomlab.com', 'disney.fandom.disneychannel.it', 'disney.dev.dc.fandomlab.com', 'disney.stage.dc.fandomlab.com', 'disney.live.dc.fandomlab.com', 'community.disneychannel.it', 'disney.fandom.disneychannel.it'],
      default_property: "disney-channel",
      assets_precompile: ['disney_application.css', 'disney_application.js', 'disney_ie9.css', 'FileAPI.js'],
      twitter_integration: true,
      allowed_context_roots: ["violetta"],
      init_ctas: 6,
      free_provider_share: true,
      aws_transcoding: true,
      galleries_split_by_property: false,
      assets:{
        "anon_avatar" => "disney_anon.png",
        "community_logo" => "disney_community_logo.png"
      }
    )      
  end
end

