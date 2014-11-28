#!/bin/env ruby
# encoding: utf-8

class SystemMailer < ActionMailer::Base
  default from: Rails.configuration.deploy_settings.fetch("mailer", {}).fetch("default_from", MAILER_DEFAULT_FROM)

  def share_interaction(user, address_to_send, calltoaction)
    @calltoaction = calltoaction
    mail(to: address_to_send, subject: "")
  end

  def welcome_mail(user)
    @cuser = user
    mail(to: user.email, subject: "Benvenuto!")
  end  

  def win_mail(user, reward, time_to_win, request)
    subject = Rails.configuration.deploy_settings["sites"][get_site_from_request(request)["id"]]["title"]
    @reward = reward
  	@cuser = user
  	@ticket_id = time_to_win
  	
  	mail(to: user.email, bcc: 'contestfandom@gmail.com', subject: "#{subject} - #{@reward.title}")
  end

  def win_admin_notice_mail(user, reward, time_to_win, request)
    subject = Rails.configuration.deploy_settings["sites"][get_site_from_request(request)["id"]]["title"]
    @reward = reward
  	@cuser = user
  	@ticket_id = time_to_win
  
  	mail(to: [ "", "concorsi@shado.tv" ], subject: "#{subject} - #{@reward.title}")
  end
  
  def notification_mail(email, html_message, subject)
    @body = html_message
    mail(to: email, subject: subject)
  end

end
