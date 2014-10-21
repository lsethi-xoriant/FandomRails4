require 'fandom_utils'
require 'digest/md5'

module CallToActionHelper

  def generate_next_interaction_response(calltoaction, interactions_showed = nil)
    response = Hash.new  
    interactions = calculate_next_interactions(calltoaction, interactions_showed)
    response[:next_interaction] = generate_response_for_next_interaction(interactions, calltoaction)
    response
  end

  def get_cta_active_count()
    cache_short("cta_active_count") do
      CallToAction.active.count
    end
  end

  def page_require_captcha?(calltoaction_comment_interaction)
    return !current_user && calltoaction_comment_interaction
  end

  def always_shown_interactions(calltoaction)
    cache_short("always_shown_interactions_#{calltoaction.id}") do
      calltoaction.interactions.where("when_show_interaction = ? AND required_to_complete = ?", "SEMPRE_VISIBILE", true).order("seconds ASC").to_a
    end
  end

  def get_cta_tags_from_cache(cta)
    cache_short(get_cta_tags_cache_key(cta.id)) do
      cta.tags.includes("tag_fields").to_a
    end
  end
  
  def interactions_required_to_complete(cta)
    cache_short get_interactions_required_to_complete_cache_key(cta.id) do
      cta.interactions.includes(:call_to_action, :resource).where("required_to_complete AND when_show_interaction <> 'MAI_VISIBILE'").order("seconds ASC").to_a
    end
  end

  def generate_response_for_next_interaction(quiz_interactions, calltoaction)
    next_quiz_interaction = quiz_interactions.first

    if next_quiz_interaction
      index_current_interaction = calculate_interaction_index(calltoaction, next_quiz_interaction)
      shown_interactions = always_shown_interactions(calltoaction)
      shown_interactions_count = shown_interactions.count if shown_interactions.count > 1
      render_interaction_str = render_to_string "/call_to_action/_undervideo_interaction", locals: { interaction: next_quiz_interaction, ctaid: next_quiz_interaction.call_to_action.id, outcome: nil, shown_interactions_count: shown_interactions_count, index_current_interaction: index_current_interaction }, layout: false, formats: :html
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
    user_calltoaction = duplicate_user_generated_cta(params, watermark)

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
  
  def duplicate_user_generated_cta(params, watermark)

    user_calltoaction = CallToAction.new(
        title: params[:title], 
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
  
end
