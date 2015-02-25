module OrzoroHelper

  def get_miniformat_info_list()
    miniformat_info_list = []

    miniformat_items = get_tags_with_tag("miniformat")

    if miniformat_items.any?
      miniformat_tag = get_tag_from_params("miniformat")
      miniformat_items = order_elements(miniformat_tag, miniformat_items)
      
      miniformat_items.each do |miniformat_item|
        extra_fields = get_extra_fields!(miniformat_item)
        miniformat_info_list << {
          "id" => miniformat_item.id,
          "slug" => miniformat_item.slug,
          "browse_url" => (extra_fields['browse_url'] rescue '#'),
          "title" => miniformat_item.title,
          "icon" => (extra_fields["icon"]["url"] rescue nil)
        }
      end
    end

    miniformat_info_list
  end

  def default_orzoro_aux(other)

    miniformat_info_list, assets = cache_medium("layout_info") do
      miniformat_info_list = get_miniformat_info_list()
      layout_assets_tag = Tag.find_by_name('assets')
      get_extra_fields!(layout_assets_tag)
      [miniformat_info_list, layout_assets_tag.extra_fields]
    end

    if other && other.has_key?(:calltoaction)
      calltoaction = other[:calltoaction]
      related_calltoaction_info = get_related_calltoaction_info(calltoaction, "miniformat")
      calltoaction_category = get_tag_with_tag_about_call_to_action(calltoaction, "category").first
    end

    if other && other.has_key?(:calltoaction_evidence_info)
      calltoaction_evidence_info = cache_short(get_evidence_calltoactions_in_property_for_user_cache_key(current_or_anonymous_user.id, nil)) do  
        calltoactions = get_highlight_calltoactions()
          
        calltoaction_evidence_info = []
        calltoactions.each do |calltoaction|
          calltoaction_evidence_info << build_default_thumb_calltoaction(calltoaction)
        end

        calltoaction_evidence_info
      end
    end
    
    aux = {
      "tenant" => $site.id,
      "calltoaction_category" => calltoaction_category,
      "anonymous_interaction" => $site.anonymous_interaction,
      "main_reward_name" => MAIN_REWARD_NAME,
      "calltoaction_evidence_info" => calltoaction_evidence_info,
      "related_calltoaction_info" => related_calltoaction_info,
      "mobile" => small_mobile_device?(),
      "enable_comment_polling" => get_deploy_setting('comment_polling', true),
      "flash_notice" => flash[:notice],
      "free_provider_share" => $site.free_provider_share,
      "miniformat_info_list" => miniformat_info_list,
      "assets" => assets,
      "root_url" => root_url
    }

    if other
      other.each do |key, value|
        aux[key] = value unless aux.has_key?(key.to_s)
      end
    end

    aux

  end
end