 class Api::V2::UserController < Api::V2::BaseController
    
    # this has to be called user_sign_in instead of just sign_in to avoid conflicts with devise
    def user_sign_in
      username = params[:username]
      password = params[:password]

      if username.include?('@')
        user = User.where(email: username).first
      else
        user = User.where(username: username).first
      end

      if !user.nil? && user.valid_password?(password)
        user.authentication_token = Devise.friendly_token
        user.save()
        respond_with_json user
      else
        respond_with_errors ['invalid credentials'], 401
      end
    end

    def user_sign_up
      user_params = {
          email: params["email"], 
          first_name: params["first_name"], 
          last_name: params["last_name"], 
          password: params["password"], 
          password_confirmation: params["password_confirmation"]
      }

      if current_user
        user = adjust_anonymous_user(user_params)
        if user.errors.empty?
          user.save()
        end
      else
        authentication_token = Devise.friendly_token
        user_parmas[:authentication_token] = authentication_token
        user = User.create(user_parmas)
      end

      if user.errors.blank?
        respond_with_json user
      else
        respond_with_errors user.errors.full_messages
      end
    end

    def facebook_provider_name
      "facebook_#{$site.id}"
    end

    def facebook_sign_in
      token = params[:token]
      koala = Koala::Facebook::API.new(token)
      facebook_user = koala.get_object('me')
      log_info("api facebook sign in", { data: facebook_user })

      # TODO: handle authentications table
      user = User.find_by_email(facebook_user["email"])
      if user
        user.authentication_token = Devise.friendly_token
        user.save()
        respond_with_json user
      else
        password = Devise.friendly_token.first(8)
        authentication_token = Devise.friendly_token
        user = User.create(
          email: facebook_user["email"], 
          first_name: facebook_user["first_name"], 
          last_name: facebook_user["last_name"], 
          password: password, 
          password_confirmation: password, 
          authentication_token: authentication_token)
        if user.errors.blank?
          respond_with_json user
        else
          respond_with_errors user.errors
        end
      end
    end

end