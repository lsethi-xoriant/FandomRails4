#!/bin/env ruby
# encoding: utf-8

class SystemMailer < ActionMailer::Base

  def share_interaction(user, to, calltoaction, aux = {})
    @cuser = user
    @calltoaction = calltoaction
    @aux = aux
    subject = @aux.has_key?(:subject) ? @aux[:subject] : $site.title
    mail(to: to, subject: "#{subject} - Un tuo amico ti ha condiviso un contenuto")
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
  
  def orzoro_cup_redeem_confirmation(cup_obj)
    subject = "Congratulazioni! Hai ordinato le tazze"
    @form_cup = cup_obj
    @cup_tag_extra_fields = get_extra_fields!(Tag.find_by_name("cup-redeemer"))
    @assets_extra_fields = get_extra_fields!(Tag.find_by_name("assets"))
    mail(to: cup_obj['identity']['email'], subject: subject)
  end

  def orzoro_newsletter_confirmation(info)
    subject = "Congratulazioni! Sei iscritto alla newsletter di Orzoro!"
    @info = info
    @assets_extra_fields = get_extra_fields!(Tag.find_by_name("assets"))
    mail(to: info[:email], subject: subject)
  end

  def orzoro_registration_confirmation_from_cups(cup_obj, user)
    subject = "Conferma il tuo indirizzo mail!"
    @form_cup = cup_obj
    @cup_tag_extra_fields = get_extra_fields!(Tag.find_by_name("cup-redeemer"))
    @assets_extra_fields = get_extra_fields!(Tag.find_by_name("assets"))
    @link = "#{root_url}complete_registration_from_cups/#{user.email}/#{user.confirmation_token}"
    mail(to: cup_obj['identity']['email'], subject: subject)
  end

  def orzoro_registration_confirmation_from_newsletter(info, user)
    subject = "Conferma il tuo indirizzo mail!"
    @info = info
    @assets_extra_fields = get_extra_fields!(Tag.find_by_name("assets"))
    @link = "#{root_url}complete_registration_from_newsletter/#{user.email}/#{user.confirmation_token}"
    mail(to: info[:email], subject: subject)
  end

end
