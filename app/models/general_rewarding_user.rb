class GeneralRewardingUser < ActiveRecord::Base  
	attr_accessible :points, :user_id

	has_many :rewarding_users
  	belongs_to :user
end
