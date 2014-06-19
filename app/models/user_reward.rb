class UserReward < ActiveRecord::Base

  attr_accessible :user_id, :reward_id, :available, :counter

  belongs_to :user
  belongs_to :reward


  # TODO: to be implemented
  def self.assign_reward(user, reward_name, counter)
    
  end

  # TODO: to be implemented
  def self.unlock_reward(user, reward_name)
    
  end
  
end