class Upload < ActiveRecord::Base
  attr_accessible :call_to_action_id, :releasing, :releasing_description, :privacy, :privacy_description
  
  has_one :interaction, as: :resource

end
