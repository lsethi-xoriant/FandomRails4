class Play < ActiveRecord::Base 
  attr_accessible :title

  validates :title, :uniqueness => { :message => "il titolo della Play interaction deve essere unico" }

  has_one :interaction, as: :resource

  def one_shot
    false
  end
end
