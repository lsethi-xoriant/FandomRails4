#!/bin/env ruby
# encoding: utf-8

class Sites::BraunIc::ProfileController < ProfileController
  def update_user
    user_params = JSON.parse(params["obj"]) rescue params["obj"]
    user_params.delete "avatar"
    user_params.delete "_avatar"

    if current_user.first_name.present?
      user_params.delete "first_name"
    end

    if current_user.last_name.present?
      user_params.delete "last_name"
    end

    if params["avatar"]
      user_params["avatar"] = params["avatar"]
    end

    response = {}

    result = current_user.update_attributes(user_params)
    if result
      response[:current_user] = build_current_user()
    else
      response[:errors] = current_user.errors.full_messages
    end

    respond_to do |format|
      format.json { render json: response.to_json }
    end
  end  
end
