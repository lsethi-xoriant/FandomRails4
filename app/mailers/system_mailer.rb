#!/bin/env ruby
# encoding: utf-8

class SystemMailer < ActionMailer::Base
  default from: "amadorabilichef@amadori.it"

  def share_mail(mailto, url, user, title)
  	@cuser = user
  	@link = url
    @ctatitle = title
    if @cuser
     mail(to: mailto, subject: "#{user.first_name} ti ha lanciato una sfida: mettiti alla prova!")
    else
  	 mail(to: mailto, subject: "Ti hanno lanciato una sfida: mettiti alla prova!")
    end
  end

  def welcome_mail(user)
    @cuser = user
    mail(to: user.email, subject: "Benvenuto su Amadorabili Chef!")
  end  

  def win_mail(user, price)

    case price.title
    when "daily"
      @price = "una Dinner Box di prodotti Amadori"
      @cooking_class = false
    when "weekly"
      @price = "un posto alla Cooking Class"
      @cooking_class = true
    when "monthly"
      @price = "un robot da cucina"
      @cooking_class = false
    end   

  	@cuser = user
  	mail(to: user.email, subject: "Concorso Amadorabili Chef – hai vinto #{ @price }")
  end

  def win_admin_notice_mail(user, price)
    
    case price.title
    when "daily"
      @price = "una Dinner Box di prodotti Amadori"
      @cooking_class = false
    when "weekly"
      @price = "un posto alla Cooking Class"
      @cooking_class = true
    when "monthly"
      @price = "un robot da cucina"
      @cooking_class = false
    end   

    @ticket = price.ticket

  	@cuser = user
  	mail(to: [ "infoconcorsi@ictlabs.it", "amadorabilichef@shado.tv" ], subject: "Concorso Amadorabili Chef – Un utente ha vinto #{ @price }")
  end

end
