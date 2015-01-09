module DisneyHelper

  def get_disney_property() 
    $context_root || "disney-channel"
  end

  def get_disney_highlight_calltoactions(property)
    # Cached in index
    tag = Tag.find_by_name("highlight")
    if tag
      highlight_calltoactions_in_property = calltoaction_active_with_tag_in_property(tag, property, "DESC")
      meta_ordering = get_extra_fields!(tag)["ordering"]    
      if meta_ordering
        ordered_highlight_calltoactions = order_highlight_calltoactions_by_ordering_meta(meta_ordering, highlight_calltoactions_in_property)
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
      "username" => current_user.username
    }
  end

  def disney_default_aux(current_property)
    filters = get_tags_with_tag("featured")

    current_property_info = {
      "id" => current_property.id,
      "background" => get_extra_fields!(current_property)["label-background"],
      "logo" => (get_extra_fields!(current_property)["logo"]["url"] rescue nil),
      "title" => get_extra_fields!(current_property)["title"],
      "image" => (get_upload_extra_field_processor(get_extra_fields!(current_property)["image"], :custom) rescue nil) 
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
          "image" => (get_upload_extra_field_processor(get_extra_fields!(filter)["image"], :custom) rescue nil) 
        }
      end
    end

    properties = get_tags_with_tag("property")

    if properties.any?
      property_info = []
      properties.each do |property|
        property_info << {
          "id" => property.id,
          "background" => get_extra_fields!(property)["label-background"],
          "title" => (get_extra_fields!(property)["title"].downcase rescue nil),
          "image" => (get_upload_extra_field_processor(get_extra_fields!(property)["image"], :custom) rescue nil) 
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
          "status" => compute_call_to_action_completed_or_reward_status(MAIN_REWARD_NAME, calltoaction),
          "thumbnail_carousel_url" => calltoaction.thumbnail(:carousel),
          "title" => calltoaction.title,
          "description" => calltoaction.description
        }
      end
      calltoaction_evidence_info
    end

    {
      "tenant" => get_site_from_request(request)["id"],
      "anonymous_interaction" => get_site_from_request(request)["anonymous_interaction"],
      "main_reward_name" => MAIN_REWARD_NAME,
      "kaltura" => get_deploy_setting("sites/#{request.site.id}/kaltura", nil),
      "filter_info" => filter_info,
      "property_info" => property_info,
      "current_property_info" => current_property_info,
      "calltoaction_evidence_info" => calltoaction_evidence_info
    }
  end

end
