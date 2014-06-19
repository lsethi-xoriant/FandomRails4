class UserReward < ActiveRecord::Base

  attr_accessible :user_id, :reward_id, :available, :counter

  belongs_to :user
  belongs_to :reward
  
end