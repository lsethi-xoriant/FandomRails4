module AnonymousNavigationHelper
  
  def interaction_allowed?(resource_type, user = nil)
    user = current_user unless user
    if registered_user?
      true
    else
      $site.interactions_for_anonymous.present? && $site.interactions_for_anonymous.include?(resource_type)
    end
  end

  def stored_anonymous_user?(user = nil)
    user = current_user unless user
    user && !user.anonymous_id.blank?
  end

  def registered_user?(user = nil)
    user = current_user unless user
    user && user.anonymous_id.blank?
  end

  def new_stored_anonymous_user()
    name = "anonymous#{Digest::MD5.hexdigest(rand.to_s)[0..5]}"
    password = Devise.friendly_token.first(6)

    user_params = {
      email: "#{name}@shado.tv", 
      username: name, 
      password: password, 
      password_confirmation: password
    }

    if request_via_api?
      user_params[:anonymous_id] = Devise.friendly_token
      user_params[:authentication_token] = Devise.friendly_token
    else
      user_params[:anonymous_id] = session[:session_id]
    end

    User.new(user_params)
  end

  def create_and_sign_in_stored_anonymous_user()
    user = new_stored_anonymous_user()
    while !user.save
      user = new_stored_anonymous_user()
    end
    sign_in(user)
    user
  end

  def request_via_api?
    session.empty?
  end

end
