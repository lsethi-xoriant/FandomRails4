class Instantwin < ActiveRecord::Base

  attr_accessible :title, :time_to_win, :contest_periodicity_id
  
  has_one :playticket_event

  belongs_to :contest_periodicity
  
end