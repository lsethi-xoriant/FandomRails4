namespace :anon_navigation do  

  task :clear_users, [:tenant] => :environment do |task, args|
    switch_tenant(args.tenant)
    anonymous_user = User.find_by_email("anonymous@shado.tv")

    users = User.where("anonymous_id IS NOT NULL").where("updated_at < ?", (Time.now.utc - 10.days))
    user_ids = users.map { |user| user.id }

    adjust_user_interactions(user_ids, anonymous_user)
    adjust_user_comment_interactions(user_ids, anonymous_user)  
    adjust_counters(user_ids, anonymous_user)

    users.destroy_all()
  end

  def adjust_counters(user_ids, anonymous_user)
    counter_rewards = Reward.includes(reward_tags: :tag).where("tags.name = 'counter'").references(:reward_tags, :tags)

    counter_rewards.each do |reward|
      
      user_rewards = UserReward.select(:period_id, :reward_id, :available, "sum(counter) as counter")
        .where(user_id: user_ids, reward_id: reward.id)
        .group(:period_id, :reward_id, :available)
        .collect { |user_reward| [user_reward.period_id, user_reward.reward_id, user_reward.available, user_reward.counter] }

      user_rewards.each do |period_id, reward_id, available, counter|

        if period_id
          anon_user_reward = anonymous_user.user_rewards.where("reward_id = ? AND period_id = ?", reward_id, period_id).first
        else
          anon_user_reward = anonymous_user.user_rewards.where("reward_id = ? AND period_id IS NULL", reward_id).first
        end

        if anon_user_reward
          counter = anon_user_reward.counter + counter
          anon_user_reward.update_attribute(:counter, counter)
        else
          UserReward.create(user_id: anonymous_user.id, available: available, period_id: period_id, reward_id: reward_id, counter: counter)
        end

      end
    end

    UserReward.where(user_id: user_ids).destroy_all()
  end

  def adjust_user_comment_interactions(user_ids, anonymous_user)
    UserCommentInteraction.where(user_id: user_ids).update_all(user_id: anonymous_user.id)
  end

  def adjust_user_interactions(user_ids, anonymous_user)
    user_interactions = UserInteraction.where(user_id: user_ids)
    user_interactions.each do |user_interaction|
      case user_interaction.interaction.resource_type.downcase
      when "vote"
        adjust_vote(user_interaction, anonymous_user)
      when "quiz"
        if user_interaction.interaction.resource.quiz_type.downcase == "versus"
          adjust_versus(user_interaction, anonymous_user)
        end
      when "like"
        adjust_like(user_interaction, anonymous_user)
      when "share"
        adjust_share(user_interaction, anonymous_user)
      else
        adjust_counter(user_interaction, anonymous_user)
      end
    end
    user_interactions.destroy_all()
  end

  def find_or_create_anon_user_interaction(user_interaction, anonymous_user, aux)
    anon_user_interaction = anonymous_user.user_interactions.find_by_interaction_id(user_interaction.interaction_id)
    unless anon_user_interaction
      anon_user_interaction = UserInteraction.create(user_id: anonymous_user.id, interaction_id: user_interaction.interaction_id, counter: 0, aux: aux)
    end
    anon_user_interaction
  end

  def adjust_like(user_interaction, anonymous_user)
    aux = { counters: {} }
    anon_user_interaction = find_or_create_anon_user_interaction(user_interaction, anonymous_user, aux)
    anon_aux = anon_user_interaction.aux

    like = user_interaction.aux["like"]

    if like
      value = anon_aux["counter"]
      anon_aux["counter"] = initialize_or_increment_value(value)
      anon_user_interaction.update_attributes(counter: (anon_user_interaction.counter + 1), aux: anon_aux)
    end
  end

  def adjust_share(user_interaction, anonymous_user)
    aux = { providers: {} }
    anon_user_interaction = find_or_create_anon_user_interaction(user_interaction, anonymous_user, aux)
    anon_aux = anon_user_interaction.aux

    providers = user_interaction.aux["providers"]
    providers.each do |provider, count|
      value = anon_aux["providers"][provider] 
      anon_aux["providers"][provider] = initialize_or_increment_value(value, count)
    end

    anon_user_interaction.update_attributes(counter: (anon_user_interaction.counter + user_interaction.counter), aux: anon_aux)
  end

  def adjust_vote(user_interaction, anonymous_user)
    aux = { vote_info_list: {} }
    anon_user_interaction = find_or_create_anon_user_interaction(user_interaction, anonymous_user, aux)
    anon_aux = anon_user_interaction.aux

    vote = user_interaction.aux["vote"]
    value = anon_aux["vote_info_list"]["#{vote}"] 
    anon_aux["vote_info_list"]["#{vote}"] = initialize_or_increment_value(value)

    anon_user_interaction.update_attributes(counter: (anon_user_interaction.counter + 1), aux: anon_aux)
  end

  def adjust_versus(user_interaction, anonymous_user)
    aux = { counters: {} }
    anon_user_interaction = find_or_create_anon_user_interaction(user_interaction, anonymous_user, aux)
    anon_aux = anon_user_interaction.aux

    answer_id = user_interaction.answer_id
    value = anon_aux["counters"]["#{answer_id}"]
    anon_aux["counters"]["#{answer_id}"] = initialize_or_increment_value(value)

    anon_user_interaction.update_attributes(counter: (anon_user_interaction.counter + 1), aux: anon_aux)
  end

  def initialize_or_increment_value(value, increment = 1)
    value.present? ? (value + increment) : increment
  end

  def adjust_counter(user_interaction, anonymous_user)
    anon_user_interaction = find_or_create_anon_user_interaction(user_interaction, anonymous_user, {})
    anon_user_interaction.update_attribute(:counter, (anon_user_interaction.counter + user_interaction.counter))
  end

end