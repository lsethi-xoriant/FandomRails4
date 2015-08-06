call_to_action = CallToAction.where(
  :title => "Cta with like interaction", 
  :name => "cta-with-like-interaction", 
  :slug => "cta-with-like-interaction"
).first_or_create
call_to_action.update_attribute(:activation_date_time, Time.now)

like = Like.where(
  :title => "LIKEFORTEST"
).first_or_create

interaction = Interaction.where(
  when_show_interaction: "SEMPRE_VISIBILE", 
  required_to_complete: false, 
  resource_id: like.id, 
  resource_type: "Like", 
  call_to_action_id: call_to_action.id, 
  aux: {}, 
  interaction_positioning: "UNDER_MEDIA"
).first_or_create

call_to_action