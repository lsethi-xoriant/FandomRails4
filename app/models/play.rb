class Play < ActiveRecord::Base 
  attr_accessible :title

  has_one :interaction, as: :resource

  def one_shot
    false
  end
end
