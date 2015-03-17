module IntesaExpoHelper

  def get_menu_items()
    result = []

    menu_items = get_tags_with_tag("menu-item")

    if menu_items.any?
      menu_item_tag = get_tag_from_params("menu-item")
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

  def default_intesa_expo_aux(other, calltoaction_info_list = nil)

    menu_items, assets = cache_medium("layout_info") do
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
      calltoaction = other[:calltoaction]
    end

    if other && other.has_key?(:calltoaction_evidence_info)
      calltoaction_evidence_info = cache_short(get_evidence_calltoactions_cache_key()) do  
        highlight_calltoactions = get_highlight_calltoactions()
        ctas = CallToAction.includes(:rewards, :interactions).active.where("rewards.id IS NULL")
        if highlight_calltoactions.any?
          ctas = ctas.where("call_to_actions.id NOT IN (?)", highlight_calltoactions.map { |calltoaction| calltoaction.id }).limit(3).to_a
        else
          ctas = ctas.active.limit(3).to_a
        end
        ctas = highlight_calltoactions + ctas
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
      "menu_items" => menu_items
    }

    if other
      other.each do |key, value|
        aux[key] = value unless aux.has_key?(key.to_s)
      end
    end

    aux

  end
end