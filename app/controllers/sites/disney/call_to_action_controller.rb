
class Sites::Disney::CallToActionController < CallToActionController
  include DisneyHelper

  def build_current_user() 
    build_disney_current_user()
  end

  def get_context()
    get_disney_property()
  end

  def show

    calltoaction_id = params[:id]
    
    calltoaction = CallToAction.includes(interactions: :resource).active.find(calltoaction_id)

    if calltoaction
      log_call_to_action_viewed(calltoaction)

      @calltoaction_info_list = build_cta_info_list_and_cache_with_max_updated_at([calltoaction], nil)
      
      optional_history = @calltoaction_info_list.first["optional_history"]
      if optional_history
        step_index = optional_history["ctas"].length + 1
        step_count = optional_history["optional_total_count"]
      end

      @aux_other_params = { 
        calltoaction: calltoaction,
        linked_call_to_actions_index: step_index, # init in build_cta_info_list_and_cache_with_max_updated_at for recoursive ctas
        linked_call_to_actions_count: step_count,
        init_captcha: true,
        sidebar_tags: ["detail"]
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
    calltoaction_info_list, has_more = get_ctas_for_stream(tag_name, params, $site.init_ctas)
    response = {
      calltoaction_info_list: calltoaction_info_list,
      has_more: has_more
    }
    
    respond_to do |format|
      format.json { render json: response.to_json }
    end 
  end
  
  def upload
    upload_interaction = Interaction.find(params[:interaction_id]).resource
    extra_fields = JSON.parse(get_extra_fields!(upload_interaction.interaction.call_to_action)['form_extra_fields'])['fields'] rescue nil;
    calltoaction = CallToAction.find(params[:cta_id])
    
    params_obj = JSON.parse(params["obj"])
    params_obj["releasing"] = params["releasing"]
    params_obj["upload"] = params["attachment"]

    extra_fields_valid, extra_field_errors, cloned_cta_extra_fields = validate_upload_extra_fileds(params_obj, extra_fields)

    if !extra_fields_valid
      response = { "errors" => extra_field_errors.join(", ") }
    else
      cloned_cta = create_user_calltoactions(upload_interaction, params_obj)
      if cloned_cta.errors.any?
        response = { "errors" => cloned_cta.errors.full_messages.join(", ") }
      else
        get_extra_fields!(cloned_cta).merge!(cloned_cta_extra_fields)
        cloned_cta.save
      end
    end

    respond_to do |format|
      format.json { render json: response.to_json }
    end 
    
    #if is_call_to_action_gallery(calltoaction)
    #  redirect_to "/gallery/#{params[:cta_id]}"
    #else
    #  redirect_to "/call_to_action/#{params[:cta_id]}"
    #end
    
  end
  
  def validate_upload_extra_fileds(params, extra_fields)
    if extra_fields.nil?
      [true, [], {}]
    else
      errors = []
      cloned_cta_extra_fields = {}
      extra_fields.each do |ef|
        if ef['required'] && params["#{ef['name']}"].blank?
          if ef['type'] == "textfield"
            errors << "#{ef['label']} non puo' essere lasciato in bianco"
          elsif
            errors << "#{ef['label']} deve essere accettato"
          end
        else
          cloned_cta_extra_fields["#{ef['name']}"] = params["#{ef['name']}"]
        end
      end
      [errors.empty?, errors, cloned_cta_extra_fields]
    end
  end
  
  def create_user_calltoactions(upload_interaction, params)
    cloned_cta = clone_and_create_cta(upload_interaction, params, upload_interaction.watermark)
    cloned_cta.build_user_upload_interaction(user_id: current_user.id, upload_id: upload_interaction.id)
    cloned_cta.save
    cloned_cta
  end

end