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
    user && user.anonymous_id.present?
  end

  def registered_user?(user = nil)
    user = current_user unless user
    user && user.anonymous_id.nil?
  end

  def new_stored_anonymous_user()
    name = "anonymous#{Digest::MD5.hexdigest(rand.to_s)[0..5]}"
    password = Devise.friendly_token.first(6)
    User.new(anonymous_id: session[:session_id], email: "#{name}@shado.tv", username: name, password: password, password_confirmation: password)
  end

  def create_and_sign_in_stored_anonymous_user()
    user = new_stored_anonymous_user()
    while !user.save
      user = new_stored_anonymous_user()
    end
    sign_in(user)
    user
  end

end
