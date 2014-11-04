#!/bin/env ruby
# encoding: utf-8

class ProfileController < ApplicationController
  include ProfileHelper
  include ApplicationHelper
  
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

  def index
  end

  def remove_provider
  	auth = current_user.authentications.find_by_provider(params[:provider])
  	auth.destroy if auth
  	redirect_to "/profile/edit"
  end

  def rankings
  end

  def levels
    @rewards_to_show, @are_properties_used = rewards_by_tag("level")
  end

  def badges
    @rewards_to_show, @are_properties_used = rewards_by_tag("badge")
  end

  def rewards_by_tag(tag_name)
    tag_to_rewards = get_tag_to_rewards()

    # rewards_from_param can include badges or levels 
    rewards_from_param = tag_to_rewards[tag_name] 

    property_tags = get_tags_with_tag("property")

    if property_tags.present?

      rewards_to_show = Hash.new

      property_tag_names = property_tags.map{ |tag| tag.name }

      tag_to_rewards.each do |tag_name, rewards|
        if property_tag_names.include?(tag_name)
          rewards_to_show[tag_name] = rewards & rewards_from_param
        end
      end

      are_properties_used = are_properties_used?(rewards_to_show)
     
      unless are_properties_used
        rewards_to_show = rewards_from_param
      end

    else
      are_properties_used = false
      rewards_to_show = rewards_from_param
    end

    [rewards_to_show, are_properties_used]
  end

  def are_properties_used?(rewards_to_show)
    not_empty_properties_counter = 0
    rewards_to_show.each do |tag_name, rewards|
      not_empty_properties_counter += 1 if rewards.any?  
    end

    not_empty_properties_counter > 0
  end
  
  def prizes
    # TODO: adjust.
  end
  
  def superfan_contest
    contest_points = cache_short(get_superfan_contest_point_key(current_user.id)) do
      get_counter_about_user_reward(SUPERFAN_CONTEST_REWARD)
    end
    @points_to_achieve = contest_points.nil? ? SUPERFAN_CONTEST_POINTS_TO_WIN : SUPERFAN_CONTEST_POINTS_TO_WIN - contest_points
    @already_win = @points_to_achieve <= 0
  end
  
  def notices
    Notice.mark_all_as_viewed()
    notices = Notice.where("user_id = ?", current_user.id).order("created_at DESC")
    @notices_list = group_notice_by_date(notices)
  end
  
  def group_notice_by_date(notices)
    notices_list = Hash.new
    notices.each do |n|
      key = n.created_at.strftime("%d %B %Y")
      if notices_list[key]
        notices_list[key] << n
      else
        notices_list[key] = [n]
      end
    end
    notices_list
  end

  def show
  end

end
