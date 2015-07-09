class Sites::BraunIc::CallToActionController < CallToActionController
  
  def show
    calltoaction_id = params[:id]
    calltoaction = CallToAction.includes(:interactions).active.references(:interactions).find(calltoaction_id)
    log_call_to_action_viewed(calltoaction)

    @calltoaction_info_list = build_cta_info_list_and_cache_with_max_updated_at([calltoaction], nil)

    @aux_other_params = { 
      calltoaction: calltoaction,
      redirect: true
    }

    set_seo_info_for_cta(calltoaction)

    descendent_calltoaction_id = params[:descendent_id]
    if(descendent_calltoaction_id)
      calltoaction_to_share = CallToAction.find(descendent_calltoaction_id)
      extra_fields = calltoaction_to_share.extra_fields

      @seo_info = {
        "title" => strip_tags(extra_fields["linked_result_title"]),
        "meta_description" => strip_tags(extra_fields["linked_result_description"]),
        "meta_image" => strip_tags(extra_fields["linked_result_image"]["url"]),
        "keywords" => get_default_keywords()
      }
    end
  end

end