class CallToActionTag < ActiveRecord::Base
  attr_accessible :call_to_action_id, :tag_id

  validates_uniqueness_of :call_to_action_id, :scope => :tag_id
  
  belongs_to :call_to_action
  belongs_to :tag
end
