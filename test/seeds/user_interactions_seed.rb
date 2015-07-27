cta_name = "cta-for-user-interactions-testing"
cta = CallToAction.find_by_name(cta_name)

unless cta
  cta = CallToAction.create(
          name: cta_name, 
          title: cta_name, 
          slug: cta_name,
          media_type: "VOID", 
          activated_at: DateTime.yesterday
        )
end

quiz_interactions = cta.interactions.where(resource_type: "Quiz")
one_shot_present = false
not_one_shot_present = false
quiz_interactions.each do |quiz_interaction|
  if quiz_interaction.resource.one_shot
    one_shot_present = true
  else
    not_one_shot_present = true
  end
end

unless one_shot_present
  quiz_resource = Quiz.new(question: "Lorem ipsum dolor sit amet, consectetur adipiscing elit.", quiz_type: "TRIVIA", one_shot: true)

  quiz_resource.answers.build(quiz_id: quiz_resource.id, text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit.", correct: true)
  quiz_resource.answers.build(quiz_id: quiz_resource.id, text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit.", correct: false)

  quiz_resource.save
  
  quiz_interaction = Interaction.create(
    resource: quiz_resource, 
    when_show_interaction: "SEMPRE_VISIBILE",
    call_to_action_id: cta.id,
    registration_needed: false
  )
end

unless one_shot_present
  quiz_resource = Quiz.new(question: "Lorem ipsum dolor sit amet, consectetur adipiscing elit.", quiz_type: "TRIVIA", one_shot: false)

  quiz_resource.answers.build(quiz_id: quiz_resource.id, text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit.", correct: true)
  quiz_resource.answers.build(quiz_id: quiz_resource.id, text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit.", correct: false)

  quiz_resource.save
  
  quiz_interaction = Interaction.create(
    resource: quiz_resource, 
    when_show_interaction: "SEMPRE_VISIBILE",
    call_to_action_id: cta.id,
    registration_needed: false
  )
end

