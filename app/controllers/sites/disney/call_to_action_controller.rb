
class Sites::Disney::CallToActionController < CallToActionController
  include DisneyHelper

  def build_current_user() 
    build_disney_current_user()
  end

  def get_context()
    get_disney_property()
  end

  def init_show_aux(calltoaction)
    { 
      init_captcha: true,
      calltoaction: calltoaction,
      sidebar_tags: ["detail"]
    }
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
    response = {
      calltoaction_info_list: get_disney_ctas_for_stream(params, 6)
    }
    
    respond_to do |format|
      format.json { render json: response.to_json }
    end 
  end

  def ordering_ctas
    response = {
      calltoaction_info_list: get_disney_ctas_for_stream(params, $site.init_ctas)
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