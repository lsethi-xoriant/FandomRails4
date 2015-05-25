class Sites::Orzoro::CallToActionController < CallToActionController
  include OrzoroHelper

  # Overridden from the base controller
  def cta_url(cta)
    orzoro_cta_url(cta)
  end

  def init_show_aux(calltoaction)
    @aux_other_params = { 
      calltoaction: calltoaction
    }
  end

  def append_calltoaction_page_elements
    ["empty"]
  end

  def next_calltoaction_in_category
    calltoaction_id = params[:calltoaction_id].to_i
    category_id = params[:category_id].to_i

    calltoaction = CallToAction.order("call_to_actions.id ASC").active.includes(:call_to_action_tags).where("call_to_action_tags.tag_id = ?", category_id).references(:call_to_action_tags)
    if params[:direction] == "next"
      calltoaction = calltoaction.where("call_to_actions.id > ?", calltoaction_id).first  
      unless calltoaction
        calltoaction = CallToAction.order("call_to_actions.id ASC").active.includes(:call_to_action_tags)
          .where("call_to_action_tags.tag_id = ?", category_id).first
      end                                                        
    else 
      calltoaction = calltoaction.where("call_to_actions.id < ?", calltoaction_id).last
      unless calltoaction
        calltoaction = CallToAction.order("call_to_actions.id ASC").active.includes(:call_to_action_tags)
          .where("call_to_action_tags.tag_id = ?", category_id).last
      end  
    end

    calltoaction_info_list = build_cta_info_list_and_cache_with_max_updated_at([calltoaction])

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

    compute_seo("-")

    seo_info = {
      "title" => @seo_title,
      "meta_description" => @seo_description,
      "meta_image" => @seo_meta_image,
      "keywords" => @seo_keywords
    }

    response = { 
      "calltoaction" => calltoaction_info_list,
      "related_product" => related_product,
      "seo_info" => seo_info
    }

    respond_to do |format|
      format.json { render json: response.to_json }
    end                       

  end

end