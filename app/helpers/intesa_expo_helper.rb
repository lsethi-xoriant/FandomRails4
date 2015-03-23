module IntesaExpoHelper

  def get_intesa_expo_ctas_with_tag(tag_name)
    param_tag = get_tag_from_params(tag_name)
    language_tag = get_tag_from_params($context_root || "it")
    tagged_tags = get_tags_with_tags_in_and([param_tag.id, language_tag.id])
    get_content_preview_stripe(tagged_tags.first.name)
  end

  def get_intesa_expo_related_ctas(cta)
    tag_tagged_with_related = get_tag_with_tag_about_call_to_action(cta, "related").first      
    if tag_tagged_with_related
      relateds = get_content_preview_stripe(tag_tagged_with_related.name)
    else
      nil
    end
  end

  def get_menu_items()
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
          "browse_url" => (extra_fields['browse_url'] rescue '#'),
          "title" => item.title
        }
      end
    end

    result
  end

  def get_intesa_expo_ctas(with_tag = nil)
    language = get_tag_from_params($context_root || "it")
    ctas = CallToAction.active.includes(:call_to_action_tags, :interactions).where("call_to_action_tags.tag_id = ?", language.id)
    if with_tag
      ctas_with_param_tag = CallToAction.includes(:call_to_action_tags).where("call_to_action_tags.tag_id = ?", with_tag.id)
      ctas = ctas.where("call_to_actions.id" => ctas_with_param_tag.map { |cta| cta.id })
    end
    ctas
  end

  def get_intesa_expo_highlight_calltoactions()
    tag_highlight = Tag.find_by_name("highlight")
    if tag_highlight
      ctas = get_intesa_expo_ctas(tag_highlight)
      order_elements(tag_highlight, ctas)
    else
      []
    end
  end

  def default_intesa_expo_aux(other, calltoaction_info_list = nil)

    menu_items, assets = cache_medium("layout_info_#{$context_root}") do
      menu_items = get_menu_items()
      layout_assets_tag = Tag.find_by_name('assets')
      if layout_assets_tag.nil?
        extra_fields = {}
      else
        extra_fields = get_extra_fields!(layout_assets_tag)
      end
      [menu_items, extra_fields]
    end

    if other && other.has_key?(:calltoaction)
      cta = other[:calltoaction]
      relateds = get_intesa_expo_related_ctas(cta)
      if cta.extra_fields
        page_stripes = []
        JSON.parse(cta.extra_fields).each do |key, value|
          if(key.include?("_stripe") && value)
            page_stripes << get_intesa_expo_ctas_with_tag(key.sub("_stripe", "")) 
          end
        end
      end
    end

    if other && other.has_key?(:calltoaction_evidence_info)
      calltoaction_evidence_info = cache_short(get_evidence_calltoactions_cache_key($context_root)) do  
        ctas = get_intesa_expo_highlight_calltoactions()
        calltoaction_evidence_info = []
        ctas.each_with_index do |calltoaction, index|
          calltoaction_evidence_info << build_default_thumb_calltoaction(calltoaction, :medium)
        end

        calltoaction_evidence_info
      end
    end
    
    aux = {
      "tenant" => $site.id,
      "anonymous_interaction" => $site.anonymous_interaction,
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
      "page_stripes" => page_stripes,
      "context_root" => $context_root,
      "language" => $context_root || "it"
    }

    if other
      other.each do |key, value|
        aux[key] = value unless aux.has_key?(key.to_s)
      end
    end

    aux

  end
  
  def get_intesa_expo_event_ctas_in_period(tag_ids, start_date, end_date = nil)
    cache_short get_ctas_with_tags_cache_key(tag_ids, "#{start_date}_#{end_date}", "and") do
      tag_ids_subselect = tag_ids.map { |tag_id| "(select call_to_action_id from call_to_action_tags where tag_id = #{tag_id})" }.join(' INTERSECT ')
      if end_date.nil?
        CallToAction.active.includes(call_to_action_tags: :tag).where("id IN (#{tag_ids_subselect}) AND (call_to_actions.valid_from > ?)", start_date).order("call_to_actions.valid_from ASC").to_a
      else
        CallToAction.active.includes(call_to_action_tags: :tag).where("id IN (#{tag_ids_subselect}) AND (call_to_actions.valid_from BETWEEN ? and ?)", start_date, end_date).order("call_to_actions.valid_from ASC").to_a
      end
    end
  end
  
end