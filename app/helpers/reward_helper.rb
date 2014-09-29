module RewardHelper
  
  include PeriodicityHelper
  include ApplicationHelper

  def assign_reward(user, reward_name, counter, site)
    user_reward = get_user_reward(user, reward_name)
    if user_reward.nil?
      reward = Reward.find_by_name(reward_name)
      UserReward.create(:user_id => user.id, :reward_id => reward.id, :available => true, :counter => counter, :period_id => nil)
    else
      user_reward.update_attributes(:counter => user_reward.counter + counter, :available => true)
    end
    active_periodicities = get_current_periodicities()
    site.periodicity_kinds.each do |pk|
      save_user_reward_with_periodicity(user, reward_name, counter, pk, active_periodicities)
    end
  end

  def save_user_reward_with_periodicity(user, reward_name, counter, periodicity_kind, active_periodicities)
    if active_periodicities.blank?
      period = nil
    else
      period = active_periodicities[periodicity_kind]
    end
    if period
      user_reward = get_user_reward_with_periodicity(user, reward_name, period.id)
      if user_reward.nil?
        reward = Reward.find_by_name(reward_name)
        UserReward.create(:user_id => user.id, :reward_id => reward.id, :available => true, :counter => counter, :period_id => period.id)
      else
        user_reward.update_attributes(:counter => user_reward.counter + counter, :available => true)
      end  
    else
      reward = Reward.find_by_name(reward_name)
      period_id = send("create_#{periodicity_kind.downcase}_periodicity")
      UserReward.create(:user_id => user.id, :reward_id => reward.id, :available => true, :counter => counter, :period_id => period_id)
    end
  end

  def get_user_reward_with_periodicity(user, reward_name, period_id)
    UserReward.includes(:reward).where("user_id = ? and rewards.name = ? and user_rewards.period_id = ?", user.id, reward_name, period_id).first
  end

  def get_user_reward(user, reward_name)
    UserReward.includes(:reward).where("user_id = ? and rewards.name = ? and user_rewards.period_id IS NULL", user.id, reward_name).first
  end

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
  
  def get_reward_with_cta
    cache_short("rewards_with_cta") do
      Reward.where("media_type = 'CALLTOACTION'").to_a
    end
  end
  
  def get_unlocked_contents
    rewards_with_cta = get_reward_with_cta
    total = rewards_with_cta.count
    rewards_with_cta.each do |r|
      if user_has_reward(r.name)
        total -= 1
      end
    end
    total
  end
  
end