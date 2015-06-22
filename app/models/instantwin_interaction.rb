class InstantwinInteraction < ActiveRecord::Base
  attr_accessible :currency_id
  
  has_one :interaction, as: :resource
  has_many :instantwins
  belongs_to :reward, :foreign_key => :currency_id

  def one_shot
    false
  end

end