module InstantwinHelper
	
	def update_contest_points user_id, points
		begin
		  time_current = Time.now.utc 
		  
		  Contest.where("start_date<? AND end_date>?", time_current, time_current).each do |ac|
		    contestpoints = ContestPoint.where("user_id=? AND contest_id=?", user_id, ac.id)
	      if contestpoints.count > 0
	        contestpoints.first.update_attribute(:points, contestpoints.first.points + points)
	      else
	        ContestPoint.create(:user_id => user_id, :contest_id => ac.id, :points => points)
	      end  
		  end
		rescue Exception => e
		end
	  
	end
	
	def get_current_contest_points user_id
		time_current = Time.now.utc 
		if (c = Contest.where("start_date<? AND end_date>?", time_current, time_current)).any? &&
			 (cp = ContestPoint.find_by_user_id_and_contest_id(user_id, c.first.id))
		    return cp.points/c.first.conversion_rate
		else
			return 0
		end
	end

end
