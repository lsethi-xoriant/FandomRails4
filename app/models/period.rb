class Period < ActiveRecord::Base
  attr_accessible :kind, :start_datetime, :end_datetime
  
  has_many :user_rewards  

end