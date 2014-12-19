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

  def index
    redirect_to "/users/edit"
  end

  def remove_provider
  	auth = current_user.authentications.find_by_provider(params[:provider])
  	auth.destroy if auth
  	redirect_to "/profile/edit"
  end

  def rankings
  end
  
  def rewards
    @levels, prop = rewards_by_tag("level")
    @mylevels, prop1 = rewards_by_tag("level", current_user)
    @badges, prop2 = rewards_by_tag("badge")
    @mybadges, prop3 = rewards_by_tag("badge", current_user)
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
  
  def superfan_contest
    contest_points = get_counter_about_user_reward(SUPERFAN_CONTEST_REWARD, false) || 0

    @points_to_achieve = SUPERFAN_CONTEST_POINTS_TO_WIN - contest_points
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
