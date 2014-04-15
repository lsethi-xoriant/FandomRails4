class UserBadge < ActiveRecord::Base
  attr_accessible :rewarding_user_id, :badge_id
  belongs_to :badge
  belongs_to :rewarding_user
end
