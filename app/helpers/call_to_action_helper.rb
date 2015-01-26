require 'fandom_utils'
require 'digest/md5'

module CallToActionHelper
  include ViewHelper

  def get_cta_active_count()
    cache_short("cta_active_count") do
      CallToAction.active.count
    end
  end

  def get_cta_max_updated_at()
    CallToAction.active.first.updated_at.strftime("%Y%m%d%H%M%S") rescue ""
  end

  def build_call_to_action_info_list(calltoactions, interactions_to_compute = nil)
    calltoaction_info_list = Array.new
    calltoactions.each do |calltoaction|

      miniformat = get_tag_with_tag_about_call_to_action(calltoaction, "miniformat").first
      if miniformat.present?
        miniformat_info = {
          "label_background" => get_extra_fields!(miniformat)["label-background"],
          "icon" => get_extra_fields!(miniformat)["icon"],
          "label_color" => get_extra_fields!(miniformat)["label-color"],
          "title" => get_extra_fields!(miniformat)["title"]
        }
      end

      flag = get_tag_with_tag_about_call_to_action(calltoaction, "flag").first
      if flag.present?
        flag_info = {
          "icon" => (get_extra_fields!(flag)["icon"]["url"] rescue nil),
        }
      end
      
      unless calltoaction.rewards.empty?
        reward = calltoaction.rewards.first
        calltoaction_reward_info = {
          "cost" => reward.cost,
          "status" => get_user_reward_status(reward)
        }
      end 

      calltoaction_info_list << {
        "calltoaction" => { 
          "id" => calltoaction.id,
          "title" => calltoaction.title,
          "description" => calltoaction.description,
          "media_type" => calltoaction.media_type,
          "media_image" => calltoaction.media_image, 
          "media_data" => calltoaction.media_data, 
          "thumbnail_url" => calltoaction.thumbnail_url,
          "thumbnail_carousel_url" => calltoaction.thumbnail(:carousel),
          "thumbnail_medium_url" => calltoaction.thumbnail(:medium),
          "interaction_info_list" => build_interaction_info_list(calltoaction, interactions_to_compute),
          "extra_fields" => (JSON.parse(calltoaction.extra_fields) rescue "{}")
        },
        "flag" => flag_info,
        "miniformat" => miniformat_info,
        "status" => compute_call_to_action_completed_or_reward_status(get_main_reward_name(), calltoaction),
        "reward_info" => calltoaction_reward_info
      }
    
    end

    return calltoaction_info_list

  end

  def build_interaction_info_list(calltoaction, interactions_to_compute)

    interaction_info_list = Array.new
    enable_interactions(calltoaction).each do |interaction|

      resource_type = interaction.resource_type.downcase

      if !interactions_to_compute || interactions_to_compute.include?(resource_type)

        resource = interaction.resource
        resource_question = resource.question rescue nil
        resource_description = resource.description rescue nil
        resource_title = resource.title rescue nil
        resource_one_shot = resource.one_shot rescue false
        resource_providers = JSON.parse(resource.providers) rescue nil

        if current_user
          user_interaction = interaction.user_interactions.find_by_user_id(current_user.id)
          if user_interaction
            user_interaction_for_interaction_info = build_user_interaction_for_interaction_info(user_interaction)
          end
        end

        
        case resource_type
        when "quiz"
          resource_type = resource.quiz_type.downcase
          answers = build_answers_for_resource(interaction, resource.answers, resource_type, user_interaction)
        when "comment"
          comment_info = build_comments_for_resource(interaction)
        when "like"
          like_info = build_likes_for_resource(interaction)
        when "upload"
          upload_info = build_uploads_for_resource(interaction)
        end

        if small_mobile_device?() && interaction.when_show_interaction.include?("OVERVIDEO")
          when_show_interaction = "SEMPRE_VISIBILE"
        else
          when_show_interaction = interaction.when_show_interaction
        end

        interaction_info_list << {
          "interaction" => {
            "id" => interaction.id,
            "when_show_interaction" => when_show_interaction,
            "overvideo_active" => false,
            "seconds" => interaction.seconds,
            "resource_type" => resource_type,
            "resource" => {
              "question" => resource_question,
              "title" => resource_title,
              "description" => resource_description,
              "one_shot" => resource_one_shot,
              "answers" => answers,
              "providers" => resource_providers,
              "comment_info" => comment_info,
              "like_info" => like_info,
              "upload_info" => upload_info
            }
          },
          "status" => get_current_interaction_reward_status(MAIN_REWARD_NAME, interaction),
          "user_interaction" => user_interaction_for_interaction_info
        }
      end

    end

    interaction_info_list

  end

  def build_user_interaction_for_interaction_info(user_interaction)
    outcome = JSON.parse(user_interaction.outcome)["win"]["attributes"] rescue nil
    user_interaction_for_interaction_info = { 
        "outcome" => outcome,
        "aux" => user_interaction.aux,
        "answer" => user_interaction.answer,
        "hash" => Digest::MD5.hexdigest("#{MD5_FANDOM_PREFIX}#{user_interaction.interaction_id}")
      }
  end

  def build_answers_for_resource(interaction, answers, resource_type, user_interaction)
    answers_for_resurce = Array.new
    answers.each do |answer|
      if resource_type == "versus" && user_interaction
        percentage = interaction_answer_percentage(interaction, answer) 
      end
      answer_correct = user_interaction ? answer.correct : false
      answers_for_resurce << {
        "id" => answer.id,
        "text" => answer.text,
        "image_medium" => answer.image(:medium),
        "correct" => answer_correct,
        "percentage" => percentage
      }
    end
    answers_for_resurce
  end

  def build_likes_for_resource(interaction)
    cache_short(get_likes_count_for_interaction_cache_key(interaction.id)) do
      interaction.user_interactions.where("(aux->>'like')::bool").count
    end
  end

  def build_comments_for_resource(interaction)
    comments, comments_total_count = get_comments_approved(interaction)

    if page_require_captcha?(interaction)
      captcha_data = generate_captcha_response
    end

    comments_for_resource = {
      "comments" => comments,     
      "comments_total_count" => comments_total_count,  
      "captcha_data" => captcha_data,
      "open" => false
    }
  end
  
  def build_uploads_for_resource(interaction)
    upload_interaction = interaction.resource
    uploads_for_resource = {
      "template_cta_id" => upload_interaction.call_to_action_id,
      "upload_number" => upload_interaction.upload_number,
      "privacy" => get_privacy_info(upload_interaction),
      "releasing" => get_releasing_info(upload_interaction)
    }
  end
  
  def get_privacy_info(upload)
    privacy_info = {
      "required" => upload.privacy?,
      "description" => upload.privacy_description
    }
  end
  
  def get_releasing_info(upload)
    privacy_info = {
      "required" => upload.releasing?,
      "description" => upload.releasing_description
    }
  end

  def generate_next_interaction_response(calltoaction, interactions_showed = nil, aux = {})
    response = Hash.new  
    interactions = calculate_next_interactions(calltoaction, interactions_showed)
    response[:next_interaction] = generate_response_for_interaction(interactions, calltoaction, aux)
    response
  end

  def page_require_captcha?(calltoaction_comment_interaction)
    return !current_user && calltoaction_comment_interaction
  end

  def always_shown_interactions(calltoaction)
    cache_short("always_shown_interactions_#{calltoaction.id}") do
      calltoaction.interactions.where("when_show_interaction = ? AND required_to_complete = ?", "SEMPRE_VISIBILE", true).order("seconds ASC").to_a
    end
  end

  def enable_interactions(calltoaction)
    cache_short("enable_interactions_#{calltoaction.id}") do
      calltoaction.interactions.includes(:resource, :call_to_action).where("when_show_interaction <> ?", "MAI_VISIBILE").to_a
    end
  end

  def get_cta_tags_from_cache(cta)
    cache_short(get_cta_tags_cache_key(cta.id)) do
      # TODO: rewrite this query as activerecord
      ActiveRecord::Base.connection.execute("select distinct(tags.name) from call_to_actions join call_to_action_tags on call_to_actions.id = call_to_action_tags.call_to_action_id join tags on tags.id = call_to_action_tags.tag_id where call_to_actions.id = #{cta.id}").map { |row| row['name'] }
    end
  end
  
  def interactions_required_to_complete(cta)
    cache_short get_interactions_required_to_complete_cache_key(cta.id) do
      cta.interactions.includes(:resource, :call_to_action).where("required_to_complete AND when_show_interaction <> 'MAI_VISIBILE'").order("seconds ASC").to_a
    end
  end

  def generate_response_for_interaction(interactions, calltoaction, aux = {}, outcome = nil)
    next_quiz_interaction = interactions.first
    if next_quiz_interaction
      index_current_interaction = calculate_interaction_index(calltoaction, next_quiz_interaction)
      shown_interactions = always_shown_interactions(calltoaction)
      if shown_interactions.count > 1
        shown_interactions_count = shown_interactions.count 
        aux[:shown_interactions_count] = shown_interactions_count
      end
      aux[:next_interaction_present] = (interactions.count > 1)
      render_interaction_str = render_to_string "/call_to_action/_undervideo_interaction", locals: { interaction: next_quiz_interaction, ctaid: next_quiz_interaction.call_to_action.id, outcome: outcome, shown_interactions_count: shown_interactions_count, index_current_interaction: index_current_interaction, aux: aux }, layout: false, formats: :html
      interaction_id = next_quiz_interaction.id
    else
      render_interaction_str = render_to_string "/call_to_action/_end_for_interactions", locals: { quiz_interactions: interactions, calltoaction: calltoaction, aux: aux }, layout: false, formats: :html
    end
    
    response = Hash.new
    response = {
      next_quiz_interaction: (interactions.count > 1),
      render_interaction_str: render_interaction_str,
      interaction_id: interaction_id
    }
  end
  
  def calculate_next_interactions(calltoaction, interactions_showed_ids)         
    if interactions_showed_ids
      interactions_showed_id_qmarks = (["?"] * interactions_showed_ids.count).join(", ")
      calltoaction.interactions.where("when_show_interaction = ? AND required_to_complete = ? AND id NOT IN (#{interactions_showed_id_qmarks})", "SEMPRE_VISIBILE", true, *interactions_showed_ids)
                                                   .order("seconds ASC")
    else
      calltoaction.interactions.where("when_show_interaction = ? AND required_to_complete = ?", "SEMPRE_VISIBILE", true)
                                                   .order("seconds ASC")
    end
  end

  def calculate_interaction_index(calltoaction, interaction)
    cache_short("interaction_#{interaction.id}_index_in_calltoaction") do
      calltoaction.interactions.where("when_show_interaction = ? AND required_to_complete = ? AND seconds <= ?", "SEMPRE_VISIBILE", true, interaction.seconds)
                                                   .order("seconds ASC").count
    end
  end

  def get_cta_template_option_list
    CallToAction.includes({:call_to_action_tags => :tag}).where("tags.name ILIKE 'template'").map{|cta| [cta.title, cta.id]}
  end
  
  def clone_and_create_cta(upload_interaction, params, watermark)
    calltoaction_template = upload_interaction.call_to_action
    cta_title = calculate_cloned_cta_title(upload_interaction, calltoaction_template, params)
    user_calltoaction = duplicate_user_generated_cta(params, watermark, cta_title)

    calltoaction_template.interactions.each do |i|
      duplicate_interaction(user_calltoaction, i)
    end

    calltoaction_template.call_to_action_tags.each do |tag|
      duplicate_cta_tag(user_calltoaction, tag)
    end

      user_calltoaction.release_required = upload_interaction.releasing? 
      user_calltoaction.build_releasing_file(file: params[:releasing])

      user_calltoaction.privacy_required = upload_interaction.privacy? 
      user_calltoaction.privacy = !params[:privacy].blank?

      #user_calltoaction.releasing_file_id = releasing.id

    user_calltoaction
  end
  
  def calculate_cloned_cta_title(upload_interaction, calltoaction_template, params)
    if upload_interaction.title_needed && params[:title].blank?
      nil
    elsif upload_interaction.title_needed && params[:title].present?
      params[:title]
    else
      calltoaction_template.title
    end
  end
  
  def duplicate_user_generated_cta(params, watermark, cta_title)

    user_calltoaction = CallToAction.new(
        title: cta_title, 
        name: generate_unique_name(), 
        user_id: current_user.id,
        media_image: params["upload"],
        media_type: "IMAGE"
        )

    if watermark.exists?
      if watermark.url.start_with?("http")
        user_calltoaction.interaction_watermark_url = watermark.url(:normalized)
      else
        user_calltoaction.interaction_watermark_url = watermark.path(:normalized)
      end
    end
    user_calltoaction
  end
  
  def generate_unique_name
    duplicated = true
    i = 0
    while duplicated && i < 5 do
      name = Digest::MD5.hexdigest("#{current_user.id}#{Time.now}")[0..8]
      if CallToAction.find_by_name(name).nil?
        duplicated = false
      end
      i += 1
    end
    "UGC_" + name
  end
  
  def clone_cta(params)
    old_cta = CallToAction.find(params[:id])
    new_cta = duplicate_cta(old_cta.id)
    old_cta.interactions.each do |i|
      duplicate_interaction(new_cta,i)
    end
    old_cta.call_to_action_tags.each do |tag|
      duplicate_cta_tag(new_cta, tag)
    end
    @cta = new_cta
    tag_array = Array.new
    @cta.call_to_action_tags.each { |t| tag_array << t.tag.name }
    @tag_list = tag_array.join(",")
    render template: "/easyadmin/call_to_action/new_cta"
  end
  
  def duplicate_cta(old_cta_id)
    cta = CallToAction.find(old_cta_id)
    cta.title = "Copy of " + cta.title
    cta.name = "copy-of-" + cta.name
    cta.activated_at = DateTime.now
    cta_attributes = cta.attributes
    cta_attributes.delete("id")
    CallToAction.new(cta_attributes, :without_protection => true)
  end
  
  def duplicate_interaction(new_cta, interaction)
    interaction_attributes = interaction.attributes
    interaction_attributes.delete("id")
    interaction_attributes.delete("rescource_type")
    interaction_attributes.delete("resource")
    new_interaction = new_cta.interactions.build(interaction_attributes, :without_protection => true)
    resource_attributes = interaction.resource.attributes
    resource_attributes.delete("id")
    resource_type = interaction.resource_type
    if resource_type == "Play"
      resource_attributes["title"] = "#{interaction.resource.attributes["title"][0..12]}T#{Time.now.strftime("%H%M")}"
    end
    resource_model = get_model_from_name(resource_type)
    new_interaction.resource = resource_model.new(resource_attributes, :without_protection => true)
    new_resource = new_interaction.resource 
    if resource_type == "Quiz"
      duplicate_quiz_answers(new_resource,interaction.resource)
    end
  end
  
  def duplicate_quiz_answers(new_quiz, old_quiz)
    old_quiz.answers.each do |a|
      answer_attributes = a.attributes
      answer_attributes.delete("id")
      new_quiz.answers.build(answer_attributes, :without_protection => true)
    end
  end
  
  def duplicate_cta_tag(new_cta, tag)
    unless tag.tag.name.downcase == "template"
      new_cta.call_to_action_tags.build(:call_to_action_id => new_cta.id, :tag_id => tag.tag_id)
    end
  end
  
  def get_max_upload_size
    MAX_UPLOAD_SIZE * BYTES_IN_MEGABYTE
  end
  
  def is_call_to_action_gallery(calltoaction)
    return has_tag_recursive(calltoaction.call_to_action_tags.map{|c| c.tag}, "gallery")
  end
  
  def has_tag_recursive(tags, tag_name)
    tags.each do |t|
      if t.name == tag_name
        return true
      end
      result = has_tag_recursive(t.tags_tags.map{ |parent_tag| parent_tag.other_tag}, tag_name)
      if result
        return result
      end
    end
    return false
  end
  
  def cta_is_a_reward(cta)
    cache_short("cta_#{cta.id}_is_a_reward") do
      cta.rewards.any?
    end
  end
  
  def cta_locked?(cta)
    cta_is_a_reward(cta) && !cta_is_unlocked(cta)
  end
  
  def cta_is_unlocked(cta)
    unlocked = false
    cta.rewards.each do |r|
      if user_has_reward(r.name)
        unlocked = true
        break
      end
    end
    unlocked
  end
  
  def has_done_share_interaction(calltoaction)
    share_interactions = get_share_from_calltoaction(calltoaction)
    if share_interactions.any?
      interaction = share_interactions.first
      if current_user
        [current_user.user_interactions.find_by_interaction_id(interaction.id), interaction]
      else
        [nil, interaction]
      end
    else
      [nil, nil]
    end
  end
  
  def get_share_from_calltoaction(calltoaction)
    cache_short("share_interaction_cta_#{calltoaction.id}") do
      calltoaction.interactions.where("when_show_interaction = 'SEMPRE_VISIBILE' AND resource_type = 'Share'").to_a
    end
  end
  
  def get_random_cta_by_tag(tag_name)
    get_ctas_with_tag(tag_name).sample
  end
  
  def get_random_cta_by_tags(*tags_name)
    get_ctas_with_tags(tags_name).sample
  end
  
  def get_number_of_comments_for_cta(cta)
    cache_short(get_comments_count_for_cta_key(cta.id)) do
      comment_interaction = cta.interactions.find_by_resource_type("Comment")
      if comment_interaction
        comment_interaction.resource.user_comment_interactions.where("approved = true").count
      else
        0
      end
    end
  end
  
  def get_number_of_likes_for_cta(cta)
    cache_short(get_likes_count_for_cta_key(cta.id)) do
      like_interaction = cta.interactions.find_by_resource_type("Like")
      if like_interaction
        build_likes_for_resource(like_interaction)
      else
        0
      end
    end
  end
  
end
