#!/bin/env ruby
# encoding: utf-8

class InstantwinController < ApplicationController
  layout "admin"
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

  #TODO MAXIBON
  #
  # play a ticket for current user on the contest
  #
  # contest_id - id of the contest
  #
  def play_ticket_mb
    @ticketended = false
    @win = false

    risp = Hash.new;
    if current_user
      contest = Contest.find(params[:contest_id])
      @contest_points = ContestPoint.where("contest_id=? AND user_id = ?",contest.id,current_user.id)   
      if @contest_points.count > 0 && @contest_points.first.points/contest.conversion_rate > 0

        @contest_points = @contest_points.first

        time_current = Time.now.in_time_zone("Rome")
        if !checkWin_mb(time_current,contest)

          PlayticketEvent.create(:points_spent => contest.conversion_rate, :used_at => time_current, :winner => false, 
                                  :user_id => current_user.id)

          @contest_points.update_attribute(:points,@contest_points.points - contest.conversion_rate)

        end
      else
        @ticketended = true
      end
    end

    risp['winner'] = @win
    risp['ticketended'] = @ticketended
    risp['prize'] = @prize
    respond_to do |format|
      format.json { render :json => risp.to_json }
    end
  end
  
  #TODO MAXIBON
  #
  # check if a ticket is winner
  #
  # ctime - timestamp of played ticket
  # contest - contest for which the ticket is used
  #
  def checkWin_mb(ctime,contest)
    contest.contest_periodicities.each do |cp|
      iw = Instantwin.where("contest_periodicity_id = ? AND instantwins.time_to_win<?",cp.id,ctime).order("instantwins.time_to_win DESC").limit(1)
      if iw.count > 0 && !check_already_win(iw.first) && !@win
        @win = true
        @prize = iw.first.contest_periodicity.instant_win_prizes.first
        
        PlayticketEvent.create(:points_spent => contest.conversion_rate, :used_at => ctime, :winner => true, 
                                :user_id => current_user.id, :instantwin_id => iw.first.id)

        @contest_points.update_attribute(:points,@contest_points.points - contest.conversion_rate)
        
        #TODO send winner mail
        #send_winner_email(iw,prize)
      end
    end
    return @win
  end
  
  #TODO MAXIBON
  #
  # check if a prize is already winned
  #
  # iw - instantwin passed
  #
  def check_already_win(iw)
    return !iw.playticket_event.nil?
  end

end