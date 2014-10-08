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

  def get_interactions_required_to_complete_cache_key(cta_id)
    "interactions_required_to_complete_#{cta_id}"
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

end
