class Comment < ActiveRecord::Base  
	attr_accessible :title, :must_be_approved

	has_many :user_comment_interactions
  has_one :interaction, as: :resource

  def one_shot
    false
  end
end
