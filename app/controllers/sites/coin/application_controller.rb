
class Sites::Coin::ApplicationController < ApplicationController

  def init_aux

    if cookies[:from_registration].blank?
      from_registration = false
    else
      connect_from_page = cookies[:from_registration]
      cookies.delete(:from_registration)
      from_registration = true
    end

    instant_win_interaction_id = get_instant_win_coin_interaction_id()
    {
      "tenant" => get_site_from_request(request)["id"],
      "anonymous_interaction" => get_site_from_request(request)["anonymous_interaction"],
      "main_reward_name" => MAIN_REWARD_NAME,
      "share_interaction_daily_done" => share_interaction_daily_done?(),
      "from_registration" => from_registration,
      "instant_win_info" => {
        "interaction_id" => instant_win_interaction_id,
        "won" => user_already_won(instant_win_interaction_id),
        "in_progress" => false
      }
    }
  end

  def registration_fully_completed?
    current_user.province.present? && current_user.birth_date.present?
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