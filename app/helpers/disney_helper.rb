module DisneyHelper

  def get_disney_property() 
    $context_root || "disney-channel"
  end
  
  def get_disney_current_contest_point_name
    unless $context_root.nil?
      "#{$context_root}_point"
    else
      "point"
    end
  end
  
  def disney_get_point_name_from_property_name(property_name)
    unless property_name == "disney-channel"
      "#{property_name}_point"
    else
      "point"
    end
  end
  
  def get_disney_highlight_calltoactions(property)
    # Cached in index
    tag = Tag.find_by_name("highlight")
    if tag
      highlight_calltoactions_in_property = calltoaction_active_with_tag_in_property(tag, property, "DESC")
      meta_ordering = get_extra_fields!(tag)["ordering"]    
      if meta_ordering
        ordered_highlight_calltoactions = order_elements_by_ordering_meta(meta_ordering, highlight_calltoactions_in_property)
      else
        highlight_calltoactions
      end
    else
      []
    end
  end

  def calltoaction_active_with_tag_in_property(tag, property, order)
    # Cached in index
    highlight_calltoactions = CallToAction.includes(:call_to_action_tags).active.where("call_to_action_tags.tag_id = ?", tag.id)
    highlight_calltoactions_in_property = CallToAction.includes(:call_to_action_tags).active.where("call_to_action_tags.tag_id = ? AND call_to_actions.id IN (?)", tag.id, highlight_calltoactions.map { |calltoaction| calltoaction.id }).order("activated_at #{order}")
  end

  def get_disney_calltoactions_count_in_property()
    property = get_tag_from_params(get_disney_property())
    cache_short(get_calltoactions_count_in_property_cache_key(property.id)) do
      CallToAction.includes(:call_to_action_tags).active.where("call_to_action_tags.tag_id = ?", property.id).count
    end
  end

  def build_disney_current_user()
    {
      "facebook" => current_user.facebook($site.id),
      "twitter" => current_user.twitter($site.id),
      "main_reward_counter" => get_point,
      "username" => current_user.username,
      "avatar" => current_avatar,
      "level" => (get_max_reward("level")["title"] rescue "nessun livello"),
      "notifications" => get_unread_notifications_count()
    }
  end

  def disney_default_aux(current_property, other = [])
    filters = get_tags_with_tag("featured")

    current_property_info = {
      "id" => current_property.id,
      "background" => get_extra_fields!(current_property)["label-background"],
      "image-background" => (get_extra_fields!(current_property)["image-background"]["url"] rescue nil),
      "logo" => (get_extra_fields!(current_property)["logo"]["url"] rescue nil),
      "title" => get_extra_fields!(current_property)["title"],
      "outer" => get_extra_fields!(current_property)["outer"],
      "outer-url" => get_extra_fields!(current_property)["outer-url"],
      "image" => (get_upload_extra_field_processor(get_extra_fields!(current_property)["image"], :thumb) rescue nil) 
    }

    if filters.any?
      if $context_root
        filters = filters & get_tags_with_tag(get_disney_property())
      end
      filter_info = []
      filters.each do |filter|
        filter_info << {
          "id" => filter.id,
          "background" => get_extra_fields!(filter)["label-background"],
          "icon" => get_extra_fields!(filter)["icon"],
          "title" => get_extra_fields!(filter)["title"],
          "image" => (get_upload_extra_field_processor(get_extra_fields!(filter)["image"], :thumb) rescue nil) 
        }
      end
    end

    properties = get_tags_with_tag("property")
    property = get_tag_from_params("property")
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
          "title" => (get_extra_fields!(property)["title"].downcase rescue nil),
          "image" => (get_upload_extra_field_processor(get_extra_fields!(property)["image"], :thumb) rescue nil) 
        }
      end
    end

    calltoaction_evidence_info = cache_short(get_evidence_calltoactions_in_property_cache_key(current_property.id)) do  

      highlight_calltoactions = get_disney_highlight_calltoactions(current_property)
      calltoactions_in_property = CallToAction.includes(:rewards, :call_to_action_tags).active.where("rewards.id IS NULL AND call_to_action_tags.tag_id = ?", current_property.id)
      if highlight_calltoactions.any?
        calltoactions_in_property = calltoactions_in_property.where("call_to_actions.id NOT IN (?)", highlight_calltoactions.map { |calltoaction| calltoaction.id })
      end

      calltoactions = highlight_calltoactions + calltoactions_in_property.limit(3).to_a
      calltoaction_evidence_info = []
      calltoactions.each do |calltoaction|
        calltoaction_evidence_info << {
          "id" => calltoaction.id,
          "status" => compute_call_to_action_completed_or_reward_status(get_main_reward_name(), calltoaction),
          "thumbnail_carousel_url" => calltoaction.thumbnail(:carousel),
          "thumbnail_medium_url" => calltoaction.thumbnail(:medium),
          "title" => calltoaction.title,
          "description" => calltoaction.description
        }
      end
      calltoaction_evidence_info
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
      "mobile" => small_mobile_device?()
    }

    other.each do |key, value|
      aux[key] = value
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
    levels = levels[get_disney_property] 
    order_rewards(levels.to_a, "cost")
    prepared_levels = {}
    if levels
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
  
  def disney_get_current_level
    cache_short(get_current_level_by_user(current_user.id, get_disney_property)) do
      levels, levels_use_prop = rewards_by_tag("level")
      property_levels = disney_prepare_levels_to_show(levels)
      current_level = property_levels.select{|key, hash| hash["status"] == "progress" }.first
      unless current_level.nil?
        current_level[1]
      else
        CACHED_NIL
      end
    end
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
