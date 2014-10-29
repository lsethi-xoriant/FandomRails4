class Sites::Ballando::CustomCallToActionController < ApplicationController

  def show_next_calltoaction
    active_calltoactions_without_rewards = CallToAction.includes(call_to_action_tags: :tag).active.where("tags.name <> 'reward-cta' OR tags.id IS NULL")

    @calltoactions = active_calltoactions_without_rewards.where("call_to_actions.id < ?", params[:id].to_i).order("call_to_actions.id DESC").limit(1).to_a
    if @calltoactions.empty?
      @calltoactions = active_calltoactions_without_rewards.where("call_to_actions.id <> ?", params[:id].to_i).order("call_to_actions.id DESC").limit(1).to_a
    end

    @calltoactions_during_video_interactions_second, 
    @calltoactions_active_interaction, 
    @calltoactions_comment_interaction = init_custom_calltoaction_view(@calltoactions)  

    render template: "/custom_call_to_action/show"
  end

  def show
    @calltoactions = CallToAction.includes(:interactions).active.where("call_to_actions.id = ?", params[:id].to_i).to_a
    
    @calltoactions_during_video_interactions_second, 
    @calltoactions_active_interaction, 
    @calltoactions_comment_interaction = init_custom_calltoaction_view(@calltoactions)  

    render template: "/custom_call_to_action/show"
  end

  def init_custom_calltoaction_view(calltoactions)
    calltoactions_during_video_interactions_second = init_calltoactions_during_video_interactions_second(calltoactions)
    calltoactions_comment_interaction = init_calltoactions_comment_interaction(calltoactions)

    calltoactions_active_interaction = Hash.new
    calltoactions_active_interaction[calltoactions[0].id] = generate_next_interaction_response(calltoactions[0])

    [calltoactions_during_video_interactions_second, calltoactions_active_interaction, calltoactions_comment_interaction]
  end
  
end