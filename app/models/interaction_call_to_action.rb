class InteractionCallToAction < ActiveRecord::Base 
  attr_accessible :call_to_action_id, :interaction_id, :condition 

  has_one :interaction
  has_one :call_to_action
end
