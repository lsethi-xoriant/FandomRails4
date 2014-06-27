class TagField < ActiveRecord::Base
  attr_accessible :name, :type, :value, :tag_id

  validates_presence_of :name
  
  belongs_to :tag
  
end
