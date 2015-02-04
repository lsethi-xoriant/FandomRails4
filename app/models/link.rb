class Link < ActiveRecord::Base 
  attr_accessible :url, :title

  has_one :interaction, as: :resource

  def one_shot
    false
  end
end
