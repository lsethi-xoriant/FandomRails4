class Sites::Forte::CustomCallToActionController < ApplicationController

  def show_next_calltoaction
    active_calltoactions_without_rewards = CallToAction.includes(:rewards).active.where("rewards.id IS NULL")

    @calltoactions = active_calltoactions_without_rewards.where("call_to_actions.id < ?", params[:id].to_i).order("call_to_actions.id DESC").limit(1).to_a
    if @calltoactions.empty?
      @calltoactions = active_calltoactions_without_rewards.where("call_to_actions.id <> ?", params[:id].to_i).order("call_to_actions.id DESC").limit(1).to_a
    end

    @calltoactions_during_video_interactions_second, 
    @calltoactions_active_interaction, 
    @calltoactions_comment_interaction,
    @aux,
    @user_main_reward_count = init_custom_calltoaction_view(@calltoactions)  

    render template: "/custom_call_to_action/show"
  end

  def show
    @calltoaction_id = params[:id].to_i
    @calltoactions = CallToAction.includes(:interactions).active.where("call_to_actions.id = ?", @calltoaction_id).to_a

    if @calltoactions.present?
    
      @calltoactions_during_video_interactions_second, 
      @calltoactions_active_interaction, 
      @calltoactions_comment_interaction,
      @aux,
      @user_main_reward_count = init_custom_calltoaction_view(@calltoactions)  

      render template: "/custom_call_to_action/show"

    else

      @user_main_reward_count = current_user ? (get_counter_about_user_reward(MAIN_REWARD_NAME, true)[PERIOD_KIND_WEEKLY] || 0) : 0
      render template: "/custom_call_to_action/empty"

    end

  end

  def init_custom_calltoaction_view(calltoactions)
    calltoactions_during_video_interactions_second = init_calltoactions_during_video_interactions_second(calltoactions)
    calltoactions_comment_interaction = init_calltoactions_comment_interaction(calltoactions)

    calltoactions_active_interaction = Hash.new
    aux = { show_next_calltoaction_button: true, show_calltoaction_page: true, small_mobile_device: small_mobile_device? }
    calltoactions_active_interaction[calltoactions[0].id] = generate_next_interaction_response(calltoactions[0], nil, aux)

    user_main_reward_count = current_user ? (get_counter_about_user_reward(MAIN_REWARD_NAME, true)[PERIOD_KIND_WEEKLY] || 0) : 0

    [calltoactions_during_video_interactions_second, calltoactions_active_interaction, calltoactions_comment_interaction, aux, user_main_reward_count]
  end
  
end