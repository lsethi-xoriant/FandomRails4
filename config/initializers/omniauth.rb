Rails.application.config.middleware.use OmniAuth::Builder do
  provider :twitter, ENV["TWITTER_APP_ID"], ENV["TWITTER_APP_SECRET"] # "3JRU786XWcHpn5jv5jE7ZQ", "BtRGAFqPhVenLj0xBjmqFl13FEccQ4VzdrZM8Mc0PZg"
  provider :facebook, ENV["FACEBOOK_APP_ID"], ENV["FACEBOOK_APP_SECRET"], :scope => 'email, user_birthday, read_stream, publish_stream', :display => 'popup'
end

OmniAuth.config.on_failure = Proc.new { |env| [302, { 'Location' => "/auth/failure", 'Content-Type'=> 'text/html' }, []] }