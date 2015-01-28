module DisneyHelper

  def get_disney_property() 
    $context_root || "disney-channel"
  end
  
  def get_disney_property_root_path
    $context_root ? "/#{$context_root}" : ""
  end
  
  def get_disney_root_path_for_property_name(property_name)
    property_name == "disney-channel" ? "" : "/#{property_name}"
  end

  def get_disney_ctas(property)
    ugc_tag = get_tag_from_params("ugc")
    calltoactions = CallToAction.active.includes(:call_to_action_tags, :rewards, :interactions).where("call_to_action_tags.tag_id = ? AND rewards.id IS NULL", property.id)
    if ugc_tag
      ugc_calltoactions = CallToAction.active.includes(:call_to_action_tags, :interactions).where("call_to_action_tags.tag_id = ?", ugc_tag.id)
      if ugc_calltoactions.any?
        calltoactions = calltoactions.where("call_to_actions.id NOT IN (?)", ugc_calltoactions.map { |calltoaction| calltoaction.id })
      end
    end
    calltoactions
  end
  
  def get_my_general_position_in_property
    property_ranking = Ranking.find_by_name("#{get_disney_property}-general-chart")
    if property_ranking
      rank = get_full_rank(property_ranking)
      [rank[:my_position], rank[:total]]
    else
      [nil, nil]
    end
  end
  
  def get_disney_current_contest_point_name
    unless $context_root.nil?
      "#{$context_root}-point"
    else
      "point"
    end
  end
  
  def disney_get_point_name_from_property_name(property_name)
    unless property_name == "disney-channel"
      "#{property_name}-point"
    else
      "point"
    end
  end
  
  def get_disney_highlight_calltoactions(property)
    # Cached in index
    tag_highlight = Tag.find_by_name("highlight")
    if tag_highlight
      calltoactions = get_disney_calltoaction_active_with_tag_in_property(tag_highlight, property, "DESC")
      meta_ordering = get_extra_fields!(tag_highlight)["ordering"]    
      if meta_ordering
        order_elements_by_ordering_meta(meta_ordering, calltoactions)
      else
        calltoactions
      end
    else
      []
    end
  end

  def get_disney_sidebar_calltoactions(property)
    # Cached in index
    tag_sidebar = Tag.find_by_name("sidebar")
    if tag_sidebar
      calltoactions = get_disney_calltoaction_active_with_tag_in_property(tag_sidebar, property, "DESC")
      meta_ordering = get_extra_fields!(tag_sidebar)["ordering"]    
      if meta_ordering
        order_elements_by_ordering_meta(meta_ordering, calltoactions)
      else
        calltoactions
      end
    else
      []
    end
  end

  def get_disney_calltoaction_active_with_tag_in_property(tag, property, order)
    # Cached in index
    tag_calltoactions = CallToAction.includes(:call_to_action_tags).active.where("call_to_action_tags.tag_id = ?", tag.id)
    get_disney_ctas(property).where("call_to_actions.id IN (?)", tag_calltoactions.map { |calltoaction| calltoaction.id }).order("activated_at #{order}")
  end

  def get_disney_calltoactions_count_in_property()
    property = get_tag_from_params(get_disney_property())
    cache_short(get_calltoactions_count_in_property_cache_key(property.id)) do
      get_disney_ctas(property).count
    end
  end

  def compute_property_path(property)
    if property.name == "disney-channel"
      nil
    else
      property.name
    end
  end

  def disney_profile_completed?()
    JSON.parse(current_user.aux)["profile_completed"] rescue true
  end

  def get_disney_membername()
    JSON.parse(current_user.aux)["membername"] rescue ""
  end

  def build_disney_current_user()
    if current_user
      profile_completed = disney_profile_completed?()
      disney_current_user = {
        "facebook" => current_user.facebook($site.id),
        "twitter" => current_user.twitter($site.id),
        "main_reward_counter" => get_point,
        "username" => current_user.username,
        "avatar" => current_avatar,
        "level" => (disney_get_current_level["level"]["name"] rescue "nessun livello"),
        "notifications" => get_unread_notifications_count(),
        "avatar" => current_avatar,
        "profile_completed" => disney_profile_completed?()
      }
      disney_current_user[:username] = get_disney_membername() if !profile_completed
      disney_current_user
    else
      nil
    end
  end

  def get_disney_filter_info()
    filters = get_tags_with_tag("featured")

    if filters.any?
      featured = get_tag_from_params("featured")
      filters = filters & get_tags_with_tag(get_disney_property())
      meta_ordering = get_extra_fields!(featured)["ordering"]    
      if meta_ordering
        filters = order_elements_by_ordering_meta(meta_ordering, filters)
      end    
      filter_info = []
      filters.each do |filter|
        filter_info << {
          "id" => filter.id,
          "background" => get_extra_fields!(filter)["label-background"],
          "icon" => get_extra_fields!(filter)["icon"],
          "title" => filter.title,
          "image" => (get_upload_extra_field_processor(get_extra_fields!(filter)["image"], :thumb) rescue nil) 
        }
      end
      filter_info
    else
      nil
    end
  end

  def build_thumb_calltoaction(calltoaction)
    {
      "id" => calltoaction.id,
      "status" => compute_call_to_action_completed_or_reward_status(get_main_reward_name(), calltoaction),
      "thumbnail_carousel_url" => calltoaction.thumbnail(:carousel),
      "thumbnail_medium_url" => calltoaction.thumbnail(:medium),
      "title" => calltoaction.title,
      "description" => calltoaction.description,
      "likes" => get_number_of_likes_for_cta(calltoaction),
      "comments" => get_number_of_comments_for_cta(calltoaction)
    }
  end

  def get_disney_related_calltoaction_info(current_calltoaction, property)
    cache_short(get_ctas_except_me_in_property_for_user_cache_key(current_calltoaction.id, property.id, current_or_anonymous_user.id)) do
      calltoactions = get_disney_ctas(property).where("call_to_actions.id <> ?", current_calltoaction.id).limit(8)
      related_calltoaction_info = []
      calltoactions.each do |calltoaction|
        related_calltoaction_info << build_thumb_calltoaction(calltoaction)
      end
      related_calltoaction_info
    end
  end

  def get_disney_sidebar_info(property)
    cache_short(get_sidebar_calltoactions_in_property_for_user_cache_key(current_or_anonymous_user.id, property.id)) do  
      calltoactions = get_disney_sidebar_calltoactions(property)

      calltoaction_info = []
      calltoactions.each do |calltoaction|
        calltoaction_info << build_thumb_calltoaction(calltoaction)
      end

      calltoaction_info
    end
  end

  def disney_default_aux(other)

    current_property = get_tag_from_params(get_disney_property())
    property = get_tag_from_params("property")

    if other && other.has_key?(:calltoaction)
      calltoaction = other[:calltoaction]
      related_calltoaction_info = get_disney_related_calltoaction_info(calltoaction, current_property)
    end

    current_property_info = {
      "id" => current_property.id,
      "name" => current_property.name,
      "background" => get_extra_fields!(current_property)["label-background"],
      "image-background" => (get_extra_fields!(current_property)["image-background"]["url"] rescue nil),
      "logo" => (get_extra_fields!(current_property)["logo"]["url"] rescue nil),
      "path" => compute_property_path(current_property),
      "outer" => get_extra_fields!(current_property)["outer"],
      "outer-url" => get_extra_fields!(current_property)["outer-url"],
      "image" => (get_upload_extra_field_processor(get_extra_fields!(current_property)["image"], :thumb) rescue nil) 
    }

    if other && other.has_key?(:filters)
      filter_info = get_disney_filter_info()
    end

    properties = get_tags_with_tag("property")
    meta_ordering = get_extra_fields!(property)["ordering"]    
    if meta_ordering
      properties = order_elements_by_ordering_meta(meta_ordering, properties)
    end

    if properties.any?
      property_info = []
      properties.each do |property|
        property_info << {
          "id" => property.id,
          "background" => get_extra_fields!(property)["label-background"],
          "path" => compute_property_path(property),
          "title" => property.title,
          "image" => (get_upload_extra_field_processor(get_extra_fields!(property)["image"], :thumb) rescue nil),
          "image_hover" => (get_upload_extra_field_processor(get_extra_fields!(property)["image-hover"], :thumb) rescue nil) 
        }
      end
    end

    if other && other.has_key?(:calltoaction_evidence_info)
      calltoaction_evidence_info = cache_short(get_evidence_calltoactions_in_property_for_user_cache_key(current_or_anonymous_user.id, current_property.id)) do  
        highlight_calltoactions = get_disney_highlight_calltoactions(current_property)
        calltoactions_in_property = get_disney_ctas(current_property)
        if highlight_calltoactions.any?
          calltoactions_in_property = calltoactions_in_property.where("call_to_actions.id NOT IN (?)", highlight_calltoactions.map { |calltoaction| calltoaction.id })
        end

        calltoactions = highlight_calltoactions + calltoactions_in_property.limit(3).to_a
        calltoaction_evidence_info = []
        calltoactions.each do |calltoaction|
          calltoaction_evidence_info << build_thumb_calltoaction(calltoaction)
        end

        calltoaction_evidence_info
      end
    end

    aux = {
      "tenant" => get_site_from_request(request)["id"],
      "anonymous_interaction" => get_site_from_request(request)["anonymous_interaction"],
      "main_reward_name" => MAIN_REWARD_NAME,
      "kaltura" => get_deploy_setting("sites/#{request.site.id}/kaltura", nil),
      "filter_info" => filter_info,
      "property_info" => property_info,
      "current_property_info" => current_property_info,
      "calltoaction_evidence_info" => calltoaction_evidence_info,
      "related_calltoaction_info" => related_calltoaction_info,
      "mobile" => small_mobile_device?(),
      "enable_comment_polling" => get_deploy_setting('comment_polling', true),
      "flash_notice" => flash[:notice],
      "sidebar_calltoaction_info" => get_disney_sidebar_info(current_property)
    }

    if other
      other.each do |key, value|
        aux[key] = value unless aux.has_key?(key.to_s)
      end
    end

    aux

  end
  
  def disney_get_max_reward(reward_name)
    get_max_reward(reward_name, $context_root)
  end
  
  # Calculate a progress into a reward level.
  #   level          - the level to check progress
  #   starting_point - the cost of the preceding level
  def disney_calculate_level_progress(level, starting_point, property_name)
    user_points = get_counter_about_user_reward(disney_get_point_name_from_property_name(property_name))
    level.cost > 0 ? ((user_points - starting_point) * 100) / (level.cost - starting_point) : 100
  end
  
  def disney_extract_name_or_username(user)
    if !user.username.empty?
      user.username
    else
      "#{user.first_name} #{user.last_name}"
    end
  end
  
  def disney_prepare_levels_to_show(levels)
    levels = levels[get_disney_property] rescue nil
    levels = order_rewards(levels.to_a, "cost")
    prepared_levels = {}
    unless levels.blank?
      index = 0
      level_before_point = 0
      level_before_status = nil
      levels.each do |level|
        if level_before_status.nil? || level_before_status == "gained"
          progress = disney_calculate_level_progress(level, level_before_point, get_disney_property)
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
  
  def disney_get_current_level()
    current_level = cache_short(get_current_level_by_user(current_user.id, get_disney_property)) do
      levels, levels_use_prop = rewards_by_tag("level")
      property_levels = disney_prepare_levels_to_show(levels)
      current_level = property_levels.select{|key, hash| hash["status"] == "progress" }.first
      unless current_level.nil?
        current_level[1]
      else
        CACHED_NIL
      end
    end
    cached_nil?(current_level) ? nil : current_level
  end
  
  def disney_get_level_number
    levels, use_property = rewards_by_tag("level")
    levels[get_disney_property].count
  end
  
  def disney_link_to_profile(options = nil, html_options = nil, &block)
    if small_mobile_device?
      light_link_to("/profile/index", options, html_options, &block)
    else
      light_link_to("/profile", options, html_options, &block)
    end
  end

end
