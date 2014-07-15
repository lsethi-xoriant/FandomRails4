class ReleasingFile < ActiveRecord::Base
  
  has_attached_file :file
  
  belongs_to :call_to_action
  
end
