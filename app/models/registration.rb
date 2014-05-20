class Registration < ActiveRecord::Base 
  attr_accessible :title 

  has_one :interaction, as: :resource
end
