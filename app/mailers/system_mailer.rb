#!/bin/env ruby
# encoding: utf-8

class SystemMailer < ActionMailer::Base
  default from: ENV['EMAIL_ADDRESS']

  def share_interaction(user, address_to_send, calltoaction)
    @calltoaction = calltoaction
    mail(to: address_to_send, subject: "")
  end

  def welcome_mail(user)
    @cuser = user
    mail(to: user.email, subject: "Benvenuto su MAXIBON!")
  end  

  def win_mail(user, price, time_to_win)
    @price = price
  	@cuser = user
  	@ticket_id = time_to_win.unique_id
  	
  	mail(to: user.email, bcc: 'contestfandom@gmail.com', subject: "MAXIBON - PARCO DIVERTIMENTI AQUAFAN 2014 – Hai vinto #{ @price.title }")
  end

  def win_admin_notice_mail(user, price, time_to_win)
    @price = price
  	@cuser = user
  	@ticket_id = time_to_win.unique_id
  	
  	mail(to: [ "", "maxibon@shado.tv" ], subject: "MAXIBON - PARCO DIVERTIMENTI AQUAFAN 2014 – Un utente ha vinto #{ @price.title }")
  end
  
  def notification_mail(email, html_message, subject)
    @body = html_message
    mail(to: email, subject: subject)
  end

end
