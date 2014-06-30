class TagField < ActiveRecord::Base
  attr_accessible :name, :field_type, :value, :tag_id

  validates_presence_of :name
  
  belongs_to :tag
  
  validate :validate_name
  
  def validate_name
    
  end
  
end
