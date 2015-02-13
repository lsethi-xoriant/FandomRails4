#!/bin/env ruby
# encoding: utf-8

class CallToActionController < ApplicationController
  
  include ActionView::Helpers::SanitizeHelper
  include RewardingSystemHelper
  include CallToActionHelper
  include ApplicationHelper
  include CaptchaHelper
  include CommentHelper

  def random_calltoaction
    except_calltoaction_id = params["except_calltoaction_id"]
    
    calltoaction = nil
    loop do 
      calltoaction = get_all_active_ctas().sample
      break if calltoaction.id != except_calltoaction_id
    end 

    response = {
      "calltoaction_info_list" => build_call_to_action_info_list([calltoaction])
    }

    respond_to do |format|
      format.json { render json: response.to_json }
    end

  end

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
    calltoaction_ids_shown = params[:calltoaction_ids_shown]
    calltoaction_ids_shown_qmarks = (["?"] * calltoaction_ids_shown.count).join(", ")

    context_tag = get_tag_from_params(get_context())

    calltoactions = cache_short(get_next_ctas_stream_cache_key(context_tag.id, calltoaction_ids_shown.last, get_cta_max_updated_at())) do
      CallToAction.active.where("call_to_actions.id NOT IN (#{calltoaction_ids_shown_qmarks})", *calltoaction_ids_shown).limit(3).to_a
    end

    response = {
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
    calltoaction_id = params[:id]
    
    calltoaction = CallToAction.includes(interactions: :resource).active_with_media.find(calltoaction_id)

    if calltoaction
      log_call_to_action_viewed(calltoaction_id)

      #calltoactions = CallToAction.includes(:interactions).active.where("call_to_actions.id <> ?", calltoaction_id).limit(2).to_a
      @calltoactions_with_current = [calltoaction] # + calltoactions
      @calltoaction_info_list = build_call_to_action_info_list(@calltoactions_with_current)
      
      if current_user
        @current_user_info = build_current_user()
      end

      @aux = init_show_aux(calltoaction)
      
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

=begin
  def build_current_user()
    {
      "facebook" => current_user.facebook(request.site.id),
      "twitter" => current_user.twitter(request.site.id),
      "main_reward_counter" => get_counter_about_user_reward(MAIN_REWARD_NAME, true),
      "registration_fully_completed" => registration_fully_completed?
    }
  end
=end

  def init_show_aux(calltoaction)
    {
      "tenant" => get_site_from_request(request)["id"],
      "anonymous_interaction" => get_site_from_request(request)["anonymous_interaction"],
      "kaltura" => get_deploy_setting("sites/#{request.site.id}/kaltura", nil),
      "init_captcha" => true,
      "mobile" => small_mobile_device?()
    }
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
    user_text = params[:comment_info][:user_text]
    
    response = Hash.new

    response[:approved] = approved

    response[:ga] = Hash.new
    response[:ga][:category] = "UserCommentInteraction"
    response[:ga][:action] = "AddComment"

    if current_user
      user_comment = UserCommentInteraction.new(user_id: current_user.id, approved: approved, text: user_text, comment_id: comment_resource.id)
      unless check_profanity_words_in_comment(user_comment).errors.any?
        user_comment.save
      end
      response[:comment] = build_comment_for_comment_info(user_comment, true)
      if approved && user_comment.errors.blank?
        user_interaction, outcome = create_or_update_interaction(current_user, interaction, nil, nil)
        expire_cache_key(get_comments_approved_cache_key(interaction.id))
      end
    else
      captcha_enabled = get_deploy_setting("captcha", true)
      response[:captcha] = captcha_enabled
      response[:captcha_evaluate] = !captcha_enabled || params[:session_storage_captcha] == Digest::MD5.hexdigest(params[:comment_info][:user_captcha] || "")
      if response[:captcha_evaluate]
        user_comment = UserCommentInteraction.new(user_id: current_or_anonymous_user.id, approved: approved, text: user_text, comment_id: comment_resource.id)
        unless check_profanity_words_in_comment(user_comment).errors.any?
          user_comment.save
        end
        response[:comment] = build_comment_for_comment_info(user_comment, true)
        if approved && user_comment.errors.blank?
          user_interaction, outcome = create_or_update_interaction(user_comment.user, interaction, nil, nil)
          expire_cache_key(get_comments_approved_cache_key(interaction.id))
        end
      end
      response[:captcha] = generate_captcha_response
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
    comments = query_block.call(interaction, response)

    response[:comments] = comments

    respond_to do |format|
      format.json { render :json => response.to_json }
    end

  end

  def get_comments_approved_except_ids(user_comments, except_comments)
    if except_comments
      comment_id_qmarks = (["?"] * except_comments.count).join(", ")
      user_comments.approved.where("id NOT IN (#{comment_id_qmarks})", *(except_comments.map { |comment| comment[:id] }))
    else
      user_comments.approved
    end
  end

  def comments_polling
    append_or_update_comments(params[:interaction_id]) do |interaction, response|

      comments_without_shown = get_comments_approved_except_ids(interaction.resource.user_comment_interactions, params[:comment_info][:comments])
      first_comment_shown_date = params[:comment_info][:comments].first[:updated_at] rescue Date.yesterday

      comments = comments_without_shown.where("date_trunc('seconds', updated_at) >= ?", first_comment_shown_date).order("updated_at DESC")
      
      comments_for_comment_info = Array.new
      comments.each do |comment|
        comments_for_comment_info << build_comment_for_comment_info(comment, true)
      end
      comments_for_comment_info
    end
  end

  def append_comments
    append_or_update_comments(params[:interaction_id]) do |interaction, response|
      comments_without_shown = get_comments_approved_except_ids(interaction.resource.user_comment_interactions, params[:comment_info][:comments])
      last_comment_shown_date = params[:comment_info][:comments].last[:updated_at]
      comments = comments_without_shown.where("date_trunc('seconds', updated_at) <= ?", last_comment_shown_date).order("updated_at DESC").limit(10)
      comments_for_comment_info = Array.new
      comments.each do |comment|
        comments_for_comment_info << build_comment_for_comment_info(comment, true)
      end
      comments_for_comment_info
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

      response["vote_info"] = build_votes_for_resource(interaction) 

    else
      user_interaction, outcome = create_or_update_interaction(current_or_anonymous_user, interaction, nil, nil)
      response[:ga][:label] = interaction.resource_type.downcase
    end

    calltoaction = interaction.call_to_action

    if user_interaction
      response["user_interaction"] = build_user_interaction_for_interaction_info(user_interaction)

      response['outcome'] = outcome

      expire_user_interaction_cache_keys()

    end

    if anonymous_user?(current_or_anonymous_user)

      if params["anonymous_user"]
        anonymous_user_main_reward_count = params["anonymous_user"][get_main_reward_name()] || 0
      else 
        anonymous_user_main_reward_count = 0
      end

      response["main_reward_counter"] = {
        "general" => (anonymous_user_main_reward_count + outcome["reward_name_to_counter"][get_main_reward_name()])
      }
      
    else
      response["main_reward_counter"] = get_point
      response = setup_update_interaction_response_info(response)
    end    
    
    response["interaction_status"] = get_current_interaction_reward_status(get_main_reward_name(), interaction)
    response["calltoaction_status"] = compute_call_to_action_completed_or_reward_status(get_main_reward_name(), calltoaction).to_json

    if interaction.interaction_call_to_actions.any?
      interaction_conditions = interaction.interaction_call_to_actions.order(:ordering, :created_at)
      
      answers_map_for_condition = {}

      interaction_conditions.each do |interaction_condition|
        if interaction_condition.condition.present?
          if answers_map_for_condition.empty?
            user_interactions_history = params[:user_interactions_history] + [user_interaction.id]
            answers_map_for_condition = map_answers_in_user_history(user_interactions_history, params[:anonymous_user_storage])
          end      
          condition = JSON.parse(interaction_condition.condition)
          if condition.has_key?("max")
            max_key = max_key_in_answers_map_for_condition(answers_map_for_condition)
            if max_key == condition["max"]
              response["next_call_to_action_info_list"] = build_call_to_action_info_list([interaction_condition.call_to_action])
            end
          end
        end
      end

      if answers_map_for_condition.empty?
        response["next_call_to_action_info_list"] = build_call_to_action_info_list([interaction.interaction_call_to_actions.first.call_to_action])
      end

    end

    respond_to do |format|
      format.json { render :json => response.to_json }
    end
  end 

  def map_answers_in_user_history(user_interactions_history, anonymous_user_storage)

    if current_user
      answers_history = UserInteraction.where(id: user_interactions_history)
    elsif $site.anonymous_interaction 
      answers_history = []
      anonymous_user_storage["user_interaction_info_list"].each do |user_interaction_info|
        if user_interactions_history.include?(user_interaction_info["user_interaction"]["id"])
          answers_history = answers_history + [user_interaction_info["user_interaction"]["answer"]["id"]]
        end
      end
    end

    answers = Answer.where(id: answers_history)
    answers_map_for_condition = {}
    answers.each do |answer|
      value = JSON.parse(answer.aux)["value"]
      if answers_map_for_condition.has_key?(value)
        answers_map_for_condition[value] = answers_map_for_condition[value] + 1
      else
        answers_map_for_condition[value] = 1
      end
    end
    answers_map_for_condition
  end

  def max_key_in_answers_map_for_condition(answers_map_for_condition)

    current_key = ""
    current_value = 0

    answers_map_for_condition.each do |key, value|
      if value > current_value
        current_key = key
        current_value = value
      end
    end

    current_key

  end

  def expire_user_interaction_cache_keys()
  end

  def setup_update_interaction_response_info(response)
    response
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

  def update_share_interaction(interaction, provider, address, facebook_message = " ")
    # When this function is called, there is a current user with the current provider anchor
    provider_json = JSON.parse(interaction.resource.providers)[provider]
    result = true

    if provider == "facebook"
      begin
        link = provider_json["link"].present? ? provider_json["link"] : "#{root_url}?calltoaction_id=#{interaction.call_to_action_id}"
        current_user.facebook(request.site.id).put_wall_post(facebook_message, 
            { name: provider_json["message"], description: provider_json["description"], link: link, picture: "#{interaction.resource.picture.url}" })
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
        send_share_interaction_email(address, interaction.call_to_action)
      else
        result = false
        error = "Formato non valido"
      end

    else
      result = false
    end

    [result, error]
  end

  def send_share_interaction_email(address, calltoaction)
    SystemMailer.share_interaction(current_user, address, calltoaction, aux).deliver
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
