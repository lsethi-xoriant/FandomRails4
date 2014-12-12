
class Sites::Forte::ApplicationController < ApplicationController
  include CallToActionHelper

  def index
    if user_signed_in?
      compute_save_and_notify_context_rewards(current_user)
    end

    return if cookie_based_redirect?
    
    init_ctas = request.site.init_ctas

    # warning: these 3 caches cannot be aggretated for some strange bug, probably due to how active records are marshalled 
    @tag = get_tag_from_params(params[:name])
    if @tag.nil? || params[:name] == "home_filter_all" 
      if params[:calltoaction_id]
        @calltoactions = [CallToAction.find_by_id(params[:calltoaction_id])]
      else
        @calltoactions = cache_short("stream_ctas_init_calltoactions") do
          CallToAction.active.limit(init_ctas).to_a
        end
      end
    else
      @calltoactions = cache_short("stream_ctas_init_calltoactions_#{params[:name]}") do
        CallToAction.active.includes(:call_to_action_tags).where("call_to_action_tags.tag_id=?", @tag.id).limit(init_ctas)
      end
    end
    
    @calltoactions_during_video_interactions_second = cache_short("stream_ctas_init_calltoactions_during_video_interactions_second") do
      init_calltoactions_during_video_interactions_second(@calltoactions)
    end

    @calltoactions_comment_interaction = init_calltoactions_comment_interaction(@calltoactions)

    @calltoactions_active_count = cache_short("stream_ctas_init_calltoactions_active_count") do
      CallToAction.active.count
    end

    @aux = init_aux()
    @aux[:calltoactions_reward] = Hash.new
    @calltoactions.each do |calltoaction|
      @aux[:calltoactions_reward][calltoaction.id] = calltoaction.rewards.first.cost if cta_locked?(calltoaction)
    end

    @calltoactions_active_interaction = Hash.new

    @home = true
  end

  def init_aux()
    {
      "tenant" => $site.id,
      "anonymous_interaction" => $site.anonymous_interaction,
      "main_reward_name" => MAIN_REWARD_NAME
    }
  end

  def gigya_socialize_redirect
    session[:gigya_socialize_redirect] = params.to_json
    redirect_to Rails.configuration.deploy_settings["sites"]["forte"]["profile_url"]
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

    profile_url = Rails.configuration.deploy_settings["sites"]["forte"]["profile_url"]
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
    
    respond_to do |format|
      format.json { render json: response.to_json }
    end
    
  end
  
end

