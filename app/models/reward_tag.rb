class RewardTag < ActiveRecord::Base

  attr_accessible :tag_id, :reward_id

  belongs_to :tag
  belongs_to :reward
  
end