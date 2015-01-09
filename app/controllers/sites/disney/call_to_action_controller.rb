
class Sites::Disney::CallToActionController < CallToActionController
  include DisneyHelper

  def append_calltoaction
    calltoactions_showed_ids = params[:calltoactions_showed].map { |calltoaction_info| calltoaction_info["calltoaction"]["id"] }
    calltoactions_showed_id_qmarks = (["?"] * calltoactions_showed_ids.count).join(", ")

    calltoactions_in_property = CallToAction.includes(:call_to_action_tags).active.where("call_to_action_tags.tag_id = ?", params[:tag_id])
    calltoactions = calltoactions_in_property.where("call_to_actions.id NOT IN (#{calltoactions_showed_id_qmarks})", *calltoactions_showed_ids).limit(3)

    response = {
      calltoaction_info_list: build_call_to_action_info_list(calltoactions)
    }
    
    respond_to do |format|
      format.json { render json: response.to_json }
    end 
  end

end