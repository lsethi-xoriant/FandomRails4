class UserComment < ActiveRecord::Base
  attr_accessible :text, :published_at, :user_id, :comment_id, :deleted

  after_save :update_cache_comment_counter
  
  scope :publish, where("published_at IS NOT NULL AND (deleted IS NULL OR deleted=false)")

  belongs_to :comment
  belongs_to :user

  validates_presence_of :comment_id

  def update_cache_comment_counter
  	# Aggiorna il numero di commenti pubblicati.
  	if published_at && published_at_was.blank?
	  	comment.interaction.update_attribute(:cache_counter, comment.interaction.cache_counter + 1)
	elsif published_at.blank? && published_at_was
	  	comment.interaction.update_attribute(:cache_counter, comment.interaction.cache_counter - 1)
	end
  end
end
