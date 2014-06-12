#!/bin/env ruby
# encoding: utf-8

require 'fandom_utils'

class RewardController < ApplicationController
  
  # Get the cataolgue of user awards differenced between already gained award, available aeard and locked award
  def index
    @user_rewards = Array.new
    UserReward.where("user_id = ? AND available = TRUE AND rewarded_count > 0", current_user.id).each do |r|
      @user_rewards.push(r.reward)
    end
    
    @user_available_rewards = Array.new
    UserReward.where("user_id = ? AND available = TRUE AND (rewarded_count = 0)", current_user.id).each do |r|
      @user_available_rewards.push(r.reward)
    end
    
    # TODO show also reward that are not inserted into UserReward table
    @user_locked_rewards = Array.new
    UserReward.where("user_id = ? AND available = FALSE", current_user.id).each do |r|
      @user_locked_rewards.push(r.reward)
    end
  end
  
  # display page detail for a specific reward
  #
  # reward_id - id of reward to display
  def show
    @reward = Reward.find(params[:reward_id])
    user_reward = UserReward.where("user_id = ? AND reward_id = ?", current_user.id, @reward.id).first
    if user_reward.nil?
      user_currency_amount = UserReward.select("rewarded_count").where("user_id = ? AND reward_id = ?", current_user.id, @reward.currency_id).first.rewarded_count
      @user_got_reward = false
      @user_can_buy_reward = false
      @currency_to_buy_reward = @reward.cost - user_currency_amount
     else
      @user_got_reward = user_reward.rewarded_count > 0
      @user_can_buy_reward = user_reward.rewarded_count > @reward.cost && !@user_got_reward
      @currency_to_buy_reward = @user_can_buy_reward ? 0 : (@reward.cost - user_reward.rewarded_count)
     end
  end
  
  def buy_reward
    reward = Reward.find(params[:reward_id])
    user_reward = UserReward.where("user_id = ? AND reward_id = ?", current_user.id, reward.id)
    
    if !user_reward.nil? && user_reward.available
      user_already_buy_reward = user_reward.rewarded_count > 0
      currency_needed = reward.cost
      currency = UserReward.where("user_id = ? AND reward_id = ?", current_user.id, reward.currency_id).first
      currency_available = currency.rewarded_count
      
      if currency_available >= currency_needed && !user_already_buy_reward
         user_reward.update_attribute(:rewarded_count,1)
         currency.update_attribute(:rewarded_count,currency.rewarded_count - reward.cost)
         flash[:notice] = "Complimenti il premio è tuo!";
      elsif currency_available < currency_needed
        flash[:notice] = "Non hai abbastanza #{reward.cost_currency.title} per acquistare il premio.";
      else
        flash[:notice] = "Hai già acquistato questo premio"
      end
      
    else
      flash[:notice] = "Non puoi acquistare il premio";
    end
    
    render template: "/reward/show"
  end
  
end