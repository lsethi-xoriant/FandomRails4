class Api::V2::RewardController < Api::V2::BaseController
  
  def show_all_catalogue
    all_rewards = get_all_rewards_map(get_property_for_reward_catalogue).map{|k,v| v}.sort_by{|reward| reward.created_at}
    cta_ids = all_rewards.map{ |reward| reward.call_to_action_id }
    
    if current_user
      header_message = "Hai #{get_counter_about_user_reward("credit")} crediti a disposizione"
      extra_info = {
        "credits" => get_counter_about_user_reward("credit")
      }
    else
      header_message = "Registrati per ottenere crediti e sbloccare i contenuti esclusivi della community."
      extra_info = nil
    end
    
    ctas = CallToAction.where("id in (?)", cta_ids)
    calltoaction_info_list = build_cta_info_list_and_cache_with_max_updated_at(ctas)
    result = {
        'call_to_action_info_list' => adjust_ctas_descriptions(calltoaction_info_list),
        'call_to_action_info_list_version' => get_max_updated_at_from_cta_info_list(calltoaction_info_list),
        'call_to_action_info_list_has_more' => false,
        'title' => "Tutti i premi",
        'header_message' => header_message,
        'extra_info' => extra_info
      }
    respond_with result.to_json
  end

  def show_all_available_catalogue
    if current_user
      all_rewards = get_all_rewards_map(get_property_for_reward_catalogue)
      user_available_rewards = get_user_available_rewards(all_rewards)
      
      cta_ids = user_available_rewards.map{ |reward| reward.call_to_action_id }
    
      ctas = CallToAction.where("id in (?)", cta_ids)
      calltoaction_info_list = build_cta_info_list_and_cache_with_max_updated_at(ctas)
      result = {
        'call_to_action_info_list' => calltoaction_info_list,
        'call_to_action_info_list_version' => get_max_updated_at_from_cta_info_list(calltoaction_info_list),
        'call_to_action_info_list_has_more' => false,
        'title' => "Premi sbloccabili"
      }
    else
      result = {}
    end
    
    respond_with result.to_json
  end

  def show_all_my_catalogue
    if current_user
      all_rewards = get_all_rewards_map(get_property_for_reward_catalogue)
      user_rewards = get_user_rewards(all_rewards)
      cta_ids = user_rewards.map{ |reward| reward.call_to_action_id }
    
      ctas = CallToAction.where("id in (?)", cta_ids)
      calltoaction_info_list = build_cta_info_list_and_cache_with_max_updated_at(ctas)
      result = {
        'call_to_action_info_list' => calltoaction_info_list,
        'call_to_action_info_list_version' => get_max_updated_at_from_cta_info_list(calltoaction_info_list),
        'call_to_action_info_list_has_more' => false,
        'title' => "I tuoi premi"
      }
    else
      result = {}
    end
    
    respond_with result.to_json
  end
  
  def buy_reward_attempt
    response = {}
    reward = Reward.find(params[:reward_id])
    if anonymous_user?
      raise Exception.new("Anonymous user cannot buy reward")
    elsif user_has_currency_for_reward(reward)
      buy_reward(current_user, reward)
      
      response["unlocked"] = true 
      response["message"] = "Premio sbloccato, hai ancora #{get_counter_about_user_reward(reward.currency.name)} #{reward.currency.name} crediti"
    else
      response["unlocked"] = false
      response["message"] = "#{reward.currency.name} insufficienti per sbloccare il premio"
    end
    
    respond_with response.to_json
  end
  
end