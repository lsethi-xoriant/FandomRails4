module RewardHelper
  
  include PeriodicityHelper
  include ApplicationHelper

  def get_reward_from_cache(reward_name)
    cache_short(get_reward_cache_key(reward_name)) do
      Reward.find_by_name(reward_name)
    end
  end
  
  def get_reward_image_for_status(reward)
    if user_has_reward(reward.name)
      reward.main_image
    elsif reward.is_expired
      reward.not_winnable_image
    else
      reward.not_awarded_image
    end
  end
  
  def order_rewards(rewards, sort_param)
    rewards.sort! do |a, b|
      a[sort_param] <=> b[sort_param]
    end
  end
  
end