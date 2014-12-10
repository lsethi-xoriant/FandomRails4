
class Sites::Forte::CallToActionController < CallToActionController

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

  ############### COMMENTS ###############

  def get_comments_approved_except_ids(user_comments, except_ids)
    if except_ids
      comments_showed_id_qmarks = (["?"] * except_ids.count).join(", ")
      comments_to_show_approved = user_comments.approved.where("id NOT IN (#{comments_showed_id_qmarks})", *except_ids)
    else
      user_comments.approved
    end
  end

  def append_comments
    append_or_update_comments(params[:interaction_id]) do |interaction, response|
      
      comments_to_show_approved = get_comments_approved_except_ids(interaction.resource.user_comment_interactions, params[:comments_shown])
      comments_to_show = comments_to_show_approved.where("date_trunc('milliseconds', updated_at) <= ?", params[:last_comment_shown_date]).order("updated_at DESC").limit(10)
      
      response[:last_comment_shown_date] = comments_to_show.any? ? comments_to_show.last.updated_at.strftime("%Y-%m-%d %H:%M:%S.%6N") : nil
      response[:comments_to_append_counter] = comments_to_show.count
      
      comments_to_show
    end    
  end

  def append_or_update_comments(interaction_id, &query_block)
    interaction = Interaction.find(interaction_id)

    response = Hash.new
    render_calltoactions_str = String.new
    comment_to_append_ids = Array.new

    comments_to_show = query_block.call(interaction, response)

    comments_to_show.each do |user_comment|
      comment_to_append_ids << user_comment.id
      render_calltoactions_str = render_calltoactions_str + (render_to_string "/call_to_action/_comment", locals: { user_comment: user_comment, new_comment_class: true }, layout: false, formats: :html)
    end

    response[:comments_to_append_ids] = comment_to_append_ids
    response[:comments_to_append] = render_calltoactions_str

    respond_to do |format|
      format.json { render :json => response.to_json }
    end
  end

  def add_comment
    interaction = Interaction.find(params[:interaction_id])
    comment_resource = interaction.resource

    approved = comment_resource.must_be_approved ? nil : true
    user_text = params[:comment]
    
    response = Hash.new

    response[:ga] = Hash.new
    response[:ga][:category] = "UserCommentInteraction"
    response[:ga][:action] = "AddComment"

    if current_user
      user_comment = UserCommentInteraction.new(user_id: current_user.id, approved: approved, text: user_text, comment_id: comment_resource.id)
      unless check_profanity_words_in_comment(user_comment).errors.any?
        user_comment.save
      end
      if approved && user_comment.errors.blank?
        user_interaction, outcome = create_or_update_interaction(current_user, interaction, nil, nil)
        expire_cache_key(get_calltoaction_last_comments_cache_key(interaction.call_to_action_id))
      end
    elsif 
      response[:captcha_check] = params[:stored_captcha] == Digest::MD5.hexdigest(params[:user_filled_captcha])
      if response[:captcha_check]
        user_comment = UserCommentInteraction.new(user_id: current_or_anonymous_user.id, approved: approved, text: user_text, comment_id: comment_resource.id)
        unless check_profanity_words_in_comment(user_comment).errors.any?
          user_comment.save
        end
        if approved && user_comment.errors.blank?
          user_interaction, outcome = create_or_update_interaction(user_comment.user, interaction, nil, nil)
          expire_cache_key(get_calltoaction_last_comments_cache_key(interaction.call_to_action_id))
        end
      end
    end

    if user_comment && user_comment.errors.any?
      response[:errors] = user_comment.errors.full_messages.join(", ")
    end

    respond_to do |format|
      format.json { render :json => response.to_json }
    end

  end

  def new_comments_polling
    append_or_update_comments(params[:interaction_id]) do |interaction, response|

      comments_to_show_approved = get_comments_approved_except_ids(interaction.resource.user_comment_interactions, params[:comments_shown])

      if params[:first_comment_shown_date].present?
        comments_to_show = comments_to_show_approved.where("date_trunc('milliseconds', updated_at) >= ?", params[:first_comment_shown_date]).order("updated_at DESC")
      else
        comments_to_show = comments_to_show_approved.order("date_trunc('milliseconds', updated_at) DESC")
      end
      
      if comments_to_show.any?
        response[:comments_count] = interaction.resource.user_comment_interactions.approved.count
        response[:first_comment_shown_date] =  comments_to_show.first.updated_at.strftime("%Y-%m-%d %H:%M:%S.%6N")
      end
      comments_to_show
    end
  end

    def show
      calltoaction_id = params[:id].to_i
      calltoaction = CallToAction.includes(:interactions).active.find_by_id(calltoaction_id)

      if calltoaction

        calltoactions = CallToAction.includes(:interactions).active.where("call_to_actions.id <> ?", calltoaction_id).limit(2).to_a
        
        @calltoactions_with_current = [calltoaction] + calltoactions

        @calltoactions_during_video_interactions_second = init_calltoactions_during_video_interactions_second(@calltoactions_with_current)
        @calltoactions_comment_interaction = init_calltoactions_comment_interaction(@calltoactions_with_current)

        @calltoactions_active_interaction = Hash.new
        @aux = { 
          "show_calltoaction_page" => true,
          "tenant" => get_site_from_request(request)["id"],
          "anonymous_interaction" => get_site_from_request(request)["anonymous_interaction"],
          "main_reward_name" => MAIN_REWARD_NAME
        }

        @calltoactions_active_interaction[@calltoactions_with_current[0].id] = generate_next_interaction_response(@calltoactions_with_current[0], nil, @aux)

      else
        redirect_to "/"
      end    

    end
  
end