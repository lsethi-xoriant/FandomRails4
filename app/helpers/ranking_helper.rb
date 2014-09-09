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
  
  def get_full_rank(ranking)
    rank = get_ranking(ranking)
    if current_user
      my_position = rank.user_to_position[current_user.id]
    else
      my_position = -1
    end
    compose_ranking_info(ranking.rank_type, ranking, rank.rankings, my_position, rank.rankings.count, rank.number_of_pages)
  end
  
  def get_fb_friends_rank(ranking)
    current_user_fb_friends = current_user.facebook(request.site.id).get_connections("me", "friends").map { |f| f.id }
    rank = get_ranking(ranking)
    filtered_rank = rank.user_to_position.select { |key,_| current_user_fb_friends.include? key }
    filtered_rank = filtered_rank.sort_by { |key, value| value }
    rank_list = prepare_friends_rank_for_json(filtered_rank, ranking)
    my_position = get_position_among_friends(rank_list)
    compose_ranking_info(ranking.rank_type, ranking, rank_list, my_position, rank.rankings.count, rank.number_of_pages)
  end
  
  def compose_ranking_info(rank_type, ranking, rank_list, my_position, total = 0, number_of_pages = 0)
    if rank_type == "my_position"
      current_page = get_pages(my_position, RANKING_USER_PER_PAGE) 
      off = (current_page - 1) * RANKING_USER_PER_PAGE
    else
      current_page = 1
      off = 0
    end
    rank_list = rank_list.slice(off, RANKING_USER_PER_PAGE)
    {rank_list: rank_list, rank_type: rank_type, ranking: ranking, current_page: current_page, my_position: my_position, total: total, number_of_pages: number_of_pages}
  end
  
  def get_full_rank_page
    page = prams[:page]
    off = (page - 1) * RANKING_USER_PER_PAGE
    ranking = Ranking.find(params[:id])
    rank = get_ranking(ranking)
    rank_list = rank.rankings.slice(off, RANKING_USER_PER_PAGE)
    respond_to do |format|
      format.json { render json: rank_list.to_json }
    end
  end
  
  def populate_rankings(ranking_names)
    rankings = Hash.new
    ranking_names.each do |rn|
      rank = Ranking.find_by_name(rn)
      if rank.people_filter != "all"
        rankings[rn] = send("get_#{rank.people_filter}_rank", rank)
      else
        rankings[rn] = get_full_rank(rank)
      end
    end
    rankings
  end
  
  def prepare_rank_for_json(ranking, user_position_hash)
    positions = Array.new
    i = 1
    ranking.each do |r|
      positions << { 
        "position" => i,
        "general_position" => user_position_hash[r.user.id], 
        "avatar" => user_avatar(r.user), 
        "user" => "#{r.user.first_name} #{r.user.last_name}", 
        "counter" => r.counter 
      }
      i += 1
    end
    positions
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