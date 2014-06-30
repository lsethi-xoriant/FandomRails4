module ProfileHelper
	
  # TODO: REDO.
	def user_progress ru, l, pl
		# ru rewarding_user, l livello che sto cercando di aggiudicarmi, pl livello precedente, quello che
		# ho conquistato per ultimo.
		delta_next_level = l.points - pl.points
		delta_next_user = ru.points - pl.points
		return (delta_next_user.to_f/delta_next_level.to_f)*100
	end

  def users_ranking(reward)
    reward.user_rewards.order("counter DESC, updated_at ASC").limit(10)
  end

  def users_before_and_after(reward = nil)
    unless reward
      reward = Tag.find_by_name("MAIN_REWARD").reward_tags.first.reward
    end

    current_user_reward = reward.user_rewards.find_by_user_id(current_user.id)

    if current_user_reward

      current_user_position_in_reward = reward.user_rewards.where("counter>=#{current_user_reward.counter}").order("counter ASC").count
      users_in_reward = reward.user_rewards

      if current_user_position_in_reward == 1  
        user_before_and_after_in_reward = current_user_in_first_position(current_user_position_in_reward, current_user_reward, users_in_reward)
      elsif current_user_position_in_reward == users_in_reward.count
        user_before_and_after_in_reward = current_user_in_last_position(current_user_position_in_reward, current_user_reward, users_in_reward)
      else  
        user_before_and_after_in_reward = current_user_in_middle_position(current_user_position_in_reward, current_user_reward, users_in_reward)
      end 

    end

    return user_before_and_after_in_reward
  end

  def users_fb_before_and_after(reward = nil)
    if current_user.facebook

      unless reward
        reward = Tag.find_by_name("MAIN_REWARD").reward_tags.first.reward
      end

      current_user_reward = reward.user_rewards.find_by_user_id(current_user.id)
      
      if current_user_reward

        current_user_fb_friends = current_user.facebook.get_connections("me", "friends").collect { |f| f["id"] }

        current_user_position_in_reward = reward.user_rewards.where("counter>=#{current_user_reward.counter} AND user_id IN (?)", current_user_fb_friends.map.collect { |u| u["id"] }).order("counter ASC").count
        users_in_reward = reward.user_rewards("user_id IN (?)", current_user_fb_friends.map.collect { |u| u["id"] })

        if current_user_position_in_reward == 1     
          user_before_and_after_in_reward = current_user_in_first_position(current_user_position_in_reward, current_user_reward, users_in_reward)
        elsif current_user_position_in_reward == users_in_reward.count
          user_before_and_after_in_reward = current_user_in_last_position(current_user_position_in_reward, current_user_reward, users_in_reward)
        else  
          user_before_and_after_in_reward = current_user_in_middle_position(current_user_position_in_reward, current_user_reward, users_in_reward)
        end 

      end

    end
    return user_before_and_after_in_reward
  end

  private

  def user_position(user_position_in_reward, user_reward)
    user_position = {
      :id => user_reward.user.id,
      :first_name => user_reward.user.first_name,
      :last_name => user_reward.user.last_name,
      :points => user_reward.counter,
      :position => user_position_in_reward
    }
  end

  def current_user_in_first_position(current_user_position_in_reward, current_user_reward, user_rewards)  
    user_position_in_reward = current_user_position_in_reward
    user_before_and_after_in_reward = Array.new
    index = 0

    user_before_and_after_in_reward[index] = user_position(user_position_in_reward, current_user_reward)

    user_rewards.where("counter<#{current_user_reward.counter}").order("counter DESC").limit(2).each do |user_reward|    
      user_position_in_reward = user_position_in_reward + 1
      index = index + 1
      user_before_and_after_in_reward[index] = user_position(user_position_in_reward, user_reward)
    end

    return user_before_and_after_in_reward
  end

  def current_user_in_last_position(current_user_position_in_reward, current_user_reward, user_rewards)
    index = 0
    user_position_in_reward = current_user_position_in_reward - 2
    user_before_and_after_in_reward = Array.new

    user_rewards.where("counter>=#{current_user_reward.counter} AND id<>#{current_user_reward.id}").order("counter ASC").limit(2).reverse.each do |user_reward|
      user_before_and_after_in_reward[index] = user_position(user_position_in_reward, user_reward)
      user_position_in_reward = user_position_in_reward + 1
      index = index + 1
    end

    user_before_and_after_in_reward[index] = user_position(user_position_in_reward, current_user_reward)
    return user_before_and_after_in_reward
  end

  def current_user_in_middle_position(current_user_position_in_reward, current_user_reward, user_rewards)
    user_before_and_after_in_reward = Array.new

    next_user_reward = user_rewards.where("counter>=#{current_user_reward.counter} AND id<>#{current_user_reward.id}").order("counter ASC").first
    user_before_and_after_in_reward[0] = user_position(current_user_position_in_reward - 1, next_user_reward)

    user_before_and_after_in_reward[1] = user_position(current_user_position_in_reward, current_user_reward)

    next_user_reward = user_rewards.where("counter<#{current_user_reward.counter}").order("counter DESC").limit(1).first
    user_before_and_after_in_reward[2] = user_position(current_user_position_in_reward + 1, next_user_reward)

    return user_before_and_after_in_reward
  end

end
