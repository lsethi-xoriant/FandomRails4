#!/bin/env ruby
# encoding: utf-8

require 'fandom_utils'

class ApplicationController < ActionController::Base
  protect_from_forgery except: :instagram_verify_token_callback, :if => proc {|c| Rails.configuration.deploy_settings.fetch('forgery_protection', true) }
  include FandomUtils
  include ApplicationHelper
  include EventHandlerHelper
  include CacheHelper
  include CacheKeysHelper
  include RewardHelper
  include CommentHelper
  include CallToActionHelper
  include CaptchaHelper

  before_filter :fandom_before_filter
  
  rescue_from CanCan::AccessDenied do |exception|
    flash[:error] = "Access denied!"
    redirect_to "/"
  end

  def file_upload_too_large
  end

  def redirect_into_iframe_calltoaction
    cookies["redirect_to_page"] = "/call_to_action/#{params[:calltoaction_id]}"
    redirect_to Rails.configuration.deploy_settings["sites"][get_site_from_request(request)["id"]]["stream_url"]
  end
  
  def cookie_based_redirect?
    if cookies["redirect_to_page"].present?
      page = cookies["redirect_to_page"]
      cookies.delete(:redirect_to_page)
      redirect_to "#{page}"
      true
    else
      false
    end
  end
  
  def delete_current_user_interactions
    authorize! :manage, :all
    current_user.user_interactions.destroy_all

    redirect_to "/"
  end
  
  def get_tag_from_params(name)
    if name
      Tag.find_by_name(name)  
    else
      nil
    end
  end

  def index
    if user_signed_in?
      compute_save_and_notify_context_rewards(current_user)
    end

    return if cookie_based_redirect?
    
    init_ctas = request.site.init_ctas

    # warning: these 3 caches cannot be aggretated for some strange bug, probably due to how active records are marshalled 
    @tag = get_tag_from_params(params[:name])
    
    if @tag.nil? || params[:name] == "home_filter_all" 
      @calltoactions = cache_short("stream_ctas_init_calltoactions") do
        CallToAction.active.limit(init_ctas).to_a
      end
    else
      @calltoactions = cache_short("stream_ctas_init_calltoactions_#{params[:name]}") do
        CallToAction.active.includes(:call_to_action_tags).where("call_to_action_tags.tag_id=?", @tag.id).limit(init_ctas)
      end
    end
    
    @calltoactions_during_video_interactions_second = cache_short("stream_ctas_init_calltoactions_during_video_interactions_second") do
      init_calltoactions_during_video_interactions_second(@calltoactions)
    end

    @calltoactions_comment_interaction = init_calltoactions_comment_interaction(@calltoactions)

    @calltoactions_active_count = cache_short("stream_ctas_init_calltoactions_active_count") do
      CallToAction.active.count
    end

    ########## NEW ANGULAR TEMPLATES ##########
    unless get_site_from_request(request)["id"] == "ballando"
      # TODO: BALLANDO
      @calltoaction_info_list = build_call_to_action_info_list(@calltoactions)
      
      if current_user
        @current_user_info = {
          "facebook" => current_user.facebook(request.site.id),
          "twitter" => current_user.twitter(request.site.id),
          "main_reward_counter" => get_counter_about_user_reward(MAIN_REWARD_NAME, true),
          "registration_fully_completed" => registration_fully_completed?
        }
      end
    end
    ########## NEW ANGULAR TEMPLATES ##########

    @aux = {
      "tenant" => get_site_from_request(request)["id"],
      "anonymous_interaction" => get_site_from_request(request)["anonymous_interaction"],
      "main_reward_name" => MAIN_REWARD_NAME
    }

    @calltoactions_active_interaction = Hash.new

    @home = true
  end

  def registration_fully_completed?
    true
  end
  
  def update_call_to_action_in_page_with_tag

    if params[:tag_id].present?
      calltoactions_count = CallToAction.active.includes(:call_to_action_tags).where("call_to_action_tags.tag_id=?", params[:tag_id]).count
      calltoactions = CallToAction.active.includes(:call_to_action_tags).where("call_to_action_tags.tag_id=?", params[:tag_id]).limit(3)
    else
      calltoactions_count = CallToAction.active.count
      calltoactions = CallToAction.active.limit(3)
    end

    calltoactions_comment_interaction = init_calltoactions_comment_interaction(calltoactions)
    render_calltoactions_str = (render_to_string "/call_to_action/_stream_calltoactions", locals: { calltoactions: calltoactions, calltoactions_comment_interaction: calltoactions_comment_interaction, active_calltoaction_id: nil, calltoactions_active_interaction: Hash.new, aux: nil }, layout: false, formats: :html)

    response = Hash.new
    response = {
      calltoactions_render: render_calltoactions_str,
      calltoactions: calltoactions,
      calltoactions_count: calltoactions_count,
      calltoactions_during_video_interactions_second: init_calltoactions_during_video_interactions_second(calltoactions)
    }
  
    respond_to do |format|
      format.json { render json: response.to_json }
    end
  end

  def init_calltoactions_comment_interaction(calltoactions)
    calltoactions_comment_interaction = Hash.new
    calltoactions.each do |calltoaction|

      interactions = cache_short("calltoaction_#{calltoaction.id}_comment_interactions") do
        calltoaction.interactions.includes(:resource).where("resource_type = 'Comment' AND when_show_interaction <> 'MAI_VISIBILE'").to_a
      end  

      calltoaction_comment_interaction = Hash.new
      if interactions.any?
        interaction = interactions[0]
        calltoaction_comment_interaction[:interaction] = interaction
        comments_to_shown, comments_count = get_last_comments_to_view(interaction)
        calltoaction_comment_interaction[:comments_to_shown_ids] = comments_to_shown.map { |comment| comment.id }
        calltoaction_comment_interaction[:comments_to_shown] = comments_to_shown     
        calltoaction_comment_interaction[:comments_count] = comments_count    
        
        if page_require_captcha?(interaction)
          calltoaction_comment_interaction[:captcha_data] = generate_captcha_response
        end
      end
      calltoactions_comment_interaction[calltoaction.id] = calltoaction_comment_interaction

    end

    calltoactions_comment_interaction

  end

  def init_calltoactions_during_video_interactions_second(calltoactions)
    calltoactions_during_video_interactions_second = Hash.new
    calltoactions.each do |calltoaction|
      interactions_overvideo_during = calltoaction.interactions.find_all_by_when_show_interaction("OVERVIDEO_DURING")
      if(interactions_overvideo_during.any?)
        calltoactions_during_video_interactions_second[calltoaction.id] = Hash.new
        interactions_overvideo_during.each do |interaction|
          calltoactions_during_video_interactions_second[calltoaction.id][interaction.id] = interaction.seconds
        end
      end
    end
    calltoactions_during_video_interactions_second
  end

  before_filter :authenticate_admin, :if => proc {|c| Rails.env == "production" && Rails.configuration.deploy_settings.fetch('http_security', true) }

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
    redirect_to "/auth/facebook_#{request.site.id}"
  end

  def sign_in_tt_from_page
    cookies[:connect_from_page] = request.referrer
    redirect_to "/auth/twitter_#{request.site.id}" 
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

  def update_avatar_image
    user = User.find(params[:user_id])
    user.update_attribute(:avatar, params[:avatar])
    redirect_to "/profile/badges"
  end

end
