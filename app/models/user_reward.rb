class UserReward < ActiveRecord::Base

  attr_accessible :user_id, :reward_id, :available, :rewarded_count

  belongs_to :user
  belongs_to :reward
  
end