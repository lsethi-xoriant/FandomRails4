module CacheExpireHelper
  def assign_reward_expires(user_id, reward_name)
    expire_cache_key(get_cta_to_reward_statuses_by_user_cache_key(user_id))
    expire_cache_key(get_status_rewar_image_key(reward_name, user_id))
    expire_cache_key(get_user_rewards_cache_key(user_id))
  end
  
  def buy_reward_catalogue_expires(currency_name, user_id)
    expire_cache_key(get_user_rewards_cache_key(user_id))
    expire_cache_key(get_reward_points_for_user_key(currency_name, user_id))
    expire_cache_key(get_catalogue_user_rewards_ids_key(user_id))
  end
end
