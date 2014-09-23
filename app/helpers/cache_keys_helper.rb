require 'fandom_utils'

module CacheKeysHelper
  def notification_cache_key(user_id)
    "unread_notifications_#{user_id}"
  end
end
