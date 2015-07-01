
class Sites::Coin::ApplicationController < ApplicationController

  def complete_for_contest
    user_params = params[:user]
    
    required_attrs = get_site_from_request(request)["required_attrs"] + ["province", "birth_date", "location", "contest", "role"]
    user_params = user_params.merge(required_attrs: required_attrs)
    user_params[:aux][:$validating_model] = "UserAux"  
    user_params[:major_date] = COIN_CONTEST_START_DATE

    response = {}
    if !current_user.update_attributes(user_params)
      response[:errors] = current_user.errors.full_messages
    else
      log_audit("registration completion", { 'form_data' => params[:user], 'user_id' => current_user.id })
    end

    respond_to do |format|
      format.json { render json: response.to_json }
    end
  end

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
        if get_site_from_request(request)["id"] == "coin"
          calltoaction = get_all_active_ctas().sample
          @calltoactions = [calltoaction]
        else
          @calltoactions = cache_short("stream_ctas_init_calltoactions") do
            CallToAction.active.limit(init_ctas).to_a
          end
        end
      end
    else
      @calltoactions = cache_short("stream_ctas_init_calltoactions_#{params[:name]}") do
        CallToAction.active.includes(:call_to_action_tags).where("call_to_action_tags.tag_id=?", @tag.id).references(:call_to_action_tags).limit(init_ctas)
      end
    end
    
    @calltoactions_active_count = cache_short("stream_ctas_init_calltoactions_active_count") do
      CallToAction.active.count
    end

    @calltoaction_info_list = build_cta_info_list_and_cache_with_max_updated_at(@calltoactions)
    
    if current_user
      @current_user_info = build_current_user().to_json
    end

    @aux = init_coint_aux

  end

  def init_coint_aux

    if cookies[:from_registration].blank?
      from_registration = false
    else
      connect_from_page = cookies[:from_registration]
      cookies.delete(:from_registration)
      from_registration = true
    end

    instant_win_interaction_id = get_instant_win_coin_interaction_id()
    user_win_info = user_already_won(instant_win_interaction_id)
    user_win = user_win_info[:win] ? user_win_info[:win] : nil

    {
      "tenant" => get_site_from_request(request)["id"],
      "anonymous_interaction" => get_site_from_request(request)["anonymous_interaction"],
      "main_reward_name" => MAIN_REWARD_NAME,
      "share_interaction_daily_done" => share_interaction_daily_done?(),
      "from_registration" => from_registration,
      "instant_win_info" => {
        "interaction_id" => instant_win_interaction_id,
        "win" => user_win,
        "message" => user_win_info[:message],
        "in_progress" => false
      }
    }
  end

  def show_stores
  end

  def registration_fully_completed?
    if current_user.aux.present?
      aux = JSON.parse(current_user.aux)
      aux_validate = aux["contest"] == "true" && aux["terms"] == "true"
      current_user.province.present? && current_user.birth_date.present? && aux_validate
    else
      false
    end
  end

  def show_cookies_policy
  end

  def show_privacy_policy
  end

  def share_interaction_daily_done?
    if current_user
      cache_short(get_share_interaction_daily_done_cache_key(current_user.id)) do
        current_user.user_interactions.includes(:interaction).where("interactions.resource_type = 'Share' AND user_interactions.created_at >= ?", Time.now.in_time_zone("Rome").beginning_of_day).references(:interactions).any?
      end
    else
      false
    end
  end
  
end