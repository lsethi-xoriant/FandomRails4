require 'fandom_utils'

module CacheKeysHelper
  
  # Notifications
  # ~~~~~
  
  def notification_cache_key(user_id)
    "unread_notifications_#{user_id}"
  end


  # Rewards
  # ~~~~~
  
  def get_reward_cache_key(reward_name)
    "reward_#{reward_name}"
  end

  # USER
  # ~~~~~

  def get_cta_completed_or_reward_status_cache_key(cta_id, user_id)
    "cta_#{cta_id}_completed_or_reward_status_for_user_#{user_id}"
  end
  
  # CTA
  # ~~~~~

  def get_calltoaction_last_comments_cache_key(cta_id)
    "calltoaction_#{cta_id}_last_comments"
  end

  def get_interactions_required_to_complete_cache_key(cta_id)
    "interactions_required_to_complete_#{cta_id}"
  end

  def get_interaction_for_calltoaction_by_resource_type_cache_key(calltoaction_id, resource_type)
    "interaction_for_calltoaction_#{calltoaction_id}_by_resource_type_#{resource_type}"
  end

  def get_interaction_for_calltoaction_by_resource_type_cache_key(calltoaction_id, resource_type)
    "interaction_for_calltoaction_#{calltoaction_id}_by_resource_type_#{resource_type}"
  end

  # CTA and tags
  # ~~~~~

  def get_cta_tags_cache_key(cta_id)
    "cta_tags_#{cta_id}"
  end
  
  def get_tag_with_tag_about_call_to_action_cache_key(cta_id, tag_name)
    "tag_with_tag_about_call_to_action_#{cta_id}_#{tag_name}"
  end

  def get_ctas_with_tag_cache_key(tag_name)
    "ctas_with_tag_#{tag_name}"
  end
  
  def get_rewards_with_tag_cache_key(tag_name)
    "rewards_with_tag_#{tag_name}"
  end


  # Tags
  # ~~~~~
  
  def get_tags_with_tag_cache_key(tag_name)
    "tags_with_tag_#{tag_name}"
  end

  # Rankings
  # ~~~~~
  def get_general_position_key(user_id)
    "user_#{user_id}_general_position"
  end
  
  def get_ranking_page_key
    "ranking_page"
  end
  
  def get_ranking_settings_key
    "ranking_page_settings"
  end
  
  # Profile
  # ~~~~~
  def get_current_user_key(user_id)
    "current_user_#{user_id}"
  end
  
  def get_status_rewar_image_key(reward_name, user_id)
    "status_reward_#{reward_name}_#{user_id}"
  end
  
  def get_reward_points_for_user_key(reward_name, user_id)
    "rewards_#{reward_name}_counter_for_user_#{user_id}"
  end
  
  def get_unlocked_contents_for_user(user_id)
    "unlocked_conents_for_user_#{user_id}"
  end
  
  def get_counter_general_reward_user_key(reward_name, user_id)
    "reward_#{reward_name}_general_counter_user_#{user_id}"
  end
  
  def get_superfan_contest_point_key(user_id)
    "superfan_contest_point_user_#{user_id}"
  end
  
end
