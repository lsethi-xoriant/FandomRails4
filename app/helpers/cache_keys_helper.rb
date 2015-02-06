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
  
  def get_tag_with_tag_about_reward_cache_key(reward_id, tag_name)
    "tag_with_tag_about_reward_#{reward_id}_#{tag_name}"
  end

  # Rewards
  # ~~~~~~~
  
  def get_reward_cache_key(reward_name)
    "reward_#{reward_name}"
  end
  
  def get_main_reward_image_cache_key
    "main_reward_image"
  end
  
  def get_user_rewards_cache_key(user_id)
    "user_#{user_id}_rewards"
  end
  
  def get_basic_reward_cache_key
    "basic_reward_ids_cache_key"
  end
  
  def get_all_rewards_map_cache_key
    "all_rewards_catalogue_map_key"
  end
  
  def get_catalogue_user_rewards_ids_key(user_id)
    "catalogue_user_#{user_id}_rewards_ids_key"
  end
  
  # Rewarding System
  # ~~~~~~~~~~~~~~~~
  
  def get_rewarding_rules_collector_cache_key(call_to_action_id)
    "rewarding_rules_collector_#{call_to_action_id}"
  end

  # User
  # ~~~~~

  def get_ctas_except_me_in_property_for_user_cache_key(calltoaction_id, property_id, user_id)
    "ctas_except_#{calltoaction_id}_in_property_#{calltoaction_id}_for_user_#{user_id}"
  end

  def get_cta_completed_or_reward_status_cache_key(reward_name, cta_id, user_id)
    "cta_#{cta_id}_completed_or_reward_status_for_user_#{user_id}_for_reward_#{reward_name}"
  end
  
  # CTA
  # ~~~~~

  def get_rss_ctas_in_property_cache_key(property_id)
    "rss_ctas_in_property_#{property_id}"
  end

  def get_tag_cache_key(tag_name)
    "tag_#{tag_name}"
  end

  def get_next_ctas_stream_for_user_cache_key(user_id, tag, prev_cta_id, cta_max_updated_at, ordering = "recent", related_to = "0")
    "next_ctas_stream_#{tag}_#{prev_cta_id}_#{cta_max_updated_at}_for_user_#{user_id}_by_#{ordering}_related_to_#{related_to}"
  end

  def get_next_ctas_stream_cache_key(tag, prev_cta_id, cta_max_updated_at, ordering = "recent", related_to = "0")
    "next_ctas_stream_#{tag}_#{prev_cta_id}_#{cta_max_updated_at}_by_#{ordering}_related_to_#{related_to}"
  end

  def get_calltoactions_in_property_cache_key(property_id, related_to = "0")
    "calltoactions_in_property_#{property_id}_related_to_#{related_to}"
  end

  def get_calltoactions_in_property_by_ordering_cache_key(property_id, ordering, related_to = "0")
    "calltoactions_in_property_#{property_id}_by_#{ordering}_related_to_#{related_to}"
  end

  def get_calltoactions_count_in_property_cache_key(property_id)
    "calltoactions_count_in_property_#{property_id}"
  end

  def get_evidence_calltoactions_cache_key()
    "evidence_calltoactions"
  end

  def get_evidence_calltoactions_in_property_for_user_cache_key(user_id, property_id)
    "evidence_calltoactions_in_property_#{property_id}_for_user_#{user_id}"
  end

  def get_sidebar_for_property_for_user_cache_key(user_id, property_id)
    "sidebar_calltoactions_in_property_#{property_id}_for_user_#{user_id}"
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
    "likes_count_for_cta_#{cta_id}"
  end

  def get_likes_count_for_interaction_cache_key(interaction_id)
    "likes_count_for_interaction_#{interaction_id}"
  end
  
  def get_tag_names_for_cta_key(cta_id)
    "tag_names_for_cta_key_#{cta_id}"
  end
  
  def get_tag_names_for_tag_key(tag_id)
    "tag_names_for_tag_key_#{tag_id}"
  end

  def get_cta_to_reward_statuses_by_user_cache_key(user_id)
    "cta_to_reward_statuses_#{user_id}"
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
  
  def get_user_ctas_with_tag_cache_key(tag_name)
    "user_ctas_with_tag_#{tag_name}"
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
  
  def get_ctas_with_tags_cache_key(tags_name, with_user_cta)
    "ctas_with_tags_#{tags_name.join("_")}_with_user_cta_#{with_user_cta}"
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
  
  def get_hidden_tags_cache_key
    "hidden_tags_ids"
  end
  
  # Rankings
  # ~~~~~
  def get_general_position_key(user_id)
    "user_#{user_id}_general_position"
  end
  
  def get_ranking_page_key
    "ranking_page"
  end
  
  def get_single_ranking_page_key(ranking_name)
    "single_ranking_page_key_#{ranking_name}"
  end
  
  def get_full_rank_cache_key(ranking_name)
    "full_rank_#{ranking_name}"
  end
  
  def get_ranking_settings_key
    "ranking_page_settings"
  end
  
  def get_rank_page_cache_key(ranking_name, page, version)
    "#{ranking_name}_page_#{page}_#{version}"
  end
  
  def get_user_position_rank_cache_key(user_id, ranking_name, version)
    "#{ranking_name}_user_#{user_id}_position_rank_#{version}"
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
  
  def get_max_reward_key(reward_name, user_id, extra_cache_key)
    "max_reward_#{reward_name}_user_#{user_id}_#{extra_cache_key}"
  end
  
  def get_current_level_by_user(user_id, extra_cache_key = "")
    "current_level_#{user_id}_for_#{extra_cache_key}"
  end
  
  # Gallery
  # ~~~~~~~
  
  def get_gallery_extra_info_key
    "gallery_tag_metadata"
  end
  
  def get_gallery_ctas_cache_key
    "ctas_gallery"
  end
  
  def get_carousel_gallery_cache_key
    "carousel_galleries"
  end
  
  def get_index_gallery_ctas_cache_key
    "infex_gallery_ctas"
  end
  
  def get_gallery_ctas_cache_key(gallery_id)
    "gallery_#{gallery_id}_ctas"
  end
  
  # Instantwin
  # ~~~~~~~~~~
  
  def get_reward_name_for_contest_key(interaction_id)
    "reward_name_for_contest_#{interaction_id}"
  end
  
  def get_user_already_won_contest(user_id, interaction_id)
    "user_#{user_id}_already_won_contest_#{interaction_id}"
  end
  
  # Browse
  # ~~~~~~
  
  def get_browse_search_results_key(term)
    "browse_search_result_#{term}"
  end
  
  def get_full_search_results_key(term, extra_cache_key = "")
    "full_search_result_#{term}_#{extra_cache_key}"
  end
  
  def get_recent_contents_cache_key(query)
    "recent_contents_cache_key_#{query}"
  end
  
  def get_browse_settings_key
    "browse_settings_key"
  end
  
  def get_index_category_cache_key(category_id)
    "index_category_cache_#{category_id}_key"
  end
  
  def get_browse_sections_cache_key
    "browse_page_sections"
  end

  # Coin
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
  
  # Disney
  # ~~~~~~~~~~
  
  def get_property_rankings_cache_key(extra_key)
    "property_rankings_thumbnails_#{extra_key}"
  end
end
