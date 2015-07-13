class Sites::BraunIc::RankingController < RankingController
  
  PER_PAGE = 10

  def show
    page = 1
    
    @aux_other_params = {
      ranking_info: compute_ranking(page, PER_PAGE)
    }
  end

  def update_ranking_pagination
    page = params[:page].to_i
    response = {
      ranking_info: compute_ranking(page, PER_PAGE)
    }

    respond_to do |format|
      format.json { render json: response.to_json }
    end 
  end

  def compute_ranking(page, per_page)
    user_rewards = UserReward.includes(:reward).where("user_rewards.period_id IS NULL AND rewards.name = 'point'").order("user_rewards.counter DESC, user_rewards.updated_at asc").references(:rewards).page(page).per(per_page)
    user_ids = user_rewards.map { |user_reward| user_reward.user_id }
    users = User.where(id: user_ids)

    # TODO: ADD MIN UPDATED AT
    timestamp = "#{from_updated_at_to_timestamp(user_rewards.maximum(:updated_at))}_#{from_updated_at_to_timestamp(users.maximum(:updated_at))}"
    ranking = cache_forever(get_ranking_cache_key(page, timestamp)) do   
      users_badge = compute_badges(user_ids)

      ranking_info = {
        ranking: [],
        num_pages: user_rewards.num_pages,
        page: page
      }
      user_rewards.each_with_index do |user_reward, index|
        ranking_info[:ranking] << {
          avatar: user_avatar(user_reward.user),
          position: ((index + 1) + (per_page * page)),
          badges: users_badge[user_reward.user_id],
          username: "#{user_reward.user.first_name} #{user_reward.user.last_name}",
          points: user_reward.counter
        }
      end

      ranking_info
    end
  end

  def compute_badges(user_ids)
    badge_tag = Tag.find("badge")
    category_tags = Tag.includes(tags_tags: :other_tag).where("other_tags_tags_tags.name = 'test'").order("tags.name asc").references(:tags_tags, :other_tag)

    users_badge = {}
    category_tags.each do |category_tag| 
      activated_at = CallToAction.includes(:call_to_action_tags).where("call_to_action_tags.tag_id = ?", category_tag.id).references(:call_to_action_tags).first.activated_at

      badge_inactive = Reward.includes(:reward_tags).where("reward_tags.tag_id = ?", category_tag.id).references(:reward_tags).order("rewards.cost asc").first
      user_to_rewards = get_user_to_rewards_with_tags_in_and([badge_tag, category_tag], user_ids)
      
      user_ids.each do |user_id|
        user_reward = user_to_rewards[user_id]
        inactive = false
        unless user_reward
          user_reward = badge_inactive
          inactive = true
        end

        image = inactive ? user_reward.not_awarded_image : user_reward.main_image

        (users_badge[user_id] ||= []) << adjust_braun_ic_reward(user_reward, inactive, activated_at)
      end
    end

    users_badge
  end

end