class UserLevel < ActiveRecord::Base
  attr_accessible :rewarding_user_id, :level_id
  belongs_to :level
  belongs_to :rewarding_user
end
