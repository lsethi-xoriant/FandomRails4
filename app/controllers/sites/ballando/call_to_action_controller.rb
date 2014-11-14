
class Sites::Ballando::CallToActionController < CallToActionController

  def setup_update_interaction_response_info(response) 
    response["contest_points_counter"] = [SUPERFAN_CONTEST_POINTS_TO_WIN - (get_counter_about_user_reward(SUPERFAN_CONTEST_REWARD, false) || 0), 0].max
    response
  end

  def get_extra_info(gallery_tag)
    cache_short(get_gallery_extra_info_key()) do
      extra = Hash.new
      TagField.where("tag_id = ?", gallery_tag.id).each do |tf|
        if tf.field_type == "STRINGA"
          extra[tf.name] = tf.value
        else
          extra[tf.name] = tf.upload
        end
      end
      extra
    end
  end
  
  def repopulate_form_info
    @gallery_tag = get_tag_with_tag_about_call_to_action(@calltoaction, "gallery").first
    @extra_info = get_extra_info(@gallery_tag)
  end
  
  def upload
    @upload_interaction = Interaction.find(params[:interaction_id])
    @extra_fields = JSON.parse(@upload_interaction.resource.aux)['extra_fields']
    @cloned_cta = create_user_calltoactions(@upload_interaction.resource)
    @calltoaction = @upload_interaction.call_to_action
    
    extra_fields = get_upload_extra_fields(params, @extra_fields)
    @extra_fields_error = get_extra_fields_errors(extra_fields, @extra_fields)
    
    if @cloned_cta.errors.any?
      repopulate_form_info
      render template: "/gallery/show"
    elsif @extra_fields_error.any?
      repopulate_form_info
      render template: "/gallery/show"
    else
      @cloned_cta.user_upload_interaction.update_attribute(:aux, extra_fields.to_json)
      flash[:notice] = "Caricamento completato con successo"
      redirect_to "/gallery/#{@calltoaction.id}"
    end

  end
  
  def get_upload_extra_fields(params, upload_extra_fields)
    extra_fields = Hash.new
    upload_extra_fields.each do |ef|
      if params["extra_fields_#{ef['name']}"].present?
        extra_fields["#{ef['name']}"] = params["extra_fields_#{ef['name']}"] 
      end
    end
    extra_fields
  end
  
  def get_extra_fields_errors(extra_fields, upload_extra_fields)
    errors = Array.new
    upload_extra_fields.each do |ef|
      if extra_fields["#{ef['name']}"].blank?
        if ef['type'] == "textfield"
          errors << "#{ef['label']} non puo' essere lasciato in bianco"
        elsif ef['type'] == "checkbox"
          errors << "#{ef['label']} deve essere accettato"
        end
      end
    end
    errors
  end

  def create_user_calltoactions(upload_interaction)  
    
      cloned_cta = clone_and_create_cta(upload_interaction, params, upload_interaction.watermark)
      cloned_cta.build_user_upload_interaction(user_id: current_user.id, upload_id: upload_interaction.id)
      cloned_cta.save
      cloned_cta

  end
  
end