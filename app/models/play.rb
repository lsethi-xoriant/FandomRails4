class Play < ActiveRecord::Base 
  attr_accessible :title, :text_before, :text_after
  
  has_one :interaction, as: :resource
end
