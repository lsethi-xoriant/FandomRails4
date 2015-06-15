module OrzoroHelper
  def orzoro_cta_url(cta)
    miniformat = get_tag_with_tag_about_call_to_action(cta, "miniformat").first
    prefix = miniformat.name
    "/#{prefix}/#{cta.slug}"
  end

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
          "name" => miniformat_item.name,
          "slug" => miniformat_item.slug,
          "browse_url" => (extra_fields['browse_url'] rescue '#'),
          "title" => miniformat_item.title,
          "icon" => (extra_fields["icon"]["url"] rescue nil)
        }
      end
    end

    miniformat_info_list
  end

  def build_orzoro_thumb_calltoaction(calltoaction, thumb_format = :thumb)   
    {
      "id" => calltoaction.id,
      "detail_url" => orzoro_cta_url(calltoaction),
      "status" => compute_call_to_action_completed_or_reward_status(get_main_reward_name(), calltoaction),
      "thumb_url" => calltoaction.thumbnail(thumb_format),
      "title" => calltoaction.title,
      "slug" => calltoaction.slug,
      "description" => calltoaction.description,
      "type" => "cta",
      "interactions" => calltoaction.interactions,
      "extra_fields" => calltoaction.extra_fields,
      "aux" => {
        "miniformat" => build_grafitag_for_calltoaction(calltoaction, "miniformat"),
        "flag" => build_grafitag_for_calltoaction(calltoaction, "flag")
      }
    }
  end

  def get_orzoro_related_calltoaction_info(current_calltoaction, related_tag_name = "miniformat")
    calltoactions = cache_short(get_ctas_except_me_cache_key(current_calltoaction.id)) do
      tag = get_tag_with_tag_about_call_to_action(current_calltoaction, related_tag_name).first
      if tag
        CallToAction.active.includes(:call_to_action_tags)
                    .where("call_to_actions.id <> ?", current_calltoaction.id)
                    .where("call_to_action_tags.tag_id = ?", tag.id)
                    .references(:call_to_action_tags)
                    .limit(8).to_a
      else
        CallToAction.active.where("call_to_actions.id <> ?", current_calltoaction.id).limit(8).to_a
      end
    end 
    related_calltoaction_info = []
    calltoactions.each do |calltoaction|
      related_calltoaction_info << build_orzoro_thumb_calltoaction(calltoaction)
    end
    related_calltoaction_info
  end

  def default_orzoro_aux(other, calltoaction_info_list = nil)

    miniformat_info_list, assets = cache_medium("layout_info") do
      miniformat_info_list = get_miniformat_info_list()
      layout_assets_tag = Tag.find_by_name('assets')
      if layout_assets_tag.nil?
        extra_fields = {}
      else
        extra_fields = get_extra_fields!(layout_assets_tag)
      end
      [miniformat_info_list, extra_fields]
    end

    if other && other.has_key?(:calltoaction)
      calltoaction = other[:calltoaction]
      calltoaction_category = get_tag_with_tag_about_call_to_action(calltoaction, "category").first
      related_calltoaction_info = get_orzoro_related_calltoaction_info(calltoaction, "category")
      if calltoaction_info_list.first["miniformat"]["name"] == "ricette"
        
        if @seo_info
          @seo_info["title"] = "Ricetta #{@seo_info["title"]} - Ricette"
        end

        related_product = get_tag_with_tag_about_call_to_action(calltoaction, "related-product").first
        if related_product
          related_product = {
            "title" => related_product.title,
            "name" => related_product.name,
            "description" => related_product.description,
            "image" => (get_extra_fields!(related_product)["image"]["url"] rescue nil),
            "browse_url" => (get_extra_fields!(related_product)['browse_url'] rescue '#')
          }
        end
      end
    end

    if other && other.has_key?(:calltoaction_evidence_info)
      calltoaction_evidence_info = cache_short(get_evidence_calltoactions_in_property_for_user_cache_key(current_or_anonymous_user.id, nil)) do  
        calltoactions = get_highlight_calltoactions()
          
        calltoaction_evidence_info = []
        calltoactions.each_with_index do |calltoaction, index|
          thumb_format = (index == 0 && !small_mobile_device?()) ? :medium : :thumb
          calltoaction_evidence_info << build_orzoro_thumb_calltoaction(calltoaction, thumb_format)
        end

        calltoaction_evidence_info
      end
    end
    
    aux = {
      "site" => $site,
      "tenant" => $site.id,
      "calltoaction_category" => calltoaction_category,
      "main_reward_name" => MAIN_REWARD_NAME,
      "calltoaction_evidence_info" => calltoaction_evidence_info,
      "related_calltoaction_info" => related_calltoaction_info,
      "mobile" => small_mobile_device?(),
      "enable_comment_polling" => get_deploy_setting('comment_polling', true),
      "flash_notice" => flash[:notice],
      "free_provider_share" => $site.free_provider_share,
      "miniformat_info_list" => miniformat_info_list,
      "assets" => assets,
      "related_product" => related_product,
      "root_url" => root_url
    }

    if other
      other.each do |key, value|
        aux[key] = value unless aux.has_key?(key.to_s)
      end
    end

    if other && other.has_key?(:seo_long_title)
      @seo_info = { "title" => (Setting.find_by_key("long_title").value rescue "") }
    end
    compute_seo("-")

    aux

  end

  def get_request_selection(cup_selected)
    selection = ""
    case cup_selected
    when nil
      selection = "Due tazze"
    when "miss_tressy"
      selection = "Tazza miss Tressy"
    when "dora"
      selection = "Tazza Dora"
    when "placemat"
      selection = "Tovaglietta"
    when "placemat_and_miss_tressy"
      selection = "Tovaglietta e tazza miss Tressy"
    when "placemat_and_dora"
      selection = "Tovaglietta e tazza Dora"
    when "placemats"
      selection = "Due tovagliette"
    when "placemats_and_two_cups"
      selection = "Due tovagliette e due tazze"
    end
    selection
  end
end