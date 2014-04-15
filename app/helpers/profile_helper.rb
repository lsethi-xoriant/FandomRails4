module ProfileHelper
	
	def user_progress ru, l, pl
		# ru rewarding_user, l livello che sto cercando di aggiudicarmi, pl livello precedente, quello che
		# ho conquistato per ultimo.
		delta_next_level = l.points - pl.points
		delta_next_user = ru.points - pl.points
		return (delta_next_user.to_f/delta_next_level.to_f)*100
	end

end
