require 'fandom_utils'
require 'digest/md5'

module CallToActionHelper
  
  def call_to_action_completed?(cta, user)
    all_interactions = cta.interactions.where("required_to_complete")
    interactions_done = all_interactions.includes(:user_interactions).where("user_interactions.user_id = ?", user.id)
    all_interactions.any? && (all_interactions.count == interactions_done.count)
  end
  
  def get_cta_template_option_list
    CallToAction.includes({:call_to_action_tags => :tag}).where("tags.name ILIKE 'template'").map{|cta| [cta.title, cta.id]}
  end
  
  def clone_and_create_cta(params, upload_file_index)
    old_cta = CallToAction.find(params[:template_cta_id])
    new_cta = duplicate_user_generated_cta(old_cta.id, params, upload_file_index)
    old_cta.interactions.each do |i|
      duplicate_interaction(new_cta,i)
    end
    old_cta.call_to_action_tags.each do |tag|
      duplicate_cta_tag(new_cta, tag)
    end
    new_cta.save
    new_cta
  end
  
  def duplicate_user_generated_cta(old_cta_id, params, upload_file_index)
    cta = CallToAction.find(old_cta_id)
    cta.user_generated = true
    cta.activated_at = nil
    cta.name = generate_unique_name()
    cta_attributes = cta.attributes
    cta_attributes.delete("id")
    cta = CallToAction.new(cta_attributes, :without_protection => true)
    cta.media_image = params["upload-#{upload_file_index}"]
    cta
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
  
end
