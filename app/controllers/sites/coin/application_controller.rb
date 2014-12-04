
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

  def init_aux

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
        current_user.user_interactions.includes(:interaction).where("interactions.resource_type = 'Share' AND user_interactions.created_at >= ?", Time.now.in_time_zone("Rome").beginning_of_day).any?
      end
    else
      false
    end
  end
  
end