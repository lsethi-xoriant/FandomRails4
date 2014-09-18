module BallandoHelper
  
  include PeriodicityHelper
  include ApplicationHelper
  
  def get_superfan_reward
    cache_short("weekly_superfan") do
      Reward.includes(reward_tag: :tag).where("tags.name = 'badges' and rewards.valid_from < ? and rewards.valid_to > ?", Time.now.utc, Time.now.utc).first  
    end
  end
  
end