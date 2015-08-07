call_to_action = CallToAction.where(
  :title => "Cta with comment interaction", 
  :name => "cta-with-comment-interaction", 
  :slug => "cta-with-comment-interaction"
).first_or_create
call_to_action.update_attribute(:activation_date_time, Time.now)

comment = Comment.where(
  :must_be_approved => true, 
  :title => "Comment for testing"
).first_or_create

interaction = Interaction.where(
  when_show_interaction: "SEMPRE_VISIBILE", 
  required_to_complete: false, 
  resource_id: comment.id, 
  resource_type: "Comment", 
  call_to_action_id: call_to_action.id, 
  aux: {}, 
  interaction_positioning: "UNDER_MEDIA"
).first_or_create

call_to_action