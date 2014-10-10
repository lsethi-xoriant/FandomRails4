class ReleasingFile < ActiveRecord::Base
  attr_accessible :file
  
  has_attached_file :file
  has_many :call_to_actions

  validates_presence_of :file
  
end
