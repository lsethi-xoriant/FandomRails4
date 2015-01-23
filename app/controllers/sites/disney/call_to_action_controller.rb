
class Sites::Disney::CallToActionController < CallToActionController
  include DisneyHelper

  def build_current_user() 
    build_disney_current_user()
  end

  def get_context()
    get_disney_property()
  end

  def init_show_aux(calltoaction)
    @aux_other_params = { 
      init_captcha: true,
      calltoaction: calltoaction
    }
  end

  def expire_user_interaction_cache_keys()
    if current_user
      current_property = get_tag_from_params(get_disney_property())
      expire_cache_key(get_evidence_calltoactions_in_property_for_user_cache_key(current_user.id, current_property.id))
    end
  end

  def send_share_interaction_email(address, calltoaction)
    property = get_tag_from_params(get_disney_property())
    aux = {
      color: get_extra_fields!(property)["label-background"],
      logo: (get_extra_fields!(property)["logo"]["url"] rescue nil),
      path: compute_property_path(property),
      root: root_url,
      subject: property.title
    }
    SystemMailer.share_interaction(current_user, address, calltoaction, aux).deliver
  end

  def append_calltoaction
    calltoaction_ids_shown = params[:calltoaction_ids_shown]
    calltoaction_ids_shown_qmarks = (["?"] * calltoaction_ids_shown.count).join(", ")

    context_tag = get_tag_from_params(get_context())

    calltoactions = cache_short(get_next_ctas_stream_cache_key(context_tag.id, calltoaction_ids_shown.last, get_cta_max_updated_at())) do
      get_disney_ctas(context_tag).where("call_to_actions.id NOT IN (#{calltoaction_ids_shown_qmarks})", *calltoaction_ids_shown).limit(3).to_a
    end

    response = {
      calltoaction_info_list: build_call_to_action_info_list(calltoactions, ["like", "comment", "share"])
    }
    
    respond_to do |format|
      format.json { render json: response.to_json }
    end 
  end

end