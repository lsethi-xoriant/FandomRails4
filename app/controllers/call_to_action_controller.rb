#!/bin/env ruby
# encoding: utf-8

class CallToActionController < ApplicationController
  
  include ActionView::Helpers::SanitizeHelper
  include RewardingSystemHelper
  include CallToActionHelper
  include ApplicationHelper
  include CaptchaHelper

  def append_calltoaction
    render_calltoactions_str = String.new
    calltoactions = Array.new

    if params[:tag_id].present?
      stream_call_to_action_to_render = CallToAction.active.where("call_to_action_tags.tag_id=?", params[:tag_id]).offset(params[:offset]).limit(3)
    else
      stream_call_to_action_to_render = CallToAction.active.offset(params[:offset]).limit(3)
    end
    
    stream_call_to_action_to_render.each do |calltoaction|
      calltoactions << calltoaction
      render_calltoactions_str = render_calltoactions_str + (render_to_string "/call_to_action/_stream_single_calltoaction", locals: { calltoaction: calltoaction }, layout: false, formats: :html)
    end

    calltoactions_during_video_interactions_second = Hash.new
    calltoactions.each do |calltoaction|
      interactions_overvideo_during = calltoaction.interactions.find_all_by_when_show_interaction("OVERVIDEO_DURING")
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
      html_to_append: render_calltoactions_str
    }
    
    respond_to do |format|
      format.json { render json: response.to_json }
    end
    
  end

  def next_interaction
    calltoaction = CallToAction.find(params[:calltoaction_id])
    quiz_interactions = calculate_next_interactions(calltoaction, params[:interactions_showed])

    next_quiz_interaction = quiz_interactions.first

    if next_quiz_interaction
      render_interaction_str = render_to_string "/call_to_action/_undervideo_interaction", locals: { interaction: next_quiz_interaction, ctaid: next_quiz_interaction.call_to_action.id, outcome: nil }, layout: false, formats: :html
      interaction_id = next_quiz_interaction.id
    else
      render_interaction_str = render_to_string "/call_to_action/_end_for_interactions", locals: { quiz_interactions: quiz_interactions, calltoaction: calltoaction }, layout: false, formats: :html
    end

    response = Hash.new
    response = {
      next_quiz_interaction: (quiz_interactions.count > 1),
      render_interaction_str: render_interaction_str,
      interaction_id: interaction_id
    }
    
    respond_to do |format|
      format.json { render json: response.to_json }
    end
  end

  def check_next_interaction
    calltoaction = CallToAction.find(params[:calltoaction_id])
    quiz_interactions = calculate_next_interactions(calltoaction, params[:interactions_showed])

    response = Hash.new
    response = {
      next_quiz_interaction: quiz_interactions.any?
    }
    
    respond_to do |format|
      format.json { render json: response.to_json }
    end
  end

  def calculate_next_interactions(calltoaction, interactions_showed_ids)
                                         
    if interactions_showed_ids
      interactions_showed_id_qmarks = (["?"] * interactions_showed_ids.count).join(", ")
      quiz_interactions = calltoaction.interactions.where("when_show_interaction = ? AND resource_type = ? AND id NOT IN (#{interactions_showed_id_qmarks})", "SEMPRE_VISIBILE", "Quiz", *interactions_showed_ids)
                                                   .order("seconds ASC")
    else
      quiz_interactions = calltoaction.interactions.where("when_show_interaction = ? AND resource_type = ?", "SEMPRE_VISIBILE", "Quiz")
                                                   .order("seconds ASC")
    end
  end

  def show
    @calltoaction = CallToAction.find(params[:id])
    @calltoactions_during_video_interactions_second = initCallToActionsDuringVideoInteractionsSecond([@calltoaction])

    @calltoaction_comment_interaction = find_interaction_for_calltoaction_by_resource_type(@calltoaction, "Comment")
    @calltoaction_like_interaction = find_interaction_for_calltoaction_by_resource_type(@calltoaction, "Comment")

    @calltoactions_correlated = get_correlated_cta(@calltoaction)

    if page_require_captcha?(@calltoaction_comment_interaction)
      @captcha_data = generate_captcha_response
    end

=begin
    if @calltoaction.enable_disqus
      @disqus_requesturl = request.url
      comment_disqus = JSON.parse(open("https://disqus.com/api/3.0/posts/list.json?api_key=#{ ENV['DISQUS_PUBLIC_KEY'] }&forum=#{ ENV['DISQUS_SHORTNAME'] }&thread:link=#{ @disqus_requesturl }&limit=2").read)
      @disqus_cursor = comment_disqus["cursor"]
      comment_disqus = comment_disqus["response"]

      @disqus_hash = Hash.new
      comment_disqus.each do |comm|
        @disqus_hash[comm["id"]] = { text: comm["message"].html_safe, name: comm["author"]["name"], image: comm["author"]["avatar"]["small"]["permalink"],
                                                 created_at: comm["createdAt"] }
      end
    end
=end
  end

  def page_require_captcha?(calltoaction_comment_interaction)
    return !current_user && calltoaction_comment_interaction
  end
  
  def get_correlated_cta(calltoaction)
    tags_with_miniformat_in_calltoaction = get_tag_with_tag_about_call_to_action(calltoaction, "miniformat")
    if tags_with_miniformat_in_calltoaction.any?
      tag_id = tags_with_miniformat_in_calltoaction.first.id
      calltoactions = CallToAction.active.where("call_to_action_tags.tag_id=? and call_to_actions.id <> ?", tag_id, calltoaction.id).limit(3)
    else
       calltoactions = Array.new
    end
  end

  def next_disqus_page
    comment_disqus = JSON.parse(open("https://disqus.com/api/3.0/posts/list.json?api_key=#{ ENV['DISQUS_PUBLIC_KEY'] }&forum=#{ ENV['DISQUS_SHORTNAME'] }&thread:link=#{ params[:disqusurl] }&limit=2&cursor=#{ params[:disquscursor]}").read)
    disqus_cursor = comment_disqus["cursor"]
    comment_disqus = comment_disqus["response"]

    disqus_hash = Hash.new
    comment_disqus.each do |comm|
      disqus_hash[comm["id"]] = { text: comm["message"].html_safe, name: comm["author"]["name"], image: comm["author"]["avatar"]["small"]["permalink"],
                                                 created_at: comm["createdAt"] }
    end

    respond_to do |format|
      format.json { render :json => disqus_hash.to_json }
    end
  end

  def add_comment
    interaction = Interaction.find(params[:interaction_id])
    comment_resource = interaction.resource

    approved = comment_resource.must_be_approved ? nil : true
    user_text = params[:comment] # sanitize(params[:comment])
    
    response = Hash.new

    if current_user
      user_comment = UserCommentInteraction.create(user_id: current_user.id, approved: approved, text: user_text, comment_id: comment_resource.id)
      if approved && user_comment.errors.blank?
        user_interaction, outcome = create_or_update_interaction(user_comment.user_id, interaction.id, nil, nil)
      end
    elsif 
      response[:captcha_check] = params[:stored_captcha] == Digest::MD5.hexdigest(params[:user_filled_captcha])
      if response[:captcha_check]
        user_comment = UserCommentInteraction.create(user_id: current_or_anonymous_user.id, text: user_text, comment_id: comment_resource.id)
        if approved && !user_comment.errors.blank?
          user_interaction, outcome = create_or_update_interaction(user_comment.user_id, interaction.id, nil, nil)
        end
      end
    end

    response[:error] = user_comment.errors

    respond_to do |format|
      format.json { render :json => response.to_json }
    end

  end

  def append_or_update_comments(interaction_id, &query_block)
    interaction = Interaction.find(interaction_id)

    response = Hash.new
    render_calltoactions_str = String.new

    comments_to_show = query_block.call(interaction, response)

    comments_to_show.each do |user_comment|
      render_calltoactions_str = render_calltoactions_str + (render_to_string "/call_to_action/_comment", locals: { user_comment: user_comment, new_comment_class: true }, layout: false, formats: :html)
    end

    response[:comments_to_append] = render_calltoactions_str

    respond_to do |format|
      format.json { render :json => response.to_json }
    end
  end

  def new_comments_polling
    append_or_update_comments(params[:interaction_id]) do |interaction, response|

      if params[:first_comment_shown_date].present?
        comments_to_show = interaction.resource.user_comment_interactions.approved.where("date_trunc('second', updated_at) > ?", params[:first_comment_shown_date]).order("updated_at DESC")
      else
        comments_to_show = interaction.resource.user_comment_interactions.approved.order("date_trunc('second', updated_at) DESC")
      end

      response[:first_comment_shown_date] = comments_to_show.any? ? comments_to_show.first.updated_at : nil
      comments_to_show
    end
  end

  def append_comments
    append_or_update_comments(params[:interaction_id]) do |interaction, response|
      comments_to_show = interaction.resource.user_comment_interactions.approved.where("updated_at < ?", params[:last_comment_shown_date]).order("updated_at DESC").limit(10)
      response[:last_comment_shown_date] = comments_to_show.any? ? comments_to_show.last.updated_at : nil
      response[:comments_to_append_counter] = comments_to_show.count
      comments_to_show
    end    
  end

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
      
      answer = Answer.find(params[:answer_id])
      user_interaction, outcome = create_or_update_interaction(current_or_anonymous_user.id, interaction.id, answer.id, nil)

      response["have_answer_media"] = answer.answer_with_media?
      response["answer"] = answer

      if answer.media_type == "IMAGE" && answer.media_image
        response["answer"]["media_image"] = answer.media_image
      end

      if interaction.resource.quiz_type.downcase == "trivia"
        response[:ga][:label] = "#{interaction.resource.quiz_type.downcase}-answer-#{answer.correct ? "right" : "wrong"}"
      else 
        response[:ga][:label] = interaction.resource.quiz_type.downcase
      end

    elsif interaction.resource_type.downcase == "like"

      user_interaction = get_user_interaction_from_interaction(interaction, current_or_anonymous_user)
      like = user_interaction ? !user_interaction.like : true

      user_interaction, outcome = create_or_update_interaction(current_or_anonymous_user.id, interaction.id, nil, like)

      response[:ga][:label] = "Like"

    elsif interaction.resource_type.downcase == "share"
      provider = params[:provider]
      result, exception = update_share_interaction(interaction, provider, params[:share_with_email_address])
      if result
        aux = { "#{provider}" => 1 }
        user_interaction, outcome = create_or_update_interaction(current_or_anonymous_user.id, interaction.id, nil, nil, aux.to_json)
        response[:ga][:label] = interaction.resource_type.downcase
      end

      response[:share] = Hash.new
      response[:share][:result] = result
      response[:share][:exception] = exception.to_s

    else
      user_interaction, outcome = create_or_update_interaction(current_or_anonymous_user.id, interaction.id, nil, nil)
      response[:ga][:label] = interaction.resource_type.downcase
    end

    if current_user && user_interaction

      response['winnable_reward_count'] = get_current_call_to_action_reward_status("POINT", interaction.call_to_action)[:winnable_reward_count]

      if outcome.errors.any?
        logger.error("errors in the rewarding system:")
        outcome.errors.each do |error|
          logger.error(error)
        end
      end

      response['outcome'] = outcome
      response["call_to_action_completed"] = call_to_action_completed?(interaction.call_to_action, current_user)

      if interaction.when_show_interaction == "SEMPRE_VISIBILE"
        response["feedback"] = render_to_string "/call_to_action/_undervideo_interaction", locals: { interaction: interaction, outcome: outcome, ctaid: interaction.call_to_action_id }, layout: false, formats: :html 
      else
        response["feedback"] = render_to_string "/call_to_action/_feedback", locals: { outcome: outcome }, layout: false, formats: :html 
      end

    else
      response['outcome'] = nil
    end

    response["main_reward_counter"] = get_counter_about_user_reward(params[:main_reward_name])

    respond_to do |format|
      format.json { render :json => response.to_json }
    end
  end 

  def calltoaction_overvideo_end
    calltoaction = CallToAction.find(params[:calltoaction_id])
    interaction = calltoaction.interactions.find_by_when_show_interaction("OVERVIDEO_END")

    if params[:right_answer_response]
      response = Hash.new
    else
      response = response_for_overvideo_interaction(interaction.id)
    end

    respond_to do |format|
      format.json { render json: response.to_json }
    end  
  end
 
  def interaction_for_next_calltoaction?(interaction)
    if interaction.resource_type.downcase.to_sym == :quiz
      interaction.resource.answers.where("call_to_action_id IS NOT NULL").any?
    else
      false
    end
  end

  def update_calltoaction_content
    response = Hash.new
    if params[:type]
      calltoaction = calltoaction_active_with_tag(params[:type], "DESC").find(params[:id])
    else
      calltoaction = CallToAction.active.find(params[:id])
    end

    if params[:type] == "youtube"
      response = {
        "share_content" => (render_to_string "/call_to_action/_share_free_footer", locals: { calltoaction: calltoaction }, layout: false, formats: :html),
        "overvideo_title" => (render_to_string "/call_to_action/_overvideo_play", locals: { calltoaction: calltoaction, calltoaction_index: params[:index] }, layout: false, formats: :html)
      }
    else
      response = {
        "share_content" => (render_to_string "/call_to_action/_share_footer", locals: { calltoaction: calltoaction }, layout: false, formats: :html),
        "overvideo_title" => (render_to_string "/call_to_action/_overvideo_play", locals: { calltoaction: calltoaction, calltoaction_index: params[:index] }, layout: false, formats: :html)
      }
    end

    respond_to do |format|
      format.json { render json: response.to_json }
    end
  end

  def get_overvideo_during_interaction
    response = response_for_overvideo_interaction(params[:interaction_id])

    respond_to do |format|
      format.json { render json: response.to_json }
    end  
  end

  def response_for_overvideo_interaction(interaction_id)
    interaction = Interaction.find(interaction_id)

    response = Hash.new
    render_calltoaction_overvideo_end_str = String.new

    if current_user
      user_interaction = UserInteraction.find_by_user_id_and_interaction_id(current_user.id, interaction.id)
    end

    render_calltoaction_overvideo_end_str = (render_to_string "/call_to_action/_overvideo_interaction", 
              locals: { interaction: interaction, user_interaction: user_interaction }, layout: false, formats: :html)

    response[:overvideo] = render_calltoaction_overvideo_end_str
    response[:interaction_done_before] = user_interaction.present?

    if interaction.resource_type.downcase.to_sym == :quiz
      response[:interaction_one_shot] = interaction.resource.one_shot
    end

    response
  end

  def update_share_interaction(interaction, provider, address)
    # When this function is called, there is a current user with the current provider anchor

    provider_json = JSON.parse(interaction.resource.providers)[provider]
    result = true

    if provider == "facebook"

      begin
        if Rails.env == "production"
          current_user.facebook(request.site.id).put_wall_post(" ", 
            { name: provider_json["message"], description: provider_json["description"], link: provider_json["link"], picture: "#{interaction.resource.picture.url}" })
        else
          current_user.facebook(request.site.id).put_wall_post(" ", 
            { name: provider_json["message"], description: provider_json["description"], link: "http://entertainment.shado.tv/" })
        end  
      rescue Exception => exception
        result = false
        error = exception
      end

    elsif provider == "twitter"

      begin 
        if Rails.env == "production"
          media = URI.parse("#{interaction.resource.picture.url}").open
          current_user.twitter(request.site.id).update_with_media("#{interaction.call_to_action.title} #{provider_json["message"]}", media)
        else
          current_user.twitter(request.site.id).update("#{interaction.call_to_action.title} #{provider_json["message"]}")
        end
      rescue Exception => exception
        result = false
        error = exception
      end

    elsif provider == "email"

      if address =~ Devise.email_regexp
        SystemMailer.share_interaction(current_user, address, interaction.call_to_action).deliver
      else
        result = false
        error = "invalid format"
      end

    else
      result = false
    end

    [result, error]
  end
  
  def upload
    upload_interaction = Interaction.find(params[:interaction_id]).resource
    errors = check_valid_upload(upload_interaction)
    if errors.any?
      flash[:error] = errors
    else
      create_user_calltoactions(upload_interaction)
      if flash[:error].blank?
        flash[:notice] = "Upload interaction completata correttamente."
      end
    end
    if is_call_to_action_gallery(upload_interaction.call_to_action)
      redirect_to "/gallery/#{params[:cta_id]}"
    else
      redirect_to "/call_to_action/#{params[:cta_id]}"
    end
    
  end
  
  def create_user_calltoactions(upload_interaction)
    releasing = ReleasingFile.new(file: params[:releasing]) if upload_interaction.releasing?
    for i in(1 .. upload_interaction.upload_number) do
      if params["upload-#{i}"]
        if params["upload-#{i}"].size <= get_max_upload_size()
          cloned_cta = clone_and_create_cta(params, i, upload_interaction.watermark)
          if cloned_cta.errors.any?
            flash[:error] << cloned_cta.errors
          else
            UserUploadInteraction.create(user_id: current_user.id, call_to_action_id: cloned_cta.id, upload_id: upload_interaction.id)
            if upload_interaction.releasing?
              releasing.save if releasing.id.blank?
              cloned_cta.update_attribute(:releasing_file_id, releasing.id)
            end
          end
        else
          # TODO insert log call for trace attack
          flash[:error] = ["I file devono essere al massimo di #{MAX_UPLOAD_SIZE} Mb"]
        end
      end
    end
  end
  
  def check_valid_upload(upload_interaction)
    errors = Array.new
    if !check_privacy_accepted(upload_interaction) 
      errors << "Errore non hai accettato la privacy" 
    end
    if !check_releasing_accepted(upload_interaction)
      errors << "Errore non hai caricato la liberatoria"
    end
    if !check_uploaded_file()
      errors << "I file devono essere al massimo di #{MAX_UPLOAD_SIZE} Mb"
    end
    errors
  end
  
  def check_privacy_accepted(upload_interaction)
    if upload_interaction.privacy? && params[:privacy].nil?
      return false
    else
      return true
    end
  end
  
  def check_releasing_accepted(upload_interaction)
    if upload_interaction.releasing? && params[:releasing].nil?
      return false
    else
      return true
    end
  end
  
  def check_uploaded_file
    return true
  end
  
end
