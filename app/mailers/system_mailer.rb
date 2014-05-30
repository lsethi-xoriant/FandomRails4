#!/bin/env ruby
# encoding: utf-8

class SystemMailer < ActionMailer::Base
  default from: ENV['EMAIL_ADDRESS']

  def share_content_email(user, address_to_send, calltoaction)
    @calltoaction = calltoaction
    mail(to: address_to_send, subject: "Ti hanno condiviso un contenuto da Maxibon - The Pool")
  end

  def welcome_mail(user)
    @cuser = user
    mail(to: user.email, subject: "Benvenuto su MAXIBON!")
  end  

  def win_mail(user, price, time_to_win)
    @price = price
  	@cuser = user
  	@ticket_id = time_to_win.unique_id
  	
  	if @price.title == "Un ingresso gratuito giornaliero all'Aquafan"
  	  @prize_won_message = "Hai vinto un ingresso gratuito giornaliero all’ Aquafan di Riccione."
  	  @message_win_validity = "Potrai utilizzare il tuo ingresso gratuito un qualsiasi giorno compreso fra il XX/XX/2014 e il XX/XX/2014. "
  	elsif @price.title == "Un pacchetto di 5 biglietti per il Maxiparty con David Guetta"
  	  @prize_won_message = "Hai vinto un pacchetto di 5 biglietti per te e i tuoi amici per il Maxiparty con David Guetta all’Aquafan di Riccione."
  	  @message_win_validity = "Potrai utilizzare il tuo ingresso il 3 agosto 2014."
  	elsif @price.title == "Un pacchetto di 5 biglietti per un evento serale Aquafan"
  	  @prize_won_message = "Hai vinto un pacchetto di 5 biglietti per un evento serale che si terrà all’Aquafan di Riccione nel mese di agosto.
Contatta Aquafan all’indirizzo info@aquafan.it o al numero +390541603050 per scoprire di quale evento si tratta."
      @message_win_validity = "Potrai utilizzare il tuo ingresso gratuito un qualsiasi giorno compreso fra il XX/XX/2014 e il XX/XX/2014."
  	end
  	
  	mail(to: user.email, subject: "MAXIBON - PARCO DIVERTIMENTI AQUAFAN 2014 – hai vinto #{ @price.title }")
  end

  def win_admin_notice_mail(user, price, time_to_win)
    @price = price
  	@cuser = user
  	@ticket_id = time_to_win.unique_id
  	
  	mail(to: [ "", "maxibon@shado.tv" ], subject: "MAXIBON - PARCO DIVERTIMENTI AQUAFAN 2014 – Un utente ha vinto #{ @price.title }")
  end

end
