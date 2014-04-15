class ContestPoint < ActiveRecord::Base

  attr_accessible :points, :user_id, :contest_id

  belongs_to :user
  belongs_to :contest
  
end