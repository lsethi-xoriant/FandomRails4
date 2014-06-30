class Comment < ActiveRecord::Base  
	attr_accessible :title, :must_be_approved

	has_many :user_comments
  has_one :interaction, as: :resource
end
