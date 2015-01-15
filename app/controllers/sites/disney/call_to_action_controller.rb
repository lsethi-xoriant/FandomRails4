
class Sites::Disney::CallToActionController < CallToActionController
  include DisneyHelper

  def build_current_user() 
    build_disney_current_user()
  end

  def get_context()
    get_disney_property()
  end

  def init_show_aux()
    current_property = get_tag_from_params(get_disney_property())
    disney_default_aux(current_property, init_captcha: true);
  end

  def append_calltoaction
    calltoactions_showed_ids = params[:calltoactions_showed].map { |calltoaction_info| calltoaction_info["calltoaction"]["id"] }
    calltoactions_showed_id_qmarks = (["?"] * calltoactions_showed_ids.count).join(", ")

    context_tag = get_tag_from_params(get_context())

    calltoactions = cache_short(get_next_ctas_stream_cache_key(context_tag.id, calltoactions_showed_ids.last, get_cta_max_updated_at())) do
      get_disney_ctas(context_tag).where("call_to_actions.id NOT IN (#{calltoactions_showed_id_qmarks})", *calltoactions_showed_ids).limit(3).to_a
    end

    response = {
      calltoaction_info_list: build_call_to_action_info_list(calltoactions)
    }
    
    respond_to do |format|
      format.json { render json: response.to_json }
    end 
  end

end