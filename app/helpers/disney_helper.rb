module DisneyHelper
  def get_disney_property
    $context_root || "disney-channel"
  end
  
  def get_disney_property_root_path
    $context_root ? "/#{$context_root}" : ""
  end

  def get_disney_ctas(property, in_gallery = false)
    get_ctas(property, in_gallery)
  end
    
  def get_disney_current_contest_point_name
    unless $context_root.nil?
      "#{$context_root}-point"
    else
      "point"
    end
  end
  
  def get_disney_highlight_calltoactions(property)
    # Cached in index
    tag_highlight = Tag.find_by_name("highlight")
    if tag_highlight
      calltoactions = get_disney_calltoaction_active_with_tag_in_property(tag_highlight, property, "DESC")
      order_elements(tag_highlight, calltoactions)
    else
      []
    end
  end

  def get_disney_calltoaction_active_with_tag_in_property(tag, property, order)
    # Cached in index
    tag_calltoactions = CallToAction.includes(:call_to_action_tags).active.where("call_to_action_tags.tag_id = ?", tag.id).references(:call_to_action_tags)
    get_disney_ctas(property).where("call_to_actions.id IN (?)", tag_calltoactions.map { |calltoaction| calltoaction.id }).order("activated_at #{order}")
  end

  def compute_property_path(property)
    if property.name == "disney-channel"
      nil
    else
      property.name
    end
  end

  def disney_profile_completed?()
    current_user.aux["profile_completed"] rescue true
  end

  def get_disney_membername()
    current_user.aux["membername"] rescue ""
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
        "level" => (get_current_level["level"]["name"] rescue "nessun livello"),
        "notifications" => get_unread_notifications_count(),
        "profile_completed" => profile_completed
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
      filters = order_elements(featured, filters)
      
      filter_info = []
      filters.each do |filter|
        filter_info << {
          "id" => filter.id,
          "name" => filter.name,
          "slug" => filter.slug,
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

  def build_disney_thumb_calltoaction(calltoaction)

    if calltoaction.interactions
      interaction_ids = calltoaction.interactions.map { |interaction| interaction.id }
    end

    {
      "id" => calltoaction.id,
      "slug" => calltoaction.slug,
      "status" => compute_call_to_action_completed_or_reward_status(get_main_reward_name(), calltoaction, anonymous_user),
      "thumbnail_carousel_url" => calltoaction.thumbnail(:carousel),
      "thumbnail_medium_url" => calltoaction.thumbnail(:medium),
      "title" => calltoaction.title,
      "description" => calltoaction.description,
      # Move this code out of cache
      # "likes" => get_number_of_interaction_type_for_cta("Like", calltoaction)
      # "comments" => get_number_of_interaction_type_for_cta("Comment", calltoaction)
      "flag" => build_grafitag_for_calltoaction(calltoaction, "flag"),
      "interaction_ids" => interaction_ids
    }

  end

  def disney_default_aux(other)
    current_property = get_tag_from_params(get_disney_property())
    property = get_tag_from_params("property")

    image_background = (get_extra_fields!(current_property)["image-background"]["url"] rescue nil)

    if other && other.has_key?(:calltoaction)
      calltoaction = other[:calltoaction]

      in_gallery = nil

      if calltoaction.user_id        
        main_related_tag = get_tag_with_tag_about_call_to_action(calltoaction, "gallery").first
        gallery_tag = main_related_tag

        gallery_ctas = get_gallery_ctas_carousel()

        if main_related_tag.present?
          params = {
            conditions: { 
              without_user_cta: true 
            }
          }
          gallery_calltoaction = get_ctas_with_tags_in_or([main_related_tag.id], params).first
          gallery_calltoaction_adjust_for_view = {
            "id" => gallery_calltoaction.id,
            "slug" => gallery_calltoaction.slug,
            "extra_fields" => get_extra_fields!(gallery_calltoaction)
          }

          gallery_upload_interaction = gallery_calltoaction.interactions.find_by_resource_type("Upload")
          
          gallery_tag_adjust_for_view =  build_gallery_tag_for_view(gallery_tag, gallery_calltoaction, gallery_upload_interaction)

          in_gallery = gallery_calltoaction.id
          related_tag_name = main_related_tag.name
          image_background = get_upload_extra_field_processor(get_extra_fields!(main_related_tag)['background_image'], :original)

          related_calltoaction_info = get_content_previews_excluding_ctas(related_tag_name, [], [calltoaction.id], 8)
          #related_calltoaction_info.contents = compute_cta_status_contents(related_calltoaction_info.contents, current_or_anonymous_user)
        end
      else
        main_related_tag = get_tag_with_tag_about_call_to_action(calltoaction, "miniformat").first
        if main_related_tag
          related_tag_name = main_related_tag.name
          related_calltoaction_info = get_content_previews_excluding_ctas(related_tag_name, [current_property], [calltoaction.id], 8)
          #related_calltoaction_info.contents = compute_cta_status_contents(related_calltoaction_info.contents, current_or_anonymous_user)
        else
          related_calltoaction_info = get_content_previews_excluding_ctas(current_property.name, [current_property], [calltoaction.id], 8)
          #related_calltoaction_info.contents = compute_cta_status_contents(related_calltoaction_info.contents, current_or_anonymous_user)
        end
      end

      # Old related implementation
      # related_calltoaction_info = get_disney_related_calltoaction_info(calltoaction, current_property, related_tag_name, in_gallery)
    end

    current_property_info = {
      "id" => current_property.id,
      "title" => current_property.title,
      "name" => current_property.name,
      "background" => get_extra_fields!(current_property)["label-background"],
      "image-background" => image_background,
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
    properties = order_elements(property, properties)
    
    if properties.any?
      property_info = get_content_previews("property")
      # property_info = []
      # properties.each do |property|
      #   property_info << {
      #     "id" => property.id,
      #     "background" => get_extra_fields!(property)["label-background"],
      #     "path" => compute_property_path(property),
      #     "title" => property.title,
      #     "image" => (get_upload_extra_field_processor(get_extra_fields!(property)["image"], :thumb) rescue nil),
      #     "image_hover" => (get_upload_extra_field_processor(get_extra_fields!(property)["image-hover"], :thumb) rescue nil) 
      #   }
      # end
    end

    if other && other.has_key?(:calltoaction_evidence_info)

      cache_key = "evidence_ctas_in_#{current_property.name}"
      cache_timestamp = get_cta_max_updated_at()

      calltoaction_evidence_info, calltoaction_ids = cache_forever(get_ctas_cache_key(cache_key, cache_timestamp)) do  
        highlight_calltoactions = get_disney_highlight_calltoactions(current_property)
        calltoactions_in_property = get_disney_ctas(current_property)
        if highlight_calltoactions.any?
          calltoactions_in_property = calltoactions_in_property.where("call_to_actions.id NOT IN (?)", highlight_calltoactions.map { |calltoaction| calltoaction.id })
        end

        calltoactions = highlight_calltoactions + calltoactions_in_property.limit(3).to_a
        calltoaction_evidence_info = []
        calltoactions.each do |calltoaction|
          calltoaction_evidence_info << build_disney_thumb_calltoaction(calltoaction)
        end

        [calltoaction_evidence_info, calltoactions.map { |cta| cta.id }]
      end

      max_user_interaction_updated_at = from_updated_at_to_timestamp(current_or_anonymous_user.user_interactions.maximum(:updated_at))
      max_user_reward_updated_at = from_updated_at_to_timestamp(current_or_anonymous_user.user_rewards.where("period_id IS NULL").maximum(:updated_at))
      user_cache_key = get_user_interactions_in_cta_info_list_cache_key(current_or_anonymous_user.id, cache_key, "#{cache_timestamp}_#{max_user_interaction_updated_at}_#{max_user_reward_updated_at}", {})

      if current_user
        calltoaction_evidence_info = cache_forever(user_cache_key) do
          adjust_thumb_cta_for_current_user(calltoaction_evidence_info)
        end
      end

      adjust_thumb_ctas(calltoaction_evidence_info)

      calltoaction_evidence_info
    end

    if other && other.has_key?(:sidebar_tag)
      _env = gallery_tag.present? ? gallery_tag : current_property
      sidebar_info = get_sidebar_info(other[:sidebar_tag], _env)
    end

    if current_property && current_property.name != $site.default_property
      property_path_name = current_property.name
    else
      property_path_name = nil;
    end

    if other && other.has_key?(:gallery_tag) 
      gallery_tag_adjust_for_view = other[:gallery_tag]
    end

    aux = {
      "site" => $site,
      "default_property" => $site.default_property,
      "tenant" => $site.id,
      "main_reward_name" => MAIN_REWARD_NAME,
      "kaltura" => get_deploy_setting("sites/#{request.site.id}/kaltura", nil),
      "filter_info" => filter_info,
      "property_info" => property_info,
      "current_property_info" => current_property_info,
      "calltoaction_evidence_info" => calltoaction_evidence_info,
      "related_calltoaction_info" => related_calltoaction_info,
      "property_path_name" => property_path_name,
      "mobile" => small_mobile_device?(),
      "free_provider_share" => $site.free_provider_share,
      "enable_comment_polling" => get_deploy_setting('comment_polling', true),
      "flash_notice" => flash[:notice],
      "sidebar_info" => sidebar_info,
      "gallery_tag" => gallery_tag_adjust_for_view
    }

    aux["gallery_calltoaction"] = gallery_calltoaction_adjust_for_view if gallery_calltoaction_adjust_for_view.present?
    aux["gallery_ctas"] = gallery_ctas if gallery_ctas.present?

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
  
  def disney_extract_name_or_username(user)
    if !user.username.empty?
      user.username
    else
      "#{user.first_name} #{user.last_name}"
    end
  end
  
  def disney_link_to_profile(options = nil, html_options = nil, &block)
    if small_mobile_device?
      light_link_to("/profile/index", options, html_options, &block)
    else
      light_link_to("/profile", options, html_options, &block)
    end
  end

end
