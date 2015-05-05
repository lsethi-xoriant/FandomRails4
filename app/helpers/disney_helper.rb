module DisneyHelper

  def check_disney_gallery_params(params)
    if params["other_params"] && params["other_params"]["gallery"]["calltoaction_id"]
      gallery_calltoaction_id = params["other_params"]["gallery"]["calltoaction_id"]
      gallery_user_id = params["other_params"]["gallery"]["user"]
    end
    [gallery_calltoaction_id, gallery_user_id]
  end

  def get_disney_ctas_for_stream_computation(tag, ordering, gallery_calltoaction_id, gallery_user_id, calltoaction_ids_shown, limit_ctas)
    calltoactions = get_disney_ctas(tag, gallery_calltoaction_id)

    # Append other scenario
    if calltoaction_ids_shown
      calltoactions = calltoactions.where("call_to_actions.id NOT IN (?)", calltoaction_ids_shown)
    end

    # User galleries scenario
    if gallery_user_id
      calltoactions = calltoactions.where("user_id = ?", gallery_user_id)
    end

    case ordering
    when "comment"
      calltoaction_ids = from_ctas_to_cta_ids_sql(calltoactions)
      gets_ctas_ordered_by_comments(calltoaction_ids, limit_ctas)
    when "view"
      calltoaction_ids = from_ctas_to_cta_ids_sql(calltoactions)
      gets_ctas_ordered_by_views(calltoaction_ids, limit_ctas)
    else
      calltoactions.limit(limit_ctas).to_a
    end
  end

  def get_disney_ctas_for_stream(params, limit_ctas)
    gallery_calltoaction_id, gallery_user_id = check_disney_gallery_params(params)

    property = get_tag_from_params(get_disney_property())
    ordering = params[:ordering] || "recent"

    cache_key = gallery_calltoaction_id ? gallery_calltoaction_id : property.name
    cache_key = "#{cache_key}_#{ordering}"

    calltoaction_ids_shown = params[:calltoaction_ids_shown]
    if calltoaction_ids_shown
      cache_key = "#{cache_key}_append_from_#{calltoaction_ids_shown.last}"
    end

    if ordering == "recent"
      cache_timestamp = get_cta_max_updated_at()
      ctas = cache_forever(get_ctas_cache_key(cache_key, cache_timestamp)) do
        get_disney_ctas_for_stream_computation(property, ordering, gallery_calltoaction_id, gallery_user_id, calltoaction_ids_shown, limit_ctas)
      end 
    else
      ctas = cache_medium(get_ctas_cache_key(cache_key, nil)) do
        get_disney_ctas_for_stream_computation(property, ordering, gallery_calltoaction_id, gallery_user_id, calltoaction_ids_shown, limit_ctas)
      end 
    end

    page_elements = ["like", "comment", "share"]
    if gallery_calltoaction_id
      page_elements = page_elements + ["vote"]
    end

    build_cta_info_list_and_cache_with_max_updated_at(ctas, page_elements)
  end

  def get_ctas_most_viewed_widget()
    property = get_tag_from_params(get_disney_property())
    result = cache_huge(get_ctas_most_viewed_cache_key(property.id)) do

      ctas = get_disney_ctas(property)
      cta_ids = from_ctas_to_cta_ids_sql(ctas)

      result = []
      gets_ctas_ordered_by_views(cta_ids, 4).each do |cta|
        result << {
          "id" => cta.id,
          "slug" => cta.slug,
          "title" => cta.title,
          "thumb_url" => cta.thumbnail(:thumb)
        }
      end 
      result
    end
  end

  def get_disney_calltoactions_count(calltoactions_in_page, aux)
    if calltoactions_in_page < $site.init_ctas
      calltoactions_in_page
    else
      cache_short(get_calltoactions_count_in_property_cache_key(property.id)) do
        CallToAction.active.count
      end
    end
  end

  def get_disney_property
    $context_root || "disney-channel"
  end
  
  def get_disney_property_root_path
    $context_root ? "/#{$context_root}" : ""
  end
  
  def get_disney_root_path_for_property_name(property_name)
    property_name == "disney-channel" ? "" : "/#{property_name}"
  end

  def get_disney_ctas(property, in_gallery = false)
    if in_gallery
      if in_gallery != "all"
        gallery_calltoaction = CallToAction.find(in_gallery)
        gallery_tag = get_tag_with_tag_about_call_to_action(gallery_calltoaction, "gallery").first
        calltoactions = CallToAction.active_with_media.includes(:call_to_action_tags).where("call_to_action_tags.tag_id = ? AND call_to_actions.user_id IS NOT NULL", gallery_tag.id)
      else
        calltoactions = CallToAction.active_with_media.where("call_to_actions.user_id IS NOT NULL")
      end
    else
      ugc_tag = get_tag_from_params("ugc")
      calltoactions = CallToAction.active.includes(:call_to_action_tags, :rewards, :interactions).where("call_to_action_tags.tag_id = ? AND rewards.id IS NULL", property.id)
      if ugc_tag
        ugc_calltoactions = CallToAction.active.includes(:call_to_action_tags, :interactions).where("call_to_action_tags.tag_id = ?", ugc_tag.id)
        if ugc_calltoactions.any?
          calltoactions = calltoactions.where("call_to_actions.id NOT IN (?)", ugc_calltoactions.map { |calltoaction| calltoaction.id })
        end
      end
    end
    calltoactions
  end
  
  def get_my_general_position_in_property
    property_ranking = Ranking.find_by_name("#{get_disney_property}-general-chart")
    if property_ranking && current_user
      get_my_general_position(property_ranking.name, current_user.id)
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
      order_elements(tag_highlight, calltoactions)
    else
      []
    end
  end

  def get_disney_sidebar_calltoactions(sidebar_tags)
    if sidebar_tags.present?
      cta_info_list, calltoaction_ids = cache_short(get_sidebar_calltoactions_cache_key(sidebar_tags)) do       
        tag_ids = []
        sidebar_tags.each do |tag_name| 
          tag = get_tag_from_params(tag_name)
          if tag
            tag_ids << tag.id
          end
        end

        calltoactions = get_ctas_with_tags_in_and(tag_ids)

        calltoaction_info = []
        calltoactions.each do |calltoaction|
          calltoaction_info << build_disney_thumb_calltoaction(calltoaction)
        end

        [calltoaction_info, calltoactions.map { |cta| cta.id }]
      end

      if current_user && cta_info_list.any?
        calltoactions = CallToAction.where(id: calltoaction_ids)
        cta_info_list = adjust_disney_thumb_calltoaction_for_current_user(cta_info_list, calltoactions)
      end

      cta_info_list
    else
      []
    end

  end

  def get_disney_sidebar_tags(sidebar_tags)
    if sidebar_tags.present?

      tag_ids = []
      sidebar_tags.each do |tag_name| 
        tag = get_tag_from_params(tag_name)
        if tag
          tag_ids << tag.id
        end
      end

      tags = get_tags_with_tags_in_and(tag_ids)

      tag_info = []
      tags.each do |tag|
        tag_info << {
          "title" => tag.title,
          "image" => (get_upload_extra_field_processor(get_extra_fields!(tag)["image"], :thumb) rescue nil),
          "description" => tag.description,
          "url" => get_extra_fields!(tag)["url"]
        }
      end
      tag_info
    else
      []
    end
  end

  def get_disney_calltoaction_active_with_tag_in_property(tag, property, order)
    # Cached in index
    tag_calltoactions = CallToAction.includes(:call_to_action_tags).active.where("call_to_action_tags.tag_id = ?", tag.id)
    get_disney_ctas(property).where("call_to_actions.id IN (?)", tag_calltoactions.map { |calltoaction| calltoaction.id }).order("activated_at #{order}")
  end

  def get_disney_calltoactions_count_in_property(calltoactions_in_page, aux)
    if aux && aux["gallery_calltoactions_count"]
      aux["gallery_calltoactions_count"]
    else
      if calltoactions_in_page < $site.init_ctas
        calltoactions_in_page
      else
        property = get_tag_from_params(get_disney_property())
        cache_short(get_calltoactions_count_in_property_cache_key(property.id)) do
          get_disney_ctas(property).count
        end
      end
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

    {
      "id" => calltoaction.id,
      "slug" => calltoaction.slug,
      "status" => compute_call_to_action_completed_or_reward_status(get_main_reward_name(), calltoaction, anonymous_user),
      "thumbnail_carousel_url" => calltoaction.thumbnail(:carousel),
      "thumbnail_medium_url" => calltoaction.thumbnail(:medium),
      "title" => calltoaction.title,
      "description" => calltoaction.description,
      "votes" => get_votes_thumb_for_cta(calltoaction),
      "likes" => get_number_of_likes_for_cta(calltoaction),
      "comments" => get_number_of_comments_for_cta(calltoaction),
      "flag" => build_grafitag_for_calltoaction(calltoaction, "flag")
    }

  end

  def get_disney_related_calltoaction_info(current_calltoaction, tag, parent_related_tag_name = "miniformat", in_gallery)
    related_calltoaction_info, calltoaction_ids = cache_short(get_ctas_except_me_in_property_cache_key(nil, tag.name)) do
      
      related_tag = get_tag_with_tag_about_call_to_action(current_calltoaction, parent_related_tag_name).first
      if related_tag
        calltoactions = CallToAction.includes(:call_to_action_tags)
                    .where("call_to_action_tags.tag_id = ?", related_tag.id)
                    .where("call_to_actions.id IN (?)", get_disney_ctas(property, in_gallery).map { |calltoaction| calltoaction.id })
                    .order("call_to_actions.activated_at DESC")
                    .limit(9).to_a
      else
        calltoactions = get_disney_ctas(tag, in_gallery).limit(9).to_a
      end

      related_calltoaction_info = []
      calltoactions.each do |calltoaction|
        related_calltoaction_info << build_disney_thumb_calltoaction(calltoaction)
      end

      [related_calltoaction_info, calltoactions.map { |cta| cta.id }]

    end 

    related_calltoaction_info.delete_if { |obj| obj["id"] == current_calltoaction.id }
    related_calltoaction_info = related_calltoaction_info[0..7]

    if current_user
      calltoactions = CallToAction.where(id: calltoaction_ids)
      related_calltoaction_info = adjust_disney_thumb_calltoaction_for_current_user(related_calltoaction_info, calltoactions)
    end

    related_calltoaction_info
  end

  def adjust_disney_thumb_calltoaction_for_current_user(calltoaction_info_list, calltoactions)
    calltoaction_info_list.each do |cta_info|
      cta = find_in_calltoactions(calltoactions, cta_info["id"])
      cta_info["status"] = compute_call_to_action_completed_or_reward_status(get_main_reward_name(), cta)
    end
    calltoaction_info_list
  end

  def get_disney_sidebar_info(sidebar_tags, gallery_cta, other)
    sidebar_tags = sidebar_tags + ["sidebar"]

    tag_info_list = cache_short(get_sidebar_tags_cache_key(sidebar_tags)) do  
      get_disney_sidebar_tags(sidebar_tags)
    end

    cta_info_list = get_disney_sidebar_calltoactions(sidebar_tags)
    
    gallery_rank = nil
    
    if gallery_cta
      gallery_tag = get_tag_with_tag_about_call_to_action(gallery_cta, "gallery").first
      gallery_tag_id = gallery_tag.id
      gallery_rank, total  = cache_short(get_sidebar_gallery_rank_cache_key(gallery_tag.id)) do
        get_vote_ranking(gallery_tag.name, 1)
      end
    end
    
    if other && other[:rank_widget] # TODO: change this when property_rank will be activate
      rank = Ranking.find_by_name("#{get_disney_property}-general-chart")
      property_rank = { rank: get_ranking(rank, 1), rank_id: rank.id }
    end

    if other && other[:fan_of_the_day_widget]
      day = Time.now - 1.day
      winner = cache_long(get_fan_of_the_day_widget_cache_key()) do
        winner_of_the_day = get_winner_of_day(day)
        if winner_of_the_day
          {avatar: user_avatar(winner_of_the_day.user), username: winner_of_the_day.user.username, counter: winner_of_the_day.counter}
        else
          {}
        end
      end
    end
    
    {
      "calltoaction_info_list" => cta_info_list,
      "tag_info_list" => tag_info_list,
      "gallery_rank" => { rank_list: gallery_rank, gallery_id: gallery_tag_id  },
      "property_rank" => property_rank,
      "fan_of_the_day" => winner
    }

  end

  def disney_default_aux(other)

    current_property = get_tag_from_params(get_disney_property())
    property = get_tag_from_params("property")

    image_background = (get_extra_fields!(current_property)["image-background"]["url"] rescue nil)

    if other && other.has_key?(:calltoaction)
      calltoaction = other[:calltoaction]

      related_tag_name = "miniformat"
      in_gallery = nil

      if calltoaction.user_id
        in_gallery = calltoaction.id
        gallery_calltoaction = CallToAction.find(in_gallery)
        

        related_tag = get_tag_with_tag_about_call_to_action(gallery_calltoaction, "gallery").first

        if related_tag.present?
          params = {
            conditions: { 
              without_user_cta: true 
            }
          }
          gallery_calltoaction = get_ctas_with_tags_in_or([related_tag.id], params).first
          gallery_calltoaction_adjust_for_view = {
            "id" => gallery_calltoaction.id,
            "slug" => gallery_calltoaction.slug,
            "extra_fields" => get_extra_fields!(gallery_calltoaction)
          }

          related_tag_name = related_tag.name
          image_background = get_upload_extra_field_processor(get_extra_fields!(related_tag)['background_image'], :original)
        else
          related_tag_name = "gallery"
        end

      end

      related_calltoaction_info = get_disney_related_calltoaction_info(calltoaction, current_property, related_tag_name, in_gallery)
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
      calltoaction_evidence_info, calltoaction_ids = cache_short(get_evidence_calltoactions_in_property_cache_key(current_property.id)) do  
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

      if current_user
        calltoactions = CallToAction.where(id: calltoaction_ids)
        calltoaction_evidence_info = adjust_disney_thumb_calltoaction_for_current_user(calltoaction_evidence_info, calltoactions)
      end

      calltoaction_evidence_info
    end

    if other && other.has_key?(:sidebar_tags)
      sidebar_tags = other[:sidebar_tags] + [current_property.name]
    else
      sidebar_tags = [current_property.name]
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
      "free_provider_share" => $site.free_provider_share,
      "enable_comment_polling" => get_deploy_setting('comment_polling', true),
      "flash_notice" => flash[:notice],
      "sidebar_info" => get_disney_sidebar_info(sidebar_tags, gallery_calltoaction, other),
      "gallery_calltoaction" => gallery_calltoaction_adjust_for_view
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
        level_before_point = level.cost
      end
    end
    prepared_levels
  end
  
  def disney_get_current_level()
    current_level = cache_short(get_current_level_by_user(current_user.id, get_disney_property)) do
      levels, levels_use_prop = rewards_by_tag("level")
      property_levels = disney_prepare_levels_to_show(levels)
      current_level = property_levels.select{|key, hash| hash["status"] == "progress" }.first || property_levels.select{|key, hash| hash["status"] == "gained" }.to_a.last 
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
