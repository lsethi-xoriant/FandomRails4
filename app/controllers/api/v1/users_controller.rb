class Api::V1::UsersController < ApplicationController
  respond_to :json
  doorkeeper_for :me

  def me
  	respond_with User.find(doorkeeper_token.resource_owner_id).to_json
  end
end
