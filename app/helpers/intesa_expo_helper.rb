module IntesaExpoHelper

  def default_intesa_expo_aux(other, calltoaction_info_list = nil)

    assets = cache_medium("layout_info") do
      layout_assets_tag = Tag.find_by_name('assets')
      if layout_assets_tag.nil?
        extra_fields = {}
      else
        extra_fields = get_extra_fields!(layout_assets_tag)
      end
      extra_fields
    end

    if other && other.has_key?(:calltoaction)
      calltoaction = other[:calltoaction]
      calltoaction_category = get_tag_with_tag_about_call_to_action(calltoaction, "category").first
      related_calltoaction_info = get_related_calltoaction_info(calltoaction, "category")
      if calltoaction_info_list.first["miniformat"]["name"] == "ricette"
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
    
    aux = {
      "tenant" => $site.id,
      "calltoaction_category" => calltoaction_category,
      "anonymous_interaction" => $site.anonymous_interaction,
      "main_reward_name" => MAIN_REWARD_NAME,
      "related_calltoaction_info" => related_calltoaction_info,
      "mobile" => small_mobile_device?(),
      "enable_comment_polling" => get_deploy_setting('comment_polling', true),
      "flash_notice" => flash[:notice],
      "free_provider_share" => $site.free_provider_share,
      "assets" => assets,
      "related_product" => related_product,
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