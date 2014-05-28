module InstantwinHelper
	
	#
	# Update the points of an user for the contests
	#
	# user_id - id of user
	# points - points gained by the user
	#
	def update_contest_points user_id, points
		begin	  
		  Contest.active.each do |ac|
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
	
	#
	# Get number of ticket for a specific user on a specific contest
	#
	# user_id - id of current user
	#
	def get_current_contest_points user_id
		if (c = Contest.active.any? && (cp = ContestPoint.find_by_user_id_and_contest_id(user_id, c.first.id))
		    return cp.points/c.first.conversion_rate
		else
			return 0
		end
	end

end
