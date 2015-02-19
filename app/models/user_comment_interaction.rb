class UserCommentInteraction < ActiveRecord::Base
  attr_accessible :text, :approved, :user_id, :comment_id, :aux
  
  scope :approved, where("user_comment_interactions.approved = true")

  belongs_to :comment
  belongs_to :user

  validates_presence_of :comment_id
  validates_presence_of :text
end
