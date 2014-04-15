class CalltoactionTag < ActiveRecord::Base
  attr_accessible :calltoaction_id, :tag_id

  validates_uniqueness_of :calltoaction_id, :scope => :tag_id
  
  belongs_to :calltoaction
  belongs_to :tag
end
