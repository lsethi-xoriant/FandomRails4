namespace :instant_win do

  START_DATE = "2013-12-3"
  END_DATE = "2014-3-12"
  DAYS_IN_MONTH = [nil, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]

  desc "Genera tutte le data e ora di vincita del concorso"
  task :generate_wins => :environment do
  	createWins
  end
  
  #TODO MAXIBON
  task :generate_maxibon_wins => :environment do
    createMaxibonWins
  end

  #TODO MAXIBON
  def createMaxibonWins
    Apartment::Database.switch("fandom")
    contest = Contest.create(:title => "Maxibon Acquafun", :start_date => "03/06/2014 11:00:00", :end_date => "01/08/2014 23:59:59", :property_id => Property.first.id)
    periodicity_type_daily = PeriodicityType.create(:name => "Giornaliera", :period => 1)
    periodicity_type_maxibon_custom = PeriodicityType.create(:name => "60gg", :period => 60) 
    contest_periodicity_1 = ContestPeriodicity.create(:title => "Biglietto Aquafun 1", :periodicity_type_id => periodicity_type_daily.id, :contest_id => contest.id)
    contest_periodicity_2 = ContestPeriodicity.create(:title => "Biglietto Aquafun 2", :periodicity_type_id => periodicity_type_daily.id, :contest_id => contest.id)
    contest_periodicity_3 = ContestPeriodicity.create(:title => "Pacchetto eventi", :periodicity_type_id => periodicity_type_maxibon_custom.id, :contest_id => contest.id)
    InstantWinPrize.create(:title => "Ingresso Aquafun", :description => "Ingresso gratuito all'Aquafun di riccione", :contest_periodicity_id => contest_periodicity_1.id)
    InstantWinPrize.create(:title => "Ingresso Aquafun", :description => "Ingresso gratuito all'Aquafun di riccione", :contest_periodicity_id => contest_periodicity_2.id)
    InstantWinPrize.create(:title => "Pack Eventi Aquafun", :description => "Pacchetto di 5 biglietti di ingresso a eventi Aquafun", :contest_periodicity_id => contest_periodicity_3.id)
    create_wins_mb(contest)
  end

  #TODO MAXIBON
  def create_wins_mb(contest)
    
    contest.contest_periodicities.each do |cp|
      case cp.periodicity_type.name
      when "Giornaliera"
        createDailyWins(contest,cp)
      when "60gg"
        create60ggWins(contest,cp)
      end
    end

    contest.update_attributes(:generated => true)
  end
  
  #TODO MAXIBON
  def create60ggWins(contest,cp)
    beginning_date = contest.start_date.to_date
    day_range = (contest.end_date.to_date - contest.start_date.to_date).to_i
    total_prizes = 20
    winner_inserted = 0
    
    while winner_inserted < total_prizes
      offest_day_win = (0..day_range).to_a.sample
      winday = beginning_date + offest_day_win
      winhour = "#{(0..23).to_a.sample}:#{(0..59).to_a.sample}:#{(0..59).to_a.sample} UTC"
      wintime = Time.parse(winday.strftime("%Y-%m-%d") +" "+ winhour)
      iw = Instantwin.new
      iw.contest_periodicity_id = cp.id
      iw.title = "Random"
      iw.time_to_win = wintime
      iw.save
      winner_inserted += 1
    end
  end

  def createDailyWins(contest,cp)
    cdate = contest.start_date.to_date
    while cdate <= contest.end_date.to_date
      time = "#{(0..23).to_a.sample}:#{(0..59).to_a.sample}:#{(0..59).to_a.sample} UTC"
      wintime = Time.parse(cdate.strftime("%Y-%m-%d") +" "+ time)
      iw = Instantwin.new
      iw.contest_periodicity_id = cp.id
      iw.title = "Daily"
      iw.time_to_win = wintime
      iw.save
      cdate += 1
    end
  end

  def days_in_month(month, year = Time.now.year)
   return 29 if month == 2 && Date.gregorian_leap?(year)
   DAYS_IN_MONTH[month]
  end

end