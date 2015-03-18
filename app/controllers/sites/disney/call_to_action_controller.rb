
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

  def append_calltoaction_page_elements
    ["like", "comment", "share"]
  end

  def append_calltoaction
    page_elements = append_calltoaction_page_elements()

    if params["other_params"] && params["other_params"]["gallery"]["calltoaction_id"]
      gallery_calltoaction_id = params["other_params"]["gallery"]["calltoaction_id"]
      page_elements = page_elements + ["vote"]
    end

    calltoaction_ids_shown = params[:calltoaction_ids_shown]
    calltoaction_ids_shown_qmarks = (["?"] * calltoaction_ids_shown.count).join(", ")

    property = get_tag_from_params(get_disney_property())

    ordering = params[:ordering]

    calltoactions = cache_short(get_next_ctas_stream_cache_key(property.id, calltoaction_ids_shown.last, get_cta_max_updated_at(), ordering, gallery_calltoaction_id)) do     
      
      calltoactions = get_disney_ctas(property, gallery_calltoaction_id).where("call_to_actions.id NOT IN (#{calltoaction_ids_shown_qmarks})", *calltoaction_ids_shown)

      case ordering
      when "comment"
        calltoaction_ids = from_ctas_to_cta_ids_sql(calltoactions)
        gets_ctas_ordered_by_comments(calltoaction_ids, 4)
      when "view"
        calltoaction_ids = from_ctas_to_cta_ids_sql(calltoactions)
        gets_ctas_ordered_by_views(calltoaction_ids, 4)
      else
        calltoactions = calltoactions.limit(4).to_a
      end
      calltoactions
    end

    response = {
      calltoaction_info_list: build_call_to_action_info_list(calltoactions, page_elements)
    }.to_json
    
    respond_to do |format|
      format.json { render json: response }
    end 
  end

  def ordering_ctas
    if params["other_params"] && (other_params = JSON.parse(params["other_params"])["gallery"]["calltoaction_id"])
      gallery_calltoaction_id = other_params
    end

    property = get_tag_from_params(get_disney_property())
    init_ctas = $site.init_ctas

    calltoactions = []
    ordering = params["ordering"]

    case ordering
    when "comment"
      calltoactions = cache_short(get_calltoactions_in_property_by_ordering_cache_key(property.id, ordering, gallery_calltoaction_id)) do
        calltoaction_ids = from_ctas_to_cta_ids_sql(get_disney_ctas(property, gallery_calltoaction_id))
        calltoactions = gets_ctas_ordered_by_comments(calltoaction_ids, init_ctas)
      end
    when "view"
      calltoactions = cache_short(get_calltoactions_in_property_by_ordering_cache_key(property.id, ordering, gallery_calltoaction_id)) do
        calltoaction_ids = from_ctas_to_cta_ids_sql(get_disney_ctas(property, gallery_calltoaction_id))
        gets_ctas_ordered_by_views(calltoaction_ids, init_ctas)
      end
    else
      calltoactions = cache_medium(get_calltoactions_in_property_cache_key(property.id, gallery_calltoaction_id, get_cta_max_updated_at())) do
        get_disney_ctas(property, gallery_calltoaction_id).limit(init_ctas).to_a
      end
    end

    response = {
      calltoaction_info_list: build_call_to_action_info_list(calltoactions, ["like", "comment", "share"])
    }
    
    respond_to do |format|
      format.json { render json: response.to_json }
    end 
  end

  def from_ctas_to_cta_ids_sql(calltoactions)
    calltoactions.joins("LEFT OUTER JOIN call_to_action_tags ON call_to_action_tags.call_to_action_id = call_to_actions.id")
                 .joins("LEFT OUTER JOIN rewards ON rewards.call_to_action_id = call_to_actions.id")
                 .select("call_to_actions.id").to_sql
  end
  
  def upload
    upload_interaction = Interaction.find(params[:interaction_id]).resource
    extra_fields = JSON.parse(get_extra_fields!(upload_interaction.interaction.call_to_action)['form_extra_fields'])['fields'] rescue nil;
    cloned_cta = create_user_calltoactions(upload_interaction)
    calltoaction = CallToAction.find(params[:cta_id])
    
    extra_fields_valid, extra_field_errors, cloned_cta_extra_fields = validate_upload_extra_fileds(params, extra_fields)
    if cloned_cta.errors.any?
      if !extra_fields_valid
        flash[:error] = (cloned_cta.errors.full_messages + extra_field_errors).join(", ")
      else
        flash[:error] = cloned_cta.errors.full_messages.join(", ")
      end
    elsif !extra_fields_valid
      flash[:error] = extra_field_errors.join(", ")
    else
      get_extra_fields!(cloned_cta).merge!(cloned_cta_extra_fields)
      cloned_cta.save
      flash[:notice] = "Caricamento completato con successo"
    end

    if is_call_to_action_gallery(calltoaction)
      redirect_to "/gallery/#{params[:cta_id]}"
    else
      redirect_to "/call_to_action/#{params[:cta_id]}"
    end
    
  end
  
  def validate_upload_extra_fileds(params, extra_fields)
    if extra_fields.nil?
      [true, [], {}]
    else
      errors = []
      cloned_cta_extra_fields = {}
      extra_fields.each do |ef|
        if ef['required'] && params["extra_fields_#{ef['name']}"].blank?
          if ef['type'] == "textfield"
            errors << "#{ef['label']} non puo' essere lasciato in bianco"
          elsif
            errors << "#{ef['label']} deve essere accettato"
          end
        else
          cloned_cta_extra_fields["#{ef['name']}"] = params["extra_fields_#{ef['name']}"]
        end
      end
      [errors.empty?, errors, cloned_cta_extra_fields]
    end
  end
  
  def create_user_calltoactions(upload_interaction)
    cloned_cta = clone_and_create_cta(upload_interaction, params, upload_interaction.watermark)
    cloned_cta.build_user_upload_interaction(user_id: current_user.id, upload_id: upload_interaction.id)
    cloned_cta.save
    cloned_cta
  end

end