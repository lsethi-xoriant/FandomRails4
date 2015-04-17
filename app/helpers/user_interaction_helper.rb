module UserInteractionHelper

  def extract_interaction_ids_from_call_to_action_info_list(calltoaction_info_list)
    interaction_ids = []
    calltoaction_info_list.each do |calltoaction_info|
      calltoaction_info["calltoaction"]["interaction_info_list"].each do |interaction_info|
        interaction_ids << interaction_info["interaction"]["id"]
      end
    end
    interaction_ids
  end

  def get_user_interactions_with_interaction_id(interaction_ids, user)
    user_interactions = UserInteraction.includes(:interaction).where(interaction_id: interaction_ids, user_id: user.id)
    if anonymous_user?(user)
      user_interactions = user_interactions.where("interactions.stored_for_anonymous")
    end
    user_interactions
  end

  def adjust_call_to_actions_with_user_interaction_data_for_current_user(calltoactions, calltoaction_info_list)
    interaction_ids = extract_interaction_ids_from_call_to_action_info_list(calltoaction_info_list)
    user_interactions = get_user_interactions_with_interaction_id(interaction_ids, current_user)

    calltoaction_info_list.each do |calltoaction_info|

      calltoaction = find_in_calltoactions(calltoactions, calltoaction_info["calltoaction"]["id"])

      if calltoaction_info["reward_info"]
        calltoaction_info["reward_info"] = update_current_user_reward(calltoaction_info["reward_info"]["reward"])
      end

      calltoaction_info["calltoaction"]["interaction_info_list"].each do |interaction_info|
        
        interaction_id = interaction_info["interaction"]["id"]
        user_interaction = find_in_user_interactions(user_interactions, interaction_id)

        if user_interaction
          user_interaction_for_interaction_info = build_user_interaction_for_interaction_info(user_interaction)
          interaction = user_interaction.interaction
          interaction_info["user_interaction"] = user_interaction_for_interaction_info
          interaction_info["status"] = get_current_interaction_reward_status(MAIN_REWARD_NAME, interaction)
          begin
            answers = user_interaction.interaction.resource.answers
            resource_type = interaction_info["interaction"]["resource_type"]
            interaction_info["interaction"]["resource"]["answers"] = build_answers_for_resource(interaction, answers, resource_type, user_interaction)
          rescue Exception => exception
            # resource without answers
          end
        end

      end

      calltoaction_info["status"] = compute_call_to_action_completed_or_reward_status(get_main_reward_name(), calltoaction, current_user)

    end
    calltoaction_info_list
  end

  def adjust_call_to_actions_with_user_interaction_data_for_anonymous_user(calltoactions, calltoaction_info_list)
    interaction_ids = extract_interaction_ids_from_call_to_action_info_list(calltoaction_info_list)
    user_interactions = get_user_interactions_with_interaction_id(interaction_ids, anonymous_user)

    calltoaction_info_list.each do |calltoaction_info|
      calltoaction_info["calltoaction"]["interaction_info_list"].each do |interaction_info|
        interaction_id = interaction_info["interaction"]["id"]
        user_interaction = find_in_user_interactions(user_interactions, interaction_id)
        if user_interaction
          interaction_info["anonymous_user_interaction_info"] = build_user_interaction_for_interaction_info(user_interaction)
        end
      end
    end
    calltoaction_info_list
  end

  def adjust_call_to_actions_with_user_interaction_data(calltoactions, calltoaction_info_list)
    if current_user
      adjust_call_to_actions_with_user_interaction_data_for_current_user(calltoactions, calltoaction_info_list) 
    elsif $site.anonymous_interaction
      adjust_call_to_actions_with_user_interaction_data_for_anonymous_user(calltoactions, calltoaction_info_list)
    else
      calltoaction_info_list
    end
  end

  def find_in_answers(answer_ids, answers)
    answers_to_return = []
    answers.each do |answer|
      if answer_ids.include?(answer.id)
        answers_to_return << answer
      end
    end
    answers_to_return
  end

  def find_in_calltoactions(calltoactions, calltoaction_id)
    calltoaction_to_return = nil
    calltoactions.each do |calltoaction|
      if calltoaction.id == calltoaction_id
        calltoaction_to_return = calltoaction 
      end
    end
    calltoaction_to_return
  end

  def find_in_user_interactions(user_interactions, interaction_id)
    user_interaction_to_return = nil
    user_interactions.each do |user_interaction|
      if user_interaction.interaction_id == interaction_id
        user_interaction_to_return = user_interaction 
      end
    end
    user_interaction_to_return
  end

  def create_or_update_interaction(user, interaction, answer_id, like, aux = "{}")

    if !anonymous_user?(user) || ($site.anonymous_interaction && interaction.stored_for_anonymous)
      user_interaction = user.user_interactions.find_by_interaction_id(interaction.id)
      expire_cache_key(get_share_interaction_daily_done_cache_key(user.id))
    end
    
    if user_interaction
      if interaction.resource.one_shot
        log_error('one shot interaction attempted more than once', { user_id: user_interaction.user.id, interaction_id: user_interaction.interaction.id, cta_id: user_interaction.interaction.call_to_action.id })
        raise Exception.new("one shot interaction attempted more than once")
      end

      case interaction.resource_type.downcase
      when "share"
        aux = merge_aux(aux, user_interaction.aux)
      when "like"
        aux = { like: !(JSON.parse(user_interaction.aux)["like"]) }.to_json
      when "vote"
        aux_parse = JSON.parse(aux)
        aux_in_user_interaction = JSON.parse(user_interaction.aux)
        aux_in_user_interaction["vote"] = aux_parse["vote"]
        if aux_in_user_interaction["vote_info_list"].has_key?(aux_parse["vote"].to_s)
          aux_in_user_interaction["vote_info_list"][aux_parse["vote"]] = aux_in_user_interaction["vote_info_list"][aux_parse["vote"].to_s] + 1
        else
          aux_in_user_interaction["vote_info_list"][aux_parse["vote"]] = 1
        end
        aux = aux_in_user_interaction.to_json
        expire_cache_key(get_cache_votes_for_interaction(interaction.id))
      end

      user_interaction.assign_attributes(counter: (user_interaction.counter + 1), answer_id: answer_id, like: like, aux: aux)
      UserCounter.update_counters(interaction, user_interaction, user, false) 

    else

      if interaction.resource_type.downcase == "vote"
        aux_parse = JSON.parse(aux)
        aux_parse["vote_info_list"] = {
          aux_parse["vote"] => 1
        }
        aux = aux_parse.to_json
        expire_cache_key(get_cache_votes_for_interaction(interaction.id))
      end

      user_interaction = UserInteraction.new(user_id: user.id, interaction_id: interaction.id, answer_id: answer_id, aux: aux)
  
      unless anonymous_user?(user)
        UserCounter.update_counters(interaction, user_interaction, user, true)
      end
    end

    unless anonymous_user?(user)
      expire_cache_key(get_cta_completed_or_reward_status_cache_key(get_main_reward_name, interaction.call_to_action_id, user.id))
    end

    if anonymous_user?(user) && !$site.anonymous_interaction
      outcome = compute_outcome(user_interaction)
    else
      outcome = compute_save_and_notify_outcome(user_interaction)
    end
    outcome.info = []
    outcome.errors = []
    
    if user_interaction.outcome.present?
      interaction_outcome = Outcome.new(JSON.parse(user_interaction.outcome)["win"])
      interaction_outcome.merge!(outcome)
    else
      interaction_outcome = outcome
    end

    outcome_for_user_interaction = { win: interaction_outcome }

    is_trivia_interaction = interaction.resource_type.downcase == "quiz" && interaction.resource.quiz_type.downcase == "trivia"
    if is_trivia_interaction
      predict_outcome_with_correct_answer = predict_outcome(interaction, user, true)
      if user_interaction.outcome.present?
        interaction_correct_answer_outcome = Outcome.new(JSON.parse(user_interaction.outcome)["correct_answer"])
        interaction_correct_answer_outcome.merge!(predict_outcome_with_correct_answer)
      else
        interaction_correct_answer_outcome = predict_outcome_with_correct_answer
      end
      outcome_for_user_interaction[:correct_answer] = interaction_correct_answer_outcome
    end

    user_interaction.assign_attributes(outcome: outcome_for_user_interaction.to_json)

    if !anonymous_user?(user) || ($site.anonymous_interaction && interaction.resource_type.downcase == "vote")
      user_interaction.save
    end
  
    [user_interaction, outcome]
  
  end
end