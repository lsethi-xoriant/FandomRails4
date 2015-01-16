#!/bin/env ruby
# encoding: utf-8

require 'fandom_utils'

class RewardController < ApplicationController
  include ApplicationHelper
  include RewardHelper
  
  def index
    user_rewards = get_user_rewards(current_user.id)
    user_available_rewards = get_user_available_rewards(current_user.id)
    newest_rewards = get_newest_rewards
    all_rewards = get_all_rewards(current_user.id)
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
      build_call_to_action_info_list(rewards.map{ |r| r.call_to_action})
    end
  end
  
  def get_user_rewards(user_id)
    Reward.includes(:user_rewards).where("user_rewards.available = TRUE AND user_rewards.counter > 0 AND user_rewards.user_id = ? AND rewards.id NOT IN (?)", user_id, get_basic_rewards_ids)
  end
  
  def get_newest_rewards
    cache_short("newest_rewards") do
      Reward.where("rewards.id NOT IN (?)", get_basic_rewards_ids).order("created_at DESC").limit(8).to_a
    end
  end
  
  def get_top_rewards(user_id)
    rewards_result_set = Reward.includes(:reward_tags => :tag).where("tags.name = 'top'")
    rewards_list = create_reward_list(rewards_result_set, user_id)
  end
  
  def get_user_available_rewards(user_id)
    avaiable_rewards = []
    Reward.where("rewards.id NOT IN (?)", get_basic_rewards_ids).each do |reward|
      if user_has_currency_for_reward(reward) && !user_has_reward(reward.name)
        avaiable_rewards << reward
      end
    end
    avaiable_rewards
  end
  
  def get_all_rewards(user_id)
    cache_short("all_catalogue_rewards") do
      Reward.where("rewards.id NOT IN (?)", get_basic_rewards_ids).to_a
    end
  end
  
  def create_reward_list(rewards, user_id)
    rewards_list = Array.new
    rewards.each do |r|
      reward_element = Hash.new
      reward_element['reward'] = r
      reward_element['user_already_bought'] = UserReward.where("user_id = ? AND reward_id = ? AND counter > 0", user_id, r.id).count > 0
      rewards_list.push(reward_element)
    end
    rewards_list
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
  
  def get_user_currency_amount(user_id, currency_id)
    user_reward_for_currency = UserReward.select("counter").where("user_id = ? AND reward_id = ?", user_id, currency_id).first 
    return user_reward_for_currency.counter
  end
  
  def want_buy_reward
    reward = Reward.find(params[:reward_id])
    user_reward = UserReward.where("user_id = ? AND reward_id = ?", current_user.id, reward.id)
    if !user_reward.nil? && user_reward.available      
      can_buy_reward(user_reward, reward)
    else
      flash[:notice] = "Non puoi acquistare il premio";
    end
    render template: "/reward/show"
  end
  
  def can_buy_reward(user_reward, reward)
    user_already_bought_reward = user_reward.counter > 0
    cost = reward.cost
    currency = UserReward.where("user_id = ? AND reward_id = ?", current_user.id, reward.currency_id).first
    available = currency.counter
    if available >= cost && !user_already_bought_reward
       buy_reward(user_reward, currency, reward)
    elsif available < cost
      flash[:notice] = "Non hai abbastanza #{reward.cost_currency.title} per acquistare il premio.";
    else
      flash[:notice] = "Hai già acquistato questo premio"
    end
  end
  
  def buy_reward(user_reward, currency, reward)
    user_reward.update_attribute(:counter,1)
    currency.update_attribute(:counter,currency.counter - reward.cost)
    flash[:notice] = "Complimenti il premio è tuo!";
  end
  
end