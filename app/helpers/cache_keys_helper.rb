module CacheKeysHelper
  
  # Notifications
  # ~~~~~~~~~~~~~
  
  def notification_cache_key(user_id)
    "unread_notifications_#{user_id}"
  end
  
  # Settings
  # ~~~~~~~~
  def get_special_guest_settings_key
    "special_guest_menu_setting"
  end
  
  def get_tag_with_tag_about_reward_cache_key(reward_id, tag_name)
    "tag_with_tag_about_reward_#{reward_id}_#{tag_name}"
  end

  def get_profanity_words_cache_key()
    "profanities"
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
  
  def get_all_rewards_map_cache_key(property)
    property_suffix = property ? "_for_property_#{property}" : ""
    "all_rewards_catalogue_map_key#{property_suffix}"
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

  def get_ctas_except_me_in_property_cache_key(calltoaction_id, property_id)
    "ctas_except_#{calltoaction_id}_in_property_#{property_id}"
  end

  def get_ctas_most_viewed_cache_key(context_root = "all")
    "ctas_most_viewed_in_#{context_root}"
  end

  def get_ctas_except_me_cache_key(calltoaction_id, context_root = "all")
    "ctas_except_#{calltoaction_id}_in_context_#{context_root}"
  end

  def get_cta_completed_or_reward_status_cache_key(reward_name, cta_id, user_id)
    "cta_#{cta_id}_completed_or_reward_status_for_user_#{user_id}_for_reward_#{reward_name}"
  end
  
  # CTA
  # ~~~

  def get_cta_info_list_cache_key(cache_key, params) 
    key = "ctas_info_list_#{cache_key}"
    key << "_only_cover" if params[:only_cover].present?
    key
  end

  def get_user_interactions_in_cta_info_list_cache_key(user_id, cache_key, timestamp, params)
    key = "user_interactions_in_cta_info_list_#{cache_key}_user_#{user_id}_#{timestamp}"
    key << "_only_cover" if params[:only_cover].present?
    key
  end

  def get_user_interactions_in_evidence_cta_info_list_cache_key(user_id, cache_key, timestamp)
    "user_interactions_in_evidence_cta_info_list_#{cache_key}_user_#{user_id}_#{timestamp}"
  end

  def get_ctas_cache_key(cache_key, timestamp, limit = "")
    "ctas_#{cache_key}_#{timestamp}_limit_#{limit}"
  end

  def get_evidence_ctas_cache_key(cache_key, timestamp)
    "evidence_ctas_#{cache_key}_#{timestamp}"
  end

  def get_linked_ctas_cache_key(timestamp)
    "linked_ctas_#{timestamp}"
  end

  def get_linked_cta_graph_cache_key(cache_key, timestamp)
    "linked_cta_graph_#{cache_key}_#{timestamp}"
  end

  def get_ctas_for_max_outcome_cache_key(timestamp)
    "ctas_for_max_outcome_#{timestamp}"
  end

  def get_outcome_values_cache_key(cache_key, timestamp)
    "outcome_values_#{cache_key}_#{timestamp}"
  end

  def get_home_stripes_cache_key(context_root = nil)
    "#{context_root}_home_stripes"
  end

  def get_related_calltoactions_cache_key(user_id, calltoaction_id)
    "related_calltoactions_for_calltoaction_#{calltoaction_id}_for_user_#{user_id}"
  end

  def get_calltoactions_count_cache_key()
    "calltoactions_count"
  end

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

  def get_calltoactions_in_property_cache_key(property_id, related_to = "0", cta_max_updated_at = "")
    "calltoactions_in_property_#{property_id}_related_to_#{related_to}_#{cta_max_updated_at}"
  end

  def get_calltoactions_in_property_by_ordering_cache_key(property_id, ordering, related_to = "0")
    "calltoactions_in_property_#{property_id}_by_#{ordering}_related_to_#{related_to}"
  end

  def get_calltoactions_count_in_property_cache_key(property_id)
    "calltoactions_count_in_property_#{property_id}"
  end

  def get_evidence_calltoactions_cache_key(context_root = nil)
    if context_root
      "evidence_calltoactions_in_context_#{context_root}"
    else
      "evidence_calltoactions"
    end
  end

  def get_evidence_calltoactions_in_property_for_user_cache_key(user_id, property_id)
    "evidence_calltoactions_in_property_#{property_id}_for_user_#{user_id}"
  end

  def get_evidence_calltoactions_in_property_cache_key(property_id)
    "evidence_calltoactions_in_property_#{property_id}"
  end

  def get_sidebar_tags_cache_key(sidebar_tags)
    "sidebar_tags_#{sidebar_tags.join("_")}"
  end

  def get_sidebar_calltoactions_cache_key(sidebar_tags)
    "sidebar_calltoacitons_#{sidebar_tags.join("_")}"
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
  
  def get_comments_count_for_cta_key(cta_id)
    "comments_count_for_cta_#{cta_id}"
  end
  
  def get_likes_count_for_cta_key(cta_id)
    "likes_count_for_cta_#{cta_id}"
  end

  def get_votes_count_for_cta_key(cta_id)
    "votes_count_for_cta_#{cta_id}"
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

  def get_cta_ids_by_property_cache_key(property, max_timestamp)
    property_name = property.nil? ? 'nil' : property.name
    "cta_of_property_#{property_name}_max_timestamp"
  end

  # CTA and tags
  # ~~~~~~~~~~~~

  def get_cta_tags_cache_key(cta_id)
    "cta_tags_#{cta_id}"
  end
  
  def get_tag_with_tag_about_call_to_action_cache_key(cta_id, tag_name)
    "tag_with_tag_about_call_to_action_#{cta_id}_#{tag_name}"
  end

  def get_tag_with_tag_about_tag_cache_key(tag_id, tag_name)
    "tag_with_tag_about_tag_#{tag_id}_#{tag_name}"
  end

  def get_ctas_with_tag_cache_key(tag_name, cta_max_updated_at = "")
    "ctas_with_tag_#{tag_name}_#{cta_max_updated_at}"
  end

  def get_all_ctas_with_tag_cache_key(tag_name, cta_max_updated_at = "")
    "all_ctas_with_tag_#{tag_name}_#{cta_max_updated_at}"
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
  
  def get_ctas_with_tags_cache_key(tag_names, extra_key, operator)
    "ctas_with_tags_#{tag_names.join("_")}_#{extra_key}_#{operator}"
  end

  def get_tags_with_tags_cache_key(tag_names, extra_key = "")
    "tags_with_tags_#{tag_names.join("_")}_#{extra_key}"
  end

  def get_all_active_ctas_cache_key()
    "active_ctas_cache_key"
  end

  def get_recent_ctas_cache_key(tag_names, ts, params)
    extra_key = get_extra_key_from_params(params)
    "#{tag_names.present? ? "#{tag_names}" : nil}ctas_with_tags_in_and_#{ts}_#{extra_key}"
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
  # ~~~~~~~~

  def get_ranking_cache_key(page, timestamp)
    "ranking_#{page}_#{timestamp}"
  end

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
  
  def get_fan_of_the_day_widget_cache_key
    "fan_of_the_day_widget"
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
  
  def get_carousel_gallery_cache_key(property_name)
    "carousel_galleries_#{property_name}"
  end
  
  def get_index_gallery_ctas_cache_key
    "infex_gallery_ctas"
  end
  
  def get_gallery_ctas_cache_key(gallery_id)
    "gallery_#{gallery_id}_ctas"
  end
  
  def get_vote_ranking_page_key(tag_name)
    "vote_ranking_for_tag_#{tag_name}"
  end
  
  def get_galleries_for_property_cache_key(property)
    "galleries_for_property_#{property}"
  end
  
  def get_sidebar_gallery_rank_cache_key(tag_name)
    "sidebar_gallery_rank_#{tag_name}"
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
    "browse_search_result_#{term.gsub(/\s+/, "")}"
  end
  
  def get_full_search_results_key(term, extra_cache_key = "")
    "full_search_result_#{term}_#{extra_cache_key}"
  end
  
  def get_recent_contents_cache_key(limit, tag_ids)
    if limit
      "recent_contents_cache_key_#{tag_ids.join("_")}_#{limit[:offset]}"
    else
      "recent_contents_cache_key_#{tag_ids.join("_")}"
    end
  end
  
  def get_browse_settings_key(extra_cache_key = "")
    "browse_settings_key_#{extra_cache_key}"
  end
  
  def get_index_category_cache_key(category_id)
    "index_category_cache_#{category_id}_key"
  end
  
  def get_browse_sections_cache_key(tags, extra_cache_key = "")
    "browse_page_sections_#{tags.map{|tag| tag.id}.join("_")}_#{extra_cache_key}"
  end

  # Coin
  # ~~~~

  def get_coin_locations_cache_key()
    "coin_locations"
  end

  def get_instant_win_coin_interaction_id_cache_key()
    "instant_win_coin_interaction_id"
  end

  def get_share_interaction_daily_done_cache_key(user_id)
    "share_interaction_daily_done_for_user_#{user_id}"
  end
  
  # Votes
  # ~~~~~
  
  def get_cache_votes_for_interaction(interaction_id)
    "cache_votes_for_interaction_#{interaction_id}"
  end
  
  # Disney
  # ~~~~~~
  
  def get_property_rankings_cache_key(extra_key)
    "property_rankings_thumbnails_#{extra_key}"
  end

  def get_total_users_until_date_cache_key(date)
    "total_users_#{date.strftime("%Y-%m-%d")}"
  end

  def get_social_reg_users_until_date_cache_key(date)
    "social_reg_users_#{date.strftime("%Y-%m-%d")}"
  end
  
  # Calendar
  # ~~~~~~~~~~
  
  def get_month_calendar_cache_key(extra_key)
    "month_#{extra_key}_events"
  end

  # Stripe
  # ~~~~~~
  def get_content_previews_cache_key(tag_name, ts, params)
    extra_key = get_extra_key_from_params(params)
    "#{tag_name}_content_previews_#{ts}_#{extra_key}"
  end

  def get_content_previews_statuses_for_tag_cache_key(tag_name, current_user, timestamp, params)
    extra_key = get_extra_key_from_params(params)
    "content_previews_statuses_for_tag_#{tag_name}_#{timestamp}_#{extra_key}_user_#{current_user.id}"
  end

  def get_recent_content_previews_cache_key(params)
    extra_key = get_extra_key_from_params(params)
    "recent_content_previews_#{extra_key}"
  end

end
