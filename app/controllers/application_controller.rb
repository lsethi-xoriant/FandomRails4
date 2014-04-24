#!/bin/env ruby
# encoding: utf-8

require 'fandom_utils'

class ApplicationController < ActionController::Base

  include FandomUtils
  before_filter :fandom_before_filter

  include ApplicationHelper

  rescue_from CanCan::AccessDenied do |exception|
    flash[:error] = "Accesso negato!"
    redirect_to root_url
  end

  protect_from_forgery except: :instagram_verify_token_callback

  #before_filter :authenticate_admin, :if => proc {|c| Rails.env == "production" }

  def authenticate_admin
    authenticate_or_request_with_http_basic do |username, password|
      username == "admin" && password == "supersecret"
    end
  end

  def check_application_client
    unless params[:client_id] && params[:client_secret] && (app_id = Doorkeeper::Application.find_by_uid_and_secret(params[:client_id], params[:client_secret]))
      render :status => :unprocessable_entity,
           :json => { :success => false,
                        :info => "invalid application",
                        :data => {} }
    end
  end

  # def sign_in_fb_from_episode
  #   cookies[:ep] = params[:id].to_i
  #   redirect_to "/auth/facebook" 
  # end

  # def sign_in_simple_from_episode
  #   cookies[:ep] = params[:id].to_i
  #   redirect_to "/sign_up"
  # end

  def instagram_verify_token_callback
    if params["hub.mode"] && params["hub.mode"] == "subscribe"
      render json: params["hub.challenge"]
    else
      instagram = JSON.parse(open("https://api.instagram.com/v1/users/1236788604/media/recent/?client_id=#{ ENV["INSTAGRAM_APP_ID"] }&count=5").read)   
      calltoaction_save = true
      instagram_media = instagram["data"].each do |m|
        if Calltoaction.find_by_secondary_id(m["id"]).blank? && m["tags"].include?("fandomshado")
          img = open(m["images"]["standard_resolution"]["url"])
          calltoaction = Calltoaction.new(title: m["caption"]["text"], image: img, property_id: Property.first.id, 
                                          activated_at: Time.at(m["created_time"].to_i), secondary_id: m["id"], media_type: "IMAGE")
          interaction = calltoaction.interactions.build(when_show_interaction: "SEMPRE_VISIBILE", points: 100)
          interaction.resource = Check.new(title: "CHECK", description: "Foto scattata...")
          calltoaction_save = calltoaction_save && calltoaction.save
        end
      end
      render json: calltoaction_save.to_json
    end
  end

  def reset_app
    RewardingUser.destroy_all
    GeneralRewardingUser.destroy_all
    Userinteraction.destroy_all
    UserBadge.destroy_all
    UserComment.destroy_all
    UserLevel.destroy_all
    Quiz.update_all(cache_correct_answer: 0)
    Quiz.update_all(cache_wrong_answer: 0)
    Interaction.update_all(cache_counter: 0)
    redirect_to "/"
  end

end
