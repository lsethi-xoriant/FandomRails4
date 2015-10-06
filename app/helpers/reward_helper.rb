module RewardHelper

  def get_tag_to_rewards()
    cache_short("tag_to_rewards") do
      rewards = Reward.all
      id_to_reward = {}
      rewards.each do |r|
        id_to_reward[r.id] = r
      end

      tag_to_rewards = {}
      RewardTag.joins(:tag).select('tags.name, reward_id').each do |reward_tag|
        (tag_to_rewards[reward_tag.name] ||= Set.new) << id_to_reward[reward_tag.reward_id]
      end

      tag_to_rewards
    end
  end
  
  def get_tag_to_my_rewards(user)
    get_user_rewards_from_cache(user)[0]
  end
  
  def get_user_rewards_from_cache(user)
    cache_short(get_user_rewards_cache_key(user.id)) do
      rewards = Reward.joins(:user_rewards).select("rewards.*").where("user_rewards.user_id = ?", user.id)
      id_to_reward = {}
      rewards.each do |r|
        id_to_reward[r.id] = r
      end
      
      name_to_reward = {}
      rewards.each do |r|
        name_to_reward[r.name] = r
      end
      
      tag_to_rewards = {}
      RewardTag.joins(:tag).select('tags.name, reward_id').each do |reward_tag|
        if id_to_reward[reward_tag.reward_id]
          (tag_to_rewards[reward_tag.name] ||= Set.new) << id_to_reward[reward_tag.reward_id]
        end
      end
      [tag_to_rewards, name_to_reward] 
    end
  end

  # Get a hash cta_id => status for a list of ctas. Needed for separate and caching ctas information 
  # not depending to user
  #   user           - the user for which calculate cta statuses
  #   ctas           - list of ctas to evaluate
  #   reward_name    - name of the reward that ctas contribute to obtain 
  def cta_to_reward_statuses_by_user(user, ctas, reward_name) 
    cta_to_reward_statuses = {}
    ctas.each do |cta|
      cta_to_reward_statuses[cta.id] = cta_reward_statuses(user, cta, reward_name)
    end
    cta_to_reward_statuses
  end

  def cta_reward_statuses(user, cta, reward_name)
    if call_to_action_completed?(cta, user)
      nil
    else
      winnable_outcome, interaction_outcomes, sorted_interactions = predict_max_cta_outcome(cta, user)
      winnable_outcome["reward_name_to_counter"][reward_name]
    end
  end


  def call_to_action_completed?(cta, user = nil)
    user = current_or_anonymous_user if user.nil?

    if !anonymous_user?(user) || stored_anonymous_user?(user)
      require_to_complete_interactions = interactions_required_to_complete(cta)

      if require_to_complete_interactions.count == 0
        false
      else
        require_to_complete_interactions_ids = require_to_complete_interactions.map { |i| i.id }
        interactions_done = UserInteraction.where("user_interactions.user_id = ? and interaction_id IN (?)", user.id, require_to_complete_interactions_ids)
        require_to_complete_interactions.count == interactions_done.count
      end
    else
      false
    end
  end

  def compute_call_to_action_completed_or_reward_status(reward_name, calltoaction, user = nil)
    user = current_or_anonymous_user if user.nil?

    if call_to_action_completed?(calltoaction, user)
      nil
    else
      call_to_action_completed_or_reward_status = compute_current_call_to_action_reward_status(reward_name, calltoaction, user)
      JSON.parse(call_to_action_completed_or_reward_status)
    end
  end

  # Generates an hash with reward information.
  def compute_current_call_to_action_reward_status(reward_name, calltoaction, user = nil)
    if user.nil?
      user = current_user
    end

    reward = get_reward_from_cache(reward_name)
    if reward
      winnable_outcome, interaction_outcomes, sorted_interactions = predict_max_cta_outcome(calltoaction, user)

      interaction_outcomes_and_interaction = interaction_outcomes.zip(sorted_interactions)

      reward_status_images = Array.new
      total_win_reward_count = 0

      if user

        interaction_outcomes_and_interaction.each do |intearction_outcome, interaction|
          user_interaction = interaction.user_interactions.find_by_user_id(user.id)        
    
          if user_interaction && user_interaction.outcome.present?
            win_reward_count = JSON.parse(user_interaction.outcome)["win"]["attributes"]["reward_name_to_counter"].fetch(reward_name, 0)
            correct_answer_outcome = JSON.parse(user_interaction.outcome)["correct_answer"]
            correct_answer_reward_count = correct_answer_outcome ? correct_answer_outcome["attributes"]["reward_name_to_counter"].fetch(reward_name, 0) : 0

            total_win_reward_count += win_reward_count;

            push_in_array(reward_status_images, reward.preview_image(:thumb), win_reward_count)
            push_in_array(reward_status_images, reward.not_winnable_image(:thumb), correct_answer_reward_count - win_reward_count)
            push_in_array(reward_status_images, reward.not_awarded_image(:thumb), intearction_outcome["reward_name_to_counter"][reward_name])
          else 
            push_in_array(reward_status_images, reward.not_awarded_image(:thumb), intearction_outcome["reward_name_to_counter"][reward_name])
          end       

        end

      else
        push_in_array(reward_status_images, reward.not_awarded_image(:thumb), winnable_outcome["reward_name_to_counter"][reward_name])
      end

      winnable_reward_count = winnable_outcome["reward_name_to_counter"][reward_name]
    end

    {
      winnable_reward_count: winnable_reward_count,
      win_reward_count: total_win_reward_count,
      reward_status_images: reward_status_images,
      reward: reward
    }.to_json
  end

  def get_current_interaction_reward_status(reward_name, interaction, user = current_user)
    reward = get_reward_by_name(reward_name)
    if reward
      reward_status_images = Array.new 

      user_interaction = user ? UserInteraction.find_by_user_id_and_interaction_id(user.id, interaction.id) : nil
      
      if user_interaction
        win_reward_count = (JSON.parse(user_interaction.outcome)["win"]["attributes"]["reward_name_to_counter"].fetch(reward_name, 0) rescue 0)
        correct_answer_outcome = (JSON.parse(user_interaction.outcome)["correct_answer"] rescue nil)
        correct_answer_reward_count = correct_answer_outcome ? correct_answer_outcome["attributes"]["reward_name_to_counter"].fetch(reward_name, 0) : 0

        winnable_reward_count = 0

        push_in_array(reward_status_images, reward.preview_image(:thumb), win_reward_count)
        push_in_array(reward_status_images, reward.not_winnable_image(:thumb), correct_answer_reward_count - win_reward_count)
      else
        win_reward_count = 0
        winnable_reward_count = predict_outcome(interaction, nil, true).reward_name_to_counter[reward_name]
        push_in_array(reward_status_images, reward.not_awarded_image(:thumb), winnable_reward_count)
      end
    end

    {
      win_reward_count: win_reward_count,
      winnable_reward_count: winnable_reward_count,
      reward_status_images: reward_status_images,
      reward: reward.to_json
    }

  end

  def get_property_point()
    get_counter_about_user_reward(get_main_reward_name)
  end  

  def get_main_reward_name()
    $context_root.blank? || $context_root == $site.default_property ? $site.main_reward_name : "#{$context_root}-#{$site.main_reward_name}"
  end

  def get_counter_about_user_reward(reward_name, all_periods = false)
    if current_user
      reward_points = { general: 0 }
      periodicity_kinds = $site.periodicity_kinds
      periodicity_kinds.each do |periodicity_kind|
        reward_points[:periodicity_kind] = 0
      end

      get_reward_with_periods(reward_name).each do |user_reward|
        if user_reward.period.blank?
          reward_points[:general] = user_reward.counter
        else
          reward_points[user_reward.period.kind] = user_reward.counter
        end
      end 
      reward_points = all_periods ? reward_points : reward_points[:general]  
    else
      nil
    end
  end

  def compute_rewards_gotten_over_total(reward_ids)
    if reward_ids.any?
      place_holders = (["?"] * reward_ids.count).join ", "
      current_or_anonymous_user.user_rewards.where("reward_id IN (#{place_holders})", *reward_ids).count
    else
      0
    end
  end

  def get_reward_with_periods(reward_name)
    reward = Reward.find_by_name(reward_name)
    if reward
      user_reward = UserReward.includes(:period)
        .where("user_rewards.reward_id = ? AND user_rewards.user_id = ?", reward.id, current_user.id)
        .where("periods.id IS NULL OR (periods.start_datetime < ? AND periods.end_datetime > ?)", Time.now.utc, Time.now.utc)
        .references(:periods)
    else
      []
    end
  end

  def user_has_reward(reward_name)
    user_reward = get_user_rewards_from_cache(current_user)[1]
    !user_reward[reward_name].nil?
  end

  def get_main_reward
    Reward.find_by_name(MAIN_REWARD_NAME);
  end

  def get_reward_by_name(reward_name)
    Reward.find_by_name(reward_name)
  end
  
  def get_main_reward_image_url
    cache_short(get_main_reward_image_cache_key) do
      Reward.find_by_name(MAIN_REWARD_NAME).main_image.url
    end
  end

  # Get max reward
  #   rward_name      - name of the reward type (eg: level, badge)
  #   extra_cache_key - further param to handle name clashing clash in case of multi property
  def get_max_reward(reward_name, extra_cache_key = "")
    cache_short(get_max_reward_key(reward_name, current_user.id, extra_cache_key)) do
      rewards, use_property = rewards_by_tag(reward_name, current_user)
      reward = nil
      if use_property
        if !rewards.empty?
          reward = get_max(rewards[$context_root]) do |x,y| if x.updated_at > y.updated_at then -1 elsif x.updated_at < y.updated_at then 1 else 0 end end
        end 
      elsif !rewards.nil?
        rweard = get_max(rewards) do |x,y| if x.updated_at > y.updated_at then -1 elsif x.updated_at < y.updated_at then 1 else 0 end end
      end
      
      if reward.nil?
        CACHED_NIL
      else
        reward
      end
    end
  end

  def rewards_by_tag(tag_name, user = nil)
    if user.nil?
      tag_to_rewards = get_tag_to_rewards()
    else
      tag_to_rewards = get_tag_to_my_rewards(user)
    end
    # rewards_from_param can include badges or levels 
    rewards_from_param = tag_to_rewards[tag_name]

    property_tags = get_tags_with_tag("property")

    if property_tags.present?

      rewards_to_show = Hash.new

      property_tag_names = property_tags.map{ |tag| tag.name }
      
      tag_to_rewards.each do |tag_name, rewards|
        if property_tag_names.include?(tag_name) && rewards_from_param
          rewards_to_show[tag_name] = rewards & rewards_from_param
        end
      end

      are_properties_used = are_properties_used?(rewards_to_show)
     
      unless are_properties_used
        rewards_to_show = rewards_from_param
      end

    else
      are_properties_used = false
      rewards_to_show = rewards_from_param
    end

    [rewards_to_show, are_properties_used]

  end
  
  def buy_reward(user, reward)
    log_synced("reward bought by user", { 
        'reward_name' => reward.name, 
        'currency' => reward.currency.name,
        'cost' => reward.cost })
    get_reward_with_periods(reward.currency.name).each do |period_reward|
      period_reward.update_attribute(:counter, period_reward.counter - reward.cost)
    end
    
    assign_reward(user, reward.name, 1, $site)
    
    buy_reward_catalogue_expires(reward.currency.name, user.id)
  end

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
    assign_reward_expires(user.id, reward_name)
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
    UserReward.includes(:reward).where("user_id = ? and rewards.name = ? and user_rewards.period_id = ?", user.id, reward_name, period_id).references(:rewards).first
  end

  def get_user_reward(user, reward_name)
    UserReward.includes(:reward).where("user_id = ? and rewards.name = ? and user_rewards.period_id IS NULL", user.id, reward_name).references(:rewards).first
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
      Reward.includes(:call_to_action).where("rewards.media_type = 'CALLTOACTION' and call_to_actions.activated_at <= ? AND call_to_actions.activated_at IS NOT NULL AND call_to_actions.media_type <> 'VOID' AND call_to_actions.user_id IS NULL", Time.now).references(:call_to_actions).to_a
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
    reward.name = "copy-of-" + reward.name
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
      get_property_point
    end
  end

  # Calculate a progress into a reward level.
  #   level          - the level to check progress
  #   starting_point - the cost of the preceding level
  def calculate_level_progress(level, starting_point)
    user_points = get_counter_about_user_reward(get_point)
    level.cost > 0 ? ((user_points - starting_point) * 100) / (level.cost - starting_point) : 100
  end

  def get_level_number
    levels, use_property = rewards_by_tag("level")
    levels.count
  end

  def user_has_currency_for_reward(reward)
    if reward.currency.nil?
      log_error("expected currency for reward", {reward_name: reward.name})
      false
    else
      get_counter_about_user_reward(reward.currency.name) >= reward.cost
    end
  end

  def get_all_rewards_map(property = nil)
    cache_short(get_all_rewards_map_cache_key(property)) do
      all_rewards = {}
      where_conditions = []

      if property && property != "all"
        rewards_with_tag_property = get_rewards_with_tag(property)
        if rewards_with_tag_property.empty?
          return {}
        else
          where_conditions << "rewards.id IN (#{rewards_with_tag_property.map{|r| r.id}.join(",")})"
        end
      end

      basic_rewards_ids = get_basic_rewards_ids()
      where_conditions << "rewards.id NOT IN (#{basic_rewards_ids.join(",")})" if basic_rewards_ids.any?

      if where_conditions.any?
        rewards = Reward.includes(:currency).includes(:call_to_action).where(where_conditions.join(" AND ")).references(:currencies, :call_to_actions).order("rewards.created_at DESC")
      else
        rewards = Reward.includes(:currency).includes(:call_to_action).references(:currencies, :call_to_actions).order("rewards.created_at DESC")
      end

      rewards.each do |reward|
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
  
  def prepare_reward_section(rewards, title, key, icon)
    
    reward_section = ContentSection.new(
      {
        key: key,
        title: title,
        icon_url: {
          "html" => "",
          "html-class" => icon
        },
        contents: prepare_rewards_for_stripe(rewards.slice(0,6)),
        view_all_link: "",
        column_number: DEFAULT_VIEW_ALL_ELEMENTS/4
      })
      
      reward_section
  end
  
  def prepare_rewards_for_stripe(rewards)
    reward_content_previews = []
    rewards.each do |reward|
      reward_content_previews << reward_to_content_preview(reward, false)
    end
    reward_content_previews
  end
  
  def get_user_rewards(all_rewards)
    return [] if all_rewards.empty?
    user_rewards = []
    get_catalogue_user_rewards_ids().each do |reward|
      user_rewards << all_rewards[reward.id] if all_rewards[reward.id]
    end
    user_rewards
  end
  
  def get_catalogue_user_rewards_ids
    cache_short(get_catalogue_user_rewards_ids_key(current_user.id)) do
      Reward.joins(:user_rewards).select("rewards.id").where("user_rewards.period_id IS NULL AND user_rewards.available = true AND user_rewards.counter > 0 AND user_rewards.user_id = ? AND rewards.id NOT IN (?)", current_user.id, get_basic_rewards_ids).to_a
    end
  end
  
  def get_user_available_rewards(all_rewards)
    return [] if all_rewards.empty?
    available_rewards = []
    all_rewards.each do |key, reward|
      if user_has_currency_for_reward(reward) && !user_has_reward(reward.name)
        available_rewards << reward
      end
    end
    available_rewards
  end
  
  def get_property_for_reward_catalogue
    get_context()
  end
  
  def get_last_badge_obtained
    property = get_property()
    if property.present?
      property_name = property.name
    end
    
    badge_tag = Tag.find_by_name("badge")
    badges, badges_use_prop = rewards_by_tag("badge")
    if badges && badges_use_prop
      badges = badges[property_name]
      if badges
        badges = order_elements(badge_tag, badges)
      end
    end
    UserReward.where("user_id = ? AND reward_id in (?)", current_user.id, badges.map{|b| b.id}).order("updated_at DESC").first.reward
  end
  
end