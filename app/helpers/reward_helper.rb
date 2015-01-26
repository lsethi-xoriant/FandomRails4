module RewardHelper
  
  include PeriodicityHelper

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
  
  def get_superfan_points_gap
    contest_points = get_counter_about_user_reward(SUPERFAN_CONTEST_REWARD, false) || 0
    SUPERFAN_CONTEST_POINTS_TO_WIN - contest_points
  end
  
  def get_point
    if $context_root.nil?
      get_counter_about_user_reward(MAIN_REWARD_NAME)
    else
      get_current_property_point
    end
  end
  
  # Calculate a progress into a reward level.
  #   level          - the level to check progress
  #   starting_point - the cost of the preceding level
  def calculate_level_progress(level, starting_point)
    user_points = get_counter_about_user_reward(get_point)
    level.cost > 0 ? ((user_points - starting_point) * 100) / (level.cost - starting_point) : 100
  end
  
  def prepare_levels_to_show(levels)
    levels = levels 
    order_rewards(levels.to_a, "cost")
    prepared_levels = {}
    if levels
      index = 0
      level_before_point = 0
      level_before_status = nil
      levels.each do |level|
        if level_before_status.nil? || level_before_status == "gained"
          progress = calculate_level_progress(level, level_before_point)
          if progress >= 100
            level_before_status = "gained"
            prepared_levels["#{index+1}"] = {"level" => level, "level_number" => index+1, "progress" => 100, "status" => level_before_status }
          else
            level_before_status = "progress"
            prepared_levels["#{index+1}"] = {"level" => level, "level_number" => index+1, "progress" => progress, "status" => level_before_status }
          end
        else
          progress = 0
          level_before_status = "locked"
          prepared_levels["#{index+1}"] = {"level" => level, "level_number" => index+1, "progress" => progress, "status" => level_before_status }
        end
        index += 1
      end
    end
    prepared_levels
  end
  
  def get_level_number
    levels, use_property = rewards_by_tag("level")
    levels.count
  end
  
  def user_has_currency_for_reward(reward)
    unless reward.currency.nil?
      get_counter_about_user_reward(reward.currency.name) >= reward.cost
    else
      get_counter_about_user_reward("credit") >= reward.cost    end
  end
  
  def get_all_rewards_map
    cache_short(get_all_rewards_map_cache_key) do
      all_rewards = Hash.new
      Reward.includes(:currency).includes(:call_to_action).where("rewards.id not in (?)", get_basic_rewards_ids).order("created_at DESC").each do |reward|
        all_rewards[reward.id] = reward
      end
      all_rewards
    end
  end
  
  def is_basic_reward(reward)
    basic_tag = Tag.find_by_name("basic")
    reward_tags = reward.reward_tags.map{ |rt| [rt.id] }
    reward_tags.include?(basic_tag.id)
  end
  
  def get_basic_rewards_ids
    cache_short(get_basic_reward_cache_key) do
      get_rewards_with_tag("basic").map{ |rt| rt.id }
    end
  end
  
  def get_user_reward_status(reward)
    if current_user
      if user_has_reward(reward.name)
        "gained"
      elsif user_has_currency_for_reward(reward)
        "avaiable"
      else
        "locked"
      end
    else
      "locked"
    end
  end
  
end