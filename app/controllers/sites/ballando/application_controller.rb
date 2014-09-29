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
    if call_to_action_completed?(calltoaction)
      response[:calltoaction_completed] = true
      interactions = calculate_next_interactions(calltoaction, params[:interactions_showed])

      interaction_index = params[:interactions_showed].present? ? (params[:interactions_showed].count + 1) : "1"
      response[:next_interaction] = generate_response_for_next_interaction(interactions, calltoaction, interaction_index)
    else
      response[:calltoaction_completed] = false
      calltoaction_reward_status = get_current_call_to_action_reward_status(MAIN_REWARD_NAME, calltoaction)
      response[:render_calltoaction_cover] = render_to_string "/call_to_action/_cover_for_interactions", locals: { calltoaction: calltoaction, calltoaction_reward_status: calltoaction_reward_status }, layout: false, formats: :html
    end

    respond_to do |format|
      format.json { render json: response.to_json }
    end
  end

end

