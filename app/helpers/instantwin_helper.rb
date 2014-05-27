module InstantwinHelper
	
	def update_contest_points user_id, points
	  
	  time_current = Time.now.in_time_zone("Rome")
	  
	  active_contests = Contest.where("start_date < ? AND end_date > ?", time_current, time_current)
	  
	  active_contests.each do |ac|
	    contestpoints = ContestPoint.where("user_id = ? AND contest_id = ?", user_id, ac.id)
      if contestpoints.count > 0
        contestpoints.first.update_attribute(:points,contestpoints.first.points + points)
      else
        ContestPoint.create(:user_id => user_id, :contest_id => contest_id, :points => points)
      end  
	  end
	  
	end
	
	def get_tickets user_id, contest_id
	  c = Contest.find(contest_id)
	  cp = ContestPoint.where("user_id = ? AND contest_id = ?", user_id, contest_id)
	  if cp.count > 0
	    return cp.points/c.conversion_rate
	  else
	    return 0
	  end
	end

end
