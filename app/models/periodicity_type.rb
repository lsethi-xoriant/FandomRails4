class PeriodicityType < ActiveRecord::Base
  attr_accessible :name, :period, :created_at, :updated_at
  
  has_many :contest_periodicities

end