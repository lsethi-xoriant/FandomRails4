class HomeLauncher < ActiveRecord::Base
  attr_accessible :description, :button, :url, :enable, :image
  has_attached_file :image

  validates_presence_of :description
  validates_presence_of :button
  validates_presence_of :url
  validates_presence_of :image

  scope :active, where("enable=?", true).order("updated_at DESC")
end
