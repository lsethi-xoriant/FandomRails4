 class Api::V2::CommentController < Api::V2::BaseController   
  
  def add_comment
    interaction = Interaction.find(params[:interaction_id])
    comment_resource = interaction.resource

    approved = comment_resource.must_be_approved ? nil : true
    user_text = params[:user_text]

    profanity_filter_automatic_setting = Setting.find_by_key('profanity.filter.automatic')
    apply_profanity_filter_automatic = profanity_filter_automatic_setting.nil? ? false : (profanity_filter_automatic_setting.value == "t")

    if apply_profanity_filter_automatic && check_profanity_words_in_comment(user_text)
      aux = { "profanity" => true }.to_json
      approved = false
    else
      aux = "{}"
    end
    
    response = Hash.new

    response[:approved] = approved
    
    user = current_or_anonymous_user
    
    user_comment = UserCommentInteraction.create(user_id: user.id, approved: approved, text: user_text, comment_id: comment_resource.id, aux: aux)
    response[:comment] = build_comment_for_comment_info(user_comment, true)
    if approved && user_comment.errors.blank?
      adjust_counter!(interaction, 1)
      user_interaction, outcome = create_or_update_interaction(user, interaction, nil, nil)
    end

    if user_comment && user_comment.errors.any?
      response[:errors] = user_comment.errors.full_messages.join(", ")
    end

    respond_to do |format|
      format.json { render :json => response.to_json }
    end

  end    

end