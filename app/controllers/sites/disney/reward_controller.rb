class Sites::Disney::RewardController < RewardController

  # RewardController get_property_for_reward_catalogue override method in order to build reward catalogue page 
  # reward lists for all Disney properties
  def get_property_for_reward_catalogue
    nil
  end

end