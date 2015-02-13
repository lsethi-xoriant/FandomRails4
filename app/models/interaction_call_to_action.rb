class InteractionCallToAction < ActiveRecord::Base 
  attr_accessible :condition, :interaction_id, :call_to_action_id

  belongs_to :interaction
  belongs_to :call_to_action
end
