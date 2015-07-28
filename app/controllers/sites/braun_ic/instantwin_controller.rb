#!/bin/env ruby
# encoding: utf-8

class Sites::BraunIc::InstantwinController < InstantwinController

  def play_ticket
    super
  end

  def send_winner_email(ticket_id, prize)
    SystemMailer.braun_win_mail(current_user).deliver_now
    SystemMailer.win_admin_notice_mail(current_user, prize, ticket_id, request).deliver_now
  end

end