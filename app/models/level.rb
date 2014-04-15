class Level < ActiveRecord::Base
  attr_accessible :name, :description, :property_id, :points, :image
  has_attached_file :image, :styles => { :medium => "300x300#", :thumb => "100x100#" }
  
  validates_presence_of :name
  validates_presence_of :description
  validates_presence_of :points

  belongs_to :property
  has_many :user_levels
end
