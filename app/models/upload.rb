class Upload < ActiveRecord::Base
  attr_accessible :call_to_action_id, :releasing, :releasing_description, :privacy, :privacy_description, :upload_number
  
  has_one :interaction, as: :resource
  belongs_to :call_to_action
  has_many :user_upload_interactions

end
