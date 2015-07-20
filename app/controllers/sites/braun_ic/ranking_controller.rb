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
    user_rewards = UserReward.includes(:reward, :user).where("user_rewards.period_id IS NULL AND rewards.name = 'point' AND (users.anonymous_id IS NULL OR users.anonymous_id = '')").order("user_rewards.counter DESC, user_rewards.updated_at asc").references(:rewards, :users).page(page).per(per_page)
    user_ids = user_rewards.map { |user_reward| user_reward.user_id }
    users = User.where(id: user_ids)

    user_rewards_updated_at = "#{from_updated_at_to_timestamp(user_rewards.minimum(:updated_at))}_#{from_updated_at_to_timestamp(user_rewards.maximum(:updated_at))}"
    users_updated_at = "#{from_updated_at_to_timestamp(users.minimum(:updated_at))}_#{from_updated_at_to_timestamp(users.maximum(:updated_at))}"
    timestamp = "#{user_rewards_updated_at}_#{users_updated_at}"
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
          username: braun_username(user_reward.user),
          points: user_reward.counter
        }
      end

      ranking_info
    end
  end

  def braun_username(user)
    if user.first_name.present? && user.last_name.present?
      "#{user.first_name} #{user.last_name}"
    else
      user.email.split("@")[0]
    end
  end

end