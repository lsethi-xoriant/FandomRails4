class Download < ActiveRecord::Base
  attr_accessible :title, :attachment

  has_attached_file :attachment
  
  has_one :interaction, as: :resource

  validates_presence_of :attachment

  def one_shot
    false
  end
end
