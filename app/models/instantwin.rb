class Instantwin < ActiveRecord::Base

  attr_accessible :title, :time_to_win_start, :time_to_win_end, :contest_periodicity_id
  
  has_one :playticket_event

  belongs_to :contest_periodicity
  
end