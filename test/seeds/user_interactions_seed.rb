cta = CallToAction.find_by_name(CTA_TEST_NAME)

unless cta
  cta = CallToAction.create(
          name: CTA_TEST_NAME, 
          title: CTA_TEST_NAME, 
          slug: CTA_TEST_NAME,
          media_type: "VOID", 
          activated_at: DateTime.yesterday
        )
end

["TRIVIA", "VERSUS"].each do |quiz_type|
  quiz_interactions = Quiz.includes(:interaction).where("quizzes.quiz_type = ? AND interactions.call_to_action_id = ?", quiz_type, cta.id).references(:interactions)

  if quiz_interactions.where("quizzes.one_shot = true").empty?
    build_quiz_interaction(cta, quiz_type, true)
  end

  if quiz_interactions.where("quizzes.one_shot = false").empty?
    build_quiz_interaction(cta, quiz_type, false)
  end
end

["Check", "Play", "Like"].each do |resource_type|
  interactions = Object.const_get(resource_type).includes(:interaction).where("interactions.call_to_action_id = ?", cta.id).references(:interactions)
  if interactions.empty?
    build_base_interaction(cta, resource_type)
  end
end

vote_interactions = Vote.includes(:interaction).where("interactions.call_to_action_id = ?", cta.id).references(:interactions)

if vote_interactions.where("votes.one_shot = true").empty?
  build_base_interaction(cta, "Vote", { title: lorem_ipsum, one_shot: true })
end

if vote_interactions.where("votes.one_shot = false").empty?
  build_base_interaction(cta, "Vote", { title: lorem_ipsum, one_shot: false })
end