module RankingHelper
  
  include PeriodicityHelper
  
  class RankingElement
    include ActiveAttr::TypecastedAttributes
    include ActiveAttr::MassAssignment
    include ActiveAttr::AttributeDefaults
    
    # key can be either tag name or special keyword such as $recent
    attribute :period, type: String
    attribute :title, type: String
    attribute :rankings
    attribute :user_to_position
  end
  
  def get_user_position(ranking)
    reward = ranking.reward
    period = get_period_by_ranking(ranking)
    if period.nil?
      current_user_reward = reward.user_rewards.where("user_id = ? AND period_id IS NULL", current_user.id).first
      reward.user_rewards.where("counter >= ? AND period_id IS NULL ", current_user_reward.counter).order("counter ASC").count
    else
      current_user_reward = reward.user_rewards.where("user_id = ? AND period_id = ?", current_user.id, period.id).first
      reward.user_rewards.where("counter >= ? AND period_id = ? ", current_user_reward.counter, period.id).order("counter ASC").count
    end
  end
  
  def get_period_by_ranking(ranking)
    active_periods = get_current_periodicities
    active_periods[ranking.period]
  end
  
  def get_ranking(ranking)
    rankings = Array.new
    if ranking.period.blank?
      rankings = cache_short("general") do
        UserReward.where("reward_id = ? and period_id IS NULL", @ranking.reward_id).order("counter DESC, updated_at ASC, user_id ASC").to_a
      end
    else
      rankings = cache_short(ranking.period) do
        UserReward.where("reward_id = ? and period_id = ?", @ranking.reward_id, period.id).order("counter DESC, updated_at ASC, user_id ASC").to_a
      end
    end
    user_position_hash = cache_short { generate_user_position_hash(rankings) }
    rank = RankingElement.new(
      period: ranking.period,
      title: ranking.title,
      rankings: rankings,
      user_to_position: user_position_hash
    )
  end
  
  def generate_user_position_hash(rankings)
    user_position_hash = Hash.new
    position = 1
    rankings.each do |r|
      user_position_hash[r.user_id] = position
      position += 1
    end
    user_position_hash
  end
  
end