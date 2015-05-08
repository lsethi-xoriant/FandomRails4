namespace :counters do

  task :init_versuses, [:tenant] => :environment do |t, args|
    switch_tenant(args.tenant)
    Quiz.where("quiz_type = 'VERSUS'").each do |quiz|
      interaction = quiz.interaction
      interaction_answers_count = interaction.user_interactions.count
      
      counter_aux = {}
      quiz.answers.each do |answer|
        counter_aux[answer.id] = UserInteraction.where("answer_id = ?", answer.id).count
      end

      #if interaction_answers_count < 1
      #  (100 / interaction.resource.answers.count.to_f).round
      #else
      #  interaction_current_answer_count = interaction.user_interactions.where("answer_id = ?", answer.id).count
      #  ((interaction_current_answer_count.to_f / interaction_answers_count.to_f) * 100).round
      #end

      setViewCounter(interaction.id, interaction_answers_count, counter_aux.to_json)
    end
  end

  task :init_votes, [:tenant] => :environment do |t, args|
    switch_tenant(args.tenant)

    Vote.all.each do |vote|
      interaction_id = vote.interaction.id
      puts interaction_id
      user_interactions = UserInteraction.where("interaction_id = ?", interaction_id)

      counter_aux = {}
      counter = user_interactions.count
      user_interactions.each do |user_interaction|
        puts user_interaction.to_json
        values = JSON.parse(user_interaction.aux)["vote_info_list"]
        values.each do |key, value|
          counter_aux[key] = counter_aux[key] ? (counter_aux[key] + value) : value
        end
      end

      setViewCounter(interaction_id, counter, counter_aux.to_json)
    end
  end

  task :init_likes, [:tenant] => :environment do |t, args|
    switch_tenant(args.tenant)

    Like.all.each do |like|
      interaction_id = like.interaction.id
      puts interaction_id
      user_interactions = UserInteraction.where("interaction_id = ?", interaction_id).where("(aux->>'like')::bool")

      counter = user_interactions.count

      setViewCounter(interaction_id, counter, "{}")
    end
  end

  task :init_comments, [:tenant] => :environment do |t, args|
    switch_tenant(args.tenant)

    Comment.all.each do |comment|
      interaction_id = comment.interaction.id
      puts interaction_id
      user_comment_interactions = comment.user_comment_interactions.where("approved = true")

      counter = user_comment_interactions.count

      setViewCounter(interaction_id, counter, "{}")
    end
  end

  def setViewCounter(interaction_id, counter, aux)
    ViewCounter.transaction do
      view_counter = ViewCounter.where("ref_type = 'interaction' AND ref_id = ?", interaction_id).first
      if view_counter
        view_counter.update_attributes(counter: counter, aux: aux)
      else
        ViewCounter.create(ref_type: "interaction", ref_id: interaction_id, counter: counter, aux: aux)
      end
    end
  end

end
