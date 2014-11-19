class Instantwin < ActiveRecord::Base

  attr_accessible :valid_from, :valid_to, :reward_info, :won, :instantwin_interaction_id
  
  belongs_to :instantwin_interaction
  
end