#!/bin/env ruby
# encoding: utf-8

class CallToActionController < ApplicationController
  
  include RewardingSystemHelper
  include CallToActionHelper
  include ApplicationHelper
  include CaptchaHelper
  include CommentHelper

  def append_comments
    append_comments_computation
  end

  def reset_redo_user_interactions
    response = reset_redo_user_interactions_computation(params)

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
    
    sidebar_tag = calltoaction.user.present? ? "sidebar-cta-gallery" : "sidebar-cta"

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

    if !anonymous_user?(current_user)
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

  def comments_polling
    append_or_update_comments(params[:interaction_id]) do |interaction, response|
      comments_without_shown = get_comments_approved_except_ids(interaction.resource.user_comment_interactions, params[:comment_ids])
      first_comment_shown_date = params[:first_updated_at] || Date.yesterday

      comments = comments_without_shown.where("date_trunc('seconds', updated_at) >= ?", first_comment_shown_date).order("updated_at DESC")
      
      comments_for_comment_info = Array.new
      comments.each do |comment|
        comments_for_comment_info << build_comment_for_comment_info(comment, true)
      end
      comments_for_comment_info
    end
  end

  def update_interaction
    response = update_interaction_computation(params)
    
    respond_to do |format|
      format.json { render :json => response.to_json }
    end
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

    extra_fields_valid, extra_field_errors, cloned_cta_extra_fields = validate_upload_extra_fields(params_obj, extra_fields)

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
