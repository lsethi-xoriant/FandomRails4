#!/bin/env ruby
# encoding: utf-8

class SystemMailer < ActionMailer::Base

  def share_interaction(user, to, calltoaction, aux = {})
    subject = $site.title
    @cuser = user
    @calltoaction = calltoaction
    mail(to: to, subject: "#{subject} - Un tuo amico di ha condiviso un contenuto")
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
  	
  	mail(to: user.email, bcc: 'contestfandom@gmail.com', subject: "#{subject} - Hai vinto #{@reward.title}")
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
