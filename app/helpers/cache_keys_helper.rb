require 'fandom_utils'

module CacheKeysHelper
  
  # Notifications
  # ~~~~~
  
  def notification_cache_key(user_id)
    "unread_notifications_#{user_id}"
  end
  
  # Settings
  # ~~~~~~~
  def get_special_guest_settings_key
    "special_guest_menu_setting"
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

  def get_evidence_calltoactions_cache_key()
    "evidence_calltoactions"
  end

  def get_calltoaction_last_comments_cache_key(cta_id)
    "calltoaction_#{cta_id}_last_comments"
  end

  def get_comments_approved_cache_key(interaction_id)
    "interaction_#{interaction_id}_comments_approved"
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
  
  def get_comments_count_for_cta_key(cta_id)
    "comments_count_for_cta_#{cta_id}"
  end
  
  def get_likes_count_for_cta_key(cta_id)
    "comments_likes_for_cta_#{cta_id}"
  end
  
  def get_tag_names_for_cta_key(cta_id)
    "tag_names_for_cta_key_#{cta_id}"
  end
  
  def get_tag_names_for_tag_key(tag_id)
    "tag_names_for_tag_key_#{tag_id}"
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
  
  def get_ctas_with_tag_with_match_cache_key(tag_name)
    "ctas_with_tag_with_match_#{tag_name}"
  end
  
  def get_rewards_with_tag_cache_key(tag_name)
    "rewards_with_tag_#{tag_name}"
  end
  
  def get_last_rewards_for_tag(tag_name, user_id)
    "last_rewards_with_tag_#{tag_name}_user_#{user_id}"
  end
  
  def get_ctas_with_tags_cache_key(tags_name)
    "ctas_with_tags_#{tags_name.join("_")}"
  end

  def get_all_active_ctas_cache_key()
    "active_ctas_cache_key"
  end

  # Tags
  # ~~~~~
  
  def get_tags_with_tag_cache_key(tag_name)
    "tags_with_tag_#{tag_name}"
  end
  
  def get_tags_with_tag_with_match_cache_key(tag_name, query)
    "tags_with_tag_with_match_#{tag_name}_#{query}"
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
  # ~~~~~~~
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
  
  def get_max_reward_key(reward_name, user_id)
    "max_reward_#{reward_name}_user_#{user_id}_key"
  end
  
  # Gallery
  # ~~~~~~~
  
  def get_gallery_extra_info_key
    "gallery_tag_metadata"
  end
  
  # Instantwin
  # ~~~~~~~~~~
  
  def get_reward_name_for_contest_key(interaction_id)
    "reward_name_for_contest_#{interaction_id}"
  end
  
  def get_user_already_won_contest(user_id, interaction_id)
    "user_#{user_id}_already_won_contest_#{interaction_id}"
  end
  
  # BROWSE
  # ~~~~~~
  
  def get_browse_search_results_key(term)
    "browse_search_result_#{term}"
  end

  # COIN
  # ~~~~~~~~~~

  def get_coin_locations_cache_key()
    "coin_locations"
  end

  def get_instant_win_coin_interaction_id_cache_key()
    "instant_win_coin_interaction_id"
  end

  def get_share_interaction_daily_done_cache_key(user_id)
    "share_interaction_daily_done_for_user_#{user_id}"
  end
  
end
