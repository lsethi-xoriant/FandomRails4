module InstantwinHelper

  def get_instant_win_coin_interaction_id()
    interaction_id = cache_short(get_instant_win_coin_interaction_id_cache_key()) do
      begin
        CallToAction.valid.find_by_name("coin_contest").interactions.first.id
      rescue Exception => exception
        CACHED_NIL
      end
    end

    cached_nil?(interaction_id) ? nil : interaction_id
  end

	# Returns days in a month
  #
  # month - month want to know days amount
  # year - specific year 
  def days_in_month(month, year = Time.now.year)
   return 29 if month == 2 && Date.gregorian_leap?(year)
   DAYS_IN_MONTH[month]
  end

	# Get number of tickets for specific user on specific contest
	#
	# user_id - id of current user
	# interaction_id - id of instantwin interaction 
	#
	def has_tickets(interaction_id)
	  reward_name = get_reward_name_for_contest(interaction_id)
	  tickets = get_counter_about_user_reward(reward_name) || 0
	  tickets > 0
	end

	def get_reward_name_for_contest(interaction_id)
	  cache_short(get_reward_name_for_contest_key(interaction_id)) do
	    Interaction.find(interaction_id).resource.reward.name
	  end
	end

	# Check if a user has already won a prize in the active contest
	#
	# user_id - id of current user
	# interaction_id - id of instantwin interaction
	#
	def user_already_won(interaction_id)
    if current_user
  	  user_interactions = cache_short(get_user_already_won_contest(current_user.id, interaction_id)) do
  	    UserInteraction.where("interaction_id = ? AND user_id = ? AND (aux->>'instant_win_id') IS NOT NULL", interaction_id, current_user.id).to_a
  	  end
    end

    if user_interactions
      if user_interactions.any?
        reward_id = user_interactions.first.aux["reward_id"]
        reward_title = Reward.find_by_id(reward_id).title
      end
    end

	 {
      win: user_interactions ? user_interactions.any? : false,
      message: reward_title
    }

	end

  def deduct_ticket(reward_name)
    get_reward_with_periods(reward_name).each do |reward|
      reward.update_attribute(:counter, reward.counter - 1)
    end
  end

end