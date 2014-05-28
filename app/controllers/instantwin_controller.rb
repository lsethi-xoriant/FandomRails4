#!/bin/env ruby
# encoding: utf-8

class InstantwinController < ApplicationController
  DAYS_IN_MONTH = [nil, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
  
  #
  # Returns days in a month
  #
  # month - month want to know days amount
  # year - specific year
  # 
  def days_in_month(month, year = Time.now.year)
   return 29 if month == 2 && Date.gregorian_leap?(year)
   DAYS_IN_MONTH[month]
  end

  #
  # play a ticket for current user on the contest
  #
  # contest_id - id of the contest
  #
  def play_ticket_mb

    win = false

    if current_user
      contest = Contest.active.find(params[:contest_id])
      contest_points = ContestPoint.where("contest_id=? AND user_id=?", contest.id, current_user.id)   
      if contest_points.count > 0 && contest_points.first.points/contest.conversion_rate > 0

        contest_points = contest_points.first

        time_current = Time.now.utc
        unless (win = check_win_mb(time_current, contest, contest_points))

          PlayticketEvent.create(:points_spent => contest.conversion_rate, :used_at => time_current, :winner => false, 
                                  :user_id => current_user.id)

          contest_points.update_attribute(:points, contest_points.points - contest.conversion_rate)

        end
      end
    end

    risp = {
      'winner' => win
      'points_updated' = get_current_contest_points current_user.id
      'prize' = @prize
    }

    respond_to do |format|
      format.json { render :json => risp.to_json }
    end
  end
  
  def check_win_mb ctime, contest, contest_points
    win = false
    contest.contest_periodicities.each do |cp|
      # TODO - I can't win prizes about days before.
      iw = Instantwin.where("contest_periodicity_id=? AND instantwins.time_to_win<?", cp.id, ctime).order("instantwins.time_to_win DESC").limit(1)
      if iw.count > 0 && !check_already_win(iw.first) && !win
        
        win = true

        # TODO - If possible transform @prize in prize and adjust the code.
        @prize = iw.first.contest_periodicity.instant_win_prizes.first
        
        PlayticketEvent.create(:points_spent => contest.conversion_rate, :used_at => ctime, :winner => true, 
                                :user_id => current_user.id, :instantwin_id => iw.first.id)

        contest_points.update_attribute(:points, contest_points.points - contest.conversion_rate)
        
        # TODO - send winner mail
        # send_winner_email(iw,prize)
      end
    end
    return win
  end
  
  #
  # Check if a prize is already winned
  #
  # iw - instantwin passed
  #
  def check_already_win iw
    return iw.playticket_event.present?
  end

end