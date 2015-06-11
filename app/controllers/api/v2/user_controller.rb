 class Api::V2::UserController < ApplicationController
    
    respond_to :json
    
    def sign_in
      username = params[:username]
      password = params[:password]
      user = User.where(username: username).first
      if !user.nil? && user.valid_password?(password)
        respond_with user.to_json
      else
        respond_with nil
      end
    end

    def sign_up
      user = User.create(params[:user])
      if user.errors.blank?
        respond_with user.to_json
      else
        respond_with user.errors.to_json
      end
    end

end