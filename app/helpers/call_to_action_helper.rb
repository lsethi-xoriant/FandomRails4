module CallToActionHelper

  def get_parent_cta_name(cta_info)
    get_parent_cta(cta_info)["calltoaction"]["name"]
  end

  def get_parent_cta(cta_info)
    if cta_info["optional_history"].present? && cta_info["optional_history"]["parent_cta_info"].present?
      cta_info["optional_history"]["parent_cta_info"]
    else
      cta_info
    end
  end

  def get_sidebar_info(sidebar_tag_name, property)
    widget_tag = Tag.find_by_name("widget")
    if widget_tag.present?
      property_sidebar_tag = property.present? ? [property, widget_tag] : [widget_tag]

      sidebar_content_previews = get_content_previews(sidebar_tag_name, property_sidebar_tag)
      
      sidebar_content_previews.contents.each do |content|
        case content.title
        when "sign-up-widget"
          content.type = content.title
        when "fan-of-the-day-widget"
          content.type = content.title
          winner_of_the_day = get_winner_of_day(Date.yesterday)
          if winner_of_the_day
            content.extra_fields["widget_info"] = {
              avatar: user_avatar(winner_of_the_day.user), 
              username: winner_of_the_day.user.username, 
              counter: winner_of_the_day.counter
            }
          end
        when "popular-ctas-widget"
          content.type = content.title
          content.extra_fields["widget_info"] = {
            ctas: get_ctas_most_viewed(property)
          }
        when "ranking-widget"
          ranking_name = property.present? ? "#{property.name}-general-chart" : "general-chart"
          ranking = Ranking.find_by_name(ranking_name)
          content.type = content.title
          content.extra_fields["widget_info"] = {
            rank: get_ranking(ranking, 1),
            rank_id: ranking.id
          }
        when "gallery-ranking-widget"
          content.type = content.title
          gallery = property
          rank, rank_count = get_vote_ranking(gallery.name, 1)
          content.extra_fields["widget_info"] = { 
            rank: rank, 
            gallery_id: gallery.id  
          }
        else
          # Nothing to do
        end
      end
    else
      sidebar_content_previews = []
    end

    sidebar_content_previews

  end

  def get_ctas_most_viewed(property)
    max_timestamp = get_cta_max_updated_at()
    cache_key = get_cta_ids_by_property_cache_key(property, max_timestamp)

    cta_ids = cache_forever(cache_key) do
      ctas = get_ctas(property)
      cta_ids = from_ctas_to_cta_ids_sql(ctas)
    end

    result = []
    ctas_most_viewed = gets_ctas_ordered_by_views(cta_ids, 4)
    ctas_most_viewed.each do |cta|
      result << {
        "id" => cta.id,
        "slug" => cta.slug,
        "title" => cta.title,
        "thumb_url" => cta.thumbnail(:thumb)
      }
    end 
    result
  end

  def check_gallery_params(params)
    if params["other_params"] && params["other_params"]["gallery"]["calltoaction_id"]
      {
        "gallery_calltoaction_id" => params["other_params"]["gallery"]["calltoaction_id"],
        "gallery_user_id" => params["other_params"]["gallery"]["user"]
      }
    else
      nil
    end
  end

  def get_ctas_for_stream(tag_name, params, limit_ctas)
    limit_ctas_with_has_more_check = limit_ctas + 1

    gallery_info = check_gallery_params(params)
    ordering = params[:ordering] || "recent"

    if tag_name
      tag = get_tag_from_params(tag_name)
    end
   
    if tag
      cache_key = tag.name
    else
      cache_key = ""
    end
    if gallery_info
      cache_key = "gallery_#{cache_key}_#{gallery_info["gallery_calltoaction_id"]}"
      if gallery_info["gallery_user_id"].present?
        cache_key = "#{cache_key}_user_#{gallery_info["gallery_user_id"]}"
      end
    end
    cache_key = "#{cache_key}_#{ordering}"

    calltoaction_ids_shown = params[:calltoaction_ids_shown]
    if calltoaction_ids_shown
      cache_key = "#{cache_key}_append_from_#{calltoaction_ids_shown.last}"
    end

    exclude_cta_with_ids = params["exclude_cta_with_ids"]
    if exclude_cta_with_ids
      cache_key = "#{cache_key}_except_#{exclude_cta_with_ids.join("_")}"
    end

    if ordering == "recent"
      cache_timestamp = get_cta_max_updated_at()
      ctas = cache_forever(get_ctas_cache_key(cache_key, cache_timestamp, limit_ctas)) do
        get_ctas_for_stream_computation(tag, ordering, gallery_info, calltoaction_ids_shown, limit_ctas_with_has_more_check, exclude_cta_with_ids)
      end 
    else
      ctas = get_ctas_for_stream_computation(tag, ordering, gallery_info, calltoaction_ids_shown, limit_ctas_with_has_more_check, exclude_cta_with_ids)
    end

    page_elements = params && params["page_elements"] ? params["page_elements"] : nil
    if gallery_info
      if page_elements.present?
        page_elements = page_elements + ["vote"]
      end
    end

    params_for_build_cta_info_list = { only_cover: true }
    if params && params[:comments_limit].present?
      params_for_build_cta_info_list[:comments_limit] = params[:comments_limit]
    end

    ctas = build_cta_info_list_and_cache_with_max_updated_at(ctas, page_elements, params_for_build_cta_info_list)

    if limit_ctas < ctas.length
      has_more = true
      ctas.pop
    else
      has_more = false
    end

    [ctas, has_more]
  end

  def get_ctas_for_stream_computation(tag, ordering, gallery_info, calltoaction_ids_shown, limit_ctas, exclude_cta_with_ids = nil)
    if gallery_info
      gallery_calltoaction_id = gallery_info["gallery_calltoaction_id"]
      gallery_user_id = gallery_info["gallery_user_id"]
    end

    if gallery_info && $site.id == "disney"
      tag = nil
    end

    calltoactions = get_ctas(tag, gallery_calltoaction_id)

    # Append other scenario
    if calltoaction_ids_shown
      calltoactions = calltoactions.where("call_to_actions.id NOT IN (?)", calltoaction_ids_shown)
    end

    if exclude_cta_with_ids
      calltoactions = calltoactions.where("call_to_actions.id NOT IN (?)", exclude_cta_with_ids)
    end

    # User galleries scenario
    if gallery_user_id
      calltoactions = calltoactions.where("user_id = ?", gallery_user_id)
    end

    case ordering
    when "comment"
      if calltoactions.size > 0
        calltoaction_ids = from_ctas_to_cta_ids_sql(calltoactions)
        gets_ctas_ordered_by_comments(calltoaction_ids, limit_ctas)
      else
        []
      end
    when "view"
      if calltoactions.size > 0
        calltoaction_ids = from_ctas_to_cta_ids_sql(calltoactions)
        gets_ctas_ordered_by_views(calltoaction_ids, limit_ctas)
      else
        []
      end
    else
      calltoactions.limit(limit_ctas).to_a
    end
  end

  # Returns a list of call to actions filtered by tag, or belonging to some gallery
  # 
  # tag        - the tag to filter on; can be null
  # in_gallery - either null, or a gallery cta id, or the string "all", meaning to get all ctas of all galleries 
  def get_ctas(tag, in_gallery = nil)
    if in_gallery
      return get_ctas_in_gallery(tag, in_gallery)
    else
      return get_ctas_not_in_gallery(tag)
    end
  end

  def get_ctas_in_gallery(tag, gallery_cta_id_or_all)
    if gallery_cta_id_or_all == "all"
      if tag
        return CallToAction.active.includes(:call_to_action_tags).where("call_to_action_tags.tag_id = ? AND call_to_actions.user_id IS NOT NULL AND call_to_actions.approved", tag.id).references(:call_to_action_tags)
      else
        return CallToAction.active.where("call_to_actions.user_id IS NOT NULL AND call_to_actions.approved")
      end
    else # single gallery
      gallery_calltoaction = CallToAction.find(gallery_cta_id_or_all)
      gallery_tag = get_tag_with_tag_about_call_to_action(gallery_calltoaction, "gallery").first
      return CallToAction.active.includes(:call_to_action_tags).where("call_to_action_tags.tag_id = ? AND call_to_actions.user_id IS NOT NULL AND call_to_actions.approved", gallery_tag.id).references(:call_to_action_tags)
    end
  end

  def get_ctas_not_in_gallery(tag)
    if tag
      calltoactions = CallToAction.active.includes(:call_to_action_tags, :rewards, :interactions).where("call_to_action_tags.tag_id = ? AND rewards.id IS NULL", tag.id).references(:call_to_action_tags, :rewards, :interactions)
    else
      calltoactions = CallToAction.active.includes(:rewards, :interactions).where("rewards.id IS NULL").references(:rewards, :interactions)
    end
    ugc_tag = get_tag_from_params("ugc")
    if ugc_tag
      ugc_calltoactions = CallToActionTag.select(:call_to_action_id).where("call_to_action_tags.tag_id = ?", ugc_tag.id)
      if ugc_calltoactions.any?
        calltoactions = calltoactions.where("call_to_actions.id NOT IN (?)", ugc_calltoactions)
      end
    end
    calltoactions
  end

  def cta_url(cta)
    if $context_root
      "/#{$context_root}/call_to_action/#{cta.slug}"
    else 
      "/call_to_action/#{cta.slug}"
    end
  end

  def get_calltoactions_count(calltoactions_in_page, aux)
    if calltoactions_in_page < $site.init_ctas
      calltoactions_in_page
    else
      cache_short(get_calltoactions_count_cache_key()) do
        CallToAction.active.count
      end
    end
  end

  def get_all_ctas_with_tag(tag_name)
    cache_short get_ctas_with_tag_cache_key(tag_name) do
      CallToAction.includes(call_to_action_tags: :tag).where("tags.name = ?", tag_name).references(:call_to_action_tags).order("activated_at DESC").to_a
    end
  end

  def get_property_from_cta(cta)
    properties_tag = get_tag_with_tag_about_call_to_action(cta, "property")
    if properties_tag.empty?
      ""
    else
      "#{properties_tag.first.name}"
    end
  end

  def aws_trasconding_not_required_or_completed(cta)
    aux = cta.aux || {}
    @aws_transcoding_media_status = aux["aws_transcoding_media_status"]
    !@aws_transcoding_media_status || @aws_transcoding_media_status == "done"
  end

  def from_ctas_to_cta_ids_sql(call_to_actions)
    # calltoactions.joins("LEFT OUTER JOIN call_to_action_tags ON call_to_action_tags.call_to_action_id = call_to_actions.id")
    #              .joins("LEFT OUTER JOIN rewards ON rewards.call_to_action_id = call_to_actions.id")
    #              .select("call_to_actions.id").to_sql
    call_to_actions.map {|cta| cta.id}.join(",")
  end

  def gets_ctas_ordered_by_comments(calltoaction_ids, cta_count)
    #sql = "SELECT call_to_actions.id,  sum((user_comment_interactions.approved is not null and user_comment_interactions.approved)::integer) " +
    #      "FROM call_to_actions LEFT OUTER JOIN interactions ON call_to_actions.id = interactions.call_to_action_id LEFT OUTER JOIN user_comment_interactions ON interactions.resource_id = user_comment_interactions.comment_id " +
    #      "WHERE interactions.resource_type = 'Comment' AND call_to_actions.id in (#{calltoaction_ids}) " +
    #      "GROUP BY call_to_actions.id " +
    #      "ORDER BY sum DESC limit #{cta_count};"
    query = 
      "SELECT interactions.call_to_action_id AS id " +
      "FROM interactions LEFT OUTER JOIN view_counters ON interactions.id = view_counters.ref_id " +
      "WHERE (view_counters.ref_type is null OR view_counters.ref_type = 'interaction') AND interactions.call_to_action_id IN (#{calltoaction_ids}) AND interactions.resource_type = 'Comment' " +
      "ORDER BY coalesce(view_counters.counter, 0) DESC limit #{cta_count};"
    execute_sql_and_get_ctas_ordered(query)
  end

  def gets_ctas_ordered_by_views(calltoaction_ids, cta_count)
    query = "SELECT call_to_actions.id " +
            "FROM call_to_actions LEFT OUTER JOIN view_counters ON call_to_actions.id = view_counters.ref_id " +
            "WHERE (view_counters.ref_type is null OR view_counters.ref_type = 'cta') AND call_to_actions.id in (#{calltoaction_ids}) " +
            "ORDER BY (coalesce(view_counters.counter, 0) / (extract('epoch' from (now() - coalesce(call_to_actions.activated_at, call_to_actions.created_at) )) / 3600 / 24)) DESC, call_to_actions.activated_at DESC limit #{cta_count};"
    execute_sql_and_get_ctas_ordered(query)
  end

  def execute_sql_and_get_ctas_ordered(query)
    cta_ids = ActiveRecord::Base.connection.execute(query)
    order =  cta_ids.map { |r| "call_to_actions.id = #{r["id"].to_i} DESC" }
    CallToAction.where("call_to_actions.id" => cta_ids.map { |r| r["id"].to_i }).order("#{order.join(",")}").to_a
  end

  def get_cta_active_count()
    cache_short("cta_active_count") do
      CallToAction.active.count
    end
  end

  def get_cta_max_updated_at(ids = [])
    where_clause = ids.empty? ? "user_id IS NULL" : "user_id IS NULL AND id IN (#{ids.join(",")})"
    maximum = CallToAction.active_no_order_by.where(where_clause).maximum(:updated_at)
    from_updated_at_to_timestamp(maximum)
  end

  def get_max_updated_at(models)
    max_updated_at = nil
    models.each do |model|
      if !max_updated_at || model.updated_at > max_updated_at
        max_updated_at = model.updated_at
      end
    end
    from_updated_at_to_timestamp(max_updated_at)
  end

  def get_user_interactions_max_updated_at_for_cta(user, cta)
    maximum = UserInteraction.where(:user_id => user.id, :interaction_id => Interaction.where(:call_to_action_id => cta.id)).maximum(:updated_at)
    from_updated_at_to_timestamp(maximum)
  end

  def from_updated_at_to_timestamp(updated_at)
    if updated_at
      updated_at.to_i.to_s
    else
      nil
    end
  end

  def build_cta_info_list_and_cache_with_max_updated_at(calltoactions, interactions_to_compute = nil, params = {})
    calltoaction_ids = calltoactions.map { |calltoaction| calltoaction.id }
    interactions_to_compute_key = interactions_to_compute.present? ? interactions_to_compute.join("_") : "all"
    calltoactions_key = calltoaction_ids.join("_")
    cache_timestamp = get_max_updated_at(calltoactions)
    cache_key = get_cta_info_list_cache_key("#{calltoactions_key}_interaction_types_#{interactions_to_compute_key}_#{cache_timestamp}", params)

    build_cta_info_list(cache_key, calltoactions, interactions_to_compute, params)
  end

  def build_cta_info_list(cache_key, calltoactions, interactions_to_compute = nil, params = {})
    calltoaction_info_list = cache_forever(cache_key) do
      
      calltoaction_info_list = Array.new
      interactions = {}
      interaction_id_to_answers = {}

      calltoactions.each do |calltoaction|
    
        interaction_info_list = build_interaction_info_list(calltoaction, interactions_to_compute)

        reward = Reward.includes(:currency).where(call_to_action_id: calltoaction.id).references(:currencies).first
        if reward.present?
          calltoaction_reward_info = {
            "cost" => reward.cost,
            "status" => "locked",
            "has_currency" => false,
            "reward" => reward,
            "id" => reward.id          
          }
        end

        # user cta adjusted out of cache block
        user_info = { id: calltoaction.user.id } if calltoaction.user.present?

        cta_extra_fields = get_extra_fields!(calltoaction)
        
        if cta_extra_fields["linked_call_to_actions_count"]
          optional_history = {
            "optional_total_count" => cta_extra_fields["linked_call_to_actions_count"],
            "optional_index_count" => 1
          }
        else
          optional_history = {}
        end

        if calltoaction.media_type == "YOUTUBE"
          if calltoaction.media_data.present?
            if calltoaction.media_data.include?(",")
              vcodes = calltoaction.media_data.split(",")
              vcode = vcodes.first
            else
              vcode = calltoaction.media_data
            end
          end
        end

        if calltoaction.enable_disqus
          disqus_setting = get_deploy_setting("sites/#{$site.id}/disqus", nil)
          if disqus_setting
            disqus = { shortname: disqus_setting["app_shortname"] }
          end
        end
        
        calltoaction_info = {
            "calltoaction" => { 
              "id" => calltoaction.id,
              "disqus" => disqus,
              "name" => calltoaction.name,
              "slug" => calltoaction.slug,
              "detail_url" => cta_url(calltoaction),
              "valid_from" => (calltoaction.valid_from.in_time_zone($site.timezone) rescue nil),
              "valid_to" => (calltoaction.valid_to.in_time_zone($site.timezone) rescue nil),
              "title" => calltoaction.title,
              "description" => calltoaction.description,
              "media_type" => calltoaction.media_type,
              "media_image" => calltoaction.media_image(:extra_large),
              "vcode" => vcode,
              "vcodes" => vcodes, 
              "media_data" => get_cta_media_data(calltoaction), 
              "thumbnail_url" => calltoaction.thumbnail_url,
              "thumbnail_carousel_url" => calltoaction.thumbnail(:carousel),
              "thumbnail_medium_url" => calltoaction.thumbnail(:medium),
              "thumbnail_wide_url" => calltoaction.thumbnail(:wide),
              "interaction_info_list" => interaction_info_list,
              "extra_fields" => get_extra_fields!(calltoaction),
              "activated_at" => calltoaction.activated_at,
              "user" => user_info,
              "updated_at" => calltoaction.updated_at
            },
            "optional_history" => optional_history,
            "flag" => build_grafitag_for_calltoaction(calltoaction, "flag"),
            "miniformat" => build_grafitag_for_calltoaction(calltoaction, "miniformat"),
            "status" => compute_call_to_action_completed_or_reward_status(get_main_reward_name(), calltoaction, anonymous_user),
            "reward_info" => calltoaction_reward_info
        }

        calltoaction_info_list << calltoaction_info

      end

      calltoaction_info_list
    end

    interaction_ids = extract_interaction_ids_from_call_to_action_info_list(calltoaction_info_list)

    calltoaction_ids = calltoactions.map { |calltoaction| calltoaction.id }
    max_user_interaction_updated_at = from_updated_at_to_timestamp(current_or_anonymous_user.user_interactions.includes(:interaction).maximum(:updated_at))
    max_user_reward_updated_at = from_updated_at_to_timestamp(current_or_anonymous_user.user_rewards.where("period_id IS NULL").maximum(:updated_at))
    user_cache_key = get_user_interactions_in_cta_info_list_cache_key(current_or_anonymous_user.id, cache_key, "#{max_user_interaction_updated_at}_#{max_user_reward_updated_at}", params)

    calltoaction_info_list = cache_forever(user_cache_key) do
      if current_user
        interaction_ids = extract_interaction_ids_from_call_to_action_info_list(calltoaction_info_list)
        user_interactions = get_user_interactions_with_interaction_id(interaction_ids, current_user)
        adjust_call_to_actions_with_user_interaction_data(calltoactions, calltoaction_info_list, user_interactions)
        
        # calltoaction_info_list is updated in case of linked ctas; if so, it already fully "prepared"     
        calltoaction_info_list = check_and_find_next_cta_from_user_interactions(calltoactions, calltoaction_info_list, interactions_to_compute)
      else    
        interaction_ids = extract_interaction_ids_from_call_to_action_info_list(calltoaction_info_list)
        user_interactions = get_user_interactions_with_interaction_id(interaction_ids, anonymous_user)
      
        calltoaction_info_list.each do |calltoaction_info|
          calltoaction_info["calltoaction"]["interaction_info_list"].each do |interaction_info|
            interaction_id = interaction_info["interaction"]["id"]
            user_interaction = find_in_user_interactions(user_interactions, interaction_id)
            if user_interaction
              interaction_info["anonymous_user_interaction_info"] = build_user_interaction_for_interaction_info(user_interaction)
            end
          end
        end
      end
      calltoaction_info_list
    end

    if small_mobile_device?()
      calltoaction_info_list.each do |calltoaction_info|
        calltoaction_info["calltoaction"]["interaction_info_list"].each do |interaction_info_list|
          if interaction_info_list["interaction"]["when_show_interaction"].include?("OVERVIDEO")
            interaction_info_list["interaction"]["when_show_interaction"] = "SEMPRE_VISIBILE"
          end

          if interaction_info_list["interaction"]["resource_type"] != "pin"
            interaction_info_list["interaction"]["interaction_positioning"] = "UNDER_MEDIA"
          end
        end
      end
    end

    if calltoaction_info_list.length == 1 && calltoaction_info_list[0]["calltoaction"]["disqus"]
      calltoaction_info_list[0]["calltoaction"]["disqus"]["sso"] = disqus_sso
    end

    calltoaction_info_list_to_adjust = []
    calltoaction_info_list.each do |calltoaction_info|
      calltoaction_info_list_to_adjust << calltoaction_info
      if calltoaction_info["optional_history"]["parent_cta_info"].present?
        calltoaction_info_list_to_adjust << calltoaction_info["optional_history"]["parent_cta_info"]
      end
    end

    adjust_counters(calltoaction_info_list_to_adjust, params)
    adjust_user_ctas(calltoaction_info_list)

    if params[:only_cover].blank?
      calltoaction_info_list.collect! do |calltoaction_info|
        calltoaction_info["calltoaction"]["interaction_info_list"].each do |interaction_info|
          if interaction_info["interaction"]["resource_type"] == "randomresource"
            cta = get_random_call_to_action(Interaction.find(interaction_info["interaction"]["id"]))
            calltoaction_info = build_cta_info_list_and_cache_with_max_updated_at([cta], nil, { only_cover: true }).first
          end
        end
        calltoaction_info
      end
    end

    calltoaction_info_list

  end

  def adjust_counters(calltoaction_info_list, params = {})
    interaction_ids = extract_interaction_ids_from_call_to_action_info_list(calltoaction_info_list)

    resource_ids = extract_resource_ids_from_call_to_action_info_list(calltoaction_info_list, "comment")
    if resource_ids.any?
      comments_limit = params[:comments_limit].present? ? params[:comments_limit].to_i : 5
      get_comments_query = "SELECT id FROM (select row_number() over (partition by comment_id ORDER BY updated_at DESC) as r, t.* FROM user_comment_interactions t WHERE approved = true AND comment_id IN (#{resource_ids.join(',')})) x WHERE x.r <= #{comments_limit};"
      comments = ActiveRecord::Base.connection.execute(get_comments_query)
      comment_ids = comments.map { |comment| comment["id"] }
      comments = UserCommentInteraction.includes(:user).where(id: comment_ids).references(:users).order("user_comment_interactions.updated_at DESC")
    end

    counters = ViewCounter.where("ref_type = 'interaction' AND ref_id IN (?)", interaction_ids)
    calltoaction_info_list.each do |calltoaction_info|
      calltoaction_info["calltoaction"]["interaction_info_list"].each do |interaction_info|
        interaction_id = interaction_info["interaction"]["id"]
        counter = find_interaction_in_counters(counters, interaction_id)
        interaction_info["interaction"]["resource"]["counter"] = counter ? counter.counter : 0
        if interaction_info["interaction"]["resource_type"] == "vote" || interaction_info["interaction"]["resource_type"] == "versus" 
          aux = counter ? counter.aux : {}
          interaction_info["interaction"]["resource"]["counter_aux"] = aux
        elsif interaction_info["interaction"]["resource_type"] == "comment"
          interaction_info["interaction"]["resource"]["comment_info"] = {
            "comments_total_count" => interaction_info["interaction"]["resource"]["counter"],
            "comments" => build_comments_by_resource_id(comments, interaction_info["interaction"]["resource"]["id"]) 
          } 
        end
      end
    end
  end
  
  def get_cta_media_data(cta)
    if cta.media_type == "FLOWPLAYER" && cta.media_data.blank? 
      cta.media_image.url
    else
      cta.media_data
    end
  end

  def build_interaction_info_list(calltoaction, interactions_to_compute)

    interaction_info_list = Array.new
    interactions = enable_interactions(calltoaction) 

    interactions.each do |interaction|

      resource_type = interaction.resource_type.downcase

      if !interactions_to_compute || interactions_to_compute.include?(resource_type)

        resource = interaction.resource
        resource_question = resource.question rescue nil
        resource_description = resource.description rescue nil
        resource_title = resource.title rescue nil
        resource_one_shot = resource.one_shot rescue false
        resource_providers = resource.providers rescue nil
        resource_url = resource.url rescue "/"
        resource_coordinates = resource.coordinates rescue nil

        if interaction.stored_for_anonymous
          anonymous_user_interaction = interaction.user_interactions.find_by_user_id(anonymous_user.id)
          if anonymous_user_interaction
            anonymous_user_interaction_info = build_user_interaction_for_interaction_info(anonymous_user_interaction)
          else
            anonymous_user_interaction_info = nil
          end
        else
          anonymous_user_interaction_info = nil
        end

        extra_fields = {}
        case resource_type
        when "quiz"
          resource_type = resource.quiz_type.downcase
          resource_answers = resource.answers
          answers = build_answers_for_resource(interaction, resource_answers, resource_type, nil)
        when "upload"
          upload_info = build_uploads_for_resource(interaction)
        when "vote"
          vote_info = build_votes_for_resource(interaction)
          # TODO: its actually a mistake to have extra fields in the interaction; the aux field should have been used instead
          extra_fields = get_extra_fields!(interaction.resource)
        when "download"
          ical = resource.ical_fields
          attachment = resource.attachment.url rescue nil
        end

        interaction_info_list << {
          "interaction" => {
            "id" => interaction.id,
            "when_show_interaction" => interaction.when_show_interaction,
            "interaction_positioning" => interaction.interaction_positioning,
            "overvideo_active" => false,
            "registration_needed" => (interaction.registration_needed || false),
            "seconds" => interaction.seconds,
            "resource_type" => resource_type,
            "resource" => {
              "id" => resource.id,
              "extra_fields" => extra_fields,
              "question" => resource_question,
              "title" => resource_title,
              "description" => resource_description,
              "one_shot" => resource_one_shot,
              "answers" => answers,
              "providers" => resource_providers,
              "counter" => 0,
              "upload_info" => upload_info,
              "ical" => ical,
              "vote_info" => vote_info,
              "url" => resource_url,
              "coordinates" => resource_coordinates,
              "attachment" => attachment
            }
          },
          "status" => get_current_interaction_reward_status(MAIN_REWARD_NAME, interaction, nil),
          "anonymous_user_interaction_info" => anonymous_user_interaction_info
        }
      end

    end

    interaction_info_list

  end

  def build_user_interaction_for_interaction_info(user_interaction)
    outcome = JSON.parse(user_interaction.outcome)["win"]["attributes"] rescue nil
    user_interaction_for_interaction_info = {
        "id" => user_interaction.id,
        "outcome" => outcome,
        "aux" => user_interaction.aux,
        "interaction_id" => user_interaction.interaction_id,
        "answer" => user_interaction.answer,
        "hash" => Digest::MD5.hexdigest("#{MD5_FANDOM_PREFIX}#{user_interaction.interaction_id}")
      }
  end

  def build_answers_for_resource(interaction, answers, resource_type, user_interaction)
    answers_for_resource = Array.new
    answers.each do |answer|
      #if resource_type == "versus" && user_interaction
      #  percentage = interaction_answer_percentage(interaction, answer) 
      #end
      answer_correct = user_interaction ? answer.correct : false
      answers_for_resource << {
        "id" => answer.id,
        "text" => answer.text,
        "aux" => answer.aux,
        "image_medium" => answer.image(:medium),
        "image" => answer.image(:original),
        "correct" => answer_correct
        #{}"percentage" => percentage
      }
    end
    answers_for_resource
  end

  def build_votes_for_resource(interaction)
    {
      min: interaction.resource.vote_min,
      max: interaction.resource.vote_max
    } 
  end

  def build_comments_for_resource(interaction)
    comments, comments_total_count = get_comments_approved(interaction)

    comments_for_resource = {
      "comments" => comments,     
      "comments_total_count" => comments_total_count,  
      "open" => false
    }
  end
  
  def build_uploads_for_resource(interaction)
    upload_interaction = interaction.resource
    uploads_for_resource = {
      "template_cta_id" => upload_interaction.call_to_action_id,
      "upload_number" => upload_interaction.upload_number,
      "privacy" => get_privacy_info(upload_interaction),
      "releasing" => get_releasing_info(upload_interaction),
      "title_needed" => upload_interaction.title_needed
    }
  end
  
  def get_privacy_info(upload)
    {
      "required" => upload.privacy?,
      "description" => upload.privacy_description
    }
  end
  
  def get_releasing_info(upload)
    {
      "required" => upload.releasing?,
      "description" => upload.releasing_description
    }
  end

  def generate_next_interaction_response(calltoaction, interactions_showed = nil, aux = {})
    response = Hash.new  
    interactions = calculate_next_interactions(calltoaction, interactions_showed)
    response[:next_interaction] = generate_response_for_interaction(interactions, calltoaction, aux)
    response
  end

  def page_require_captcha?(calltoaction_comment_interaction)
    return !current_user && calltoaction_comment_interaction
  end

  def always_shown_interactions(calltoaction)
    calltoaction.interactions.where("when_show_interaction = ? AND required_to_complete = ?", "SEMPRE_VISIBILE", true).order("seconds ASC").to_a
  end

  def enable_interactions(calltoaction)
    Interaction.where(call_to_action_id: calltoaction.id).where.not(when_show_interaction: "MAI_VISIBILE")
  end

  def get_cta_tags_from_cache(cta)
    cache_short(get_cta_tags_cache_key(cta.id)) do
      CallToActionTag.joins(:tag).where(:call_to_action_id => cta.id).pluck(:name)
    end
  end
  
  def interactions_required_to_complete(cta)
    cta.interactions.includes(:resource, :call_to_action).where("required_to_complete AND when_show_interaction <> 'MAI_VISIBILE'").order("seconds ASC").to_a
  end

  def generate_response_for_interaction(interactions, calltoaction, aux = {}, outcome = nil)
    next_quiz_interaction = interactions.first
    if next_quiz_interaction
      index_current_interaction = calculate_interaction_index(calltoaction, next_quiz_interaction)
      shown_interactions = always_shown_interactions(calltoaction)
      if shown_interactions.count > 1
        shown_interactions_count = shown_interactions.count 
        aux[:shown_interactions_count] = shown_interactions_count
      end
      aux[:next_interaction_present] = (interactions.count > 1)
      render_interaction_str = render_to_string "/call_to_action/_undervideo_interaction", 
        locals: { 
          interaction: next_quiz_interaction, 
          ctaid: next_quiz_interaction.call_to_action.id, 
          outcome: outcome, 
          shown_interactions_count: shown_interactions_count, 
          index_current_interaction: index_current_interaction, 
          aux: aux 
        }, layout: false, formats: :html
      interaction_id = next_quiz_interaction.id
    else
      render_interaction_str = render_to_string "/call_to_action/_end_for_interactions", 
      locals: { 
        quiz_interactions: interactions, 
        calltoaction: calltoaction, 
        aux: aux 
      }, layout: false, formats: :html
    end
    
    response = Hash.new
    response = {
      next_quiz_interaction: (interactions.count > 1),
      render_interaction_str: render_interaction_str,
      interaction_id: interaction_id
    }
  end
  
  def calculate_next_interactions(calltoaction, interactions_showed_ids)         
    if interactions_showed_ids
      interactions_showed_id_qmarks = (["?"] * interactions_showed_ids.count).join(", ")
      calltoaction.interactions.where("when_show_interaction = ? AND required_to_complete = ? 
        AND id NOT IN (#{interactions_showed_id_qmarks})", "SEMPRE_VISIBILE", true, *interactions_showed_ids).order("seconds ASC")
    else
      calltoaction.interactions.where("when_show_interaction = ? AND required_to_complete = ?", "SEMPRE_VISIBILE", true).order("seconds ASC")
    end
  end

  def calculate_interaction_index(calltoaction, interaction)
    cache_short("interaction_#{interaction.id}_index_in_calltoaction") do
      calltoaction.interactions.where("when_show_interaction = ? 
        AND required_to_complete = ? AND seconds <= ?", "SEMPRE_VISIBILE", true, interaction.seconds).order("seconds ASC").count
    end
  end

  def get_cta_template_option_list
    CallToAction.includes({:call_to_action_tags => :tag}).where("tags.name ILIKE 'template'").references(:call_to_action_tags).map{|cta| [cta.title, cta.id]}
  end
  
  def clone_and_create_cta(upload_interaction, params, watermark)
    calltoaction_template = upload_interaction.call_to_action
    cta_title = calculate_cloned_cta_title(upload_interaction, calltoaction_template, params)
    cta_description = calculate_cloned_cta_description(upload_interaction, calltoaction_template, params)
    user_calltoaction = duplicate_user_generated_cta(params, watermark, cta_title, cta_description, calltoaction_template)

    calltoaction_template.interactions.each do |i|
      duplicate_interaction(user_calltoaction, i)
    end

    calltoaction_template.call_to_action_tags.each do |tag|
      duplicate_cta_tag(user_calltoaction, tag)
    end

    user_calltoaction.release_required = upload_interaction.releasing? rescue false
    user_calltoaction.build_releasing_file(file: params["releasing"])

    user_calltoaction.privacy_required = upload_interaction.privacy? rescue false
    user_calltoaction.privacy = !params["privacy"].blank?

    # user_calltoaction.releasing_file_id = releasing.id

    user_calltoaction
  end
  
  def calculate_cloned_cta_title(upload_interaction, calltoaction_template, params)
    if (upload_interaction.title_needed rescue true) && params["title"].blank?
      nil
    elsif (upload_interaction.title_needed rescue true) && params["title"].present?
      params["title"]
    else
      calltoaction_template.title
    end
  end
  
  def calculate_cloned_cta_description(upload_interaction, calltoaction_template, params)
    if params["description"].blank?
      calltoaction_template.description
    else
      params["description"]
    end
  end
  
  def duplicate_user_generated_cta(params, watermark, cta_title, description, cta_template)
    unique_name = generate_unique_name()

    if params["upload"]
      if params["upload"].content_type.start_with?("video") || params["upload"].content_type.start_with?("audio")
        media_image = params["upload"]
        thumbnail = nil
        media_type = "FLOWPLAYER"
        media_data = nil
      else 
        media_image = params["upload"] # cta_template.media_image
        thumbnail = params["upload"] # cta_template.thumbnail
        media_type = "IMAGE"
        media_data = nil
      end
    elsif params["vcode"]
      media_image = thumbnail = open("http://img.youtube.com/vi/#{params["vcode"]}/0.jpg") rescue cta_template.thumbnail
      media_type = "YOUTUBE"
      media_data = params["vcode"]
    else
      media_image = cta_template.media_image
      thumbnail = cta_template.thumbnail
      media_type = cta_template.media_type
      media_data = cta_template.media_data
    end
    
    extra_fields = cta_template.extra_fields.nil? ? "{}" : cta_template.extra_fields 
    extra_fields.merge!(params.fetch('extra_fields', {}))

    user_calltoaction = CallToAction.new(
        title: cta_title,
        description: description,
        name: unique_name,
        slug: unique_name, 
        user_id: params["user_id"] || current_user.id,
        media_image: media_image,
        thumbnail: (params["upload"] && params["upload"].content_type =~ %r{^(image|(x-)?application)/(x-png|pjpeg|jpeg|jpg|png|gif)$}) ? params["upload"] : thumbnail,
        media_type: media_type,
        media_data: media_data,
        extra_fields: extra_fields
        )
    if watermark
      if watermark.exists?
        if watermark.url.start_with?("http")
          user_calltoaction.interaction_watermark_url = watermark.url(:normalized)
        else
          user_calltoaction.interaction_watermark_url = watermark.path(:normalized)
        end
      end
    end
    
    if $site.aws_transcoding
      if params["upload"] && params["upload"].content_type.start_with?("video")
        aux_fields = user_calltoaction.aux || {}
        aux_fields['aws_transcoding_media_status'] = "requested"
        user_calltoaction.aux = aux_fields.to_json
      end
    end
    
    user_calltoaction
  end
  
  def generate_unique_name
    duplicated = true
    i = 0
    # TODO: an exception should be raised if tries exceed 5
    while duplicated && i < 5 do      
      # TODO: there is a race condition in case 2 anonymous users upload something at the same millisecond
      name = Digest::MD5.hexdigest("#{current_or_anonymous_user.id}#{Time.now}")[0..8]
      if CallToAction.find_by_name(name).nil?
        duplicated = false
      end
      i += 1
    end
    "UGC_" + name
  end

  def generate_unique_name_for_interaction
    duplicated = true
    i = 0
    while duplicated && i < 5 do
      name = Digest::MD5.hexdigest("#{current_or_anonymous_user.id}#{Time.now}")[0..8]
      if Interaction.find_by_name(name).nil?
        duplicated = false
      end
      i += 1
    end
    "UGC_" + name
  end

  def clone_cta(old_cta_id)
    old_cta = CallToAction.find(old_cta_id)
    new_cta = duplicate_cta(old_cta_id)
    old_cta.interactions.each do |i|
      duplicate_interaction(new_cta, i)
    end
    old_cta.call_to_action_tags.each do |tag|
      duplicate_cta_tag(new_cta, tag)
    end
    @cta = new_cta
    tag_array = Array.new
    @cta.call_to_action_tags.each { |t| tag_array << t.tag.name }
    @tag_list = tag_array.join(",")
    render template: "/easyadmin/call_to_action/new_cta"
  end

  def clone_linking_cta(old_cta_id)
    @current_cta = CallToAction.find(old_cta_id)
    @current_cta_answer_linkings = call_to_action_answers_linked_cta(old_cta_id)
    if params[:commit] == "SALVA"
      ActiveRecord::Base.transaction do
        begin
          @cloned_cta_map = {
            @current_cta.name => { 
              "title" => params[:cloned_cta_title], 
              "name" => params[:cloned_cta_name],
              "slug" => params[:cloned_cta_slug], 
              "questions" => params[:cloned_cta_questions],
              "answers" => params[:cloned_cta_answers]
            } 
          }.merge(params[:cloned_cta])
          cloned_interactions_map = {}
          cloned_cta_map = {}
          @cloned_cta_map.each do |old_cta_name, new_params|
            old_cta = CallToAction.find_by_name(old_cta_name)
            new_cta = duplicate_cta(old_cta.id)
            old_cta.interactions.each do |i|
              if new_params["questions"]
                if i.resource_type == "Quiz" and new_params["questions"][i.resource_id.to_s]
                  custom_resource_attributes = { "Quiz" => { "question" => new_params["questions"][i.resource_id.to_s] } }
                  if new_params["answers"]
                    custom_resource_attributes.merge!({ "Answer" => { "answers" => new_params["answers"] } })
                  end
                end
              end
              new_interaction = duplicate_interaction(new_cta, i, custom_resource_attributes)
              cloned_interactions_map[i.id] = new_interaction
            end
            old_cta.call_to_action_tags.each do |tag|
              duplicate_cta_tag(new_cta, tag)
            end
            new_cta.title = new_params["title"]
            new_cta.name = new_params["name"]
            new_cta.slug = new_params["slug"]
            new_cta.save
            cloned_cta_map[old_cta.id] = new_cta.id
          end
          duplicate_interaction_call_to_actions(@cloned_cta_map, cloned_interactions_map)
          update_answer_call_to_action_ids(cloned_cta_map)
        rescue Exception => e
          flash[:error] = "Errore: #{e} - #{e.backtrace[0..2]}"
          raise ActiveRecord::Rollback
        end
        flash[:notice] = "CallToAction '#{@current_cta.name}' e collegate clonate con successo"
      end
    else
      @tree, cycles = CtaForest.add_next_cta({}, Node.new(old_cta_id), [], [old_cta_id])
      @linked_ctas = []
      if @tree.children.any?
        @tree.children.each do |child|
          build_linked_cta_attr_array(@linked_ctas, child)
        end
      end
    end
    render :template => "/easyadmin/call_to_action/clone_linked_cta"
  end

  def build_linked_cta_attr_array(linked_ctas, tree)
    cta = CallToAction.find(tree.value)
    cta_attributes = {}
    unless linked_ctas.any? { |h| h["name"] == cta.name }
      linked_ctas << cta_attributes(cta)
    end
    if tree.children.any?
      tree.children.each do |child|
        build_linked_cta_attr_array(linked_ctas, child)
      end
    end
    return
  end

  def cta_attributes(cta)
    cta_attributes = { "title" => cta.title, "name" => cta.name, "slug" => cta.slug }
    answer_links = call_to_action_answers_linked_cta(cta)
    if answer_links.any?
      cta_attributes.merge!({ "answer_linkings" => {} })
      answer_links.each do |answer_id_call_to_action_id|
        answer = Answer.find(answer_id_call_to_action_id.keys[0])
        cta_attributes["answer_linkings"][answer.quiz_id] = 
          (cta_attributes["answer_linkings"][answer.quiz_id] || []) << answer_id_call_to_action_id
      end
    end
    cta_attributes
  end

  def duplicate_cta(old_cta_id)
    cta = CallToAction.find(old_cta_id)
    cta.title = "Copy of " + cta.title
    cta.name = "copy-of-" + cta.name
    cta.slug = "copy-of-" + cta.slug
    cta.activated_at = DateTime.now
    cta_attributes = cta.attributes
    cta_attributes.delete("id")
    CallToAction.new(cta_attributes, :without_protection => true)
  end

  def update_answer_call_to_action_ids(cloned_cta_map)
    cloned_cta_map.values.each do |new_cta_id|
      quiz_interaction = CallToAction.find(new_cta_id).interactions.where(:resource_type => "Quiz").first
      if quiz_interaction
        Answer.where(:quiz_id => quiz_interaction.resource_id).each do |answer|
          answer.update_attribute :call_to_action_id, cloned_cta_map[answer.call_to_action_id] if answer.call_to_action_id
        end
      end
    end
  end

  def duplicate_interaction_call_to_actions(cloned_cta_map, cloned_interactions_map)
    cloned_cta_map.each do |old_cta_name, new_params|
      old_cta = CallToAction.find_by_name(old_cta_name)
      old_cta.interactions.each do |old_interaction|
        old_interaction_id = old_interaction.id
        InteractionCallToAction.where(:interaction_id => old_interaction_id).each do |old_icta|
          new_icta = InteractionCallToAction.new(
            :interaction_id => cloned_interactions_map[old_interaction_id].id, 
            :call_to_action_id => CallToAction.find_by_name(cloned_cta_map[CallToAction.find(old_icta.call_to_action_id).name]["name"]).id
            )
          new_icta.save
        end
      end
    end
  end

  def duplicate_interaction(new_cta, interaction, custom_resource_attributes = nil)
    interaction_attributes = interaction.attributes
    interaction_attributes.delete("id")
    interaction_attributes.delete("name")
    interaction_attributes.delete("rescource_type")
    interaction_attributes.delete("resource")
    new_interaction = new_cta.interactions.build(interaction_attributes, :without_protection => true)
    resource_attributes = interaction.resource.attributes
    resource_attributes.delete("id")
    resource_type = interaction.resource_type

    if resource_type == "Play"
      resource_attributes["title"] = "#{interaction.resource.attributes["title"][0..12]}T#{Time.now.strftime("%H%M")}"
    end

    if custom_resource_attributes
      custom_resource_attributes.each do |k, v|
        if k == resource_type
          v.each do |key, value|
            resource_attributes[key] = value
          end
        end
      end
    end
    
    resource_model = get_model_from_name(resource_type)
    new_interaction.resource = resource_model.new(resource_attributes, :without_protection => true)
    new_resource = new_interaction.resource 
    if resource_type == "Quiz"
      custom_answers = custom_resource_attributes ? custom_resource_attributes["Answer"] : nil
      duplicate_quiz_answers(new_resource, interaction.resource, custom_answers)
    end
    new_interaction
  end

  def duplicate_quiz_answers(new_quiz, old_quiz, custom_answers)
    old_quiz.answers.each do |a|
      answer_attributes = a.attributes
      answer_attributes.delete("id")
      if custom_answers
        answer_attributes["text"] = custom_answers["answers"][a.id.to_s]
      end
      new_quiz.answers.build(answer_attributes, :without_protection => true)
    end
  end

  def duplicate_cta_tag(new_cta, tag)
    unless tag.tag.name.downcase == "template"
      new_cta.call_to_action_tags.build(:tag_id => tag.tag_id)
    end
  end

  def get_max_upload_size
    MAX_UPLOAD_SIZE * BYTES_IN_MEGABYTE
  end

  def is_call_to_action_gallery(calltoaction)
    return has_tag_recursive(calltoaction.call_to_action_tags.map{|c| c.tag}, "gallery")
  end

  def has_tag_recursive(tags, tag_name)
    tags.each do |t|
      if t.name == tag_name
        return true
      end
      result = has_tag_recursive(t.tags_tags.map{ |parent_tag| parent_tag.other_tag}, tag_name)
      if result
        return result
      end
    end
    return false
  end

  def cta_is_a_reward(cta)
    cache_short("cta_#{cta.id}_is_a_reward") do
      cta.rewards.any?
    end
  end

  def cta_locked?(cta)
    cta_is_a_reward(cta) && !cta_is_unlocked(cta)
  end

  def cta_is_unlocked(cta)
    unlocked = false
    cta.rewards.each do |r|
      if user_has_reward(r.name)
        unlocked = true
        break
      end
    end
    unlocked
  end

  def has_done_share_interaction(calltoaction)
    share_interactions = get_share_from_calltoaction(calltoaction)
    if share_interactions.any?
      interaction = share_interactions.first
      if current_user
        [current_user.user_interactions.find_by_interaction_id(interaction.id), interaction]
      else
        [nil, interaction]
      end
    else
      [nil, nil]
    end
  end

  def get_share_from_calltoaction(calltoaction)
    cache_short("share_interaction_cta_#{calltoaction.id}") do
      calltoaction.interactions.where("when_show_interaction = 'SEMPRE_VISIBILE' AND resource_type = 'Share'").to_a
    end
  end

  def get_random_cta_by_tag(tag_name)
    get_ctas_with_tag(tag_name).sample
  end

  def get_number_of_interaction_type_for_cta(type, cta)
    #cache_short(get_comments_count_for_cta_key(cta.id)) do
      type_interaction = cta.interactions.find_by_resource_type(type)
      if type_interaction
        type_counter = ViewCounter.where(:ref_type => "interaction", :ref_id => type_interaction.id).first
        if type_counter.nil?
          0
        else
          type_counter.counter
        end
        #comment_interaction.resource.user_comment_interactions.where("approved = true").count
      else
        nil
      end
    #end
  end

  def get_votes_thumb_for_cta(cta) 
    cache_short(get_votes_count_for_cta_key(cta.id)) do
      interaction = cta.interactions.find_by_resource_type("Vote")
      if interaction
        build_votes_for_resource(interaction)
      else
        0
      end
    end
  end

  def get_linked_call_to_action_conditions
    conditions = { 
      "more" =>
        lambda { |symbolic_name_to_counter, condition_params| 
          max_key = max_key_in_symbolic_name_to_counter(symbolic_name_to_counter)
          return max_key == condition_params
        },
      "points_between" =>
        lambda { |points_to_counter, condition_params|
          sum = points_to_counter.map { |x,y| x.to_i * y.to_i }.inject(:+)
          lower_bound, upper_bound = condition_params.split(',').map { |x| x.strip.to_i } 
          return sum >= lower_bound && sum <= upper_bound 
        }
    }
  end

  # This helper returns the url of the video in the original file folder if the folder is set 
  # (that means that AWS transcoding has been activated) or else it returns the normal path
  def get_cta_media_url_or_original_url(cta, original_media_path)
    if original_media_path.nil? || cta.aux.nil? || cta.aux["aws_transcoding_media_status"] != "done"
      cta.media_image.url
    else
      "#{@original_media_path}#{cta.user_id}-#{cta.id}-media.mp4"
    end
  end

  def check_profanity_words_in_comment(user_comment)

    user_comment_text = user_comment.text.downcase

    @profanities_regexp = cache_short(get_profanity_words_cache_key()) do
      pattern_array = Array.new

      profanity_words = Setting.find_by_key("profanity.words")
      if profanity_words
        profanity_words.value.split(",").each do |exp|
          pattern_array.push(build_regexp(exp))
        end
      end

      Regexp.union(pattern_array)
    end

    if user_comment_text =~ @profanities_regexp
      user_comment.errors.add(:text, "contiene parole non ammesse")
      return user_comment
    end

    user_comment
  end

  # this the implementation of call_to_action#upload, shared with the related API
  def upload_helper
    upload_interaction = Interaction.find(params[:interaction_id]).resource
    extra_fields = JSON.parse(get_extra_fields!(upload_interaction.interaction.call_to_action)['form_extra_fields'])['fields'] rescue nil;
    calltoaction = CallToAction.find(params[:cta_id])

    params_obj = JSON.parse(params["obj"])
    params_obj["releasing"] = params["releasing"]
    params_obj["upload"] = params["attachment"]

    extra_fields_valid, extra_field_errors, cloned_cta_extra_fields = validate_upload_extra_fields(params_obj, extra_fields)

    if !extra_fields_valid
      response = { "errors" => extra_field_errors.join(", ") }
    else
      cloned_cta = create_user_calltoactions(upload_interaction, params_obj)
      if cloned_cta.errors.any?
        response = { "errors" => cloned_cta.errors.full_messages.join(", ") }
      else
        get_extra_fields!(cloned_cta).merge!(cloned_cta_extra_fields)
        cloned_cta.save
      end
    end

    respond_to do |format|
      format.json { render json: response.to_json }
    end     
  end
  
  def create_user_calltoactions(upload_interaction, params)
    cloned_cta = clone_and_create_cta(upload_interaction, params, upload_interaction.watermark)
    cloned_cta.build_user_upload_interaction(user_id: current_user.id, upload_id: upload_interaction.id)
    cloned_cta.save
    cloned_cta
  end
end
