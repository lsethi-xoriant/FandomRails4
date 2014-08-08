class UserReward < ActiveRecord::Base

  attr_accessible :user_id, :reward_id, :available, :counter

  belongs_to :user
  belongs_to :reward
  belongs_to :period


  def self.get_user_reward(user, reward_name)
    UserReward.includes(:reward).where("user_id = ? and rewards.name = ?", user.id, reward_name).first
  end

  # Returns a list of triples: name, available, counter
  def self.get_rewards_info(user)
    UserReward.includes(:reward).select("rewards.name, rewards.countable, available, counter").where("user_id = ?", user.id)
  end
  
  def self.assign_reward(user, reward_name, counter)
    user_reward = get_user_reward(user, reward_name) 
    if user_reward.nil?
      reward = Reward.find_by_name(reward_name)
      return create(:user_id => user.id, :reward_id => reward.id, :available => true, :counter => counter)
    else
      user_reward.update_attributes(:counter => user_reward.counter + counter, :available => true)
      return user_reward
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

end