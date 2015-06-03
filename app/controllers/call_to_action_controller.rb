#!/bin/env ruby
# encoding: utf-8

class CallToActionController < ApplicationController
  
  include RewardingSystemHelper
  include CallToActionHelper
  include ApplicationHelper
  include CaptchaHelper
  include CommentHelper

  # For logged user, last_linked_calltoaction for anonymous user
  def reset_redo_user_interactions
    user_interactions = UserInteraction.where(id: params[:user_interaction_ids])
    cta = nil
    user_interactions.each do |user_interaction|
      aux = user_interaction.aux
      aux["to_redo"] = true
      user_interaction.update_attributes(aux: aux.to_json)
      unless aux["user_interactions_history"]
        cta = user_interaction.interaction.call_to_action
      end
    end
    response = {
      calltoaction_info_list: build_cta_info_list_and_cache_with_max_updated_at([cta])
    }
    respond_to do |format|
      format.json { render json: response.to_json }
    end 
  end

  # For anonymous user
  def last_linked_calltoaction
    calltoaction = CallToAction.find(params[:calltoaction_id])
    linked_interaction = calltoaction.interactions.includes(:interaction_call_to_actions).where("interaction_call_to_actions.interaction_id IS NOT NULL").references(:interaction_call_to_actions).first 

    if !current_user && $site.anonymous_interaction 
      user_interaction_info_list = params[:anonymous_user_interactions]
      
      calltoaction_id_to_return = calltoaction.id
      calltoaction_to_evaluate = calltoaction.id
      linked_call_to_actions_index = 0
      user_interactions_history = []
      while calltoaction_to_evaluate.present?
        calltoaction_id_to_return = calltoaction_to_evaluate
        linked_call_to_actions_index = linked_call_to_actions_index + 1
        if user_interaction_info_list["user_interaction_info_list"]
          user_interaction_info_list["user_interaction_info_list"].each do |index, user_interaction_info|
            if user_interaction_info["calltoaction_id"] == calltoaction_to_evaluate
              current_interaction = user_interaction_info["user_interaction"]
              aux_parse = current_interaction["aux"]
              if aux_parse["to_redo"] == false
                user_interactions_history = user_interactions_history + [index]
                calltoaction_to_evaluate = aux_parse["next_calltoaction_id"]
              end
              break
            end
          end
          if calltoaction_to_evaluate == calltoaction_id_to_return
            break
          end
        else
          calltoaction_id_to_return = calltoaction_to_evaluate
          break
        end
      end

      go_on = calltoaction.id != calltoaction_id_to_return
      if go_on
        calltoaction = CallToAction.find(calltoaction_id_to_return)
      end

      response = {
        go_on: go_on,
        linked_call_to_actions_index: linked_call_to_actions_index,
        calltoaction_info_list: build_cta_info_list_and_cache_with_max_updated_at([calltoaction]),
        user_interactions_history: user_interactions_history
      }
      
      respond_to do |format|
        format.json { render json: response.to_json }
      end 

    end

  end

  def random_calltoaction
    except_calltoaction_id = params["except_calltoaction_id"]
    
    calltoaction = nil
    loop do 
      calltoaction = get_all_active_ctas().sample
      break if calltoaction.id != except_calltoaction_id
    end 

    response = {
      "calltoaction_info_list" => build_cta_info_list_and_cache_with_max_updated_at([calltoaction])
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
    init_ctas = $site.init_ctas * 2
    tag = get_property()
    tag_name = tag.present? ? tag.name : nil
    calltoaction_info_list, has_more = get_ctas_for_stream(tag_name, params, init_ctas)

    params[:page_elements] = ["empty"]
    response = {
      calltoaction_info_list: calltoaction_info_list,
      has_more: has_more
    }
    
    respond_to do |format|
      format.json { render json: response.to_json }
    end 
  end

  def ordering_ctas
    init_ctas = $site.init_ctas
    tag_name = get_property()
    tag_name = tag.present? ? tag.name : nil
    calltoaction_info_list, has_more = get_ctas_for_stream(tag_name, params, init_ctas)

    params[:page_elements] = ["empty"]
    response = {
      calltoaction_info_list: calltoaction_info_list,
      has_more: has_more
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
    
    calltoaction = CallToAction.includes(:interactions).active.references(:interactions).find(calltoaction_id)

    if calltoaction
      log_call_to_action_viewed(calltoaction)

      @calltoaction_info_list = build_cta_info_list_and_cache_with_max_updated_at([calltoaction], nil)
      
      optional_history = @calltoaction_info_list.first["optional_history"]
      if optional_history
        step_index = optional_history["optional_index_count"]
        step_count = optional_history["optional_total_count"]
      end

      #if current_user
      #  @current_user_info = build_current_user()
      #end

      @aux_other_params = { 
        calltoaction: calltoaction,
        linked_call_to_actions_index: step_index, # init in build_cta_info_list_and_cache_with_max_updated_at for recoursive ctas
        linked_call_to_actions_count: step_count
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
      calltoactions = CallToAction.includes(:call_to_action_tags).active.where("call_to_action_tags.tag_id=? and call_to_actions.id <> ?", tag_id, calltoaction.id).references(:call_to_action_tags).references(:call_to_action_tags).limit(3)
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
    user_text = params[:comment_info][:user_text]

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

    response[:ga] = Hash.new
    response[:ga][:category] = "UserCommentInteraction"
    response[:ga][:action] = "AddComment"

    if current_user
      user_comment = UserCommentInteraction.create(user_id: current_user.id, approved: approved, text: user_text, comment_id: comment_resource.id, aux: aux)
      response[:comment] = build_comment_for_comment_info(user_comment, true)
      if approved && user_comment.errors.blank?
        adjust_counter!(interaction, 1)
        user_interaction, outcome = create_or_update_interaction(current_user, interaction, nil, nil)
      end
    else
      captcha_enabled = get_deploy_setting("captcha", true)
      response[:captcha] = captcha_enabled
      response[:captcha_evaluate] = !captcha_enabled || params[:session_storage_captcha] == Digest::MD5.hexdigest(params[:comment_info][:user_captcha] || "")
      if response[:captcha_evaluate]
        user_comment = UserCommentInteraction.create(user_id: current_or_anonymous_user.id, approved: approved, text: user_text, comment_id: comment_resource.id, aux: aux)
        response[:comment] = build_comment_for_comment_info(user_comment, true)
        if approved && user_comment.errors.blank?
          user_interaction, outcome = create_or_update_interaction(user_comment.user, interaction, nil, nil)
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

    linked_cta = nil
    if interaction.interaction_call_to_actions.any?
      interaction_call_to_actions = interaction.interaction_call_to_actions.order(:ordering, :created_at)

      symbolic_name_to_counter = nil

      interaction_call_to_actions.each do |interaction_call_to_action|
        if interaction_call_to_action.condition.present?
          # the symbolic_name_to_counter is populated "lazily" only if there is at least one condition present
          if symbolic_name_to_counter.nil?
            user_interactions_history = params[:user_interactions_history] # + [user_interaction.id]
            current_answer = params[:params]
            symbolic_name_to_counter = user_history_to_answer_map_fo_condition(current_answer, user_interactions_history, params[:anonymous_user_storage])
          end
          condition = interaction_call_to_action.condition
          condition_name, condition_params = condition.first
          if get_linked_call_to_action_conditions[condition_name].call(symbolic_name_to_counter, condition_params)
            linked_cta = interaction_call_to_action.call_to_action
          end
        else
          linked_cta = interaction_call_to_action.call_to_action
          break
        end
      end

      next_cta_id = linked_cta.nil? ? nil : linked_cta.id
    end

    aux = {
      user_interactions_history: params[:user_interactions_history],
      next_calltoaction_id: next_cta_id,
      to_redo: false
    }

    if interaction.resource_type.downcase == "quiz"
      answer = Answer.find(params[:params])
      user_interaction, outcome = create_or_update_interaction(current_or_anonymous_user, interaction, answer.id, nil, aux.to_json)
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
      counter = ViewCounter.where("ref_type = 'interaction' AND ref_id = ?", interaction.id).first
      response["counter_aux"] = counter ? counter.aux : {}
      response["counter"] = counter ? counter.counter : 0

    elsif interaction.resource_type.downcase == "like"

      # TODO: user_interaction calculated 2 times
      user_interaction = get_user_interaction_from_interaction(interaction, current_or_anonymous_user)
      like = user_interaction ? !user_interaction.like : true

      aux["like"] = true

      user_interaction, outcome = create_or_update_interaction(current_or_anonymous_user, interaction, nil, nil, aux.to_json)

      response[:ga][:label] = "Like"

    elsif interaction.resource_type.downcase == "share"
      provider = params[:provider]
      result, exception = update_share_interaction(interaction, provider, params[:share_with_email_address], params[:facebook_message])
      if result
        aux["#{provider}"] = 1
        user_interaction, outcome = create_or_update_interaction(current_or_anonymous_user, interaction, nil, nil, aux.to_json)
        response[:ga][:label] = interaction.resource_type.downcase
      end

      response[:share] = Hash.new
      response[:share][:result] = result
      response[:share][:exception] = exception.to_s
    
    elsif interaction.resource_type.downcase == "vote"
      aux["call_to_action_id"] = interaction.call_to_action.id
      aux["vote"] = params[:params] 

      user_interaction, outcome = create_or_update_interaction(current_or_anonymous_user, interaction, nil, nil, aux.to_json)
      response[:ga][:label] = interaction.resource_type.downcase

      counter = ViewCounter.where("ref_type = 'interaction' AND ref_id = ?", interaction.id).first
      response["counter_aux"] = counter.aux

    elsif interaction.resource_type.downcase == "randomresource"

      ctas = get_ctas(tag).to_a
      loop do
        next_random_cta = ctas.sample
        break if next_random_cta.id != interaction.id
      end

    else
      if interaction.resource_type.downcase == "download" 
        response["download_interaction_attachment"] = interaction.resource.attachment.url
      end

      user_interaction, outcome = create_or_update_interaction(current_or_anonymous_user, interaction, nil, aux.to_json)
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

    unless linked_cta.nil?
      response["next_call_to_action_info_list"] = build_cta_info_list_and_cache_with_max_updated_at([linked_cta])
    end

    respond_to do |format|
      format.json { render :json => response.to_json }
    end
  end 

  def user_history_to_answer_map_fo_condition(current_answer, user_interactions_history, anonymous_user_storage)
    if current_user
      answers_history = UserInteraction.where(id: user_interactions_history).map { |ui| ui.answer_id }
    elsif $site.anonymous_interaction 
      answers_history = []
      anonymous_user_storage["user_interaction_info_list"].each do |index, user_interaction_info|
        if user_interactions_history.include?(user_interaction_info["user_interaction"]["interaction_id"]) # For anonymous the user_interaction id is the interaction id. He must be only one user interaction for interaction.
          answers_history = answers_history + [user_interaction_info["user_interaction"]["answer"]["id"]]
        end
      end
    else
      throw Exception.new("for linked interactions the user must be logged or the anonymous navigation must be enabled")
    end

    answers_history = answers_history + [current_answer]

    answers = Answer.where(id: answers_history)
    symbolic_name_to_counter = {}
    answers.each do |answer|
      value = answer.aux["symbolic_name"]
      if symbolic_name_to_counter.has_key?(value)
        symbolic_name_to_counter[value] = symbolic_name_to_counter[value] + 1
      else
        symbolic_name_to_counter[value] = 1
      end
    end
    symbolic_name_to_counter
  end

  def max_key_in_symbolic_name_to_counter(symbolic_name_to_counter)

    current_key = ""
    current_value = 0

    symbolic_name_to_counter.each do |key, value|
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
    provider_json = interaction.resource.providers[provider]
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

      if !current_user
        throw Exception.new("to sent an email the user must be logged")
      end

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
