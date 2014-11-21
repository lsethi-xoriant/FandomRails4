
class Sites::Coin::ApplicationController < ApplicationController

  def init_aux
    instant_win_interaction_id = get_instant_win_coin_interaction_id()
    {
      "tenant" => get_site_from_request(request)["id"],
      "anonymous_interaction" => get_site_from_request(request)["anonymous_interaction"],
      "main_reward_name" => MAIN_REWARD_NAME,
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
  
end