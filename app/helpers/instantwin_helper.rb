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
	def has_tickets()
	  reward_name = get_instantwin_ticket_name()
	  tickets = get_counter_about_user_reward(reward_name) || 0
	  tickets > 0
	end

  def get_instantwin_ticket_name()
    $site.instantwin_ticket_name
  end

	# Check if a user has already won a prize in the active contest
	#
	# user_id - id of current user
	# interaction_id - id of instantwin interaction
	#
	def user_already_won(interaction_id)
    if current_user
  	  user_interactions = UserInteraction.where("interaction_id = ? AND user_id = ? AND (aux->>'instant_win_id') IS NOT NULL", interaction_id, current_user.id).to_a
      if user_interactions.any?
        reward_id = user_interactions.first.aux["reward_id"]
        reward_title = Reward.find(reward_id).title
      end
    end
    
    {
      win: (user_interactions.present? && user_interactions.any?),
      message: reward_title
    }
	end

  def deduct_ticket()
    instantwin_ticket_name = get_instantwin_ticket_name()
    get_reward_with_periods(instantwin_ticket_name).each do |user_reward|
      user_reward.update_attribute(:counter, (user_reward.counter - 1))
    end
  end

  def check_win(interaction, time)
    instantwin = interaction.resource.instantwins.where("valid_from <= ? AND (valid_to IS NULL or valid_to >= ?) AND won = false", time, time).first
    if instantwin.nil?
      [nil, nil]
    else
      reward = Reward.find(instantwin.reward_info['reward_id'])
      instantwin.update_attribute(:won, true)
      [instantwin, reward]
    end
  end

  def send_winner_email(ticket_id, prize)
    SystemMailer.win_mail(current_user, prize, ticket_id, request).deliver_now
    SystemMailer.win_admin_notice_mail(current_user, prize, ticket_id, request).deliver_now
  end

end