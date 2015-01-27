require 'fandom_utils'

module CacheExpireHelper
  def assign_reward_expires(user_id)
    expire_cache_key(get_cta_to_reward_statuses_by_user_cache_key(user_id))
  end
end
