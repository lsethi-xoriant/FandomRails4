class Share < ActiveRecord::Base
  attr_accessible :providers, :picture
  has_attached_file :picture, :styles => { :large => "600x600", :medium => "234x139>", :thumb => "100x100>" }
  
  has_one :interaction, as: :resource
end
