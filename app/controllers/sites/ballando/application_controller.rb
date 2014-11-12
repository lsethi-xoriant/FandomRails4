
class Sites::Ballando::ApplicationController < ApplicationController
  include CallToActionHelper

  def gigya_socialize_redirect
    session[:gigya_socialize_redirect] = params.to_json
    redirect_to Rails.configuration.deploy_settings["sites"]["ballando"]["profile_url"]
  end

  def refresh_top_window
    if cookies[:connect_from_page].blank?
      render text: "<html><body><script>window.top.location.href = \"/\";</script></body></html>"
    else
      connect_from_page = cookies[:connect_from_page]
      cookies.delete(:connect_from_page)
      render text: "<html><body><script>window.top.location.href = \"#{connect_from_page}\";</script></body></html>"
    end

  end

  def redirect_top_with_cookie
    cookies[:connect_from_page] = params[:connect_from_page]
    
    if params[:redirect_to_page].present?
      cookies["redirect_to_page"] = params[:redirect_to_page]
    end

    profile_url = Rails.configuration.deploy_settings["sites"]["ballando"]["profile_url"]
    render text: "<html><body><script>window.top.location.href = \"#{profile_url}\";</script></body></html>"
  end

  def redirect_into_special_guest
    cookies["redirect_to_page"] = "/gallery/55"
    redirect_to Rails.configuration.deploy_settings["sites"][get_site_from_request(request)["id"]]["stream_url"]
  end

  def generate_cover_for_calltoaction
    calltoaction = CallToAction.find(params[:calltoaction_id])
    response = generate_next_interaction_response(calltoaction, params[:interactions_showed], params[:aux] || {})
    response[:calltoaction_completed] = true # TODO: remove this in angularJS
    
=begin
    if call_to_action_completed?(calltoaction)
      response[:calltoaction_completed] = true
      interactions = calculate_next_interactions(calltoaction, params[:interactions_showed])
      response[:next_interaction] = generate_response_for_interaction(interactions, calltoaction)
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
    aux = { "#{params[:provider]}" => 1 }

    user_interaction, response[:outcome] = create_or_update_interaction(current_or_anonymous_user, interaction, nil, nil, aux.to_json)
    
    response[:result] = user_interaction.errors.blank?
    response["main_reward_counter"] = get_counter_about_user_reward(MAIN_REWARD_NAME, true)
    response["contest_points_counter"] = [SUPERFAN_CONTEST_POINTS_TO_WIN - (get_counter_about_user_reward(SUPERFAN_CONTEST_REWARD, false) || 0), 0].max
    
    respond_to do |format|
      format.json { render json: response.to_json }
    end
    
  end
  
end

