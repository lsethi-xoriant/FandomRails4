#!/bin/env ruby
# encoding: utf-8

class ProfileController < ApplicationController
  include ProfileHelper
  include ApplicationHelper
  include RankingHelper
  include RewardHelper

  before_filter :check_user_logged

  def update_user
    user_params = JSON.parse(params["obj"]) rescue params["obj"]
    user_params.delete "avatar"
    user_params.delete "_avatar"

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

  def check_user_logged
    if current_user.nil? || stored_anonymous_user?
      if cookies[:connect_from_page].blank?
        if $site.id == "ballando"
          profile_path = Rails.configuration.deploy_settings["sites"][$site.id]["stream_url"] || request.url
        else
          profile_path = request.url 
        end
        cookies[:connect_from_page] = profile_path
      end
      redirect_to "/users/sign_in"
    end
  end

  def complete_for_contest
    user_params = params[:user]

    # braun_ic
    if $site.id == "braun_ic" && current_user.day_of_birth.present? && current_user.month_of_birth.present? && current_user.year_of_birth.present?
      user_params[:day_of_birth] = current_user.day_of_birth
      user_params[:month_of_birth] = current_user.month_of_birth
      user_params[:year_of_birth] = current_user.year_of_birth
    end 

    extra_fields = get_form_attributes(params["interaction_id"])

    form_attributes_valid, errors, user_extra_fields = validate_upload_extra_fields(user_params, extra_fields)

    user_params.delete :email
    user_params.delete :id

    response = {}
    if !form_attributes_valid
      response[:errors] = errors
    elsif !update_current_user_info_with_contest_registration_params(user_params)
      response[:errors] = current_user.errors.full_messages
    else
      log_audit("registration completion", { 'form_data' => params[:user], 'user_id' => current_user.id })
    end

    respond_to do |format|
      format.json { render json: response.to_json }
    end
  end

  def update_current_user_info_with_contest_registration_params(user_extra_fields)
    user_model_fields = {}
    aux = {}
    user_model_attributes = User.accessible_attributes.to_a
    user_extra_fields.each do |extra_field, value|
      entry = { extra_field => value }
      if user_model_attributes.include?(extra_field)
        user_model_fields.merge!(entry)
      else
        aux.merge!(entry)
      end
    end
    if current_user.aux
      aux = current_user.aux.merge(aux)
    end
    current_user.update_attributes(user_model_fields.merge({ "aux" => aux }))
  end

  def index
    if small_mobile_device?
      @level = get_current_level
      @my_position, total = get_my_general_position_in_property

      render template: "/profile/index_mobile"
    else
      # The destination page is initalized by Devise gem.
      redirect_to ($context_root.present? ? "/#{$context_root}/users/edit" : "/users/edit")
    end
  end


  def remove_provider
    provider_name = "#{params[:provider]}_#{$site.id}"
  	auth = current_user.authentications.find_by_provider(provider_name)
  	auth.destroy if auth
  	redirect_to "/profile/edit"
  end

  def rankings
    rank = get_general_ranking()

    @property_rank = get_full_rank(rank)
    
    @fan_of_days = []
    (1..8).each do |i|
      day = Time.now - i.day
      winner = get_winner_of_day(day)
      @fan_of_days << {"day" => "#{day.strftime('%d')} #{calculate_month_string_ita(day.strftime('%m').to_i)[0..2].camelcase}", "winner" => winner} if winner
    end
    
    gallery_tags = get_tags_with_tag("gallery")
    gallery_tag = Tag.find_by_name("gallery")
    @property_rankings = get_property_rankings()
    
    gallery_tags = get_gallery_for_ranking_by_property(gallery_tags)
    @galleries = order_elements(gallery_tag, gallery_tags.sort_by{ |tag| tag.created_at }.reverse)
    
    if small_mobile_device?
      render template: "profile/rankings_mobile"
    else
      render template: "profile/rankings"
    end
  end

  def get_gallery_for_ranking_by_property(gallery_tags)
    property = get_property()
    gallery_tags.delete_if do |gallery_tag| 
      has_ranking = get_extra_fields!(gallery_tag)["has_ranking"]
      has_ranking ? (has_ranking["value"] == false) : false
    end
    if property.present? && property.name == $site.default_property
      gallery_tags
    elsif property.present?
      property_name = property.name
      gallery_tag_ids = gallery_tags.map { |t| t.id }
      Tag.includes(tags_tags: :other_tag).where("other_tags_tags_tags.name = ? AND tags.id in (?)", property_name, gallery_tag_ids).references(:tags_tags, :other_tag)
    else 
      []
    end
  end

  def rewards
    property = get_property()
    if property.present?
      property_name = property.name
    end

    levels, levels_use_prop = rewards_by_tag("level")
    @levels = levels.present? ? prepare_levels_to_show(levels, property_name) : nil
    
    badge_tag = Tag.find_by_name("badge")
    badges, badges_use_prop = rewards_by_tag("badge")
    if badges && badges_use_prop
      @badges = badges[property_name]
      if @badges
        @badges = order_elements(badge_tag, @badges)
      end
    end

    if small_mobile_device?
      render template: "/profile/rewards_mobile"
    else      
      if levels_use_prop
        @my_levels = get_other_property_rewards("level", property_name)
      end
      if badges_use_prop
        @mybadges = get_other_property_rewards("badge", property_name)
      end
    end   
  end

  def get_property_rankings
    property = get_property()
    if property.present?
      property_name = property.name
    end

    cache_short(get_property_rankings_cache_key(property_name)) do
      property_rankings = Array.new
      properties = get_tags_with_tag("property")
      properties.each do |p|
        if property_name != p.name
          thumb_url = get_upload_extra_field_processor(get_extra_fields!(p)['thumbnail'], :medium) rescue ""
          property_ranking = {"title" => p.title, "thumb" => thumb_url, "link" => "#{get_root_path(p.name)}/profile/rankings"}
          property_rankings << property_ranking
        end  
      end
      property_rankings
    end
  end

  def get_root_path(property_name)
    property_name == $site.default_property ? "" : "/#{property_name}"
  end
  
  def levels
    @rewards_to_show, @are_properties_used = rewards_by_tag("level")
  end

  def badges
    @rewards_to_show, @are_properties_used = rewards_by_tag("badge")
  end

  def prizes
    # TODO: adjust.
  end

  def load_more_notice
    notices = Notice.where("user_id = ?", current_user.id).order("created_at DESC").limit(params[:count])
    notices_list = group_notice_by_date(notices)
    respond_to do |format|
      format.json { render :json => notices_list.to_json }
    end
  end
  
  def superfan_contest
    contest_points = get_counter_about_user_reward(SUPERFAN_CONTEST_REWARD, false) || 0

    @points_to_achieve = SUPERFAN_CONTEST_POINTS_TO_WIN - contest_points
    @already_win = @points_to_achieve <= 0
  end
  
  def notices
    Notice.mark_all_as_viewed()
    expire_cache_key(notification_cache_key(current_user.id))
    notices = Notice.where("user_id = ?", current_user.id).order("created_at DESC")
    @notices_list = group_notice_by_date(notices)
  end

  def group_notice_by_date(notices)
    notices_list = []
    
    notices.each do |n|
      date = n.created_at.strftime("%d %B %Y")
      notices_list << {date: date, notice: n}
    end
    notices_list
  end

  def show
  end
  
end
