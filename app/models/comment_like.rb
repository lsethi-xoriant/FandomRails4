class CommentLike < ActiveRecord::Base  
  attr_accessible :title, :comment_id

  belongs_to :comment
  has_one :interaction, as: :resource

  def one_shot
    false
  end
end