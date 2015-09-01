module BraunIcHelper

  def braun_ic_contest_identitycollection_active?
    assets = Tag.find("assets")
    date = assets.extra_fields["contest_identitycollection_start_date"] || CONTEST_IDENTITY_COLLECTION_START_DATE
    Time.now.utc >= date.to_time.utc
  end

  def braun_ic_iw_user_valid?()
    if current_user
      if current_user.birth_date
        contest_start_date = Time.parse(CONTEST_BRAUN_IW_START_DATE)
        birth_date = Time.parse(current_user.birth_date.to_s)
        birth_date_valid_for_contest?(contest_start_date, birth_date)
      else
        true
      end
    else
      true
    end
  end
  
  def adjust_braun_ic_reward(reward, inactive, activated_at)
    image = inactive.present? ? reward.not_awarded_image : reward.main_image
      
    { 
      name: reward.name,
      title: reward.title,
      description: reward.short_description,
      image: image,
      cost: reward.cost,
      extra_fields: reward.extra_fields,
      inactive: inactive,
      activated_at: activated_at
    }
  end  

  def compute_user_badge(user_id)
    compute_badges([user_id])[user_id]
  end

  def compute_badges(user_ids)
    badge_tag = Tag.find("badge")
    category_tags = Tag.includes(tags_tags: :other_tag).where("other_tags_tags_tags.name = 'test'").order("tags.name asc").references(:tags_tags, :other_tag)

    users_badge = {}
    category_tags.each do |category_tag| 
      activated_at = CallToAction.includes(:call_to_action_tags).where("call_to_action_tags.tag_id = ?", category_tag.id).references(:call_to_action_tags).first.activated_at

      badge_inactive = Reward.includes(:reward_tags).where("reward_tags.tag_id = ?", category_tag.id).references(:reward_tags).order("rewards.cost asc").first
      user_to_rewards = get_user_to_rewards_with_tags_in_and([badge_tag, category_tag], user_ids)
      
      user_ids.each do |user_id|
        user_reward = user_to_rewards[user_id]
        inactive = false
        unless user_reward
          user_reward = badge_inactive
          inactive = true
        end

        image = inactive ? user_reward.not_awarded_image : user_reward.main_image

        (users_badge[user_id] ||= []) << adjust_braun_ic_reward(user_reward, inactive, activated_at)
      end
    end

    users_badge
  end

end