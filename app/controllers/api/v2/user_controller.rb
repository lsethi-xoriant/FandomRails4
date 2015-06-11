 class Api::V2::UserController < ApplicationController
    
    respond_to :json
    
    def sign_in
      user = may_get_user(params[:username], params[:password])
      if user.nil?
        respond_with nil
      else
        respond_with user.to_json
      end
    end

    def may_get_user(username, password)
      if !username.nil? && !password.nil?
        user = User.where(username: username).first
        if !user.nil? && user.valid_password?(password)
          return user
        end
      end
      return nil
    end

end