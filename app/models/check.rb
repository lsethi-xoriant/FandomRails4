class Check < ActiveRecord::Base 
  attr_accessible :title, :description 

  has_one :interaction, as: :resource

  def one_shot
    true
  end
end
