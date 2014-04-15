class Play < ActiveRecord::Base 
  attr_accessible :title 
  
  has_one :interaction, as: :resource
end
