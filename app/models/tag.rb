class Tag < ActiveRecord::Base
  attr_accessible :text

  validates_presence_of :text
  
  has_many :calltoaction_tags
end
