class UserComment < ActiveRecord::Base
  attr_accessible :text, :approved, :user_id, :comment_id
  
  scope :approved, where("approved=true")

  belongs_to :comment
  belongs_to :user

  validates_presence_of :comment_id
  validates_presence_of :text
end
