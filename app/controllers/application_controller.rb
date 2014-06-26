#!/bin/env ruby
# encoding: utf-8

require 'fandom_utils'

class ApplicationController < ActionController::Base
  protect_from_forgery except: :instagram_verify_token_callback

  include FandomUtils
  include ApplicationHelper

  before_filter :fandom_before_filter

  rescue_from CanCan::AccessDenied do |exception|
    flash[:error] = "Access denied!"
    redirect_to "/"
  end

  def index
    @calltoactions = cache_short { CallToAction.active.limit(3).to_a }
    @calltoactions_during_video_interactions_second = Hash.new
    @calltoactions.each do |calltoaction|
      interactions_overvideo_during = calltoaction.interactions.find_all_by_when_show_interaction("OVERVIDEO_DURING")
      if(interactions_overvideo_during.any?)
        @calltoactions_during_video_interactions_second[calltoaction.id] = Hash.new
        interactions_overvideo_during.each do |interaction|
          @calltoactions_during_video_interactions_second[calltoaction.id][interaction.id] = interaction.seconds
        end
      end
    end
  end

  before_filter :authenticate_admin, :if => proc {|c| Rails.env == "production" }

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

  def redirect_into_iframe_path
    session[:redirect_path] = params[:path]
    redirect_to request.site.force_facebook_tab
  end

  def sign_in_fb_from_page
    cookies[:connect_from_page] = request.referrer
    redirect_to "/auth/facebook" 
  end

  def sign_in_tt_from_page
    cookies[:connect_from_page] = request.referrer
    redirect_to "/auth/twitter" 
  end

  def sign_in_simple_from_page
    cookies[:connect_from_page] = request.referrer
    redirect_to "/users/sign_up"
  end

  def how_to
  end

  # curl -F 'client_id=[CLIENT_ID]' \
  #    -F 'client_secret=[CLIENT_SECRET]' \
  #    -F 'object=tag' \
  #    -F 'aspect=media' \
  #    -F 'object_id=[TAG]' \
  #    -F 'callback_url=http://[example.com]/instagram_verify_token_callback' \
  #    https://api.instagram.com/v1/subscriptions/
  def instagram_verify_token_callback
    if params["hub.mode"] && params["hub.mode"] == "subscribe"
      render json: params["hub.challenge"]
    else
      calltoaction_save = true
      InstagramAdminUser.all.each do |iu|
        begin
          user = JSON.parse(open("https://api.instagram.com/v1/users/search?q=#{ iu.nickname }&client_id=f77c4dfff5e048b198504cb97a4c6194&count=1").read)
          instagram = JSON.parse(open("https://api.instagram.com/v1/users/#{ user["data"][0]["id"] }/media/recent/?client_id=#{ ENV["INSTAGRAM_APP_ID"] }&count=5").read)   
          instagram_media = instagram["data"].each do |m|
            if CallToAction.find_by_secondary_id(m["id"]).blank? && m["tags"].include?("NOMETAG")
              img = open(m["images"]["standard_resolution"]["url"])

              # Customize the calltoaction created.
              calltoaction = CallToAction.new(
                title: m["caption"]["text"], image: img, 
                activated_at: Time.at(m["created_time"].to_i - 1.hour), secondary_id: m["id"], media_type: "IMAGE", 
                enable_disqus: true, category_id: (category ? category.id : nil)
              )

              # Anchor interactions to instagram calltoaction.
              # interaction = calltoaction.interactions.build(when_show_interaction: "SEMPRE_VISIBILE", points: 100)
              # interaction.resource = Check.new(title: "CHECK", description: "Foto scattata...")

              calltoaction_save = calltoaction_save && calltoaction.save
            end
          end
        rescue Exception
          calltoaction_save = false
        end
      end
      render json: calltoaction_save.to_json
    end
  end

end
