module UserInteractionHelper

  def reset_redo_user_interactions_computation(params)
    user_interactions = UserInteraction.where(id: params[:user_interaction_ids]).order(created_at: :desc)
    cta = CallToAction.find(params[:parent_cta_id])

    user_interactions.each do |user_interaction|
      aux = user_interaction.aux
      aux["to_redo"] = true
      user_interaction.update_attributes(aux: aux)
    end

    {
      calltoaction_info: build_cta_info_list_and_cache_with_max_updated_at([cta]).first
    }
  end

  def create_user_interaction_for_registration()
    basic_interaction = Basic.where({ :basic_type => "Registration" }).first
    if basic_interaction
      interaction = Interaction.where({ :resource_id => basic_interaction.id, :resource_type => "Basic" }).first
      create_or_update_interaction(current_user, interaction, nil, nil)
    end
  end

  def adjust_user_ctas(cta_info_list)
    user_ids = []
    cta_info_list.each do |cta_info|
      if cta_info["calltoaction"]["user"].present?
        user_ids << cta_info["calltoaction"]["user"][:id]
      end
    end
    if user_ids.any?
      users = User.where(id: user_ids)
      cta_info_list.each do |cta_info|
        if cta_info["calltoaction"]["user"].present?
          user = find_content_by_id(users, cta_info["calltoaction"]["user"][:id])       
          cta_info["calltoaction"]["user"] = {
            username: user.username,
            avatar: user_avatar(user),
            first_name: user.first_name,
            last_name: user.last_name,
            is_anonymous: anonymous_user?(user),
            is_stored_anonymous: stored_anonymous_user?(user)
          }
        end
      end
    end
  end

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
    UserInteraction.includes(:interaction).where(interaction_id: interaction_ids, user_id: user.id)
  end

  def check_and_find_next_cta_from_user_interactions(calltoactions, cta_info_list, interactions_to_compute) 
    end_ctas = []
    end_cta_extras = []

    is_cta_info_list_updated = false

    cta_info_list.each do |cta_info|  
      interaction_ids = extract_interaction_ids_from_call_to_action_info_list([cta_info])
      user_interactions = get_user_interactions_with_interaction_id(interaction_ids, current_user)

      next_cta, nested_user_interaction_id = check_and_find_next_cta_from_user_interactions_computation(cta_info, user_interactions)
      nested_user_interaction_ids = [] 
      nested_user_interaction_ids << nested_user_interaction_id if nested_user_interaction_id
      
      step = 1
      end_cta = nil
      while next_cta
        end_cta = next_cta
        user_interactions = UserInteraction.includes(:interaction).where("interactions.call_to_action_id = ? AND user_interactions.user_id = ?", next_cta.id, current_user.id).references(:interactions)
        next_cta, nested_user_interaction_id = check_and_find_next_cta_from_user_interactions_computation(next_cta, user_interactions)
        nested_user_interaction_ids << nested_user_interaction_id if nested_user_interaction_id
        step = step + 1
      end
              
      if end_cta.present?
        is_cta_info_list_updated = true 
        end_ctas << end_cta
      else
        parent_cta = find_in_calltoactions(calltoactions, cta_info["calltoaction"]["id"])
        end_ctas << parent_cta
      end
      
      end_cta_extras << [step, nested_user_interaction_ids]
    end

    if is_cta_info_list_updated
      end_cta_info_list = build_cta_info_list_and_cache_with_max_updated_at(end_ctas, interactions_to_compute)
      end_cta_info_list.each_with_index do |end_cta, index|
        parent_cta_info = cta_info_list[index] 
        step, linked_user_interaction_ids = end_cta_extras[index]
        end_cta["optional_history"] = update_cta_info_optional_history(parent_cta_info, end_cta, linked_user_interaction_ids, step) 
      end
    else
      end_cta_info_list = cta_info_list
    end

    end_cta_info_list
  end

  def update_cta_info_optional_history(parent_cta_info, cta_info, linked_user_interaction_ids, index)
    {
      "parent_cta_info" => parent_cta_info,
      "user_interactions" => linked_user_interaction_ids,
      "optional_index_count" => index,
      "optional_total_count" => parent_cta_info["optional_history"]["optional_total_count"],
    }
  end

  def check_and_find_next_cta_from_user_interactions_computation(cta_info, user_interactions)
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

  def build_current_user_reward(reward)
    {
      "cost" => reward.cost,
      "status" => get_user_reward_status(reward),
      "id" => reward.id
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
    find_content_by_id(calltoactions, calltoaction_id)
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
        user = anonymous_user?(comment.user) ? anonymous_user : comment.user
        result << {
          "id" => comment.id,
          "text" => comment.text,
          "updated_at" => comment.updated_at.strftime("%Y/%m/%d %H:%M:%S"),
          "user" => {
            "name" => user.username,
            "avatar" => user_avatar(user)
          }
        }
      end
    end
    result
  end

  def find_content_by_id(elements, id)
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
          aux["#{value}"] = aux["#{value}"] ? (aux["#{value}"] + 1) : 1
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
    aux.each do |key, value|
      if key != "providers"
        user_interaction_aux[key] = value
      end
    end

    case resource_type
    when "share"
      if user_interaction
        providers = aux["providers"]
        providers.each do |provider, increment|
          value = user_interaction_aux["providers"][provider] 
          user_interaction_aux["providers"][provider] = value.present? ? (value + increment) : increment
        end
      end
    when "comment"
      adjust_counter!(interaction)
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
      user_interaction_aux["next_random_cta"] = (user_interaction_aux["next_random_cta"] || []) << next_random_cta        
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

    if anonymous_user?(user) && !stored_anonymous_user?(user)
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
  
  def update_interaction_computation(params)
    interaction = Interaction.find(params[:interaction_id])
    calltoaction = interaction.call_to_action

    aux = {}
    response = {}
    response[:calltoaction_id] = interaction.call_to_action_id;

    response[:ga] = Hash.new
    response[:ga][:category] = "UserInteraction"
    response[:ga][:action] = "CreateOrUpdate"
    response[:ga][:label] = interaction.resource_type 

    linked_cta = nil
    if interaction.interaction_call_to_actions.any?
      linked_cta = compute_linked_cta(interaction, params[:user_interactions_history], params[:params])
      next_cta_id = linked_cta.nil? ? nil : linked_cta.id
    end

    aux[:to_redo] = false

    aux[:user_interactions_history] = params[:user_interactions_history] if params[:user_interactions_history]
    aux[:next_cta_id] = next_cta_id if next_cta_id

    case interaction.resource_type.downcase
    when "quiz"
      answer = Answer.find(params[:params])
      user_interaction, outcome, response = update_quiz_interaction(interaction, answer, aux, response)
    when "like"
      user_interaction, outcome = create_or_update_interaction(current_or_anonymous_user, interaction, nil, nil, aux.to_json)
    when "share"
      user_interaction, outcome, response = update_share_interaction(interaction, aux, params[:provider], params[:share_with_email_address], params[:facebook_message], response)
    when "vote"
      aux[:vote] = params[:params]
      user_interaction, outcome = create_or_update_interaction(current_or_anonymous_user, interaction, nil, nil, aux.to_json)
      response["counter_aux"], response["counter"] = get_interaction_counter_from_view_counter(interaction.id)
    when "randomresource"
      user_interaction, outcome, response = update_random_interaction(calltoaction, interaction, aux, response)
    when "download"
      response["download_interaction_attachment"] = interaction.resource.attachment.url
      user_interaction, outcome = create_or_update_interaction(current_or_anonymous_user, interaction, nil, aux.to_json)
    else
      user_interaction, outcome = create_or_update_interaction(current_or_anonymous_user, interaction, nil, aux.to_json)
    end

    if user_interaction
      response[:user_interaction] = build_user_interaction_for_interaction_info(user_interaction)
      response[:outcome] = outcome

      if $site.id == "braun_ic"
        reward_names = outcome[:reward_name_to_counter].map { |key, value| key.to_s }
        badge_tag = Tag.find("badge")
        reward = Reward.includes(:reward_tags).where("reward_tags.tag_id = ?", badge_tag.id).where(name: reward_names).references(:reward_tags).order(cost: :desc).first
        
        if reward
          parent_cta = CallToAction.find(params[:parent_cta_id])
          response[:badge] = adjust_braun_ic_reward(reward, false, parent_cta.activated_at, parent_cta.name)
        end
      end

      if stored_anonymous_user? && $site.interactions_for_anonymous_limit.present?
        user_interactions_count = current_user.user_interactions.count
        response[:notice_anonymous_user] = user_interactions_count > 0 && user_interactions_count % $site.interactions_for_anonymous_limit == 0
      end
    end 

    response = update_cta_and_interaction_status(calltoaction, interaction, response)

    if linked_cta.present?
      parent_cta = CallToAction.find(params[:parent_cta_id])
      response[:next_call_to_action_info] = build_cta_info_list_and_cache_with_max_updated_at([parent_cta]).first
    end

    if current_user && $site.id != "disney"
      response[:current_user] = build_current_user()
    elsif $site.id == "disney"
      response[:current_user] = build_disney_current_user()
    end

    response
  end
  
  def compute_linked_cta(interaction, user_interactions_history, current_answer)
    interaction_call_to_actions = interaction.interaction_call_to_actions.order(:ordering, :created_at)

    linked_cta = nil
    symbolic_name_to_counter = nil

    interaction_call_to_actions.each do |interaction_call_to_action|
      if interaction_call_to_action.condition.present?
        # the symbolic_name_to_counter is populated "lazily" only if there is at least one condition present
        if symbolic_name_to_counter.nil?
          symbolic_name_to_counter = user_history_to_answer_map_to_condition(current_answer, user_interactions_history)
        end
        condition = interaction_call_to_action.condition
        condition_name, condition_params = condition.first
        if get_linked_call_to_action_conditions[condition_name].call(symbolic_name_to_counter, condition_params)
          linked_cta = interaction_call_to_action.call_to_action
          break
        end
      else
        linked_cta = interaction_call_to_action.call_to_action
        break
      end
    end
    linked_cta
  end
  
  def update_quiz_interaction(interaction, answer, aux, response)
    user_interaction, outcome = create_or_update_interaction(current_or_anonymous_user, interaction, answer.id, nil, aux.to_json)
    
    quiz_type = interaction.resource.quiz_type.downcase

    response["answer"] = answer
    response["has_answer_media"] = answer.answer_with_media?

    answers = interaction.resource.answers
    response["answers"] = build_answers_for_resource(interaction, answers, quiz_type, user_interaction)
    
    if answer.media_type == "IMAGE" && answer.media_image
      response["answer_media_image_url"] = answer.media_image.url
    end

    if answer.call_to_action_id
      answer_cta = answer.call_to_action
      response["next_call_to_action_info_list"] = build_cta_info_list_and_cache_with_max_updated_at([answer_cta])
    end

    response["counter_aux"], response["counter"] = get_interaction_counter_from_view_counter(interaction.id)

    if quiz_type == "trivia"
      response[:ga][:label] = "#{interaction.resource.quiz_type.downcase}-answer-#{answer.correct ? "right" : "wrong"}"
    else 
      response[:ga][:label] = interaction.resource.quiz_type.downcase
    end

    [user_interaction, outcome, response]
  end

  def update_share_interaction(interaction, aux, provider, address, facebook_message = " ", response)
    unless current_user
      throw Exception.new("the user must be logged")
    end

    provider_json = interaction.resource.providers[provider]
    is_share_valid = true
    error = nil

    begin 

      case provider 
      when "facebook"
        link = provider_json["link"].present? ? provider_json["link"] : "#{root_url}?calltoaction_id=#{interaction.call_to_action_id}"
        current_user.facebook(request.site.id).put_wall_post(facebook_message, 
              { name: provider_json["message"], description: provider_json["description"], link: link, picture: "#{interaction.resource.picture.url}" })
      when "twitter"   
        if Rails.env == "production"
          media = URI.parse("#{interaction.resource.picture.url}").open
          current_user.twitter(request.site.id).update_with_media("#{interaction.call_to_action.title} #{provider_json["message"]}", media)
        else
          current_user.twitter(request.site.id).update("#{interaction.call_to_action.title} #{provider_json["message"]}")
        end
      when "email"
        if address =~ Devise.email_regexp
          send_share_interaction_email(address, interaction.call_to_action)
        else
          is_share_valid = false
          error = "Formato non valido"
        end
      else
        is_share_valid = false
      end

    rescue Exception => exception
      is_share_valid = false
      error = exception.to_s
    end

    if is_share_valid
      aux["providers"] = { provider => 1 }
      user_interaction, outcome = create_or_update_interaction(current_or_anonymous_user, interaction, nil, nil, aux.to_json)
      response[:ga][:label] = interaction.resource_type.downcase
    end

    response[:share] = Hash.new
    response[:share][:result] = is_share_valid
    response[:share][:exception] = error 

    [user_interaction, outcome, response]
  end

  def update_random_interaction(cta, interaction, aux, response)
    next_random_cta = get_random_call_to_action(interaction, cta.id)
    aux[:next_random_cta] = next_random_cta.id

    user_interaction, outcome = create_or_update_interaction(current_or_anonymous_user, interaction, nil, nil, aux.to_json)    

    response[:next_random_call_to_action_info_list] = build_cta_info_list_and_cache_with_max_updated_at([next_random_cta])
    response[:ga][:label] = interaction.resource_type

    [user_interaction, outcome, response]
  end

  def get_random_call_to_action(interaction, id_cta_to_exclude = nil)
    tag = Tag.find_by_name(interaction.resource.tag)
    template_ctas = get_all_ctas_with_tag("template")
    where_clause = "call_to_actions.id NOT IN (#{template_ctas.map{|c| c.id}.join(",")}) AND call_to_action_tags.tag_id = #{tag.id} AND rewards.id IS NULL"
    if id_cta_to_exclude
      where_clause << " AND call_to_actions.id <> #{id_cta_to_exclude}"
    end
    ctas = CallToAction.includes(:call_to_action_tags, :rewards, :interactions).where(where_clause).references(:call_to_action_tags, :rewards, :interactions)
    random_cta = ctas.offset(rand(ctas.count)).first
  end

  def get_interaction_counter_from_view_counter(interaction_id)
    counter = ViewCounter.where("ref_type = 'interaction' AND ref_id = ?", interaction_id).first
    counter_aux = counter ? counter.aux : {}
    counter = counter ? counter.counter : 0
    [counter_aux, counter]
  end
  
  def update_cta_and_interaction_status(cta, interaction, response)
    response[:interaction_status] = get_current_interaction_reward_status(get_main_reward_name(), interaction)
    response[:calltoaction_status] = compute_call_to_action_completed_or_reward_status(get_main_reward_name(), cta)
    response
  end
  
  def user_history_to_answer_map_to_condition(current_answer, user_interactions_history)
    if current_user
      answers_history = UserInteraction.where(id: user_interactions_history).map { |ui| ui.answer_id }
    else
      throw Exception.new("for linked interactions the user must be logged or the anonymous navigation must be enabled")
    end

    answers_history = answers_history + [current_answer]

    answers = Answer.where(id: answers_history)
    symbolic_name_to_counter = {}
    answers.each do |answer|
      value = answer.aux["symbolic_name"]
      if symbolic_name_to_counter.has_key?(value)
        symbolic_name_to_counter[value] = symbolic_name_to_counter[value] + 1
      else
        symbolic_name_to_counter[value] = 1
      end
    end
    symbolic_name_to_counter
  end

  def max_key_in_symbolic_name_to_counter(symbolic_name_to_counter)

    current_key = ""
    current_value = 0

    symbolic_name_to_counter.each do |key, value|
      if value > current_value
        current_key = key
        current_value = value
      end
    end

    current_key

  end
  
  def reset_redo_user_interactions
    user_interactions = UserInteraction.where(id: params[:user_interaction_ids]).order(created_at: :desc)
    cta = CallToAction.find(params[:parent_cta_id])

    user_interactions.each do |user_interaction|
      aux = user_interaction.aux
      aux["to_redo"] = true
      user_interaction.update_attributes(aux: aux)
    end

    return build_cta_info_list_and_cache_with_max_updated_at([cta]).first
     
  end

end