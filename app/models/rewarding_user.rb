class RewardingUser < ActiveRecord::Base  
	attr_accessible :credits, :points, :user_id, :rewarding_user_id, :property_id, :general_rewarding_user_id

	has_many :user_badges
	has_many :user_levels
	belongs_to :property
	belongs_to :user
	belongs_to :general_rewarding_user
	before_save :check_general_rewarding_user
	after_save :update_general_rewarding_user
  after_destroy :update_general_rewarding_user_after_destroy

	def check_general_rewarding_user
		self.general_rewarding_user_id = GeneralRewardingUser.create(user_id: user_id).id if general_rewarding_user_id.blank?
	end

	def update_general_rewarding_user
		general_rewarding_user.update_attribute(:points, general_rewarding_user.points + (points - points_was))
	end

  def update_general_rewarding_user_after_destroy
    general_rewarding_user.update_attribute(:points, general_rewarding_user.points - points)
  end
  
end
