class HomeLauncher < ActiveRecord::Base
  attr_accessible :description, :button, :url, :enable, :image, :anchor
  has_attached_file :image
  do_not_validate_attachment_file_type :image

  validates_presence_of :description
  validates_presence_of :button
  validates_presence_of :url
  validates_presence_of :image

  scope :active, -> { where("enable=?", true).order("updated_at DESC") }
end
