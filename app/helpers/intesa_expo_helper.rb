module IntesaExpoHelper

  def has_cta_spotlight?(cta_info)
    cta_info && cta_info["calltoaction"]["extra_fields"] && cta_info["calltoaction"]["extra_fields"]["spotlight"]
  end

  def get_intesa_expo_ctas_with_tag(tag_name, params = {})

    language_tag = get_tag_from_params($context_root || "it")

    case tag_name
    when "$prev-event-live"
      tag_name = "prev-event-live"
      current_time = Time.now.strftime("%Y/%m/%d %H:%M:%S")
      params.merge({ 
        ical_end_datetime: current_time,
        order_string: "cast(\"ical_fields\"->'start_datetime'->>'value' AS timestamp) DESC" 
      })
    when "$next-event-live"
      tag_name = "next-event-live"
      current_time = Time.now.strftime("%Y/%m/%d %H:%M:%S")
      params.merge({ 
        ical_start_datetime: current_time,
        order_string: "cast(\"ical_fields\"->'start_datetime'->>'value' AS timestamp) ASC" 
      })
    when "event"
      current_time = Time.now.strftime("%Y/%m/%d %H:%M:%S")
      # exclude_cta_ids = CallToAction.active.where("cast(\"extra_fields\"->>'valid_from' AS timestamp) < ?", current_time).map { |cta| cta.id }
      params.merge({ 
        ical_start_datetime: current_time,
        order_string: "cast(\"ical_fields\"->'start_datetime'->>'value' AS timestamp) ASC" 
      })
    else
      # nothing to do
    end

    param_tag = get_tag_from_params(tag_name)
    tagged_tags = get_tags_with_tags_in_and([param_tag.id, language_tag.id])
    get_content_previews(tagged_tags.first.name, [], params)

  end

  def get_intesa_expo_related_ctas(cta)
    tag_tagged_with_related = get_tag_with_tag_about_call_to_action(cta, "related").first   
    if tag_tagged_with_related
      get_content_previews_excluding_ctas(tag_tagged_with_related.name, [], [cta.id], 8)
    else
      nil
    end

    # params = { conditions: { exclude_cta_ids: [cta.id] }, related: true }   
    # if tag_tagged_with_related
    #   relateds = get_content_previews(tag_tagged_with_related.name, [], params)
    # else
    #   nil
    # end

  end

  def get_intesa_menu_items()
    result = []

    menu_item_tag = get_tag_from_params("menu-item")
    language_tag = get_tag_from_params($context_root || "it")
    menu_items = get_tags_with_tags_in_and([menu_item_tag.id, language_tag.id])

    if menu_items.any?
      
      menu_items = order_elements(menu_item_tag, menu_items)
      
      menu_items.each do |item|
        extra_fields = get_extra_fields!(item)
        result << {
          "id" => item.id,
          "name" => item.name,
          "slug" => item.slug,
          "title" => item.title,
          "extra_fields" => extra_fields
        }
      end
    end

    result
  end

  def get_intesa_expo_ctas(with_tag = nil)
    language = get_tag_from_params($context_root || "it")
    ctas = CallToAction.active.includes(:call_to_action_tags, :interactions).references(:call_to_action_tags, :interactions)
                              .where("call_to_action_tags.tag_id = ?", language.id)
                              .where("call_to_actions.valid_from < ? OR call_to_actions.valid_from IS NULL", Time.now.utc)
    if with_tag
      ctas_with_param_tag = CallToAction.includes(:call_to_action_tags).where("call_to_action_tags.tag_id = ?", with_tag.id).references(:call_to_action_tags)
      ctas = ctas.where("call_to_actions.id" => ctas_with_param_tag.map { |cta| cta.id })
    end
    ctas
  end

  def get_intesa_expo_highlight_calltoactions()
    tag_highlight = get_tag_from_params("highlight-#{get_intesa_property()}")
    if tag_highlight
      ctas = get_intesa_expo_ctas(tag_highlight)
      order_elements(tag_highlight, ctas)
    else
      []
    end
  end

  def default_intesa_expo_aux(other, calltoaction_info_list = nil)

    menu_items, assets = cache_medium("layout_info_#{$context_root}") do
      menu_items = get_intesa_menu_items()
      layout_assets_tag = get_tag_from_params('assets')
      if layout_assets_tag.nil?
        extra_fields = {}
      else
        extra_fields = get_extra_fields!(layout_assets_tag)
      end
      [menu_items, extra_fields]
    end

    if other && other.has_key?(:calltoaction)
      cta = other[:calltoaction]
      
      live = get_tag_from_params("live")
      is_live_cta = cta.call_to_action_tags.where("tag_id = ?", live.id).any?

      relateds = get_intesa_expo_related_ctas(cta)
      
      if !is_live_cta && relateds
        relateds_tag_keys = []
        relateds.contents.each do |related|
          if related.tags
            relateds_tag_keys =  relateds_tag_keys + related.tags.keys
          end
        end
        has_related_live = relateds_tag_keys.include?(live.id)
      end

      if cta.extra_fields
        page_stripes = []
        stripe_field = cta.extra_fields["stripe"]
        if stripe_field
          stripe_field.split(",").each do |tag|
            page_stripes << get_intesa_expo_ctas_with_tag(tag)
          end
        end
      end

    end

    if other && other.has_key?(:calltoaction_evidence_info)
      calltoaction_evidence_info = cache_short(get_evidence_calltoactions_cache_key($context_root)) do  
        
        ctas_evidence_count = 5
        highlight_calltoactions = get_intesa_expo_highlight_calltoactions()
        ctas = get_intesa_expo_ctas()
        
        if $context_root == "imprese"
          ignore_cta_tags = CallToActionTag.includes(:tag).where("tags.name IN (?)", ["story-imprese", "interview-imprese"]).references(:tags)
          ctas = ctas.where("call_to_actions.id IN (?)", ignore_cta_tags.map { |tag| tag.call_to_action_id })
        else
          ctas = ctas.where("(call_to_actions.extra_fields->>'layout') IS NULL OR (call_to_actions.extra_fields->>'layout') <> 'press'")
        end

        result_ctas = highlight_calltoactions[0..8]

        if highlight_calltoactions.count < ctas_evidence_count
          if highlight_calltoactions.any?
            ctas_evidence_count = ctas_evidence_count - highlight_calltoactions.count
            ctas = ctas.where("call_to_actions.id NOT IN (?)", highlight_calltoactions.map { |calltoaction| calltoaction.id })
          end
          result_ctas = result_ctas + ctas.limit(ctas_evidence_count).to_a
        end

        interactions = get_cta_to_interactions_map(result_ctas.map { |cta| cta.id })

        calltoaction_evidence_info = []
        result_ctas.each do |calltoaction|
          calltoaction_evidence_info << cta_to_content_preview(calltoaction, true, interactions[calltoaction.id])
        end

        calltoaction_evidence_info
      end
    end

    current_property = get_property()
    if current_property && current_property.name != $site.default_property
      property_path_name = current_property.name
    else
      property_path_name = nil;
    end
    
    aux = {
      "site" => $site,
      "tenant" => $site.id,
      "calltoaction_evidence_info" => calltoaction_evidence_info,
      "main_reward_name" => MAIN_REWARD_NAME,
      "mobile" => small_mobile_device?(),
      "enable_comment_polling" => get_deploy_setting('comment_polling', true),
      "flash_notice" => flash[:notice],
      "free_provider_share" => $site.free_provider_share,
      "assets" => assets,
      "root_url" => root_url,
      "menu_items" => menu_items,
      "relateds" => relateds,
      "is_live_cta" => is_live_cta,
      "has_related_live" => has_related_live,
      "page_stripes" => page_stripes,
      "context_root" => $context_root,
      "language" => get_intesa_property(),
      "property_path_name" => property_path_name,
      "current_property_info" => { "path" => get_intesa_property() }
    }

    if other
      other.each do |key, value|
        aux[key] = value unless aux.has_key?(key.to_s)
      end
    end

    compute_seo()

    aux

  end

  
  def get_intesa_property()
    $context_root || "it"
  end
  
end