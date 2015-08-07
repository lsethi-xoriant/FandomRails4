call_to_action = CallToAction.where(
  :title => "Cta with trivia interaction", 
  :name => "cta-with-trivia-interaction", 
  :slug => "cta-with-trivia-interaction"
).first_or_create
call_to_action.update_attribute(:activation_date_time, Time.now)

trivia = Quiz.where(
  :question => "Question for trivia testing", 
  :one_shot => true
).first_or_create

interaction = Interaction.where(
  when_show_interaction: "SEMPRE_VISIBILE", 
  required_to_complete: true, 
  resource_id: trivia.id, 
  resource_type: "Quiz", 
  call_to_action_id: call_to_action.id, 
  aux: {}, 
  interaction_positioning: "UNDER_MEDIA"
).first_or_create

correct_answer = Answer.where(
  :quiz_id => trivia.id, 
  :text => "Right", 
  :correct => true, 
  :call_to_action_id => nil, 
  :media_data => "", 
  :media_type => "VOID", 
  :blocking => false
).first_or_create

wrong_answer_1 = Answer.where(
  :quiz_id => trivia.id, 
  :text => "Wrong 1", 
  :correct => false, 
  :call_to_action_id => nil, 
  :media_data => "", 
  :media_type => "VOID", 
  :blocking => false
).first_or_create

wrong_answer_2 = Answer.where(
  :quiz_id => trivia.id, 
  :text => "Wrong 2", 
  :correct => false, 
  :call_to_action_id => nil, 
  :media_data => "", 
  :media_type => "VOID", 
  :blocking => false
).first_or_create

trivia.update_attribute(:quiz_type, "TRIVIA")

call_to_action