module NoticeHelper

  def get_unread_notifications()
    if current_user
      user_id = current_user.id
      cache_short(notification_cache_key(user_id)) do
        Notice.where("user_id = ? AND viewed = FALSE", user_id).to_a
      end
    else
      []
    end
  end
  
  def get_unread_notifications_count()
    get_unread_notifications().count
  end
  
  def create_notice(params)
    expire_cache_key(notification_cache_key(params[:user_id]))
    Notice.create(params)
  end
  
end