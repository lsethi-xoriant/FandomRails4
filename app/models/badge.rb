class Badge < ActiveRecord::Base
  attr_accessible :name, :description, :property_id, :role, :role_value, :image
  has_attached_file :image, :styles => { :medium => "300x300#", :thumb => "100x100#" }
  
  belongs_to :property
  has_many :user_badges

  validates_presence_of :name
  validates_presence_of :role
  validates_presence_of :role_value

  def role_enum
    ["TRIVIA_RIGHT", "PLAY_UNICI", "VERSUS", "CHECK", "LIKE"]
  end
end
