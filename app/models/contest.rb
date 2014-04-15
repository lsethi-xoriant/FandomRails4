class Contest < ActiveRecord::Base
  attr_accessible :title, :start_date, :end_date, :property_id, :contest_periodicities_attributes, :generated,
  					:conversion_rate
  
  has_many :contest_periodicities
  belongs_to :property

  accepts_nested_attributes_for :contest_periodicities
end