module InstantwinHelper
	
	def update_contest_points user_id, contest_id, points
	  contestpoints = ContestPoint.where("user_id = ? AND contest_id = ?", user_id, contest_id)
		if contestpoints.count > 0
		  contestpoints.first.update_attribute(:points,contestpoints.first.points + points)
		else
		  ContestPoint.create(:user_id => user_id, :contest_id => contest_id, :points => points)
		end
	end

end
