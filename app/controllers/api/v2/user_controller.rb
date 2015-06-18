 class Api::V2::UserController < Api::V2::BaseController
    
    # this has to be called user_sign_in instead of just sign_in to avoid conflicts with devise
    def user_sign_in
      username = params[:username]
      password = params[:password]

      user = User.where(username: username).first
      if !user.nil? && user.valid_password?(password)
        user.authentication_token = Devise.friendly_token
        user.save()
        respond_with_json user
      else
        respond_with_errors ['invalid credentials'], 401
      end
    end

    def user_sign_up
      user = User.create(params[:user])
      if user.errors.blank?
        respond_with_json user
      else
        respond_with_errors user.errors
      end
    end

end