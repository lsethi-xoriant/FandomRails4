#!/bin/env ruby
# encoding: utf-8

require 'fandom_utils'

class RewardController < ApplicationController
  
  def index
    @user_rewards = get_user_rewards(current_user.id)
    @top_rewards = get_top_rewards(current_user.id)
    @user_available_rewards = get_user_available_rewards(current_user.id)
    @user_all_rewards = get_all_rewards(current_user.id)
  end
  
  def get_user_rewards(user_id)
    Reward.includes(:user_rewards).where("user_rewards.available = TRUE AND user_rewards.rewarded_count > 0 AND user_rewards.user_id = ?", user_id)
  end
  
  def get_top_rewards(user_id)
    rewards_result_set = Reward.includes(:reward_tags => :tag).where("tags.text = 'top'")
    rewards_list = create_reward_list(rewards_result_set, user_id)
  end
  
  def get_user_available_rewards(user_id)
    Reward.includes(:user_rewards).where("user_rewards.available = TRUE AND user_rewards.rewarded_count = 0 AND user_rewards.user_id = ?", user_id)
  end
  
  def get_all_rewards(user_id)
    reward_system_tag = ["basic"]
    excluded_reward_ids = RewardTag.includes(:tag).where("tags.text in (?) AND reward_id IS NOT NULL", reward_system_tag).map{ |row| row.reward_id }
    rewards_result_set = Reward.where("id not in (?)", excluded_reward_ids)
    rewards_list = create_reward_list(rewards_result_set, user_id)
  end
  
  def create_reward_list(rewards, user_id)
    rewards_list = Array.new
    rewards.each do |r|
      reward_element = Hash.new
      reward_element['reward'] = r
      reward_element['user_already_bought'] = UserReward.where("user_id = ? AND reward_id = ? AND rewarded_count > 0", user_id, r.id).count > 0
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
      @user_got_reward = user_reward.rewarded_count > 0
      @user_can_buy_reward = user_reward.rewarded_count > @reward.cost && !@user_got_reward
      @currency_to_buy_reward = @user_can_buy_reward ? 0 : (@reward.cost - user_reward.rewarded_count)
     end
  end
  
  def get_user_currency_amount(user_id, currency_id)
    user_reward_for_currency = UserReward.select("rewarded_count").where("user_id = ? AND reward_id = ?", user_id, currency_id).first 
    return user_reward_for_currency.rewarded_count
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
    user_already_bought_reward = user_reward.rewarded_count > 0
    cost = reward.cost
    currency = UserReward.where("user_id = ? AND reward_id = ?", current_user.id, reward.currency_id).first
    available = currency.rewarded_count
    if available >= cost && !user_already_bought_reward
       buy_reward(user_reward, currency, reward)
    elsif available < cost
      flash[:notice] = "Non hai abbastanza #{reward.cost_currency.title} per acquistare il premio.";
    else
      flash[:notice] = "Hai già acquistato questo premio"
    end
  end
  
  def buy_reward(user_reward, currency, reward)
    user_reward.update_attribute(:rewarded_count,1)
    currency.update_attribute(:rewarded_count,currency.rewarded_count - reward.cost)
    flash[:notice] = "Complimenti il premio è tuo!";
  end
  
end