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
  
  def get_my_general_position
    ranking = Ranking.find_by_name("general_chart")
    rank = get_ranking(ranking)
    rank.user_to_position[current_user.id]
  end
  
  def get_reward_points_in_period(period_kind, reward_name)
    period = get_current_periodicities[period_kind]
    reward = cache_short("#{reward_name}") { Reward.find_by_name(reward_name) }
    user_reward = UserReward.where("reward_id = ? and period_id = ? and user_id = ?", reward.id, period.id, current_user.id).first
    if user_reward
      user_reward.counter
    else
      0
    end
  end
  
  def get_ranking(ranking)
    rankings = Array.new
    period = get_current_periodicities[ranking.period]
    if period.blank?
      rankings = cache_short("#{ranking.id}_general") do
        UserReward.where("reward_id = ? and period_id IS NULL and user_id <> ?", ranking.reward_id, anonymous_user.id).order("counter DESC, updated_at ASC, user_id ASC").to_a
      end
    else
      rankings = cache_short("#{ranking.id}_#{period.id}") do
        UserReward.where("reward_id = ? and period_id = ? and user_id <> ?", ranking.reward_id, period.id, anonymous_user.id).order("counter DESC, updated_at ASC, user_id ASC").to_a
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
  
  def get_vote_ranking(vote_ranking)
    rankings = Array.new
    period = get_current_periodicities[vote_ranking.period]
    if period.blank?
      rankings = cache_short("vote_rank_#{vote_ranking.id}_general") do
        vote_ranking_list = Array.new
        vote_ranking.vote_ranking_tags.each do |rt|
          call_to_actions = get_ctas_with_tag(rt.tag.name)
          call_to_actions.each do |cta|
            vote_sum = UserInteraction.select("SUM((aux->>'vote')::int)").where("(aux->>'call_to_action_id')::int = ?", cta.id).first.sum
            vote_ranking_list << {cta: cta, total_vote: vote_sum, user: cta.user}
          end
        end
        vote_ranking_list = vote_ranking_list.sort_by{ |x| x[:total_vote] }
      end
    else
      rankings = cache_short("vote_rank_#{vote_ranking.id}_#{period.id}") do
        vote_ranking_list = Array.new
        vote_ranking.vote_ranking_tags.each do |rt|
          call_to_actions = get_ctas_with_tag(rt.tag.name)
          call_to_actions.each do |cta|
            vote_sum = UserInteraction.select("SUM((aux->>'vote')::int)").where("(aux->>'call_to_action_id')::int = ?", cta.id)
            vote_ranking_list << {cta: cta, total_vote: vote_sum, user: cta.user}
          end
        end
        vote_ranking_list = vote_ranking_list.sort_by{ |x| x[:total_vote] }
      end
    end
    rank = RankingElement.new(
      period: vote_ranking.period,
      title: vote_ranking.title,
      rankings: prepare_vote_rank_for_json(rankings),
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
  
  def get_full_rank_page(ranking, page)
    rank = get_ranking(ranking)
    if current_user
      my_position = rank.user_to_position[current_user.id]
    else
      my_position = -1
    end
    compose_ranking_info(ranking.rank_type, ranking, rank.rankings, my_position, rank.rankings.count, rank.number_of_pages, page)
  end
  
  def get_full_vote_rank(vote_ranking)
    rank = get_vote_ranking(vote_ranking)
    compose_vote_ranking_info(vote_ranking.rank_type, vote_ranking, rank.rankings, rank.rankings.count, rank.number_of_pages)
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
  
  def compose_ranking_info(rank_type, ranking, rank_list, my_position, total = 0, number_of_pages = 0, current_page = 1)
    if rank_type == "my_position" && my_position
      current_page = get_pages(my_position, RANKING_USER_PER_PAGE)
    end
    off = (current_page.to_i - 1) * RANKING_USER_PER_PAGE
    rank_list = rank_list.slice(off, RANKING_USER_PER_PAGE)
    {rank_list: rank_list, rank_type: rank_type, ranking: ranking, current_page: current_page, my_position: my_position, total: total, number_of_pages: number_of_pages}
  end
  
  def compose_vote_ranking_info(rank_type, ranking, rank_list, total = 0, number_of_pages = 0)
    current_page = 1
    off = 0
    rank_list = rank_list.slice(off, RANKING_USER_PER_PAGE)
    {rank_list: rank_list, rank_type: rank_type, ranking: ranking, current_page: current_page, total: total, number_of_pages: number_of_pages}
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
  
  def populate_vote_rankings(vote_ranking_names)
    rankings = Hash.new
    vote_ranking_names.each do |rn|
      rank = VoteRanking.find_by_name(rn)
      rankings[rn] = get_full_vote_rank(rank)
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
  
  def prepare_vote_rank_for_json(ranking)
    positions = Array.new
    i = 1
    ranking.each do |r|
      if r[:user]
        avatar = user_avatar(r[:user])
        user_id = r[:user].id
        user_name = "#{r[:user].first_name} #{r[:user].last_name}"
      else
        avatar = ""
        user_id = -1
        user_name = ""
      end
      
      positions << { 
        "position" => i, 
        "cta_thumb" => r[:cta].thumbnail(:thumb),
        "cta_title" => r[:cta].title,
        "avatar" => avatar, 
        "user_id" => user_id,
        "user" => user_name, 
        "counter" => r[:total_vote] 
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