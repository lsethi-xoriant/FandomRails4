
class Sites::Ballando::CallToActionController < CallToActionController

  def setup_update_interaction_response_info(response) 
    response["contest_points_counter"] = [SUPERFAN_CONTEST_POINTS_TO_WIN - (get_counter_about_user_reward(SUPERFAN_CONTEST_REWARD, false) || 0), 0].max
    response
  end
  
end