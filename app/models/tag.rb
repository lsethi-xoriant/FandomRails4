class Tag < ActiveRecord::Base
  attr_accessible :name,  :description, :locked, :tag_fields_attributes

  validates_presence_of :name
  
  has_many :call_to_action_tags
  has_many :reward_tags
  has_many :tags_tags
  has_many :tag_fields
  
  accepts_nested_attributes_for :tag_fields
  
  validates_associated :tag_fields
  
  validate :exclude_cyclic_references
  
  def exclude_cyclic_references
    
  end
  
end
