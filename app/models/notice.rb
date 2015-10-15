class Notice < ActiveRecord::Base
  attr_accessible :user_id, :html_notice, :last_sent, :viewed, :read, :created_at, :updated_at, :aux

  belongs_to :user

  def self.mark_all_as_viewed
    Notice.where("viewed = FALSE").each do |n|
      n.update_attribute(:viewed, true)
    end
  end

  def self.mark_as_viewed(notice_id)
    Notice.find(notice_id).update_attribute(:viewed, true)
  end

  def self.mark_as_read(notice_id)
    Notice.find(notice_id).update_attribute(:read, true)
  end

  def self.mark_all_as_read
    Notice.where("read = FALSE").each do |n|
      n.update_attribute(:read, true)
    end
  end

  def send_to_user(request, send_mail)
    if user.aux
      aux_hash = JSON.parse(user.aux)
      if aux_hash['subscriptions']
        if aux_hash['subscriptions']['notifications'] == false
          return
        end
      end
    end
    if send_mail
      text = html_notice || aux[:text]
      SystemMailer.notification_mail(user.email, text, "Hai ricevuto una notifica su #{request.site.title}").deliver
    end

    update_attributes(:last_sent => Time.now, :viewed => false, :read => false)
  end

  def self.get_user_latest_notice(user, number_of_notice)
    Notice.where("user_id = ?", user.id).order("created_at DESC").limit(number_of_notice)
  end

end
