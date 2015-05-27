class ReleasingFile < ActiveRecord::Base
  attr_accessible :file

  has_attached_file :file
  do_not_validate_attachment_file_type :file

  has_many :call_to_actions

  validates_presence_of :file
  
end
