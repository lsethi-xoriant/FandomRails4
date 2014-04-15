namespace :instant_win do

  START_DATE = "2013-12-3"
  END_DATE = "2014-3-12"
  DAYS_IN_MONTH = [nil, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]

  desc "Genera tutte le data e ora di vincita del concorso"
  task :generate_wins => :environment do
  	createWins  
  end

  def createWins
    contests = Contest.all
    contests.each do |contest|
    	case contest.periodicity
    	when "1"
    		createDailyWins(contest.id)
    	when "7"
    		createWeeklyWins(contest.id)
    	when "30"
    		createMonthlyWins(contest.id)
    	end
    			
    end
  end

  def createDailyWins(contestid)
  	cdate = START_DATE.to_date
  	while cdate <= END_DATE.to_date
	  	time = "#{(0..23).to_a.sample}:#{(0..59).to_a.sample}:#{(0..59).to_a.sample} UTC"
	  	wintime = Time.parse(cdate.strftime("%Y-%m-%d") +" "+ time)
	  	iw = Instantwin.new
	  	iw.contest_id = contestid
	  	iw.title = "daily"
	  	iw.time_to_win = wintime
	  	iw.save
	  	cdate += 1
	end
  end

  def createWeeklyWins(contestid)
  	cdate = START_DATE.to_date
  	while cdate < END_DATE.to_date
	  	time = "#{(0..23).to_a.sample}:#{(0..59).to_a.sample}:#{(0..59).to_a.sample} UTC"
	  	weekly_win_day = cdate + (0..6).to_a.sample
      while weekly_win_day > END_DATE.to_date
        weekly_win_day = cdate + (0..6).to_a.sample
      end
	  	wintime = Time.parse(weekly_win_day.strftime("%Y-%m-%d") +" "+ time)
	  	iw = Instantwin.new
	  	iw.contest_id = contestid
	  	iw.title = "weekly"
	  	iw.time_to_win = wintime
	  	iw.save
	  	cdate += 7
	  end
  end

  def createMonthlyWins(contestid)

    cdate = START_DATE.to_date
    while cdate < END_DATE.to_date
      time = "#{(0..23).to_a.sample}:#{(0..59).to_a.sample}:#{(0..59).to_a.sample} UTC"
      monthly_win_day = cdate + (0..27).to_a.sample
      while monthly_win_day > END_DATE.to_date
        monthly_win_day = cdate + (0..27).to_a.sample
      end
      wintime = Time.parse(monthly_win_day.strftime("%Y-%m-%d") +" "+ time)
      iw = Instantwin.new
      iw.contest_id = contestid
      iw.title = "monthly"
      iw.time_to_win = wintime
      iw.save
      cdate += 28
    end

  end

  def days_in_month(month, year = Time.now.year)
   return 29 if month == 2 && Date.gregorian_leap?(year)
   DAYS_IN_MONTH[month]
  end

end