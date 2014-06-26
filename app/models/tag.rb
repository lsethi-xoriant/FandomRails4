class Tag < ActiveRecord::Base
  attr_accessible :name

  validates_presence_of :name
  
  has_many :call_to_action_tags
  has_many :reward_tags
  has_many :tags_tags
  belongs_to :parent, :class_name => "Tag", :foreign_key => 'parent_id'
  
end
