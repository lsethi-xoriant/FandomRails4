class Sites::Ballando::ApplicationController < ApplicationController
  include CallToActionHelper

  def refresh_top_window
    if cookies[:connect_from_page].blank?
      render text: "<html><body><script>window.top.location.href = \"/\";</script></body></html>"
    else
      connect_from_page = cookies[:connect_from_page]
      cookies.delete(:connect_from_page)
      render text: "<html><body><script>window.top.location.href = \"#{connect_from_page}\";</script></body></html>"
    end
  end

  def generate_cover_for_calltoaction
    response = Hash.new

    calltoaction = CallToAction.find(params[:calltoaction_id])
    
    response[:calltoaction_completed] = true
    interactions = calculate_next_interactions(calltoaction, params[:interactions_showed])
    response[:next_interaction] = generate_response_for_next_interaction(interactions, calltoaction)

=begin
    if call_to_action_completed?(calltoaction)
      response[:calltoaction_completed] = true
      interactions = calculate_next_interactions(calltoaction, params[:interactions_showed])
      response[:next_interaction] = generate_response_for_next_interaction(interactions, calltoaction)
    else
      response[:calltoaction_completed] = false
      calltoaction_reward_status = get_current_call_to_action_reward_status(MAIN_REWARD_NAME, calltoaction)
      response[:render_calltoaction_cover] = render_to_string "/call_to_action/_cover_for_interactions", locals: { calltoaction: calltoaction, calltoaction_reward_status: calltoaction_reward_status }, layout: false, formats: :html
    end
=end

    respond_to do |format|
      format.json { render json: response.to_json }
    end
  end
  
  def update_basic_share_interaction
    response = Hash.new
    
    response[:ga] = Hash.new
    response[:ga][:category] = "UserInteraction"
    response[:ga][:action] = "CreateOrUpdate"
    response[:ga][:label] = "Share"
    interaction = Interaction.find(params[:interaction_id])
    user_interaction, response[:outcome] = create_or_update_interaction(current_or_anonymous_user, interaction, nil, nil)
    
    response[:result] = user_interaction.errors.blank?
    debugger  
    
    respond_to do |format|
      format.json { render json: response.to_json }
    end
    
  end
  
end

