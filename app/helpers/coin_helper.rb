module CoinHelper
  
  def assignPromocode()
    ActiveRecord::Base.transaction do
      promocodes = Setting.find_by_key(:promocodes)
      promocodes_values = promocodes.value.split(",")
      promocode = promocodes_values.first
      current_user.update_attribute(:aux, promocode)
      promocodes_without_user_promocode = promocodes_values.delete(promocode)
      promocodes.update_attribute(:value, promocodes_values.join(","))
    end
    SystemMailer.welcome_mail(current_user).deliver
  end

  def storeLocations()
    locations = cache_short(get_coin_locations_cache_key()) do
      Setting.find_by_key("coin.locations") || CACHED_NIL
    end
    cached_nil?(locations) ? nil : locations.value.split(",")
  end

  def assignRegistrationReward()
    assign_reward(current_user, MAIN_REWARD_NAME, 1, request.site)
  end

end
