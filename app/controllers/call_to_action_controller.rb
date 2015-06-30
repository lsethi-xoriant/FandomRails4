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
    user_interactions = UserInteraction.where(id: params[:user_interaction_ids]).order(created_at: :desc)
    cta = CallToAction.find(params[:parent_cta_id])

    user_interactions.each do |user_interaction|
      aux = user_interaction.aux
      aux["to_redo"] = true
      user_interaction.update_attributes(aux: aux)
    end

    response = {
      calltoaction_info: build_cta_info_list_and_cache_with_max_updated_at([cta]).first
    }

    respond_to do |format|
      format.json { render json: response.to_json }
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

    log_call_to_action_viewed(calltoaction)

    @calltoaction_info_list = build_cta_info_list_and_cache_with_max_updated_at([calltoaction], nil)
    
    sidebar_tag = calltoaction.user_id.present? ? "sidebar-cta-gallery" : "sidebar-cta"

    @aux_other_params = { 
      calltoaction: calltoaction,
      init_captcha: (current_user.nil? || current_user.anonymous_id.present?),
      sidebar_tag: sidebar_tag
    }

    set_seo_info_for_cta(calltoaction)

    descendent_calltoaction_id = params[:descendent_id]
    if(descendent_calltoaction_id)
      calltoaction_to_share = CallToAction.find(descendent_calltoaction_id)
      extra_fields = calltoaction_to_share.extra_fields

      @seo_info = {
        "title" => strip_tags(extra_fields["linked_result_title"]),
        "meta_description" => strip_tags(extra_fields["linked_result_description"]),
        "meta_image" => strip_tags(extra_fields["linked_result_image"]["url"]),
        "keywords" => get_default_keywords()
      }
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

    if registered_user?(current_user)
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

  def update_random_interaction(cta, interaction, aux, response)
    # TODO: Optimize next random call to action searching (with cache?)
    tag = Tag.find_by_name(interaction.resource.tag)
    ctas_without_me_count = get_ctas(tag).where("call_to_actions.id <> ?", cta.id).count
    next_random_cta = ctas_without_me.offset(rand(ctas_without_me_count)).first

    user_interaction, outcome = create_or_update_interaction(current_or_anonymous_user, interaction, nil, nil, aux.to_json)    

    response[:next_random_call_to_action_info_list] = build_cta_info_list_and_cache_with_max_updated_at([next_random_cta])
    response[:ga][:label] = interaction.resource_type

    [user_interaction, outcome, response]
  end

  def update_interaction
    
=begin    
    interaction = Interaction.find(params[:interaction_id])
    calltoaction = interaction.call_to_action

    aux = {}
    response = {}
    response[:calltoaction_id] = interaction.call_to_action_id;

    response[:ga] = Hash.new
    response[:ga][:category] = "UserInteraction"
    response[:ga][:action] = "CreateOrUpdate"
    response[:ga][:label] = interaction.resource_type 

    linked_cta = nil
    if interaction.interaction_call_to_actions.any?
      linked_cta = compute_linked_cta(interaction, params[:user_interactions_history], params[:params])
      next_cta_id = linked_cta.nil? ? nil : linked_cta.id
    end

    aux[:to_redo] = false

    aux[:user_interactions_history] = params[:user_interactions_history] if params[:user_interactions_history]
    aux[:next_cta_id] = next_cta_id if next_cta_id

    case interaction.resource_type.downcase
    when "quiz"
      answer = Answer.find(params[:params])
      user_interaction, outcome, response = update_quiz_interaction(interaction, answer, aux, response)
    when "like"
      user_interaction, outcome = create_or_update_interaction(current_or_anonymous_user, interaction, nil, nil, aux.to_json)
    when "share"
      user_interaction, outcome, response = update_share_interaction(interaction, aux, params[:provider], params[:share_with_email_address], params[:facebook_message], response)
    when "vote"
      aux[:vote] = params[:params]
      user_interaction, outcome = create_or_update_interaction(current_or_anonymous_user, interaction, nil, nil, aux.to_json)
      response["counter_aux"], response["counter"] = get_interaction_counter_from_view_counter(interaction.id)
    when "randomresource"
      user_interaction, outcome, response = update_cta_and_interaction_status(calltoaction, interaction, response)
    when "download"
      response["download_interaction_attachment"] = interaction.resource.attachment.url
      user_interaction, outcome = create_or_update_interaction(current_or_anonymous_user, interaction, nil, aux.to_json)
    else
      user_interaction, outcome = create_or_update_interaction(current_or_anonymous_user, interaction, nil, aux.to_json)
    end

    if user_interaction
      response[:user_interaction] = build_user_interaction_for_interaction_info(user_interaction)
      response[:outcome] = outcome
      if stored_anonymous_user? && $site.interactions_for_anonymous_limit.present?
        user_interactions_count = current_user.user_interactions.count
        response[:notice_anonymous_user] = user_interactions_count > 0 && user_interactions_count % $site.interactions_for_anonymous_limit == 0
      end
    end 
    
    response = update_cta_and_interaction_status(calltoaction, interaction, response)

    if linked_cta.present?
      response[:next_call_to_action_info_list] = build_cta_info_list_and_cache_with_max_updated_at([linked_cta])
    end

    if current_user && $site.id != "disney"
      response[:current_user] = JSON.parse(build_current_user())
    elsif $site.id == "disney"
      response[:current_user] = build_disney_current_user()
    end
=end
    
    response = update_interaction_helper(params)
    
    respond_to do |format|
      format.json { render :json => response.to_json }
    end
  end 

  def user_history_to_answer_map_fo_condition(current_answer, user_interactions_history)
    if current_user
      answers_history = UserInteraction.where(id: user_interactions_history).map { |ui| ui.answer_id }
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
