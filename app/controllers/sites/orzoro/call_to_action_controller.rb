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

    response = { "calltoaction" => build_call_to_action_info_list([calltoaction]) }

    respond_to do |format|
      format.json { render json: response.to_json }
    end                       

  end

end