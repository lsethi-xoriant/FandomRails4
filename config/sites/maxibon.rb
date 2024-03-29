module Fandom
  class Application < Rails::Application
    register_fandom_site(
      id: 'maxibon', 
      title: 'Maxibon The Pool',
      domains: ['maxibon.fandom.localdomain', 'maxibon.shado.tv', 'maxibon.stage.fandomlab.com', 'maxibon.dev.fandomlab.com', 'maxibon.live.fandomlab.com', 'www.maxibon.it', 'maxibon.it', '10.1.30.104'],
      assets_precompile: ['maxibon_application.css', 'maxibon_application.js'],
      environment: { 
        'EMAIL_ADDRESS' => 'noreply@maxibon.it', 
      },
      force_facebook_tab: 'https://apps.facebook.com/shadostage', #'https://www.facebook.com/testshado/app_354949221264454'
      public_pages: Set.new(["calltoaction#share_free", "calltoaction#update_play_interaction"])
    )
  end
end

=begin
  module Fandom
    class Application < Rails::Application
      register_fandom_site(
        id: 'maxibon', 
        domains: ['maxibon.fandom.localdomain', 'maxibon.shado.tv', 'maxibon.stage.fandomlab.com', 'maxibon.live.fandomlab.com', 'www.maxibon.it', 'maxibon.it'],
        assets_precompile: ['maxibon_application.css', 'maxibon_application.js'],
        environment: { 
          'EMAIL_ADDRESS' => 'noreply@maxibon.it', 
        },
        
        desktop_iframe: {
          forced_except: ['youtube'],
          allowed_referrers: ['maxibon.it', 'facebook.com', 'youtube.com'] 
        },

        logged_url: 'https://www.facebook.com/MaxibonMaxiconoItalia/app_597403706967732'

        #force_facebook_tab: 'https://www.facebook.com/MaxibonMaxiconoItalia/app_597403706967732' 
      )
    end
  end
=end