#!/bin/env ruby
# encoding: utf-8

class SystemMailer < ActionMailer::Base
  default from: "noreply@maxibon.it"

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
    mail(to: user.email, subject: "Benvenuto su MAXIBON!")
  end  

  def win_mail(user, price)

    @price = price

  	@cuser = user
  	mail(to: user.email, subject: "MAXIBON - PARCO DIVERTIMENTI AQUAFAN 2014 – hai vinto #{ @price.title }")
  end

  def win_admin_notice_mail(user, price)
    
    @price = price

  	@cuser = user
  	mail(to: [ "", "maxibon@shado.tv" ], subject: "MAXIBON - PARCO DIVERTIMENTI AQUAFAN 2014 – Un utente ha vinto #{ @price.title }")
  end

end
