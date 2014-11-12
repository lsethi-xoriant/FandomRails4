#!/bin/env ruby
# encoding: utf-8

class CallToActionController < ApplicationController
  
  include ActionView::Helpers::SanitizeHelper
  include RewardingSystemHelper
  include CallToActionHelper
  include ApplicationHelper
  include CaptchaHelper
  include CommentHelper

  def facebook_share_page_with_meta
    @calltoaction = CallToAction.active.find(params[:calltoaction_id])
    fb_meta_info = get_fb_meta(@calltoaction)
    if fb_meta_info
      @fb_meta_tags = (
                        '<meta property="og:type" content="article" />' +
                        '<meta property="og:locale" content="it_IT" />' +
                        '<meta property="og:title" content="' + fb_meta_info['title'] + '" />' +
                        '<meta property="og:description" content="' + fb_meta_info['description'] +'" />' +
                        '<meta property="og:image" content="' + fb_meta_info['image_url'] + '" />'
                      ).html_safe
    end
  end

  def append_calltoaction
    
    calltoactions = Array.new
    render_calltoactions_str = String.new
    
    if get_site_from_request(request)["id"] == "ballando"
      # TODO: BALLANDO
      calltoactions_showed_ids = params[:calltoactions_showed].map { |calltoaction| calltoaction["id"] }
    else
      calltoactions_showed_ids = params[:calltoactions_showed].map { |calltoaction_info| calltoaction_info["calltoaction"]["id"] }
    end
    calltoactions_showed_id_qmarks = (["?"] * calltoactions_showed_ids.count).join(", ")

    if params[:tag_id].present?
      stream_call_to_action_to_render = CallToAction.includes(:call_to_action_tags).where("call_to_action_tags.tag_id = ?", params[:tag_id]).active
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
      if get_site_from_request(request)["id"] == "ballando"
        # TODO: BALLANDO
        render_calltoactions_str = render_calltoactions_str + (render_to_string "/call_to_action/_stream_single_calltoaction", locals: { calltoaction: calltoaction, calltoaction_comment_interaction: calltoactions_comment_interaction[calltoaction.id], active_calltoaction_id: nil, calltoaction_active_interaction: Hash.new, aux: nil }, layout: false, formats: :html)
      end
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
      html_to_append: render_calltoactions_str,
      calltoaction_info_list: build_call_to_action_info_list(calltoactions)
    }
    
    respond_to do |format|
      format.json { render json: response.to_json }
    end
    
  end

  def next_interaction
    calltoaction = CallToAction.find(params[:calltoaction_id])
    interactions = calculate_next_interactions(calltoaction, params[:interactions_showed])

    response = generate_response_for_interaction(interactions, calltoaction, params[:aux] || {})
    
    respond_to do |format|
      format.json { render json: response.to_json }
    end
  end

  def check_next_interaction
    calltoaction = CallToAction.find(params[:calltoaction_id])
    current_interaction = calltoaction.interactions.find(params[:interaction_id])

    interactions = always_shown_interactions(calltoaction)

    next_interaction = false
    interactions.each do |interaction|
      if interaction.seconds > current_interaction.seconds
        next_interaction = true 
        break
      end
    end

    response = Hash.new
    response = {
      next_interaction: next_interaction
    }
    
    respond_to do |format|
      format.json { render json: response.to_json }
    end
  end
  
  # TODO: cache this
  def get_fb_meta(cta)
    share_interaction = cta.interactions.find_by_resource_type("Share")
    if share_interaction
      share_resource = share_interaction.resource
      share_info = JSON.parse(share_resource.providers)
      info = {
        'title' => get_cta_share_title(cta, share_info),
        'description' => get_cta_share_description(cta, share_info),
        'image_url' => get_cta_share_image(cta, share_resource)
      }
    else
      nil
    end
  end
  
  def get_cta_share_title(cta, share_info)
    if share_info['facebook']['message'].present?
      share_info['facebook']['message']
    else
      cta.title
    end
  end
  
  def get_cta_share_description(cta, share_info)
    if share_info['facebook']['description'].present?
      share_info['facebook']['description']
    else
      cta.description
    end
  end
  
  def get_cta_share_url(cta, share_info)
    if share_info['facebook']['link'].present?
      share_info['facebook']['link']
    else
      ""
    end
  end
  
  def get_cta_share_image(cta, share)
    if share.picture.present?
      share.picture(:thumb).split("?").first
    else
      cta.thumbnail(:medium).split("?").first
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
      aux = { show_calltoaction_page: true }
      @calltoactions_active_interaction[@calltoactions_with_current[0].id] = generate_next_interaction_response(@calltoactions_with_current[0], nil, aux)

    else

      redirect_to "/"

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
  
  def get_correlated_cta(calltoaction)
    tags_with_miniformat_in_calltoaction = get_tag_with_tag_about_call_to_action(calltoaction, "miniformat")
    if tags_with_miniformat_in_calltoaction.any?
      tag_id = tags_with_miniformat_in_calltoaction.first.id
      calltoactions = CallToAction.includes(:call_to_action_tags).active.where("call_to_action_tags.tag_id=? and call_to_actions.id <> ?", tag_id, calltoaction.id).limit(3)
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

  def check_profanity_words_in_comment(user_comment)

    user_comment_text = user_comment.text.downcase

    @profanities_regexp = cache_short("profanities") do
      pattern_array = Array.new

      Setting.where(key: 'profanity.words').first.value.split(",").each do |exp|
        pattern_array.push(build_regexp(exp))
      end

      Regexp.union(pattern_array)
    end

    if user_comment_text =~ @profanities_regexp
      user_comment.errors.add(:text, "contiene parole non ammesse")
      return user_comment
    end

    user_comment
  end

  def build_regexp(line)
    string = "(\\W+|^)"
    line.strip.each_char do |c|
      if REGEX_SPECIAL_CHARS.include? c
        c = "\\" + c
      end
      if c != " "
        string += "(\\W*)" + c
      end
    end
    Regexp.new(string)
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

  def get_comments_approved_except_ids(user_comments, except_ids)
    if except_ids
      comments_showed_id_qmarks = (["?"] * except_ids.count).join(", ")
      comments_to_show_approved = user_comments.approved.where("id NOT IN (#{comments_showed_id_qmarks})", *except_ids)
    else
      user_comments.approved
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

  def append_comments
    append_or_update_comments(params[:interaction_id]) do |interaction, response|
      
      comments_to_show_approved = get_comments_approved_except_ids(interaction.resource.user_comment_interactions, params[:comments_shown])
      comments_to_show = comments_to_show_approved.where("date_trunc('milliseconds', updated_at) <= ?", params[:last_comment_shown_date]).order("updated_at DESC").limit(10)
      
      response[:last_comment_shown_date] = comments_to_show.any? ? comments_to_show.last.updated_at.strftime("%Y-%m-%d %H:%M:%S.%6N") : nil
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
      
      answer = Answer.find(params[:params])
      user_interaction, outcome = create_or_update_interaction(current_or_anonymous_user, interaction, answer.id, nil)
      response["have_answer_media"] = answer.answer_with_media?
      response["answer"] = answer

      if answer.media_type == "IMAGE" && answer.media_image
        response["answer"]["media_image"] = answer.media_image
      end

      if interaction.resource.quiz_type.downcase == "trivia"
        response[:ga][:label] = "#{interaction.resource.quiz_type.downcase}-answer-#{answer.correct ? "right" : "wrong"}"
      else 
        response["answers"] = build_answers_for_resource(interaction, interaction.resource.answers, "versus")
        response[:ga][:label] = interaction.resource.quiz_type.downcase
      end

    elsif interaction.resource_type.downcase == "like"

      # TODO: user_interaction calculated 2 times
      user_interaction = get_user_interaction_from_interaction(interaction, current_or_anonymous_user)
      like = user_interaction ? !user_interaction.like : true

      user_interaction, outcome = create_or_update_interaction(current_or_anonymous_user, interaction, nil, like)

      response[:ga][:label] = "Like"

    elsif interaction.resource_type.downcase == "share"
      provider = params[:provider]
      result, exception = update_share_interaction(interaction, provider, params[:share_with_email_address])
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
      anonymous_user_main_reward_count = JSON.parse(params["anonymous_user"])[MAIN_REWARD_NAME]
      response["main_reward_counter"] = anonymous_user_main_reward_count + outcome["reward_name_to_counter"][MAIN_REWARD_NAME]
    else
      response["main_reward_counter"] = get_counter_about_user_reward(MAIN_REWARD_NAME, true) #HERE
      response["contest_points_counter"] = [SUPERFAN_CONTEST_POINTS_TO_WIN - (get_counter_about_user_reward(SUPERFAN_CONTEST_REWARD, false) || 0), 0].max
    end

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
    @upload_interaction = Interaction.find(params[:interaction_id])
    @cloned_cta = create_user_calltoactions(@upload_interaction.resource)

    if @cloned_cta.errors.any?
      render template: "/upload_interaction/new"
    else
      flash[:notice] = "Caricamento completato con successo"
      redirect_to "/upload_interaction/new"
    end

    #if is_call_to_action_gallery(upload_interaction.call_to_action)
    #  redirect_to "/gallery/#{params[:cta_id]}"
    #else
      #redirect_to "/upload_interaction/new"
    #end 
  end
  
  def create_user_calltoactions(upload_interaction)  
    
      cloned_cta = clone_and_create_cta(upload_interaction, params, upload_interaction.watermark)
      cloned_cta.build_user_upload_interaction(user_id: current_user.id, upload_id: upload_interaction.id)
      cloned_cta.save
      cloned_cta

=begin    
    for i in(1 .. upload_interaction.upload_number) do
      if params["upload-#{i}"]
        if params["upload-#{i}"].size <= get_max_upload_size()
          cloned_cta = clone_and_create_cta(upload_interaction, params, i, upload_interaction.watermark)
          if cloned_cta.errors.any?
            flash[:error] << cloned_cta.errors
          else
            UserUploadInteraction.create(user_id: current_user.id, call_to_action_id: cloned_cta.id, upload_id: upload_interaction.id)
            if upload_interaction.releasing?
              releasing.save if releasing.id.blank?
              cloned_cta.releasing_file_id = releasing.id
            end
            cloned_cta.save
          end
        else
          flash[:error] = ["I file devono essere al massimo di #{MAX_UPLOAD_SIZE} Mb"]
        end
      end
    end
=end

  end
  
  def check_valid_upload(upload_interaction)
    errors = Array.new
    if !check_privacy_accepted(upload_interaction) 
      errors << "Devi accettare la privacy" 
    end
    if !check_releasing_accepted(upload_interaction)
      errors << "Devi caricare la liberatoria"
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
