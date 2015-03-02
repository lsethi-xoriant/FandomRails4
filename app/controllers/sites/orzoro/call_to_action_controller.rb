class Sites::Orzoro::CallToActionController < CallToActionController

  def init_show_aux(calltoaction)
    @aux_other_params = { 
      calltoaction: calltoaction
    }
  end

  def append_calltoaction_page_elements
    ["empty"]
  end

  def next_calltoaction_in_category
    calltoaction_id = params[:calltoaction_id]
    category_id = params[:category_id]

    calltoaction = CallToAction.active.includes(:call_to_action_tags).where("call_to_action_tags.tag_id = ?", category_id)
    if params[:direction] == "next"
      calltoaction = calltoaction.where("call_to_actions.id > ?", calltoaction_id).last  
      unless calltoaction
        calltoaction = CallToAction.active.includes(:call_to_action_tags)
          .where("call_to_action_tags.tag_id = ?", category_id).last
      end                                                        
    else 
      calltoaction = calltoaction.where("call_to_actions.id < ?", calltoaction_id).first
      unless calltoaction
        calltoaction = CallToAction.active.includes(:call_to_action_tags)
          .where("call_to_action_tags.tag_id = ?", category_id).first
      end  
    end

    calltoaction_info_list = build_call_to_action_info_list([calltoaction])

   if calltoaction_info_list.first["miniformat"]["name"] == "ricette"
      related_product = get_tag_with_tag_about_call_to_action(calltoaction, "related-product").first
      if related_product
        related_product = {
          "title" => related_product.name,
          "description" => related_product.description,
          "image" => (get_extra_fields!(related_product)["image"]["url"] rescue nil),
          "browse_url" => (get_extra_fields!(related_product)['browse_url'] rescue '#')
        }
      end
    end

    response = { 
      "calltoaction" => calltoaction_info_list,
      "related_product" => related_product
    }

    respond_to do |format|
      format.json { render json: response.to_json }
    end                       

  end

end