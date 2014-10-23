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
    cache_short(get_status_rewar_image_key(reward.name, current_user.id)) do
      if user_has_reward(reward.name)
        reward.main_image.url
      elsif reward.is_expired
        reward.not_winnable_image.url
      else
        reward.not_awarded_image.url
      end
    end
  end
  
  def order_rewards(rewards, sort_param)
    rewards.sort! do |a, b|
      a[sort_param] <=> b[sort_param]
    end
  end
  
  def get_reward_with_cta
    cache_short("rewards_with_cta") do
      Reward.includes(:call_to_action).where("rewards.media_type = 'CALLTOACTION' and call_to_actions.activated_at <= ? AND call_to_actions.activated_at IS NOT NULL AND call_to_actions.media_type <> 'VOID' AND call_to_actions.user_id IS NULL", Time.now).to_a
    end
  end
  
  def get_unlocked_contents
    cache_short(get_unlocked_contents_for_user(current_user.id)) do
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

  def clone_reward(params)
    old_reward = Reward.find(params[:id])
    new_reward = duplicate_reward(old_reward.id)
    old_reward.reward_tags.each do |tag|
      duplicate_reward_tag(new_reward, tag)
    end
    @reward = new_reward
    tag_array = Array.new
    @reward.reward_tags.each { |t| tag_array << t.tag.name }
    @tag_list = tag_array.join(",")
    render template: "/easyadmin/easyadmin_reward/new"
  end

  def duplicate_reward(old_reward_id)
    reward = Reward.find(old_reward_id)
    reward.title = "Copy of " + reward.title
    reward.created_at = DateTime.now
    reward_attributes = reward.attributes
    reward_attributes.delete("id")
    Reward.new(reward_attributes, :without_protection => true)
  end
  
  def duplicate_reward_tag(new_reward, tag)
    new_reward.reward_tags.build(:reward_id => new_reward.id, :tag_id => tag.tag_id)
  end

end