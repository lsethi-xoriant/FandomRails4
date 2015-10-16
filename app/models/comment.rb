class Comment < ActiveRecord::Base  
	attr_accessible :title, :must_be_approved

	has_many :user_comment_interactions
  has_one :interaction, as: :resource
  has_one :comment_like

  def one_shot
    false
  end
end
