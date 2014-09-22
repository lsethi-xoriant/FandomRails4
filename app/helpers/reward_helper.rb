module RewardHelper
  
  include PeriodicityHelper
  include ApplicationHelper
  
  def get_reward_image_for_status(reward)
    if user_has_reward(reward.name)
      reward.main_image
    elsif reward.is_published
      reward.not_awarded_image
    else
      reward.not_winnable_image
    end
  end
  
  def order_rewards(rewards, sort_param)
    rewards.sort! do |a, b|
      a[sort_param] <=> b[sort_param]
    end
  end
  
end