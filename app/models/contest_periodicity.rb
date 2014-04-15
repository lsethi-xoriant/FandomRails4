class ContestPeriodicity < ActiveRecord::Base
  attr_accessible :title, :custom_periodicity, :periodicity_type_id, :contest_id, :created_at, :updated_at
  
  has_many :prizes
  belongs_to :periodicity_type
  belongs_to :contest

end