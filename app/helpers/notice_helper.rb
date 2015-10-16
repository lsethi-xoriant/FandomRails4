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
    if $site.assets["community_logo"].nil?
      icon = ""
    else
      icon = $site.assets["community_logo"]
    end
    property_tag = get_tag_with_tag_about_reward(reward, "property").first
    unless property_tag.nil?
      notification_icon = get_extra_fields!(property_tag)["logo"]
      icon = get_upload_extra_field_processor(notification_icon, "medium")
    end
    icon
  end

  def get_notice_icon_from_cta(cta)
    if $site.assets["community_logo"].nil?
      icon = ""
    else
      icon = $site.assets["community_logo"]
    end
    property_tag = get_tag_with_tag_about_call_to_action(cta, "property").first
    unless property_tag.nil?
      notification_icon = get_extra_fields!(property_tag)["logo"]
      icon = get_upload_extra_field_processor(notification_icon, "medium")
    end
    icon
  end

  def group_notice_by_date(notices)
    notices_list = []
    notices.each do |n|
      date = n.created_at.strftime("%d %B %Y")
      notices_list << { date: date, notice: get_notice_attributes(n) }
    end
    notices_list
  end

  def get_notice_attributes(notice)
    attributes = notice.attributes.symbolize_keys
    if notice.aux # structured notice
      if notice.aux["ref_type"] # not custom
        notice_logo = nil
        notice_image = nil
        notice_link = nil

        if notice.aux["ref_type"] == "reward"
          reward = Reward.find(notice.aux["ref_id"])
          notice_logo = get_notice_icon(reward)
          notice_image = reward.main_image.url
          if reward.call_to_action
            notice_link = "/call_to_action/#{reward.call_to_action.slug}"
          end
        else
          if notice.aux["ref_type"] == "call_to_action"
            cta = CallToAction.find(notice.aux["ref_id"])
            notice_image = cta.thumbnail.url(:medium)
          else # user_comment_interaction
            cta = UserCommentInteraction.find(notice.aux["ref_id"]).comment.interaction.call_to_action
          end
          notice_logo = get_notice_icon_from_cta(cta)
          notice_link = "/call_to_action/#{cta.slug}"
        end

        attributes[:notice_logo] = notice_logo
        attributes[:notice_image] = notice_image
        attributes[:notice_link] = notice_link
      end
    end
    attributes 
  end

end