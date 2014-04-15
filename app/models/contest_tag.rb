class ContestPoint < ActiveRecord::Base

  attr_accessible :tag_id, :contest_id

  belongs_to :tag
  belongs_to :contest
  
end