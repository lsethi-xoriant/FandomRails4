class Tag < ActiveRecord::Base
  attr_accessible :text

  validates_presence_of :text
  
  has_many :call_to_action_tags
  has_many :reward_tags
end
