class Ranking < ActiveRecord::Base  
	attr_accessible :title, :period, :reward_id, :name

  belongs_to :reward
  
  def get_periods_enum
    PERIOD_TYPES
  end
  
end
