#!/bin/env ruby
# encoding: utf-8

include InstantwinHelper

class InstantwinController < ApplicationController
  DAYS_IN_MONTH = [nil, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]

  before_filter :authorize_user, except: :show_winners

  def authorize_user
    authorize! :play, :contest
  end
  
  def show_winners
    @winners = Array.new
    today_midnight = DateTime.now.midnight.utc
    wins = PlayticketEvent.where("winner = true AND used_at < ?", today_midnight)
    @winner_per_page = 12
    
    wins.each do |win_event|
      winner = Hash.new
      winner['avatar'] = user_avatar(win_event.user)
      winner['name'] = "#{win_event.user.first_name} #{win_event.user.last_name}"
      winner['prize'] = "#{win_event.contest_periodicity.instant_win_prizes.first.title}"
      @winners.push(winner)
    end
  end
  
  # Returns days in a month
  #
  # month - month want to know days amount
  # year - specific year 
  def days_in_month(month, year = Time.now.year)
   return 29 if month == 2 && Date.gregorian_leap?(year)
   DAYS_IN_MONTH[month]
  end

  # TODO: maxibon
  #
  # play a ticket for current user on the contest
  #
  # contest_id - id of the contest
  def play_ticket_mb
    @user_already_wins = false
    if current_user
      contest = Contest.active.find(params[:contest_id])
      contest_points = ContestPoint.where("contest_id=? AND user_id=?", contest.id, current_user.id)   
      if contest_points.count > 0 && contest_points.first.points/contest.conversion_rate > 0

        contest_points = contest_points.first

        time_current = Time.now.utc
        
        win = check_win_mb(time_current,contest,contest_points)
        
        if !win

          PlayticketEvent.create(:points_spent => contest.conversion_rate, :used_at => time_current, :winner => false, 
                                  :user_id => current_user.id)

          contest_points.update_attribute(:points, contest_points.points - contest.conversion_rate)

        end
      end
    end

    risp = Hash.new
    risp = {
      'winner' => win,
      'points_updated' => (get_current_contest_points current_user.id),
      'prize' => @prize,
      'prize_image' => (@prize ? @prize.image.url : ""),
      'user_already_wins' => @user_already_wins
    }

    respond_to do |format|
      format.json { render :json => risp.to_json }
    end
  end
  
  # TODO: maxibon
  #
  # check if a ticket is winner
  #
  # time_current - timestamp of played ticket
  # contest - contest for which the ticket is used
  def check_win_mb(time_current,contest,contest_points)
    win = false
    contest.contest_periodicities.each do |contest_periodicity|
      time_to_win_list = Instantwin.where("contest_periodicity_id = ? AND instantwins.time_to_win_start<= ? AND (instantwins.time_to_win_end IS NULL OR ? <= instantwins.time_to_win_end)",contest_periodicity.id,time_current,time_current).order("instantwins.time_to_win_start DESC").limit(1)
      if time_to_win_list.count > 0
        time_to_win = time_to_win_list.first 
        if !(check_already_win_by_user(contest_periodicity) || check_already_win(time_to_win) || win )
          win = true
          @prize = time_to_win.contest_periodicity.instant_win_prizes.first
          PlayticketEvent.create(:points_spent => contest.conversion_rate, :used_at => time_current, :winner => true, 
                                  :user_id => current_user.id, :instantwin_id => time_to_win.id, :contest_periodicity_id => contest_periodicity.id)
  
          contest_points.update_attribute(:points, contest_points.points - contest.conversion_rate)
          
          send_winner_email(time_to_win,@prize)
        end

      end
    end
    return win
  end
  

  # TODO: maxibon
  #
  # Check if a prize is already winned
  #
  # iw - instantwin passed
  #
  def check_already_win iw
    return iw.playticket_event.present?
  end
  
  # TODO: maxibon
  #
  # Check if a prize is already winned by current user
  #
  # iw - instantwin passed
  #
  def check_already_win_by_user contest_periodicity
    @user_already_wins = PlayticketEvent.where("user_id=? AND winner=true",current_user.id).present?
    return @user_already_wins
  end
  
  def send_winner_email(time_to_win,price)
    SystemMailer.win_mail(current_user, price, time_to_win).deliver
    SystemMailer.win_admin_notice_mail(current_user, price, time_to_win).deliver
  end

end