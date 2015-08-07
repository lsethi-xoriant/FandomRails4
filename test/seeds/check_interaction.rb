call_to_action = CallToAction.where(
  :title => "Cta with check interaction", 
  :name => "cta-with-check-interaction", 
  :slug => "cta-with-check-interaction"
).first_or_create
call_to_action.update_attribute(:activation_date_time, Time.now)

check = Check.where(:title => "Check for testing").first_or_create

interaction = Interaction.where(
  when_show_interaction: "SEMPRE_VISIBILE", 
  required_to_complete: true, 
  resource_id: check.id, 
  resource_type: "Check", 
  call_to_action_id: call_to_action.id, 
  aux: {}, 
  interaction_positioning: "UNDER_MEDIA"
).first_or_create

call_to_action