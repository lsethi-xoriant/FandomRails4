#!/bin/env ruby
# encoding: utf-8

require 'fandom_utils'

class RewardController < ApplicationController
  include ApplicationHelper
  include RewardHelper
  
  def index
    all_rewards = get_all_rewards_map
    if current_user
      user_rewards = get_user_rewards(all_rewards).slice(0,8)
      user_available_rewards = get_user_available_rewards(all_rewards)
    else
      user_rewards = []
      user_available_rewards = []
    end
    newest_rewards = all_rewards.map{|k,v| v}.sort_by{|reward| reward.created_at}.slice(0,8)
    all_rewards = []
    reward_list = {
      "user_rewards" => prepare_rewards_for_presentation(user_rewards),
      "user_available_rewards" => prepare_rewards_for_presentation(user_available_rewards),
      "newest_rewards" => prepare_rewards_for_presentation(newest_rewards),
      "all_rewards" => prepare_rewards_for_presentation(all_rewards)
    }
    @reward_list = reward_list
  end
  
  def prepare_rewards_for_presentation(rewards)
    unless rewards.empty?
      reward_info_list = []
      rewards.each do |reward|
        reward_info_list << {
          "calltoaction" => { 
            "id" => reward.call_to_action.id,
            "title" => reward.call_to_action.title,
            "thumbnail_url" => reward.call_to_action.thumbnail_url,
          },
          "reward_info" => {
            "cost" => reward.cost,
            "status" => get_user_reward_status(reward)
          }
        }
      end
      reward_info_list
    end
  end
  
  def get_catalogue_user_rewards_ids
    cache_short(get_catalogue_user_rewards_ids_key(current_user.id)) do
      Reward.joins(:user_rewards).select("rewards.id").where("user_rewards.available = TRUE AND user_rewards.counter > 0 AND user_rewards.user_id = ? AND rewards.id NOT IN (?)", current_user.id, get_basic_rewards_ids).to_a
    end
  end
  
  def get_user_rewards(all_rewards)
    user_rewards = []
    get_catalogue_user_rewards_ids.each do |reward|
      user_rewards << all_rewards[reward.id]
    end
    user_rewards
  end
  
  def get_user_available_rewards(all_rewards)
    avaiable_rewards = []
    all_rewards.each do |key, reward|
      if user_has_currency_for_reward(reward) && !user_has_reward(reward.name)
        avaiable_rewards << reward
      end
    end
    avaiable_rewards
  end
  
  def show
    @reward = Reward.find(params[:reward_id])
    user_reward = UserReward.where("user_id = ? AND reward_id = ?", current_user.id, @reward.id).first
    if user_reward.nil?
      @user_got_reward = false
      @user_can_buy_reward = false
    else
      @user_got_reward = user_reward.counter > 0
      @user_can_buy_reward = user_reward.counter > @reward.cost && !@user_got_reward
      @currency_to_buy_reward = @user_can_buy_reward ? 0 : (@reward.cost - user_reward.counter)
     end
  end
  
  def buy_reward
    response = {}
    reward = Reward.find(params[:reward_id])
    if user_has_currency_for_reward(reward)
      get_reward_with_periods(reward.currency.name).each do |period_reward|
        period_reward.update_attribute(:counter, period_reward.counter - reward.cost)
      end
      UserReward.create(user_id: current_user.id, reward_id: reward.id, available: true, counter: 1)
      expire_cache_key(get_reward_points_for_user_key(reward.currency.name, current_user.id))
      response["html"] = "<p class=\"cta-preview__unlocked-message\">PREMIO SBLOCCATO</p>
      <p><small>Hai speso #{reward.cost} #{reward.currency.name}</small></p>
      <p><small>Hai ancora #{get_counter_about_user_reward(reward.currency.name)} #{reward.currency.name}</small></p>
      <button class=\"btn btn-primary\" onclick=\"javascript:location.reload();\">Scopri il premio</button>".html_safe
    else
      response["html"] = "<p>Non hai abbastanza #{reward.currency.name} per sbloccare questo premio</p><div class=\"col-sm-12  cta-cover__winnable-reward text-right\">
      <span class=\"label label-warning cta-preview__credits--reward\">+#{reward.cost}<i class=\"fa fa-copyright\"></i></span></div>".html_safe
    end
    respond_to do |format|
      format.json { render :json => response.to_json }
    end
  end
  
  def show_all_catalogue
    all_rewards = get_all_rewards_map.map{|k,v| v}.sort_by{|reward| reward.created_at}
    reward_list = {
      "all_rewards" => prepare_rewards_for_presentation(all_rewards)
    }
    @title = "Tutti i premi"
    @reward_key = "all_rewards"
    @reward_list = reward_list
  end
  
  def show_all_available_catalogue
    if current_user
      all_rewards = get_all_rewards_map
      user_available_rewards = get_user_available_rewards(all_rewards)
      reward_list = {
        "user_available_rewards" => prepare_rewards_for_presentation(user_available_rewards)
      }
      @reward_list = reward_list
      @title = "Premi che puoi sbloccare"
      @reward_key = "user_available_rewards"
      render template: "/reward/show_all_catalogue"
    else
      redirect_to "/reward/catalogue" 
    end
  end
  
  def show_all_my_catalogue
    if current_user
      all_rewards = get_all_rewards_map
      user_rewards = get_user_rewards(all_rewards)
      reward_list = {
        "user_rewards" => prepare_rewards_for_presentation(user_rewards),
      }
      @reward_list = reward_list
      @title = "I miei premi"
      @reward_key = "user_rewards"
      render template: "/reward/show_all_catalogue"
    else
      redirect_to "/reward/catalogue" 
    end
  end
  
end