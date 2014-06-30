class UserComment < ActiveRecord::Base
  attr_accessible :text, :published_at, :user_id, :comment_id, :deleted
  
  scope :publish, where("published_at IS NOT NULL AND (deleted IS NULL OR deleted=false)")

  belongs_to :comment
  belongs_to :user

  validates_presence_of :comment_id
  validates_presence_of :text
end
