#!/bin/env ruby
# encoding: utf-8

require 'fandom_utils'
require 'net/http'

class ApplicationController < ActionController::Base
  protect_from_forgery except: [:instagram_new_tagged_media_callback, :facebook_app], :if => proc {|c| Rails.configuration.deploy_settings.fetch('forgery_protection', true) }
  include FandomUtils
  include ApplicationHelper

  before_filter :fandom_before_filter
  
  rescue_from CanCan::AccessDenied do |exception|
    log_error('authorization denied', { 'exception' => exception.to_s, 'backtrace' => exception.backtrace })
    redirect_to "/"
  end

  def cookies_policy
  end

  def update_basic_share_interaction
    response = Hash.new
    
    response[:ga] = Hash.new
    response[:ga][:category] = "UserInteraction"
    response[:ga][:action] = "CreateOrUpdate"
    response[:ga][:label] = "Share"

    interaction = Interaction.find(params[:interaction_id])

    aux = {
      providers: {
        params[:provider] => 1
      }
    }

    if params[:user_interactions_history].present?
      aux[:user_interactions_history] = params[:user_interactions_history]
    end

    user_interaction, response[:outcome] = create_or_update_interaction(current_or_anonymous_user, interaction, nil, nil, aux.to_json)
    
    response[:current_user] = build_current_user() if current_user && $site.id != "disney"
    if stored_anonymous_user? && $site.interactions_for_anonymous_limit.present?
      user_interactions_count = current_user.user_interactions.count
      response[:notice_anonymous_user] = user_interactions_count > 0 && user_interactions_count % $site.interactions_for_anonymous_limit == 0
    end

    respond_to do |format|
      format.json { render json: response.to_json }
    end
    
  end

  def get_context()
    $context_root
  end

  def facebook_app
    cookies[:oauth_connect_from_page] = Rails.configuration.deploy_settings["sites"][get_site_from_request(request).id]["authentications"]["facebook"]["app"]
    redirect_to "/"
  end

  def user_cookies
    # domain: request.domain
    user_cookies = { value: true, expires: 1.year.from_now } 
    secure_cookies = get_deploy_setting('secure_cookies', false)
    if secure_cookies
      user_cookies[:secure] = secure_cookies
    end
    cookies[:user_cookies] = user_cookies
     
    respond_to do |format|
      format.json { render json: {}.to_json }
    end
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

  def index
    if current_user
      compute_save_and_notify_context_rewards(current_user)
    end

    return if cookie_based_redirect?
    
    init_ctas = $site.init_ctas
    
    property = get_property()
    featured_tag_name = "featured"

    if property
      property_name = property.name
      featured_content_previews = get_content_previews(featured_tag_name, [property])
    else
      featured_content_previews = nil
    end

    params = { "page_elements" => ["like", "comment", "share", "randomresource"] }
    @calltoaction_info_list, @has_more = get_ctas_for_stream(property_name, params, init_ctas)

    @aux_other_params = { 
      calltoaction_evidence_info: true,
      featured_content_previews: featured_content_previews,
      sidebar_tag: "sidebar-home",
      tag_menu_item: "home"
    }
  end

  def init_aux()
    filters = get_tags_with_tag("featured")
    current_property = get_tags_with_tag($context_root)

    if filters.any?
      if $context_root
        filters = filters & current_property
      end
      filter_info = []
      filters.each do |filter|
        filter_info << {
          "id" => filter.id,
          "background" => get_extra_fields!(filter)["label-background"],
          "icon" => get_extra_fields!(filter)["icon"],
          "title" => get_extra_fields!(filter)["title"],
          "image" => (get_upload_extra_field_processor(get_extra_fields!(filter)["image"], :thumb) rescue nil),
          "mobile" => small_mobile_device?()
        }
      end
    end

    properties = get_tags_with_tag("property")

    if properties.any?
      property_info = []
      properties.each do |property|
        property_info << {
          "id" => property.id,
          "background" => get_extra_fields!(property)["label-background"],
          "icon" => get_extra_fields!(property)["icon"],
          "title" => property.title,
          "image" => (get_upload_extra_field_processor(get_extra_fields!(property)["image"], :custom) rescue nil) 
        }
      end
    end

    calltoaction_evidence_info = cache_short(get_evidence_calltoactions_cache_key()) do   
      highlight_calltoactions = get_highlight_calltoactions()
      active_calltoactions_without_rewards = CallToAction.includes(:rewards, :interactions).active.where("rewards.id IS NULL").references(:rewards, :interactions)
      if highlight_calltoactions.any?
        last_calltoactions = active_calltoactions_without_rewards.where("call_to_actions.id NOT IN (?)", highlight_calltoactions.map { |calltoaction| calltoaction.id }).limit(3).to_a
      else
        last_calltoactions = active_calltoactions_without_rewards.active.limit(3).to_a
      end
      calltoactions = highlight_calltoactions + last_calltoactions
      calltoaction_evidence_info = []
      calltoactions.each do |calltoaction|
        calltoaction_evidence_info << {
          "id" => calltoaction.id,
          "status" => compute_call_to_action_completed_or_reward_status(MAIN_REWARD_NAME, calltoaction),
          "thumbnail_carousel_url" => calltoaction.thumbnail(:carousel),
          "title" => calltoaction.title,
          "description" => calltoaction.description
        }
      end
      calltoaction_evidence_info
    end

    {
      "tenant" => get_site_from_request(request)["id"],
      "anonymous_interaction" => get_site_from_request(request)["anonymous_interaction"],
      "main_reward_name" => MAIN_REWARD_NAME,
      "kaltura" => get_deploy_setting("sites/#{request.site.id}/kaltura", nil),
      "filter_info" => filter_info,
      "property_info" => property_info,
      "calltoaction_evidence_info" => calltoaction_evidence_info,
      "enable_comment_polling" => get_deploy_setting('comment_polling', true)
    }

  end
  
  def update_call_to_action_in_page_with_tag

    if params[:tag_id].present?
      calltoactions_count = CallToAction.active.includes(:call_to_action_tags).where("call_to_action_tags.tag_id = ?", params[:tag_id]).references(:call_to_action_tags).count
      calltoactions = CallToAction.active.includes(:call_to_action_tags).where("call_to_action_tags.tag_id = ?", params[:tag_id]).references(:call_to_action_tags).limit(3)
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
        calltoaction.interactions.where("resource_type = 'Comment' AND when_show_interaction <> 'MAI_VISIBILE'").to_a
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
      interactions_overvideo_during = calltoaction.interactions.where("when_show_interaction = 'OVERVIDEO_DURING'")
      if(interactions_overvideo_during.any?)
        calltoactions_during_video_interactions_second[calltoaction.id] = Hash.new
        interactions_overvideo_during.each do |interaction|
          calltoactions_during_video_interactions_second[calltoaction.id][interaction.id] = interaction.seconds
        end
      end
    end
    calltoactions_during_video_interactions_second
  end

  before_filter :basic_http_security_check

  def basic_http_security_check
    credentials = get_optional_http_security_credentials()
    if !request_via_api? && !credentials.nil?
      authenticate_or_request_with_http_basic do |username, password|
        username == credentials['username'] && password == credentials['password']
      end
    end
  end

  def get_optional_http_security_credentials
    credentials = get_deploy_setting("sites/#{$site.id}/http_security_credentials", nil)
    credentials = get_deploy_setting("http_security_credentials", nil) unless credentials
    if credentials 
      credentials
    # backward compatibility
    elsif get_deploy_setting("http_security", false)
      { 'username' => 'admin', 'password' => 'supersecret'} 
    else
      nil
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
    cookies["redirect_to_page"] = request.referrer
    redirect_to "/auth/facebook_#{request.site.id}"
  end

  def anchor_provider_from_calltoaction
    cookies[:calltoaction_id] = params[:calltoaction_id]
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

  def modify_instagram_upload_object
    interaction = Interaction.find(params[:interaction_id])
    aux = interaction.aux || {}
    if ((aux["configuration"]["type"] == "instagram" && aux["configuration"]["instagram_tag"]) rescue false)
      res, delete_success = delete_instagram_tag_subscription(interaction)
    end
    delete_success ||= true
    unless delete_success == false
      res, add_success, subscription = add_instagram_tag_subscription(interaction, params[:tag_name])
    end
    add_success ||= false
    if delete_success and add_success
      render :json => subscription["id"].to_i
    else
      render :json => { :errors => "Errore #{delete_success ? "nell'aggiunta" : "nella disiscrizione"} del tag" }, :status => 500
    end
  end

  def add_instagram_tag_subscription(interaction, tag_name)
    ig_settings = get_deploy_setting("sites/#{request.site.id}/authentications/instagram", nil)

    # To create a subscription, make a POST request to the subscriptions endpoint.
    #
    #  Examples:
    #
    #    curl -F 'client_id=[CLIENT_ID]' \
    #    -F 'client_secret=[CLIENT_SECRET]' \
    #    -F 'object=tag' \
    #    -F 'aspect=media' \
    #    -F 'object_id=[TAG_NAME]' \
    #    -F 'callback_url=http://[example.com]/instagram_tag_subscription/[TAG_NAME]' \
    #    https://api.instagram.com/v1/subscriptions/
    request_params = { 
      "client_id" => ig_settings["client_id"], 
      "client_secret" => ig_settings["client_secret"], 
      "object" => "tag", 
      "aspect" => "media", 
      "object_id" => tag_name, 
      "callback_url" => "http://dev.fandomlab.com#{Setting.find_by_key(INSTAGRAM_CALLBACK_URL).value}"
    }

    headers = {'Content-Type' => 'application/json', 'Accept' => 'application/json'}

    res = HTTParty.post("https://api.instagram.com/v1/subscriptions/",
      { 
        :headers => headers,
        :body => request_params
      })

    res = JSON.parse(res.body)
    success = res["meta"]["code"] == 200 rescue false

    if success

      # We find the requested subscription from Instagram subscriptions list provided with response ("data" array). Structure below:
      # data : {
      #           "id": "123456",
      #           "type": "subscription",
      #           "object": "tag",
      #           "object_id": "tag_name",
      #           "aspect": "media",
      #           "callback_url": "http://your-callback.com/url/"
      #         }
      new_tag = res["data"]
      aux = interaction.aux || {}
      aux["configuration"] = { "type" => "instagram", "instagram_tag" => { "subscription_id" => new_tag["id"], "name" => new_tag["object_id"] } }
      interaction_updated = interaction.update_attribute(:aux, aux.to_json)

      if interaction_updated
        instagram_subscriptions_setting = Setting.where(:key => INSTAGRAM_SUBSCRIPTIONS_SETTINGS_KEY).first_or_create
        instagram_subscriptions_setting_hash = JSON.parse(instagram_subscriptions_setting.value) rescue {}
        instagram_subscriptions_setting_hash[new_tag["object_id"]] = { "subscription_id" => new_tag["id"], "interaction_id" => interaction.id }
        instagram_subscriptions_setting.value = instagram_subscriptions_setting_hash.to_json
        instagram_subscriptions_setting.save
      end

    end
    interaction_updated ||= false
    [res, (success and interaction_updated), new_tag]
  end

  def delete_instagram_tag_subscription(interaction)
    ig_settings = get_deploy_setting("sites/#{request.site.id}/authentications/instagram", nil)
    request_params = { 
      "client_id" => ig_settings["client_id"], 
      "client_secret" => ig_settings["client_secret"], 
      "id" => interaction.aux["configuration"]["instagram_tag"]["subscription_id"]
    }

    headers = {'Content-Type' => 'application/json', 'Accept' => 'application/json'}

    res = HTTParty.delete("https://api.instagram.com/v1/subscriptions/",
      { 
        :headers => headers,
        :query => request_params
      })

    res = JSON.parse(res.body)
    success = res["meta"]["code"] == 200 rescue false

    if success
      aux = interaction.aux
      old_tag_name = aux["configuration"]["instagram_tag"]["name"]
      aux.delete("configuration")
      interaction_updated = interaction.update_attribute(:aux, aux.to_json)

      if interaction_updated
        instagram_subscriptions_setting = Setting.find_by_key(INSTAGRAM_SUBSCRIPTIONS_SETTINGS_KEY)
        instagram_subscriptions_setting_hash = JSON.parse(instagram_subscriptions_setting.value)
        instagram_subscriptions_setting_hash.delete(old_tag_name)
        instagram_subscriptions_setting.value = instagram_subscriptions_setting_hash.to_json
      end

    end
    [res, (success and interaction_updated)]
  end

  def build_arguments_string_for_request(params)
    res = ""
    params.each_with_index do |(key, value), i|
      connector = i == 0 ? "?" : "&"
      res += connector + "#{key}=#{value}"
    end
    res
  end

  def update_avatar_image
    user = User.find(params[:user_id])
    user.update_attribute(:avatar, params[:avatar])
    redirect_to "/profile/badges"
  end

end