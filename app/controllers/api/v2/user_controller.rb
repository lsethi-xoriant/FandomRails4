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

    def facebook_provider_name
      "facebook_#{$site.id}"
    end

    def facebook_sign_in
      token = params[:token]
      token = "CAAJn9fHaIYgBALw5lX74nCPhyWLaCAEYeZBXZB6MujbA6weQT95lLAl1krZBZCrNqfqHNIlAvZCiqL12PMRA3QDDi4aszfopWWKZAegsedY6NJMdF8ABLIN2oYA3FY5Bq8hGucKC7nJk2hWnbs1x6XA6PixZC3rG90JJm5P0vwjpZAbnGxuLuG35M1gtzuFCJodu4dP4Ggox3JxA2k4fgOoQ"
      koala = Koala::Facebook::API.new(token)
      facebook_user = koala.get_object('me')

      # TODO: handle authentications table
      user = User.find_by_email(facebook_user["email"])
      if user
        respond_with_json user
      else
        password = Devise.friendly_token.first(8)
        user = User.create(email: facebook_user["email"], first_name: facebook_user["first_name"], last_name: facebook_user["last_name"], password: password, password_confirmation: password)
        if user.errors.blank?
          respond_with_json user
        else
          respond_with_errors user.errors
        end
      end
    end

end