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
        if prev_cta_info["optional_history"].present?
          prev_cta_info["optional_history"]["optional_index_count"] = prev_cta_info["optional_history"]["optional_index_count"] + 1
        end
      end
      next_cta = next_cta_to_return
      
      if next_cta  
        next_cta_info_list = build_cta_info_list_and_cache_with_max_updated_at([next_cta], interactions_to_compute)
        next_cta_info = next_cta_info_list.first
        update_cta_info_optional_history(cta_info, next_cta_info, prev_cta_info, linked_user_interaction_ids) 
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
      if aux["next_cta_id"] && !to_redo
        next_cta = CallToAction.find(aux["next_cta_id"])
        linked_user_interaction_id = user_interaction.id
        break
      end
    end
    [next_cta, linked_user_interaction_id]
  end

  def update_cta_info_optional_history(parent_cta_info, next_cta_info, prev_cta_info, linked_user_interaction_ids)
    optional_index_count = prev_cta_info["optional_history"]["optional_index_count"]
    optional_total_count = prev_cta_info["optional_history"]["optional_total_count"]

    next_cta_info["optional_history"] = {
      "parent_cta_info" => parent_cta_info,
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

  def adjust_user_interaction_aux(resource_type, user_interaction, interaction, aux, answer_id)
    user_interaction_aux = user_interaction.present? ? user_interaction.aux : aux
    user_interaction_aux["to_redo"] = aux["to_redo"] if aux["to_redo"]

    case resource_type
    when "share"
      if user_interaction
        providers = aux["providers"]
        providers.each do |provider, increment|
          value = user_interaction_aux["providers"][provider] 
          user_interaction_aux["providers"][provider] = value.present? ? (value + increment) : increment
        end
      end
    when "like"
      if user_interaction
        like = user_interaction_aux["like"]
        user_interaction_aux = { like: !like }
        counter_value = !like ? 1 : -1
      else
        user_interaction_aux = { like: true }
        counter_value = 1
      end
      adjust_counter!(interaction, counter_value)
    when "vote"
      vote = aux["vote"]
      if user_interaction
        if user_interaction_aux["vote_info_list"]["#{vote}"].present?
          user_interaction_aux["vote_info_list"]["#{vote}"] = user_interaction_aux["vote_info_list"]["#{vote}"] + 1
        else
          user_interaction_aux["vote_info_list"]["#{vote}"] = 1
        end
      else
        user_interaction_aux["vote_info_list"] = { vote => 1 }
      end
      adjust_counter!(interaction, vote)
    when "quiz"
      if interaction.resource.quiz_type == "VERSUS"
        adjust_counter!(interaction, answer_id.to_s)
      end
    when "randomresource"
      next_random_cta = aux["next_random_cta"]
      user_interaction_aux["next_random_cta"] = (user_interaction_aux["next_random_cta"] || []) + next_random_cta        
    end

    return user_interaction_aux
  end

  def update_user_counters(interaction, user_interaction, user)
    UserCounter.update_counters(interaction, user_interaction, user, user_interaction.present?)
  end

  def adjust_outcome_for_trivia(interaction, user_interaction, user, outcome)
    predict_outcome_with_correct_answer = predict_outcome(interaction, user, true)
    if user_interaction.outcome.present?
      correct_answer_outcome = Outcome.new(JSON.parse(user_interaction.outcome)["correct_answer"])
      correct_answer_outcome.merge!(predict_outcome_with_correct_answer)
    else
      correct_answer_outcome = predict_outcome_with_correct_answer
    end
    outcome[:correct_answer] = correct_answer_outcome
    outcome
  end

  def compute_and_assign_outcome_to_user_interaction(interaction, user_interaction, user)
    new_outcome = compute_save_and_notify_outcome(user_interaction)
    new_outcome.info = []
    new_outcome.errors = []

    if user_interaction.outcome.present?
      interaction_outcome = Outcome.new(JSON.parse(user_interaction.outcome)["win"])
      interaction_outcome.merge!(new_outcome)
    else
      interaction_outcome = new_outcome
    end

    outcome = { win: new_outcome }

    is_trivia_interaction = interaction.resource_type.downcase == "quiz" && interaction.resource.quiz_type.downcase == "trivia"
    if is_trivia_interaction
      outcome = adjust_outcome_for_trivia(interaction, user_interaction, user, outcome)
    end

    user_interaction.assign_attributes(outcome: outcome.to_json)
    [user_interaction, new_outcome]
  end

  def create_or_update_interaction(user, interaction, answer_id, like, aux = "{}")
    aux = JSON.parse(aux)

    if !interaction_allowed?(interaction.resource_type.downcase, user)
      log_error('an interaction not allowed for anonymous user has been invoked', { user_id: user.id, interaction_id: interaction.id, cta_id: interaction.call_to_action_id })
      raise Exception.new("an interaction not allowed for anonymous user has been invoked")
    end

    if anonymous_user?(user)
      user = create_and_sign_in_stored_anonymous_user()
    elsif stored_anonymous_user?(user)
      user.update_attribute(:updated_at, Time.now)
    end

    user_interaction = user.user_interactions.find_by_interaction_id(interaction.id)
    aux = adjust_user_interaction_aux(interaction.resource_type.downcase, user_interaction, interaction, aux, answer_id)

    if user_interaction
      if interaction.resource.one_shot
        log_error('one shot interaction attempted more than once', { user_id: user_interaction.user.id, interaction_id: user_interaction.interaction.id, cta_id: user_interaction.interaction.call_to_action.id })
        raise Exception.new("one shot interaction attempted more than once")
      end

      user_interaction.assign_attributes(counter: (user_interaction.counter + 1), answer_id: answer_id, aux: aux)  
    else
      user_interaction = UserInteraction.new(user_id: user.id, interaction_id: interaction.id, answer_id: answer_id, aux: aux)
    end

    update_user_counters(interaction, user_interaction, user)

    user_interaction, outcome = compute_and_assign_outcome_to_user_interaction(interaction, user_interaction, user)    
    user_interaction.save
  
    [user_interaction, outcome]
  end

end