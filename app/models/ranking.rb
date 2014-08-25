class Ranking < ActiveRecord::Base  
	attr_accessible :title, :period, :reward_id, :name

  belongs_to :reward
  
end
