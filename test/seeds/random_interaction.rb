ctas = {}
for i in 1..5
  call_to_action = CallToAction.where(
    :title => "Cta with random interaction #{i}", 
    :name => "cta-with-random-interaction-#{i}", 
    :slug => "cta-with-random-interaction-#{i}", 
    :media_type => "IMAGE"
  ).first_or_create
  call_to_action.update_attribute(:activation_date_time, Time.now) if i == 1
  ctas.merge!({i => call_to_action})
end

random = RandomResource.where(
  :tag => "random-test"
).first_or_create

tag = Tag.where(:name => "random-test", :description => "Tag for random interaction testing").first_or_create

ctas.each do |index, cta|
  CallToActionTag.where(:call_to_action_id => cta.id, :tag_id => tag.id).first_or_create

  Interaction.where(
    when_show_interaction: "SEMPRE_VISIBILE", 
    required_to_complete: false, 
    resource_id: random.id, 
    resource_type: "RandomResource", 
    call_to_action_id: cta.id, 
    aux: {}, 
    interaction_positioning: "UNDER_MEDIA"
  ).first_or_create
end

ctas[1]