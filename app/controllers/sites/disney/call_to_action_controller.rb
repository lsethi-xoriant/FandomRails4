
class Sites::Disney::CallToActionController < CallToActionController
  include DisneyHelper

  def get_context()
    get_disney_property()
  end

  def show

    calltoaction_id = params[:id]
    
    calltoaction = CallToAction.includes(:interactions).references(:interactions).active.find(calltoaction_id)

    if calltoaction
      log_call_to_action_viewed(calltoaction)

      @calltoaction_info_list = build_cta_info_list_and_cache_with_max_updated_at([calltoaction], nil)
      
      optional_history = @calltoaction_info_list.first["optional_history"]
      if optional_history
        step_index = optional_history["optional_index_count"]
        step_count = optional_history["optional_total_count"]
        parent_cta_id = optional_history["parent_cta_id"]
      end

      sidebar_tag = calltoaction.user_id.present? ? "sidebar-cta-gallery" : "sidebar-cta"

      @aux_other_params = { 
        calltoaction: calltoaction,
        linked_call_to_actions_index: step_index, # init in build_cta_info_list_and_cache_with_max_updated_at for recoursive ctas
        linked_call_to_actions_count: step_count,
        parent_cta_id: parent_cta_id,
        init_captcha: (current_user.nil? || current_user.anonymous_id.present?),
        sidebar_tag: sidebar_tag
      }

      set_seo_info_for_cta(calltoaction)

      descendent_calltoaction_id = params[:descendent_id]
      if(descendent_calltoaction_id)
        calltoaction_to_share = CallToAction.find(descendent_calltoaction_id)
        extra_fields = JSON.parse(calltoaction_to_share.extra_fields)

        @seo_info["title"] = strip_tags(extra_fields["linked_result_title"]) rescue ""
        @seo_info["meta_description"] = strip_tags(extra_fields["linked_result_description"]) rescue ""
        @seo_info["meta_image"] = strip_tags(extra_fields["linked_result_image"]["url"]) rescue ""
      end
      
    else

      redirect_to "/"

    end

  end

  def expire_user_interaction_cache_keys()
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
    tag_name = get_disney_property()
    params[:page_elements] = ["like", "comment", "share"]
    calltoaction_info_list, has_more = get_ctas_for_stream(tag_name, params, 6)
    response = {
      calltoaction_info_list: calltoaction_info_list,
      has_more: has_more
    }
    
    respond_to do |format|
      format.json { render json: response.to_json }
    end 
  end

  def ordering_ctas
    tag_name = get_disney_property()
    params[:page_elements] = ["like", "comment", "share"]

    if params["other_params"]
      params["other_params"] = JSON.parse(params["other_params"])
    end
    calltoaction_info_list, has_more = get_ctas_for_stream(tag_name, params, $site.init_ctas)
    response = {
      calltoaction_info_list: calltoaction_info_list,
      has_more: has_more
    }
    
    respond_to do |format|
      format.json { render json: response.to_json }
    end 
  end

end