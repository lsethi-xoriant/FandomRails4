#!/bin/env ruby
# encoding: utf-8

class ProfileController < ApplicationController
  include ProfileHelper
  include ApplicationHelper
  include RankingHelper
  include RewardHelper
  
  before_filter :check_user_logged
  
  def check_user_logged
    unless current_user
      if cookies[:connect_from_page].blank?
        profile_path = Rails.configuration.deploy_settings["sites"][get_site_from_request(request)["id"]]["stream_url"] || request.url
        cookies[:connect_from_page] = profile_path
      end
      redirect_to "/users/sign_in"
    end
  end

  def complete_for_contest
    user_params = params[:user]
    
    required_attrs = get_site_from_request(request)["required_attrs"] + ["province", "birth_date", "gender", "location"]
    user_params = user_params.merge(required_attrs: required_attrs)
    user_params[:aux][:$validating_model] = "UserAux"  
    user_params[:major_date] = CONTEST_START_DATE

    response = {}
    if !current_user.update_attributes(user_params)
      response[:errors] = current_user.errors.full_messages
    else
      log_audit("registration completion", { 'form_data' => params[:user], 'user_id' => current_user.id })
    end

    respond_to do |format|
      format.json { render json: response.to_json }
    end
  end

  def index_mobile
    @level = get_current_level;
    @my_position, total = get_my_general_position_in_property
  end

  def index
    if small_mobile_device?
      redirect_to "/profile/index"
    else
      if $context_root.present?
        redirect_to "/#{$context_root}/users/edit"
      else
        redirect_to "/users/edit"
      end
    end
  end

  def remove_provider
    provider_name = "#{params[:provider]}_#{$site.id}"
  	auth = current_user.authentications.find_by_provider(provider_name)
  	auth.destroy if auth
  	redirect_to "/profile/edit"
  end

  def rankings
    property = get_property()
    if property.present?
      property_name = property.name
      rank = Ranking.find_by_name("#{property_name}-general-chart")
    else
      rank = Ranking.find_by_name("general-chart")
    end

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
    
    gallery_tags = get_gallery_for_property(gallery_tags)
    @galleries = order_elements(gallery_tag, gallery_tags.sort_by{ |tag| tag.created_at }.reverse)
    
    if small_mobile_device?
      render template: "profile/rankings_mobile"
    else
      render template: "profile/rankings"
    end
  end

  def get_gallery_for_property(gallery_tags)
    property = get_property()
    if property.present? && property.name == $site.default_property
      gallery_tags
    elsif property.present?
      property_name = property.name
      Tag.includes(:tags_tags => :other_tag).where("other_tags_tags_tags.name = ? AND tags.id in (?)", property_name, gallery_tags.map { |t| t.id })
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

  def get_other_property_rewards(reward_name, property_name)
    myrewards, use_prop = rewards_by_tag(reward_name, current_user)
    other_rewards = []
    if myrewards.present?
      get_tags_with_tag("property").each do |property|
        if myrewards[property.name] && property.name != property_name
          reward = get_max(myrewards[property.name]) do |x,y| 
            y.updated_at <=> x.updated_at # -1, 1 or 0
          end
          other_rewards << { "reward" => reward, "property" => property }
        end
      end
    end
    other_rewards
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
