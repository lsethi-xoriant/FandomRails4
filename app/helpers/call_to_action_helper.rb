require 'fandom_utils'
require 'digest/md5'

module CallToActionHelper
  include ViewHelper

  def cta_url(cta)
    if $context_root
      "/#{$context_root}/call_to_action/#{cta.slug}"
    else 
      "/call_to_action/#{cta.slug}"
    end
  end

  def get_cta_active_count()
    cache_short("cta_active_count") do
      CallToAction.active.count
    end
  end

  def get_cta_max_updated_at()
    CallToAction.active.first.updated_at.strftime("%Y%m%d%H%M%S") rescue ""
  end

  def build_default_thumb_calltoaction(calltoaction, thumb_format = :thumb)   
    {
      "attributes" => {
        "id" => calltoaction.id,
        "detail_url" => cta_url(calltoaction),
        "status" => compute_call_to_action_completed_or_reward_status(get_main_reward_name(), calltoaction),
        "thumb_url" => calltoaction.thumbnail(thumb_format),
        "title" => calltoaction.title,
        "description" => calltoaction.description,
        "type" => "cta",
        "aux" => {
          "miniformat" => build_grafitag_for_calltoaction(calltoaction, "miniformat"),
          "flag" => build_grafitag_for_calltoaction(calltoaction, "flag")
        }
      }
    }
  end

  def build_grafitag_for_tag(tag, tag_name)
    grafitag = get_tag_with_tag_about_tag(tag, tag_name).first
    if grafitag.present?
      build_grafitag(grafitag)
    else
      nil
    end
  end

  def build_grafitag_for_calltoaction(calltoaction, tag_name)
    grafitag = get_tag_with_tag_about_call_to_action(calltoaction, tag_name).first
    if grafitag.present?
      build_grafitag(grafitag)
    else
      nil
    end
  end

  def build_grafitag(grafitag)
    {
      "label_background" => get_extra_fields!(grafitag)["label-background"],
      "icon" => get_extra_fields!(grafitag)["icon"],
      "image" => (get_extra_fields!(grafitag)["image"]["url"] rescue nil),
      "label_color" => get_extra_fields!(grafitag)["label-color"] || "#fff",
      "title" => grafitag.title,
      "name" => grafitag.name
    }
  end

  def build_call_to_action_info_list(calltoactions, interactions_to_compute = nil)

    calltoaction_ids = calltoactions.map { |calltoaction| calltoaction.id }
    interactions_to_compute_key = interactions_to_compute.present? ? interactions_to_compute.join("-") : "all"

    calltoaction_info_list_and_interactions = cache_short(get_calltoactions_info_cache_key(calltoaction_ids.join("-"), interactions_to_compute_key)) do
      
      calltoaction_info_list = Array.new
      interactions = {}
      interaction_id_to_answers = {}

      calltoactions.each do |calltoaction|
    
        interaction_info_list, interactions_for_calltoaction, interaction_id_to_answers_for_calltoaction = build_interaction_info_list(calltoaction, interactions_to_compute)
        interactions_for_calltoaction.each do |key, value|
          interactions[key] = value
        end
        interaction_id_to_answers_for_calltoaction.each do |key, value|
          interaction_id_to_answers[key] = value
        end

        reward = Reward.includes(:currency).where(call_to_action_id: calltoaction.id).first
        if reward.present?
          calltoaction_reward_info = {
            "cost" => reward.cost,
            "status" => "locked",
            "has_currency" => false,
            "reward" => reward,
            "id" => reward.id          
          }
        end

        if calltoaction.user.present?
          user_name = calltoaction.user.username
          user_user_avatar = user_avatar(calltoaction.user)
        end

        calltoaction_info = {
            "calltoaction" => { 
              "id" => calltoaction.id,
              "name" => calltoaction.name,
              "slug" => calltoaction.slug,
              "detail_url" => cta_url(calltoaction),
              "title" => calltoaction.title,
              "description" => calltoaction.description,
              "media_type" => calltoaction.media_type,
              "media_image" => calltoaction.media_image(:extra_large), 
              "media_data" => calltoaction.media_data, 
              "thumbnail_url" => calltoaction.thumbnail_url,
              "thumbnail_carousel_url" => calltoaction.thumbnail(:carousel),
              "thumbnail_medium_url" => calltoaction.thumbnail(:medium),
              "interaction_info_list" => interaction_info_list,
              "extra_fields" => (JSON.parse(calltoaction.extra_fields) rescue "{}"),
              "activated_at" => calltoaction.activated_at,
              "user_id" => calltoaction.user_id,
              "user_name" => user_name,
              "user_avatar" => user_user_avatar
            },
            "flag" => build_grafitag_for_calltoaction(calltoaction, "flag"),
            "miniformat" => build_grafitag_for_calltoaction(calltoaction, "miniformat"),
            "status" => compute_call_to_action_completed_or_reward_status(get_main_reward_name(), calltoaction, anonymous_user),
            "reward_info" => calltoaction_reward_info
        }

        calltoaction_info_list << calltoaction_info

      end

      result = { calltoaction_info_list: calltoaction_info_list , interactions: interactions, interaction_id_to_answers: interaction_id_to_answers }
      # This hack is needed to avoid a strange "@new_record" string being serialized instead of an object id
      # Marshal.dump(result)  
      result

    end

    calltoaction_info_list, interactions, interaction_id_to_answers = calltoaction_info_list_and_interactions[:calltoaction_info_list], 
                                                                      calltoaction_info_list_and_interactions[:interactions],
                                                                      calltoaction_info_list_and_interactions[:interaction_id_to_answers]                                                         

    if current_user
      calltoaction_info_list_for_current_user = [] 
      calltoaction_info_list.each do |calltoaction_info|

        interaction_info_list = []
        calltoaction = find_in_calltoactions(calltoactions, calltoaction_info["calltoaction"]["id"])

        if calltoaction_info["reward_info"]
          reward = calltoaction_info["reward_info"]["reward"]
          calltoaction_info["reward_info"] = {
            "cost" => reward.cost,
            "status" => get_user_reward_status(reward),
            "id" => reward.id,
          }
        end

        user_interactions = UserInteraction.where(interaction_id: interactions.keys, user_id: current_user.id)
        calltoaction_info["calltoaction"]["interaction_info_list"].each do |interaction_info|
          interaction = interactions[interaction_info["interaction"]["id"]]
          user_interaction = find_in_user_interactions(user_interactions, interaction.id)
          if user_interaction
            user_interaction_for_interaction_info = build_user_interaction_for_interaction_info(user_interaction)
            answers = interaction_id_to_answers[interaction.id]
            if answers
              resource_type = interaction_info["interaction"]["resource_type"]
              interaction_info["interaction"]["resource"]["answers"] = build_answers_for_resource(interaction, answers, resource_type, user_interaction)
            end
          end
          interaction_info["user_interaction"] = user_interaction_for_interaction_info
          interaction_info["status"] = get_current_interaction_reward_status(MAIN_REWARD_NAME, interaction)
          interaction_info_list << interaction_info
        end
        calltoaction_info["status"] = compute_call_to_action_completed_or_reward_status(get_main_reward_name(), calltoaction, current_user)
        calltoaction_info["calltoaction"]["interaction_info_list"] = interaction_info_list
        calltoaction_info_list_for_current_user << calltoaction_info
      end
      calltoaction_info_list = calltoaction_info_list_for_current_user
    end
    calltoaction_info_list
  end

  def find_in_calltoactions(calltoactions, calltoaction_id)
    calltoaction_to_return = nil
    calltoactions.each do |calltoaction|
      if calltoaction.id == calltoaction_id
        calltoaction_to_return = calltoaction 
      end
    end
    calltoaction_to_return
  end

  def find_in_user_interactions(user_interactions, interaction_id)
    user_interaction_to_return = nil
    user_interactions.each do |user_interaction|
      if user_interaction.interaction_id == interaction_id
        user_interaction_to_return = user_interaction 
      end
    end
    user_interaction_to_return
  end

  def build_interaction_info_list(calltoaction, interactions_to_compute)

    interaction_info_list = Array.new
    interactions = {}
    interaction_id_to_answers = {}

    enable_interactions(calltoaction).each do |interaction|

      resource_type = interaction.resource_type.downcase

      if !interactions_to_compute || interactions_to_compute.include?(resource_type)

        interactions[interaction.id] = interaction

        resource = interaction.resource
        resource_question = resource.question rescue nil
        resource_description = resource.description rescue nil
        resource_title = resource.title rescue nil
        resource_one_shot = resource.one_shot rescue false
        resource_providers = JSON.parse(resource.providers) rescue nil
        resource_url = resource.url rescue "/"

        if ($site.anonymous_interaction && interaction.stored_for_anonymous)
          user_interaction = interaction.user_interactions.find_by_user_id(current_or_anonymous_user.id)
          if user_interaction
            anonymous_user_interaction_info = build_user_interaction_for_interaction_info(user_interaction)
          end
        end

        case resource_type
        when "quiz"
          resource_type = resource.quiz_type.downcase
          resource_answers = resource.answers
          answers = build_answers_for_resource(interaction, resource_answers, resource_type, user_interaction)
          interaction_id_to_answers[interaction.id] = resource_answers
        when "comment"
          comment_info = build_comments_for_resource(interaction)
        when "like"
          like_info = build_likes_for_resource(interaction)
        when "upload"
          upload_info = build_uploads_for_resource(interaction)
        when "vote"
          vote_info = build_votes_for_resource(interaction)
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
              "upload_info" => upload_info,
              "vote_info" => vote_info,
              "url" => resource_url
            }
          },
          "status" => get_current_interaction_reward_status(MAIN_REWARD_NAME, interaction, nil),
          "user_interaction" => nil,
          "anonymous_user_interaction_info" => anonymous_user_interaction_info
        }
      end

    end

    [interaction_info_list, interactions, interaction_id_to_answers]

  end

  def build_user_interaction_for_interaction_info(user_interaction)
    outcome = JSON.parse(user_interaction.outcome)["win"]["attributes"] rescue nil
    user_interaction_for_interaction_info = {
        "id" => user_interaction.id,
        "outcome" => outcome,
        "aux" => user_interaction.aux,
        "interaction_id" => user_interaction.interaction_id,
        "answer" => user_interaction.answer,
        "hash" => Digest::MD5.hexdigest("#{MD5_FANDOM_PREFIX}#{user_interaction.interaction_id}")
      }
  end

  def build_answers_for_resource(interaction, answers, resource_type, user_interaction)
    answers_for_resource = Array.new
    answers.each do |answer|
      if resource_type == "versus" && user_interaction
        percentage = interaction_answer_percentage(interaction, answer) 
      end
      answer_correct = user_interaction ? answer.correct : false
      answers_for_resource << {
        "id" => answer.id,
        "text" => answer.text,
        "aux" => answer.aux,
        "image_medium" => answer.image(:medium),
        "correct" => answer_correct,
        "percentage" => percentage
      }
    end
    answers_for_resource
  end

  def build_votes_for_resource(interaction)
    {
      min: interaction.resource.vote_min,
      max: interaction.resource.vote_max,
      total: get_cta_vote_info(interaction.id)['total']
    } 
  end

  def build_likes_for_resource(interaction)
    cache_short(get_likes_count_for_interaction_cache_key(interaction.id)) do
      interaction.user_interactions.where("(aux->>'like')::bool").count
    end
  end

  def build_comments_for_resource(interaction)
    comments, comments_total_count = get_comments_approved(interaction)

    #if page_require_captcha?(interaction)
    #  captcha_data = generate_captcha_response
    #end

    comments_for_resource = {
      "comments" => comments,     
      "comments_total_count" => comments_total_count,  
      #"captcha_data" => captcha_data,
      "open" => false
    }
  end
  
  def build_uploads_for_resource(interaction)
    upload_interaction = interaction.resource
    uploads_for_resource = {
      "template_cta_id" => upload_interaction.call_to_action_id,
      "upload_number" => upload_interaction.upload_number,
      "privacy" => get_privacy_info(upload_interaction),
      "releasing" => get_releasing_info(upload_interaction),
      "title_needed" => upload_interaction.title_needed
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
    cta_description = calculate_cloned_cta_description(upload_interaction, calltoaction_template, params)
    user_calltoaction = duplicate_user_generated_cta(params, watermark, cta_title, cta_description)

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
  
  def calculate_cloned_cta_description(upload_interaction, calltoaction_template, params)
    if params[:description].blank?
      calltoaction_template.description
    else
      params[:description]
    end
  end
  
  def duplicate_user_generated_cta(params, watermark, cta_title, description)
    unique_name = generate_unique_name()

    user_calltoaction = CallToAction.new(
        title: cta_title,
        description: description,
        name: unique_name,
        slug: unique_name, 
        user_id: current_user.id,
        media_image: params["upload"],
        thumbnail: (params["upload"] if params["upload"].content_type =~ %r{^(image|(x-)?application)/(x-png|pjpeg|jpeg|jpg|png|gif)$}),
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

  def generate_unique_name_for_interaction
    duplicated = true
    i = 0
    while duplicated && i < 5 do
      name = Digest::MD5.hexdigest("#{current_user.id}#{Time.now}")[0..8]
      if Interaction.find_by_name(name).nil?
        duplicated = false
      end
      i += 1
    end
    "UGC_" + name
  end

  def clone_cta(old_cta_id)
    old_cta = CallToAction.find(old_cta_id)
    new_cta = duplicate_cta(old_cta_id)
    old_cta.interactions.each do |i|
      duplicate_interaction(new_cta, i)
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

  def clone_linking_cta(old_cta_id)
    @current_cta = CallToAction.find(old_cta_id)
    if params[:commit] == "SALVA"
      ActiveRecord::Base.transaction do
        begin
          @cloned_cta_map = { @current_cta.name => { "title" => params[:cloned_cta_title], 
                                                      "name" => params[:cloned_cta_name],
                                                      "slug" => params[:cloned_cta_slug] } 
                            }.merge(params[:cloned_cta])
          cloned_interactions_map = {}
          @cloned_cta_map.each do |old_cta_name, new_params|
            old_cta = CallToAction.find_by_name(old_cta_name)
            new_cta = duplicate_cta(old_cta.id)
            old_cta.interactions.each do |i|
              new_interaction = duplicate_interaction(new_cta, i)
              cloned_interactions_map[i.id] = new_interaction
            end
            old_cta.call_to_action_tags.each do |tag|
              duplicate_cta_tag(new_cta, tag)
            end
            new_cta.title = new_params["title"]
            new_cta.name = new_params["name"]
            new_cta.slug = new_params["slug"]
            new_cta.save
          end
          duplicate_interaction_call_to_actions(@cloned_cta_map, cloned_interactions_map)
        rescue Exception => e
          flash[:error] = "Errore: #{e}"
          raise ActiveRecord::Rollback
        end
        flash[:notice] = "CallToAction '#{@current_cta.name}' e collegate clonate con successo"
      end
    else
      @linked_cta_set = Set.new
      @trees = [[@current_cta]]
      next_call_to_action_linked_to(@current_cta, @trees)
      @linked_cta_set = build_linked_cta_attr_set(@current_cta, @trees)
    end
    render :template => "/easyadmin/call_to_action/clone_linked_cta"
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

  def duplicate_interaction_call_to_actions(cloned_cta_map, cloned_interactions_map)
    cloned_cta_map.each do |old_cta_name, new_params|
      old_cta = CallToAction.find_by_name(old_cta_name)
      old_cta.interactions.each do |old_interaction|
        old_interaction_id = old_interaction.id
        InteractionCallToAction.where(:interaction_id => old_interaction_id).each do |old_icta|
          new_icta = InteractionCallToAction.new(
            :interaction_id => cloned_interactions_map[old_interaction_id].id, 
            :call_to_action_id => CallToAction.find_by_name(cloned_cta_map[CallToAction.find(old_icta.call_to_action_id).name]["name"]).id
            )
          new_icta.save
        end
      end
    end
  end

  def duplicate_interaction(new_cta, interaction)
    interaction_attributes = interaction.attributes
    interaction_attributes.delete("id")
    interaction_attributes.delete("name")
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
    new_interaction
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
      new_cta.call_to_action_tags.build(:tag_id => tag.tag_id)
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

  def get_votes_thumb_for_cta(cta) 
    cache_short(get_votes_count_for_cta_key(cta.id)) do
      interaction = cta.interactions.find_by_resource_type("Vote")
      if interaction
        build_votes_for_resource(interaction)
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

  def get_votes_for_cta(cta_id)
    result = UserInteraction.select("SUM((aux->>'vote')::int) as votes").where("(aux->>'call_to_action_id')::int = ?", cta_id).first
    if result.votes.blank?
      nil
    else
      result.votes
    end
  end

  def is_linking?(cta_id)
    CallToAction.find(cta_id).interactions.each do |interaction|
      return true if InteractionCallToAction.find_by_interaction_id(interaction.id)
    end
    false
  end

  def is_linked?(cta_id)
    return true if InteractionCallToAction.find_by_call_to_action_id(cta_id)
    false
  end

  def build_html_jstree(tree_array, current_cta_id = 0)
    res = ""
    unless tree_array.nil?
      tree_array.each_with_index do |tree, i|
        res += i == 0 ? "<div id='tree#{i}' class='tree'>" : "<hr/><div id='tree#{i}' class='tree'>"
        tree.each do |cta|
          icon = cta.id == current_cta_id ? "fa fa-circle" : "fa fa-long-arrow-right"
          res += "<ul><li data-jstree='{\"icon\":\"#{icon}\"}'>#{cta.name}</ul>"
        end
        res += "</div>"
      end
    end
    res.html_safe
  end

  def build_tree(cta)
    begin
      res = [[cta]]
      next_call_to_action_linked_to(cta, res)
      previous_call_to_action_linked_to(cta, res)
      return res
    rescue
      message = "Hai introdotto un ciclo di call to action collegate: "
      res.each_with_index do |path, index|
        message += "Albero #{index + 1} ---> "
        path.each_with_index do |cta, i|
          if i == path.size - 1 
            message += "'#{cta.name}'. "
          else
            message += "'#{cta.name}' - "
          end
        end
      end
      cta.errors.add(:base, message)
      return [[cta]]
    end
  end

  def build_linked_cta_attr_set(root_cta, trees)
    linked_cta_set = Set.new
    trees.each do |cta_tree|
      cta_tree.each do |cta|
        linked_cta_set << { "title" => cta.title, "name" => cta.name, "slug" => cta.slug } unless cta.name == root_cta.name
      end
    end
    return linked_cta_set
  end

  def next_call_to_action_linked_to(cta, res)
    return if cta.interactions.nil?
    cta.interactions.each do |interaction|
      next_call_to_actions = InteractionCallToAction.where(:interaction_id => interaction.id).pluck(:call_to_action_id)
      if next_call_to_actions.any?
        old_res = res.dup
        next_call_to_actions.each_with_index do |cta_id, i|
          next_cta = CallToAction.find(cta_id)
          res[i] = old_res[0] + [next_cta]
          if res[i][0].id == cta_id
            raise "Cycle detected"
          end
        end
        res.each_with_index do |path, i|
          next_call_to_action_linked_to(res[i][-1], res)
        end
      end
    end
  end

  def previous_call_to_action_linked_to(cta, res)
    previous_interactions = InteractionCallToAction.where(:call_to_action_id => cta.id).pluck(:interaction_id)
    return if previous_interactions.blank?
    old_res = res.dup
    previous_interactions.each_with_index do |interaction_id, i|
      previous_cta = CallToAction.find(Interaction.find(interaction_id).call_to_action_id)
      res[i] = [previous_cta] + old_res[0]
    end
    res.each_with_index do |path, i|
      previous_call_to_action_linked_to(res[i][0], res)
    end
  end

  def save_interaction_call_to_action_linking(params, cta)
    ActiveRecord::Base.transaction do
      interaction_attributes = params["interactions_attributes"]
      interaction_attributes.each do |key, interaction_attribute|
        InteractionCallToAction.where(:interaction_id => interaction_attribute["id"]).destroy_all
        unless interaction_attribute["resource_attributes"]["linked_cta"].nil?
          interaction_attribute["resource_attributes"]["linked_cta"].each do |key, link|
            InteractionCallToAction.create(:interaction_id => interaction_attribute["id"], :call_to_action_id => link["cta_id"], :condition => { "more" => link["condition"] }.to_json )
          end
        end
      end
      build_tree(cta)
      if cta.errors.any?
        raise ActiveRecord::Rollback
      end
    end
    return cta.errors.empty?
  end

end
