module UserInteractionHelper

  def extract_interaction_ids_from_call_to_action_info_list(calltoaction_info_list, resource_type = nil)
    interaction_ids = []
    calltoaction_info_list.each do |calltoaction_info|
      calltoaction_info["calltoaction"]["interaction_info_list"].each do |interaction_info|
        if !resource_type || interaction_info["interaction"]["resource_type"] == resource_type
          interaction_ids << interaction_info["interaction"]["id"]
        end
      end
    end
    interaction_ids
  end

  def extract_resource_ids_from_call_to_action_info_list(calltoaction_info_list, resource_type = nil)
    resource_ids = []
    calltoaction_info_list.each do |calltoaction_info|
      calltoaction_info["calltoaction"]["interaction_info_list"].each do |interaction_info|
        if !resource_type || interaction_info["interaction"]["resource_type"] == resource_type
          resource_ids << interaction_info["interaction"]["resource"]["id"]
        end
      end
    end
    resource_ids
  end

  def get_user_interactions_with_interaction_id(interaction_ids, user)
    user_interactions = UserInteraction.includes(:interaction).where(interaction_id: interaction_ids, user_id: user.id).references(:interactions)
    if anonymous_user?(user)
      user_interactions = user_interactions.where("interactions.stored_for_anonymous")
    end
    user_interactions
  end

  # TODO: in future implement this feature with a cached graph in build_cta_info
  def check_and_find_next_cta_from_user_interactions(cta_info_list, user_interactions, interactions_to_compute) 
    next_cta_info_list = nil
    if cta_info_list.length == 1 && user_interactions.any?
      # TODO: for semplicity reasons only the first test CTA is handled in a CTA stream (i.e. only the single page cta is handled)
      cta_info = cta_info_list.first

      prev_cta_info = cta_info

      linked_user_interaction_ids = []

      next_cta, linked_user_interaction_id = check_and_find_next_cta_from_user_interactions_computation(user_interactions)
      linked_user_interaction_ids << linked_user_interaction_id if linked_user_interaction_id
      next_cta_to_return = next_cta
      while next_cta
        user_interactions = UserInteraction.includes(:interaction).where("interactions.call_to_action_id = ?", next_cta.id).references(:interactions)
        next_cta, linked_user_interaction_id = check_and_find_next_cta_from_user_interactions_computation(user_interactions)
        linked_user_interaction_ids << linked_user_interaction_id if linked_user_interaction_id
        if next_cta
          next_cta_to_return = next_cta
        end
        prev_cta_info["optional_history"]["optional_index_count"] = prev_cta_info["optional_history"]["optional_index_count"] + 1
      end
      next_cta = next_cta_to_return
      
      if next_cta  
        next_cta_info_list = build_cta_info_list_and_cache_with_max_updated_at([next_cta], interactions_to_compute)
        next_cta_info = next_cta_info_list.first
        update_cta_info_optional_history(next_cta_info, prev_cta_info, linked_user_interaction_ids) 
      else
        next_cta_info_list = nil
      end
    end

    next_cta_info_list
  end

  def check_and_find_next_cta_from_user_interactions_computation(user_interactions)
    next_cta = nil
    linked_user_interaction_id = nil
    user_interactions.each do |user_interaction|
      aux = user_interaction.aux
      to_redo = aux["to_redo"]
      if aux["next_calltoaction_id"] && !to_redo
        next_cta = CallToAction.find(aux["next_calltoaction_id"])
        linked_user_interaction_id = user_interaction.id
        break
      end
    end
    [next_cta, linked_user_interaction_id]
  end

  def update_cta_info_optional_history(next_cta_info, prev_cta_info, linked_user_interaction_ids)
    optional_index_count = prev_cta_info["optional_history"]["optional_index_count"]
    optional_total_count = prev_cta_info["optional_history"]["optional_total_count"]

    next_cta_info["optional_history"] = {
      "user_interactions" => linked_user_interaction_ids,
      "optional_total_count" => optional_total_count,
      "optional_index_count" => optional_index_count
    }

    # TODO: remove this line and fix orzoro templates 
    next_cta_info["calltoaction"]["extra_fields"]["linked_call_to_actions_count"] = optional_total_count
  end

  def build_current_user_reward(reward)
    {
      "cost" => reward.cost,
      "status" => get_user_reward_status(reward),
      "id" => reward.id,
    }
  end

  def adjust_call_to_actions_with_user_interaction_data(calltoactions, calltoaction_info_list, user_interactions)
    calltoaction_info_list.each do |calltoaction_info|

        calltoaction = find_in_calltoactions(calltoactions, calltoaction_info["calltoaction"]["id"])

        if calltoaction_info["reward_info"]
          calltoaction_info["reward_info"] = build_current_user_reward(calltoaction_info["reward_info"]["reward"])
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
    find_content_in_array_by_id(calltoactions, calltoaction_id)
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

  def find_interaction_in_counters(counters, id)
    counter = nil
    counters.each do |element|
      if element.ref_id == id
        counter = element 
      end
    end
    counter
  end

  def build_comments_by_resource_id(comments, resource_id)
    result = []
    comments.each do |comment|
      if comment.comment_id == resource_id
        result << {
          "id" => comment.id,
          "text" => comment.text,
          "updated_at" => comment.updated_at.strftime("%Y/%m/%d %H:%M:%S"),
          "user" => {
            "name" => comment.user.username,
            "avatar" => user_avatar(comment.user)
          }
        }
      end
    end
    result
  end

  def find_content_in_array_by_id(elements, id)
    content = nil
    elements.each do |element|
      if element.id == id
        content = element 
      end
    end
    content
  end

  def adjust_counter!(interaction, value = 1)
    ViewCounter.transaction do
      counter = ViewCounter.where("ref_type = 'interaction' AND ref_id = ?", interaction.id).first
      if counter
        if interaction.resource_type.downcase == "vote" || interaction.resource_type.downcase == "quiz"
          aux = counter.aux
          aux[value] = aux[value] ? (aux[value] + 1) : 1
          counter.update_attributes(counter: (counter.counter + 1), aux: aux.to_json)
        else
          counter.update_attribute(:counter, counter.counter + value)
        end
      else
        if interaction.resource_type.downcase == "vote" || interaction.resource_type.downcase == "quiz"
          aux = { "#{value}" => 1 }
        else
          aux = {}
        end
        ViewCounter.create(ref_type: "interaction", ref_id: interaction.id, counter: 1, aux: aux.to_json)
      end
    end
  end

  def create_or_update_interaction(user, interaction, answer_id, like, aux = "{}")
    aux = JSON.parse(aux)

    if !anonymous_user?(user) || interaction.stored_for_anonymous
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
        like_updated = !user_interaction.aux["like"]
        aux = { like: like_updated }.to_json
        like_value = like_updated ? 1 : -1
        adjust_counter!(interaction, like_value)
      when "vote"
        vote = aux["vote"]
        aux = user_interaction.aux
        if aux["vote_info_list"]["#{vote}"].present?
          aux["vote_info_list"]["#{vote}"] = aux["vote_info_list"]["#{vote}"] + 1
        else
          aux["vote_info_list"]["#{vote}"] = 1
        end
        adjust_counter!(interaction, vote)
      when "quiz"
        if interaction.resource.quiz_type == "VERSUS"
          adjust_counter!(interaction, answer_id.to_s)
        end
      when "randomresource"
        next_random_cta = aux["next_random_cta"]
        aux = user_interaction.aux
        aux["next_random_cta"] = (aux["next_random_cta"] || []) + next_random_cta        
      end

      user_interaction.assign_attributes(counter: (user_interaction.counter + 1), answer_id: answer_id, like: like, aux: aux)
      UserCounter.update_counters(interaction, user_interaction, user, false) 

    else

      case interaction.resource_type.downcase
      when "like"
         adjust_counter!(interaction, 1)
      when "vote"
        vote = aux["vote"]
        aux["vote_info_list"] = { vote => 1 }
        adjust_counter!(interaction, vote)
      when "quiz"
        if interaction.resource.quiz_type == "VERSUS"
          adjust_counter!(interaction, answer_id.to_s)
        end
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

    if !anonymous_user?(user) || interaction.stored_for_anonymous
      user_interaction.save
    end
  
    [user_interaction, outcome]
  
  end
end