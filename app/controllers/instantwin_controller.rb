#!/bin/env ruby
# encoding: utf-8

include InstantwinHelper
include ApplicationHelper
include CacheHelper

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
      if has_tickets(interaction.id) && !user_already_won(interaction.id)[:win]
        time = Time.now.utc
        instantwin, prize = check_win(interaction, time)
        if instantwin.nil?
          response[:win] = false
          response['message'] = "Non hai vinto, gioca ancora."
          aux = {"instant_win_id" => nil, "reward_id" => nil}
        else
          response[:win] = true
          response['message'] = prize.title
          aux = {"instant_win_id" => instantwin.id, "reward_id" => prize.id}
          assign_reward(current_user, prize.name, 1, request.site)
          send_winner_email(instantwin.reward_info['prize_code'], prize)
          expire_cache_key(get_user_already_won_contest(current_user.id, interaction.id))
          log_synced("assigning instant win to user", { 'instantwin_id' => instantwin.id })
        end
        deduct_ticket(interaction.resource.reward.name)
        create_or_update_interaction(current_user, interaction, nil, nil, aux.to_json)
        expire_cache_key(get_reward_points_for_user_key(interaction.resource.reward.name, current_user.id))
        response['prize'] = prize
      elsif !has_tickets(interaction.id)
        response['message'] = "Hai esaurito i biglietti"
        response[:win] = false
      else
        response['message'] = "Hai già vinto un premio"
        response[:win] = false
      end
      response["instantwin_tickets_counter"] = get_counter_about_user_reward(interaction.resource.reward.name)

    end

    response["main_reward_counter"] = get_counter_about_user_reward(MAIN_REWARD_NAME, true)

    respond_to do |format|
      format.json { render :json => response.to_json }
    end

  end

  def check_win(interaction, time)
    instantwin = interaction.resource.instantwins.where("valid_from <= ? AND (valid_to IS NULL or valid_to >= ?) AND won = false", time, time).first
    if instantwin.nil?
      [instantwin, nil]
    else
      reward = Reward.find(instantwin.reward_info['reward_id'])
      instantwin.update_attribute(:won, true)
      [instantwin, reward]
    end
  end

  def send_winner_email(time_to_win, price)
    SystemMailer.win_mail(current_user, price, time_to_win, request).deliver_now
    SystemMailer.win_admin_notice_mail(current_user, price, time_to_win, request).deliver_now
  end

end