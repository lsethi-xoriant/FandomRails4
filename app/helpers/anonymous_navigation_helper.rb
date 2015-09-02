require 'fandom_utils'

module AnonymousNavigationHelper

  def anonymous_user
    cache_medium('anonymous_user') { 
      User.find_by_email("anonymous@shado.tv")
    }
  end

  def anonymous_user?(user = nil)
    user = current_user unless user
    user.nil? || (user.present? && (user.anonymous_id.present? || anonymous_user.id == user.id))
  end
  
  def interaction_allowed?(resource_type, user = nil)
    user = current_user unless user
    if anonymous_user?
      $site.interactions_for_anonymous.present? && $site.interactions_for_anonymous.include?(resource_type)
    else
      true
    end
  end

  def stored_anonymous_user?(user = nil)
    user = current_user unless user
    user && !user.anonymous_id.blank?
  end

  def new_stored_anonymous_user()
    name = "anonymous#{Digest::MD5.hexdigest(rand.to_s)[0..5]}"
    password = Devise.friendly_token.first(6)

    user_params = {
      email: "#{name}@shado.tv", 
      username: name, 
      password: password, 
      password_confirmation: password,
      privacy: true
    }

    if request_via_api?
      user_params[:anonymous_id] = Devise.friendly_token
      user_params[:authentication_token] = Devise.friendly_token
    else
      user_params[:anonymous_id] = session.id
    end

    User.new(user_params)
  end

  def create_and_sign_in_stored_anonymous_user()
    user = new_stored_anonymous_user()
    while !user.save
      user = new_stored_anonymous_user()
    end
    change_global_user_id(user.id)
    sign_in(user)
    user
  end

  def request_via_api?
    self.is_a? Api::V2::BaseController
  end
  
  def adjust_anonymous_user(params)
    resource = current_user
    resource.assign_attributes(email: nil, username: nil)
    resource.assign_attributes(params)
    if resource.valid? # TODO: comment this
      resource.assign_attributes(anonymous_id: nil)
      sign_out(current_user) # if request_via_api?
    end
    resource
  end

end
