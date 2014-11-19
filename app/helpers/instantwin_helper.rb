module InstantwinHelper
	
	DAYS_IN_MONTH = [nil, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
	
	# Returns days in a month
  #
  # month - month want to know days amount
  # year - specific year 
  def days_in_month(month, year = Time.now.year)
   return 29 if month == 2 && Date.gregorian_leap?(year)
   DAYS_IN_MONTH[month]
  end
	
	#
	# Get number of ticket for a specific user on a specific contest
	#
	# user_id - id of current user
	# interaction_id - id of interaction instantwin 
	#
	def has_tickets(interaction_id)
	  reward_name = get_reward_name_for_contest(interaction_id)
	  tickets = get_counter_about_user_reward(reward_name)
	  tickets > 0
	end
	
	def get_reward_name_for_contest(interaction_id)
	  cache_short(get_reward_name_for_contest_key(interaction_id)) do
	    Interaction.find(interaction_id).resource.reward.name
	  end
	end
	
	#
	# Check if a user has already won a prize in the active contes
	#
	# user_id - id of current user
	# interaction_id - id of interaction instantwin
	#
	def user_already_won(interaction_id)
	  winner = cache_short(get_user_already_won_contest(current_user.id, interaction_id)) do
	    UserInteraction.where("interaction_id = ? AND user_id = ? AND (aux->>'instant_win_id') IS NOT NULL", interaction_id, current_user.id).to_a
	  end
	  winner.count > 0
	end

  def deduct_ticket(reward_name)
    get_reward_with_periods(reward_name).each do |reward|
      reward.update_attribute(:counter, reward.counter - 1)
    end
  end

end
