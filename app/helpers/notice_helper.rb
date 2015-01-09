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
  
  def get_notice_icon(reward)
    icon = asset_path('logo_community.png')
    reward.reward_tags.each do |tag|
      notification_icon = get_extra_fields!(tag)["notification-icon"]
      if notification_icon && upload_extra_field_present?(notification_icon)
        icon = get_upload_extra_field_processor(notification_icon,"medium")
      end
    end
    icon
  end
  
end