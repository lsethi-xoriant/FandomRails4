class Check < ActiveRecord::Base 
  attr_accessible :title, :description 

  has_one :interaction, as: :resource
end
