module RankingHelper
  
  include PeriodicityHelper
  include ApplicationHelper
  
  class RankingElement
    include ActiveAttr::TypecastedAttributes
    include ActiveAttr::MassAssignment
    include ActiveAttr::AttributeDefaults
    
    attribute :period, type: String
    attribute :title, type: String
    attribute :rankings
    attribute :user_to_position
    attribute :total, type: Integer
    attribute :number_of_pages, type: Integer
  end
  
  def get_ranking(ranking)
    rankings = Array.new
    period = get_current_periodicities[ranking.period]
    if period.blank?
      rankings = cache_short("#{ranking.id}_general") do
        UserReward.where("reward_id = ? and period_id IS NULL", ranking.reward_id).order("counter DESC, updated_at ASC, user_id ASC").to_a
      end
    else
      rankings = cache_short("#{ranking.id}_#{period.id}") do
        UserReward.where("reward_id = ? and period_id = ?", ranking.reward_id, period.id).order("counter DESC, updated_at ASC, user_id ASC").to_a
      end
    end
    user_position_hash = cache_short { generate_user_position_hash(rankings) }
    rank = RankingElement.new(
      period: ranking.period,
      title: ranking.title,
      rankings: prepare_rank_for_json(rankings, user_position_hash),
      user_to_position: user_position_hash,
      total: rankings.count,
      number_of_pages: get_pages(rankings.count, RANKING_USER_PER_PAGE) 
    )
  end
  
  def prepare_rank_for_json(ranking, user_position_hash)
    positions = Array.new
    ranking.each do |r|
      positions << { 
        "position" => user_position_hash[rank.user.id], 
        "avatar" => user_avatar(rank.user), 
        "user" => "#{rank.user.first_name} #{rank.user.last_name}", 
        "counter" => rank.counter 
      }
    end
  end
  
  def prepare_friends_rank_for_json(ranking, rank)
    positions = Array.new
    period = get_current_periodicities[ranking.period]
    ranking.each do |r|
      user = User.find(r[0])
      counter = UserReward.where("reward_id = ? AND user_id = ? AND period_id = ?", rank.reward.id, user.id, period.id)
      positions << { 
        "user_id" => user.id,
        "position" => r[1], 
        "avatar" => user_avatar(user), 
        "user" => "#{user.first_name} #{user.last_name}",
        "counter" => counter
      }
    end
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
  
  def get_position_among_friends(rank_list)
    i = 1
    rank_list.each do |rl|
      if rl["user_id"] == current_user.id
        return i
      end
      i += 1
    end
  end
  
end