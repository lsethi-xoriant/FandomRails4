call_to_action = CallToAction.where(
  :title => "Cta with versus interaction", 
  :name => "cta-with-versus-interaction", 
  :slug => "cta-with-versus-interaction"
).first_or_create
call_to_action.update_attribute(:activation_date_time, Time.now)

versus = Quiz.where(
  :question => "Question for versus testing", 
  :one_shot => true
).first_or_create

interaction = Interaction.where(
  when_show_interaction: "SEMPRE_VISIBILE", 
  required_to_complete: true, 
  resource_id: versus.id, 
  resource_type: "Quiz", 
  call_to_action_id: call_to_action.id, 
  aux: {}, 
  interaction_positioning: "UNDER_MEDIA"
).first_or_create

first_answer = Answer.where(
  :quiz_id => trivia.id, 
  :text => "One", 
  :correct => nil, 
  :call_to_action_id => nil, 
  :media_data => "", 
  :media_type => "VOID", 
  :blocking => false
).first_or_create

second_answer = Answer.where(
  :quiz_id => trivia.id, 
  :text => "Two", 
  :correct => nil, 
  :call_to_action_id => nil, 
  :media_data => "", 
  :media_type => "VOID", 
  :blocking => false
).first_or_create

third_answer = Answer.where(
  :quiz_id => trivia.id, 
  :text => "Three", 
  :correct => nil, 
  :call_to_action_id => nil, 
  :media_data => "", 
  :media_type => "VOID", 
  :blocking => false
).first_or_create

forth_answer = Answer.where(
  :quiz_id => trivia.id, 
  :text => "Four", 
  :correct => nil, 
  :call_to_action_id => nil, 
  :media_data => "", 
  :media_type => "VOID", 
  :blocking => false
).first_or_create

trivia.update_attribute(:quiz_type, "VERSUS")

call_to_action