class InstantwinInteraction < ActiveRecord::Base
  attr_accessible :reward_id
  
  has_one :interaction, as: :resource
  has_many :instantwins
  belongs_to :reward

  def one_shot
    false
  end

end