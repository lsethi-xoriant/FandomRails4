 class Api::V2::BaseController < ApplicationController
    # default answer type
    respond_to :json    

    # disable CSRF protection
    protect_from_forgery with: :null_session

    # disable session
    before_action :destroy_session
    def destroy_session
      request.session_options[:skip] = true
    end    

    # use simple_authentication_token gen for authentication
    acts_as_token_authentication_handler_for User, fallback: :none

    # utilities

    def respond_with_errors(errors, status = 400)
      response = { "errors" => errors }.to_json
      respond_with response, :status=>status
    end

    def respond_with_json(x)
      respond_with x.to_json
    end
end