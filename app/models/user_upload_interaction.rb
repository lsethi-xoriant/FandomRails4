class UserUploadInteraction < ActiveRecord::Base  
	attr_accessible :user_id, :call_to_action_id, :upload_id

  	belongs_to :call_to_action
  	belongs_to :user
  	belongs_to :upload
  	
end
