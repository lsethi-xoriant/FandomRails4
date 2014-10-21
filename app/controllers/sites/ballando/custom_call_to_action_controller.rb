class Sites::Ballando::CustomCallToActionController < ApplicationController

  def show
    calltoaction_id = params[:id].to_i
    @calltoactions = CallToAction.includes(:interactions).active.where("call_to_actions.id = ?", calltoaction_id).to_a

    @calltoactions_during_video_interactions_second = init_calltoactions_during_video_interactions_second(@calltoactions)
    @calltoactions_comment_interaction = init_calltoactions_comment_interaction(@calltoactions)

    @calltoactions_active_interaction = Hash.new
    @calltoactions_active_interaction[@calltoactions[0].id] = generate_next_interaction_response(@calltoactions[0])

    render template: "/custom_call_to_action/show"
  end
  
end