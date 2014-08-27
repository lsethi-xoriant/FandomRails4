include PeriodicityHelper

class UserReward < ActiveRecord::Base
  
  attr_accessible :user_id, :reward_id, :available, :counter, :period_id

  belongs_to :user
  belongs_to :reward
  belongs_to :period


  def self.get_user_reward(user, reward_name)
    UserReward.includes(:reward).where("user_id = ? and rewards.name = ? and user_rewards.period_id IS NULL", user.id, reward_name).first
  end
  
  def self.get_user_reward_with_periodicity(user, reward_name, period_id)
    UserReward.includes(:reward).where("user_id = ? and rewards.name = ? and user_rewards.period_id = ?", user.id, reward_name, period_id).first
  end

  # Returns a list of triples: name, available, counter
  def self.get_rewards_info(user, current_periodicities)
    period_ids = current_periodicities.values.map { |p| p.id }
    period_id_qmarks = (["?"] * period_ids.count).join(", ") 
    
    UserReward.includes(:reward).includes(:period).select("rewards.name, rewards.countable, available, counter, periods.kind").where("user_id = ? and (period_id in (#{period_id_qmarks}) or period_id is null)", user.id, *period_ids)
  end
  
  def self.assign_reward(user, reward_name, counter, site)
    user_reward = get_user_reward(user, reward_name)
    if user_reward.nil?
      reward = Reward.find_by_name(reward_name)
      create(:user_id => user.id, :reward_id => reward.id, :available => true, :counter => counter, :period_id => nil)
    else
      user_reward.update_attributes(:counter => user_reward.counter + counter, :available => true)
    end
    active_periodicities = get_current_periodicities()
    site.periodicity_kinds.each do |pk|
      save_user_reward_with_periodicity(user, reward_name, counter, pk, active_periodicities)
    end
  end

  def self.unlock_reward(user, reward_name)
    user_reward = get_user_reward(user, reward_name) 
    if user_reward.nil?
      reward = Reward.find_by_name(reward_name)
      return create(:user_id => user_id, :reward_id => reward.id, :available => true, :counter => 0)
    else
      user_reward.update_attributes(:available => true)
      return user_reward
    end
  end
  
  def self.save_user_reward_with_periodicity(user, reward_name, counter, periodicity_kind, active_periodicities)
    if active_periodicities.blank?
      period = nil
    else
      period = active_periodicities[periodicity_kind]
    end
    if period
      user_reward = get_user_reward_with_periodicity(user, reward_name, period.id)
      if user_reward.nil?
        reward = Reward.find_by_name(reward_name)
        create(:user_id => user.id, :reward_id => reward.id, :available => true, :counter => counter, :period_id => period.id)
      else
        user_reward.update_attributes(:counter => user_reward.counter + counter, :available => true)
      end  
    else
      reward = Reward.find_by_name(reward_name)
      period_id = send("create_#{periodicity_kind}_periodicity")
      create(:user_id => user.id, :reward_id => reward.id, :available => true, :counter => counter, :period_id => period_id)
    end
  end

end