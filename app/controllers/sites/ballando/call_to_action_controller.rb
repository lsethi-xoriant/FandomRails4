
class Sites::Ballando::CallToActionController < CallToActionController

  def update_interaction
    interaction = Interaction.find(params[:interaction_id])

    response = Hash.new

    response[:calltoaction_id] = interaction.call_to_action_id;
    
    response[:ga] = Hash.new
    response[:ga][:category] = "UserInteraction"
    response[:ga][:action] = "CreateOrUpdate"

    if interaction.resource_type.downcase == "download" 
      response["download_interaction_attachment"] = interaction.resource.attachment.url
    end

    if interaction.resource_type.downcase == "quiz"
      
      answer = Answer.find(params[:params])
      user_interaction, outcome = create_or_update_interaction(current_or_anonymous_user, interaction, answer.id, nil)
      response["has_answer_media"] = answer.answer_with_media?
      response["answer"] = answer

      if answer.media_type == "IMAGE" && answer.media_image
        response["answer"]["media_image"] = answer.media_image
      end

      if interaction.resource.quiz_type.downcase == "trivia"
        response[:ga][:label] = "#{interaction.resource.quiz_type.downcase}-answer-#{answer.correct ? "right" : "wrong"}"
      else 
        response[:ga][:label] = interaction.resource.quiz_type.downcase
      end

      response["answers"] = build_answers_for_resource(interaction, interaction.resource.answers, interaction.resource.quiz_type.downcase, user_interaction)

    elsif interaction.resource_type.downcase == "like"

      # TODO: user_interaction calculated 2 times
      user_interaction = get_user_interaction_from_interaction(interaction, current_or_anonymous_user)
      like = user_interaction ? !user_interaction.like : true

      user_interaction, outcome = create_or_update_interaction(current_or_anonymous_user, interaction, nil, nil, { like: true }.to_json)

      response[:ga][:label] = "Like"

    elsif interaction.resource_type.downcase == "share"
      provider = params[:provider]
      result, exception = update_share_interaction(interaction, provider, params[:share_with_email_address], params[:facebook_message])
      if result
        aux = { "#{provider}" => 1 }
        user_interaction, outcome = create_or_update_interaction(current_or_anonymous_user, interaction, nil, nil, aux.to_json)
        response[:ga][:label] = interaction.resource_type.downcase
      end

      response[:share] = Hash.new
      response[:share][:result] = result
      response[:share][:exception] = exception.to_s
    
    elsif interaction.resource_type.downcase == "vote"
      vote = params[:params]
      aux = { "call_to_action_id" => interaction.call_to_action.id, "vote" => vote }
      user_interaction, outcome = create_or_update_interaction(current_or_anonymous_user, interaction, nil, nil, aux.to_json)
      response[:ga][:label] = interaction.resource_type.downcase

    else
      user_interaction, outcome = create_or_update_interaction(current_or_anonymous_user, interaction, nil, nil)
      response[:ga][:label] = interaction.resource_type.downcase
    end

    if user_interaction

      calltoaction = interaction.call_to_action
      
      response["user_interaction"] = build_user_interaction_for_interaction_info(user_interaction)

      response['outcome'] = outcome

      if call_to_action_completed?(calltoaction)
        response["call_to_action_completed"] = true
      else
        winnable_outcome, interaction_outcomes, sorted_interactions = predict_max_cta_outcome(calltoaction, user_interaction.user)
        response['winnable_reward_count'] = winnable_outcome["reward_name_to_counter"][MAIN_REWARD_NAME]
      end

      if interaction.when_show_interaction == "SEMPRE_VISIBILE"
        response["feedback"] = generate_response_for_interaction([interaction], calltoaction, params[:aux] || {}, outcome)[:render_interaction_str]
      else
        response["feedback"] = render_to_string "/call_to_action/_feedback", locals: { outcome: outcome }, layout: false, formats: :html 
      end

    end

    if anonymous_user?(current_or_anonymous_user)
      anonymous_user_main_reward_count = params["anonymous_user"][MAIN_REWARD_NAME] || 0
      response["main_reward_counter"] = {
        "general" => (anonymous_user_main_reward_count + outcome["reward_name_to_counter"][MAIN_REWARD_NAME])
      }
    else
      response["main_reward_counter"] = get_counter_about_user_reward(MAIN_REWARD_NAME, true)
      response = setup_update_interaction_response_info(response)
    end    
    
    response["interaction_status"] = get_current_interaction_reward_status(MAIN_REWARD_NAME, interaction)
    response["calltoaction_status"] = compute_current_call_to_action_reward_status(MAIN_REWARD_NAME, calltoaction);

    respond_to do |format|
      format.json { render :json => response.to_json }
    end
  end 

  def setup_update_interaction_response_info(response) 
    response["contest_points_counter"] = [SUPERFAN_CONTEST_POINTS_TO_WIN - (get_counter_about_user_reward(SUPERFAN_CONTEST_REWARD, false) || 0), 0].max
    response
  end

  def get_extra_info(gallery_tag)
    cache_short(get_gallery_extra_info_key()) do
      JSON.parse(Tag.find(gallery_tag.id).extra_fields)
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

  def check_profanity_words_in_comment(user_comment)

    user_comment_text = user_comment.text.downcase

    @profanities_regexp = cache_short(get_profanity_words_cache_key()) do
      pattern_array = Array.new

      profanity_words = Setting.find_by_key("profanity.words")
      if profanity_words
        profanity_words.value.split(",").each do |exp|
          pattern_array.push(build_regexp(exp))
        end
      end

      Regexp.union(pattern_array)
    end

    if user_comment_text =~ @profanities_regexp
      user_comment.errors.add(:text, "contiene parole non ammesse")
      return user_comment
    end

    user_comment
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

  def append_calltoaction
    
    calltoactions = Array.new
    render_calltoactions_str = String.new
    
    calltoactions_showed_ids = params[:calltoactions_showed].map { |calltoaction| calltoaction["id"] }
    calltoactions_showed_id_qmarks = (["?"] * calltoactions_showed_ids.count).join(", ")

    if params[:tag_id].present?
      stream_call_to_action_to_render = CallToAction.includes(:call_to_action_tags).where("call_to_action_tags.tag_id = ?", params[:tag_id]).references(:call_to_action_tags).active
      if params[:current_calltoaction].present?
        stream_call_to_action_to_render = stream_call_to_action_to_render.where("call_to_actions.id <> ?", params[:current_calltoaction])
      end
    else
      stream_call_to_action_to_render = CallToAction.active
      if params[:current_calltoaction].present?
        stream_call_to_action_to_render = stream_call_to_action_to_render.where("call_to_actions.id <> ?", params[:current_calltoaction])
      end
    end

    stream_call_to_action_to_render = stream_call_to_action_to_render.where("call_to_actions.id NOT IN (#{calltoactions_showed_id_qmarks})", *calltoactions_showed_ids).limit(3)
    calltoactions_comment_interaction = init_calltoactions_comment_interaction(stream_call_to_action_to_render)

    stream_call_to_action_to_render.each do |calltoaction|
      calltoactions << calltoaction
      render_calltoactions_str = render_calltoactions_str + (render_to_string "/call_to_action/_stream_single_calltoaction", locals: { calltoaction: calltoaction, calltoaction_comment_interaction: calltoactions_comment_interaction[calltoaction.id], active_calltoaction_id: nil, calltoaction_active_interaction: Hash.new, aux: nil }, layout: false, formats: :html)
    end

    calltoactions_during_video_interactions_second = Hash.new
    calltoactions.each do |calltoaction|
      interactions_overvideo_during = calltoaction.interactions.where("when_show_interaction = 'OVERVIDEO_DURING'")
      if(interactions_overvideo_during.any?)
        calltoactions_during_video_interactions_second[calltoaction.id] = Hash.new
        interactions_overvideo_during.each do |interaction|
          calltoactions_during_video_interactions_second[calltoaction.id][interaction.id] = interaction.seconds
        end
      end
    end

    response = Hash.new
    response = {
      calltoactions_during_video_interactions_second: calltoactions_during_video_interactions_second,
      calltoactions: calltoactions,
      html_to_append: render_calltoactions_str,
      calltoaction_info_list: build_cta_info_list_and_cache_with_max_updated_at(calltoactions)
    }
    
    respond_to do |format|
      format.json { render json: response.to_json }
    end
    
  end
    
  def show
      calltoaction_id = params[:id].to_i
      calltoaction = CallToAction.includes(:interactions).references(:interactions).active.find_by_id(calltoaction_id)

      if calltoaction

        calltoactions = CallToAction.includes(:interactions).references(:interactions).active.where("call_to_actions.id <> ?", calltoaction_id).limit(2).to_a
        
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