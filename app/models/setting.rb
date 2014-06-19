class Setting < ActiveRecord::Base
  attr_accessible :key, :value
  
  validates_presence_of :key
end
