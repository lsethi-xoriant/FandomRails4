#!/bin/env ruby
# encoding: utf-8

class InstantwinController < ApplicationController
  layout "admin"
  DAYS_IN_MONTH = [nil, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]

  def create_wins
    @contest = Contest.find(params[:id])
    @contest.contest_periodicities.each do |cp|
      case cp.periodicity_type.name
      when "Giornaliera"
        createDailyWins(cp)
      when "Settimanale"
        createWeeklyWins(cp)
      when "Mensile"
        createMonthlyWins(cp)
      when "Custom"
        createCustomWins(cp,cp.periodicity_type.period)
      end
    end

    @contest.update_attributes(:generated => true)

  end

  def createDailyWins(contest)
    cdate = @contest.start_date.to_date
    while cdate <= @contest.end_date.to_date
      time = "#{(0..23).to_a.sample}:#{(0..59).to_a.sample}:#{(0..59).to_a.sample} UTC"
      wintime = Time.parse(cdate.strftime("%Y-%m-%d") +" "+ time)
      iw = Instantwin.new
      iw.contest_periodicity_id = contest.id
      iw.title = "Daily"
      iw.time_to_win = wintime
      iw.save
      cdate += 1
    end
  end

  def createWeeklyWins(contest)
    cdate = @contest.start_date.to_date
    while cdate < @contest.end_date.to_date
      time = "#{(0..23).to_a.sample}:#{(0..59).to_a.sample}:#{(0..59).to_a.sample} UTC"
      weekly_win_day = cdate + (0..6).to_a.sample

      while weekly_win_day > @contest.end_date.to_date
        weekly_win_day = cdate + (0..6).to_a.sample
      end

      wintime = Time.parse(weekly_win_day.strftime("%Y-%m-%d") +" "+ time)
      iw = Instantwin.new
      iw.contest_periodicity_id = contest.id
      iw.title = "Weekly"
      iw.time_to_win = wintime
      iw.save
      cdate += 7
    end
  end

  def createMonthlyWins(contest)

    cdate = @contest.start_date.to_date
    
    while cdate.year < @contest.end_date.to_date.year || (cdate.year == @contest.end_date.to_date.year && cdate.month <= @contest.end_date.to_date.month)
      
      time = "#{(0..23).to_a.sample}:#{(0..59).to_a.sample}:#{(0..59).to_a.sample} UTC"
      monthly_win_day = cdate + (0..(days_in_month(cdate.month, cdate.year)-cdate.day)).to_a.sample

      while monthly_win_day > @contest.end_date.to_date
        monthly_win_day = cdate + (0..(days_in_month(cdate.month, cdate.year)-cdate.day)).to_a.sample
      end

      wintime = Time.parse(monthly_win_day.strftime("%Y-%m-%d") +" "+ time)

      iw = Instantwin.new
      iw.contest_periodicity_id = contest.id
      iw.title = "monthly"
      iw.time_to_win = wintime
      iw.save
      cdate += 1.month
      cdate.change(day: 1)
    end

  end

  def createCustomWins(contest,period)
    cdate = @contest.start_date.to_date
    while cdate < @contest.end_date.to_date
      time = "#{(0..23).to_a.sample}:#{(0..59).to_a.sample}:#{(0..59).to_a.sample} UTC"
      win_day = cdate + (0..period).to_a.sample

      while win_day > @contest.end_date.to_date
        win_day = cdate + (0..period).to_a.sample
      end

      wintime = Time.parse(win_day.strftime("%Y-%m-%d") +" "+ time)
      iw = Instantwin.new
      iw.contest_periodicity_id = contest.id
      iw.title = "Custom"
      iw.time_to_win = wintime
      iw.save
      cdate += period
    end
  end

  def days_in_month(month, year = Time.now.year)
   return 29 if month == 2 && Date.gregorian_leap?(year)
   DAYS_IN_MONTH[month]
  end

  def play_ticket
    @message = ""
    @message_premio = ""
    @premio_class = ""

    risp = Hash.new;
    if current_user
      contest = Contest.find(params[:contest_id])      
      if !ContestPoint.where("contest.id=? AND user_id = ?",contest.id,current_user.id).first.nil? && ContestPoint.where("contest.id=? AND user_id = ?", contest.id, current_user.id).first.points/contest.conversion_rate > 0

        contest_points = ContestPoint.where("contest.id=? AND user_id = ?",contest.id,current_user.id).first

        time_current = Time.now.in_time_zone("Rome")
        if !checkWin(time_current,contest)

          #inserisco evento biglietto giocato e non vinto
          PlayticketEvent.create(:points_spent => contest.conversion_rate, :used_at => time_current, :winner => false, 
                                  :user_id => current_user.id)

          #tolgo i punti relativi al gioco di un biglietto
          contest_points.update_attribute(:points,contest_point.points - contest.conversion_rate)

          @message = "<div class='giocata non-vinto' style='display:none;'>NON HAI VINTO, RITENTA</div>"
        end
      else
        @message = "<div class='giocata non-vinto' style='display:none;'>Hai finito tutti i biglietti!</div>"
      end
    end

    risp['message'] = @message
    risp['message_premio'] = @message_premio
    risp['premio_class'] = @premio_class
    respond_to do |format|
      format.json { render :json => risp.to_json }
    end
  end

  #TODO MAXIBON
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

          #inserisco evento biglietto giocato e non vinto
          PlayticketEvent.create(:points_spent => contest.conversion_rate, :used_at => time_current, :winner => false, 
                                  :user_id => current_user.id)

          #tolgo i punti relativi al gioco di un biglietto
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
  def checkWin_mb(ctime,contest)
    contest.contest_periodicities.each do |cp|
      iw = Instantwin.where("contest_periodicity_id = ? AND instantwins.time_to_win<?",cp.id,ctime).order("instantwins.time_to_win DESC").limit(1)
      if iw.count > 0 && !check_already_win(iw.first) && !@win
        @win = true
        @prize = iw.first.contest_periodicity.instant_win_prizes.first
        
        #inserisco evento biglietto giocato e non vinto
        PlayticketEvent.create(:points_spent => contest.conversion_rate, :used_at => ctime, :winner => true, 
                                :user_id => current_user.id, :instantwin_id => iw.first.id)

        #tolgo i punti relativi al gioco di un biglietto
        @contest_points.update_attribute(:points,@contest_points.points - contest.conversion_rate)
        
        #invio mail all'utente
        #send_winner_email(iw,prize)
      end
    end
    return @win
  end
  
  #TODO MAXIBON
  def check_already_win(iw)
    return !iw.playticket_event.nil?
  end

  def checkWin(ctime,contest)
    win = false
    contest.contest_periodicities.each do |cp|
      iw = Instantwin.where("contest_periodicity_id = ? AND instantwins.time_to_win<?",cp.id,ctime).order("instantwins.time_to_win DESC").limit(1).first
      
    end
  end

  def checkWeeklyWin(time,t)
    iw = Instantwin.includes(:contest).where("contests.periodicity = '7' AND instantwins.time_to_win<?",time).order("instantwins.time_to_win DESC").limit(1).first

    if iw.blank? || ( ((time.to_date - ENV['START_DATE'].to_date).to_i / 7).to_i  != ((iw.time_to_win.to_date - ENV['START_DATE'].to_date).to_i / 7).to_i ) 
      #se non c'è un istant win antecedente o se è del giorno prima esco
      return false
    end
    
    if Ticket.where("instantwin_id=? and winner = true",iw.id).count > 0
      #se premio già vinto esco
      return false
    end

    if Ticket.includes(:instantwin, :instantwin => :contest).where("tickets.user_id=? and tickets.winner = true and contests.periodicity='7'",current_user.id).count > 0
      #se premio è già stato vinto dall'utente
      return false
    end

    t.used = true
    t.used_at = time
    t.winner = true
    t.instantwin_id = iw.id
    t.save
    @message = "<div class='giocata vinto' style='display:none;'>HAI VINTO 1 POSTO NELLA COOKING CLASS!</div>"
    @message_premio = "Hai vinto un posto alla Cooking Class con Bruno Barbieri partecipando al concorso Amadorabili Chef! A breve riceverai un'email all'indirizzo email
                      che hai utilizzato per la registrazione con  tutte le istruzioni per convalidare la tua vincita!"
    @premio_class = "cooking"

    # Mando un'email all'utente che ha vinto e all'amministrazione per avvisare della vincita.
    send_winner_email(iw)

    return true

  end

  def checkMontlyWin(time,t)
    iw = Instantwin.includes(:contest).where("contests.periodicity = '30' AND instantwins.time_to_win<?",time).order("instantwins.time_to_win DESC").limit(1).first

    if iw.blank? || (time.to_date.mon - iw.time_to_win.to_date.mon) != 0
      #se non c'è un istant win antecedente o se è del giorno prima esco
      return false
    end
    
    if Ticket.where("instantwin_id=? and winner = true",iw.id).count > 0
      #se premio già vinto da altro utente
      return false
    end

    if Ticket.includes(:instantwin, :instantwin => :contest).where("tickets.user_id=? and tickets.winner = true and contests.periodicity='30'",current_user.id).count > 0
      #se premio è già stato vinto dall'utente
      return false
    end

    t.used = true
    t.used_at = time
    t.winner = true
    t.instantwin_id = iw.id
    t.save
    @message = "<div class='giocata vinto' style='display:none;'>HAI VINTO UN ROBOT DA CUCINA!!!</div>"
    @message_premio = "Hai vinto un robot da cucina partecipando al concorso Amadorabili Chef! A breve riceverai un'email all'indirizzo email che hai utilizzato per la
registrazione con  tutte le istruzioni per convalidare la tua vincita!"
    @premio_class = "bimby"

    # Mando un'email all'utente che ha vinto e all'amministrazione per avvisare della vincita.
    send_winner_email(iw)

    return true
  end

  def checkDailyWin(time,t)
    iw = Instantwin.includes(:contest).where("contests.periodicity = '1' AND instantwins.time_to_win<?",time).order("instantwins.time_to_win DESC").limit(1).first
    
    if iw.blank? || (time.to_date - iw.time_to_win.to_date).to_i > 0
      #se non c'è un istant win antecedente o se è del giorno prima esco
      return false
    end
    
    if Ticket.where("instantwin_id=? and winner = true",iw.id).count > 0
      #se premio già vinto esco
      return false
    end

    if Ticket.includes(:instantwin, :instantwin => :contest).where("tickets.user_id=? and tickets.winner = true and contests.periodicity='1'",current_user.id).count > 0
      #se premio è già stato vinto dall'utente
      return false
    end

    t.used = true
    t.used_at = time
    t.winner = true
    t.instantwin_id = iw.id
    t.save
    @message = "<div class='giocata vinto' style='display:none;'>HAI VINTO UNA DINNER BOX!!!</div>"
    @message_premio = "Hai vinto una Dinner Box di prodotti Amadori partecipando al concorso Amadorabili Chef! A breve riceverai un'email all'indirizzo email che hai
utilizzato per la registrazione con  tutte le istruzioni per convalidare la tua vincita!"
    @premio_class = "dinner"

    # Mando un'email all'utente che ha vinto e all'amministrazione per avvisare della vincita.
    send_winner_email(iw)

    return true

  end

end