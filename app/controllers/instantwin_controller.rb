#!/bin/env ruby
# encoding: utf-8

class InstantwinController < ApplicationController

  def show_winners
    @winners = Array.new
    today_midnight = DateTime.now.midnight.utc
    wins = PlayticketEvent.where("winner = true AND used_at < ?", today_midnight)
    @winner_per_page = 9

    wins.each do |win_event|
      winner = Hash.new
      winner['avatar'] = user_avatar(win_event.user)
      winner['name'] = "#{win_event.user.first_name} #{win_event.user.last_name}"
      winner['prize'] = "#{win_event.contest_periodicity.instant_win_prizes.first.title}"
      @winners.push(winner)
    end
  end

  def play_ticket

    response = {}

    if current_user

      interaction = Interaction.find(params[:interaction_id])
      if has_tickets() && !user_already_won(interaction.id)[:win]
        time = Time.now.utc
        log_synced("instant win attempted", { "interaction_id" => interaction.id })
        instantwin, prize = check_win(interaction, time)
        if instantwin.nil?
          response[:win] = false
          response["message"] = "Non hai vinto, gioca ancora."
          aux = { "instant_win_id" => nil, "reward_id" => nil }
          log_synced("instant loss", { "interaction_id" => interaction.id })
        else
          response[:win] = true
          response["message"] = prize.title
          aux = { "instant_win_id" => instantwin.id, "reward_id" => prize.id }
          assign_reward(current_user, prize.name, 1, request.site)
          send_winner_email(instantwin.reward_info["prize_code"], prize)
          log_synced("assigning instant win to user", { "interaction_id" => interaction.id, "instantwin_id" => instantwin.id })
        end
        deduct_ticket()
        create_or_update_interaction(current_user, interaction, nil, nil, aux.to_json)
        response["prize"] = prize
      elsif !has_tickets()
        log_synced("instant win error: no tickets", { "interaction_id" => interaction.id })
        response["message"] = "Hai esaurito i biglietti"
        response[:win] = false
      else
        log_synced("instant win error: already won", { "interaction_id" => interaction.id })
        response["message"] = "Hai già vinto un premio"
        response[:win] = false
      end
      response["instantwin_tickets_counter"] = get_counter_about_user_reward(get_instantwin_ticket_name())

    end

    respond_to do |format|
      format.json { render :json => response.to_json }
    end

  end

end