class PlayticketEvent < ActiveRecord::Base

  attr_accessible :points_spent, :used_at, :winner, :user_id, :contest_periodicity_id, :instantwin_id

  belongs_to :user
  belongs_to :contest_periodicity
  belongs_to :instantwin
  
end