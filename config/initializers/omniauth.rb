Rails.application.config.middleware.use OmniAuth::Builder do
  provider :twitter, ENV["TWITTER_APP_ID"], ENV["TWITTER_APP_SECRET"] # "3JRU786XWcHpn5jv5jE7ZQ", "BtRGAFqPhVenLj0xBjmqFl13FEccQ4VzdrZM8Mc0PZg"
  #provider :facebook, Rails.configuration.deploy_settings["sites"]["fandom"]["facebook"]["app_id"], Rails.configuration.deploy_settings["sites"]["fandom"]["facebook"]["app_secret"], :scope => 'email, user_birthday, read_stream, publish_stream'
  provider :facebook_fandom, Rails.configuration.deploy_settings["sites"]["fandom"]["facebook"]["app_id"], Rails.configuration.deploy_settings["sites"]["fandom"]["facebook"]["app_secret"], :scope => 'email, user_birthday, read_stream, publish_stream'
end

OmniAuth.config.on_failure = Proc.new { |env| [302, { 'Location' => "/auth/failure", 'Content-Type'=> 'text/html' }, []] }

module OmniAuth::Strategies

  class FacebookFandom < Facebook
    def name 
      :facebook_fandom
    end 
  end

end