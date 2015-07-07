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
    user_rewards = UserReward.includes(:reward).where("user_rewards.period_id IS NULL AND rewards.name = 'point'").order("user_rewards.counter asc, user_rewards.updated_at asc").references(:rewards).page(page).per(per_page)
    user_ids = user_rewards.map { |user_reward| user_reward.user_id }
    users = User.where(id: user_ids)

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
    reward_ids = get_rewards_with_tags_in_and([badge_tag]).map { |r| r.id }

    rewards = Reward.includes(:user_rewards).where("rewards.id IN (?)", reward_ids)
    rewards = order_elements(badge_tag, rewards)

    users_badge = {}

    user_ids.each do |user_id|
      reward = rewards.where("user_rewards.user_id = ?", user_id).references(:user_rewards).order(cost: :desc).first
      if reward
        inactive = false
      else
        reward = rewards.order(cost: :asc).first 
        inactive = true
      end

      (users_badge[user_id] ||= []) << {
        name: reward.name,
        image: reward.main_image,
        cost: reward.cost,
        extra_fields: reward.extra_fields,
        inactive: inactive
      }
    end

    users_badge

  end

end