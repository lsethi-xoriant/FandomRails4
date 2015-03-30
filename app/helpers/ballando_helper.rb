module BallandoHelper
  
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
  
  def get_superfan_reward
    cache_short("weekly_superfan") do
      Reward.includes({ :reward_tags => :tag }).where("tags.name = 'superfan' and rewards.valid_from < ? and rewards.valid_to > ?", Time.now.utc, Time.now.utc).first  
    end
  end
  
  def is_special_guest_active
    setting = cache_short(get_special_guest_settings_key) do 
      Setting.find_by_key("ballando_special_guest")
    end
    !setting.nil? && setting.value.downcase == "si"
  end
  
  def expire_gigya_url_cache_key
    expire_cache_key 'gigya.url'
  end
  
  def gigya_url
    cache_short 'gigya.url' do
      rows = Setting.where(key: 'gigya.url').select('value')
      if rows.count > 0 && rows[0].value.strip.length > 0
        rows[0].value
      else
        "http://cdn.gigya.com/js/socialize.js"
      end
    end
  end
  
  def ballando_get_my_position
      ballando_get_my_general_position
  end
  
  def ballando_get_my_general_position
    users_positions = cache_short(get_ranking_page_key){ ballando_populate_rankings(get_ranking_settings) }
    if users_positions['general_chart'][:my_position]
      [users_positions['general_chart'][:my_position], users_positions['general_chart'][:total]] 
    else
      [nil, nil]
    end
  end
  
  def ballando_get_ranking(ranking)
    if ranking
      rankings = Array.new
      period = get_current_periodicities[ranking.period]

      if period.blank?
        rankings = UserReward.includes(:user).where("user_rewards.reward_id = ? and user_rewards.period_id IS NULL and user_id <> ?", ranking.reward_id, anonymous_user.id).order("counter DESC, updated_at ASC, user_id ASC").to_a
      else
        rankings = UserReward.includes(:user).where("reward_id = ? and period_id = ? and user_id <> ?", ranking.reward_id, period.id, anonymous_user.id).order("counter DESC, updated_at ASC, user_id ASC").to_a
      end
      user_position_hash = cache_short("#{ranking.id}_user_position") { ballando_generate_user_position_hash(rankings) }
      rank = RankingElement.new(
        period: ranking.period,
        title: ranking.title,
        rankings: ballando_prepare_rank_for_json(rankings, user_position_hash),
        user_to_position: user_position_hash,
        total: rankings.count,
        number_of_pages: get_pages(rankings.count, RANKING_USER_PER_PAGE) 
      )
    end
  end
  
  def ballando_get_full_rank(ranking)
    rank = ballando_get_ranking(ranking)
    if current_user
      my_position = rank.user_to_position[current_user.id]
    else
      my_position = -1
    end
    if ranking.rank_type == "trirank"
      ballando_compose_triranking_info(ranking.rank_type, ranking, rank.rankings, my_position, rank.rankings.count, rank.number_of_pages)
    else
      ballando_compose_ranking_info(ranking.rank_type, ranking, rank.rankings, my_position, rank.rankings.count, rank.number_of_pages)
    end
  end
  
  def ballando_get_full_rank_page(ranking, page)
    rank = ballando_get_ranking(ranking)
    if current_user
      my_position = rank.user_to_position[current_user.id]
    else
      my_position = -1
    end
    ballando_compose_ranking_info(ranking.rank_type, ranking, rank.rankings, my_position, rank.rankings.count, rank.number_of_pages, page)
  end
  
  def ballando_compose_ranking_info(rank_type, ranking, rank_list, my_position, total = 0, number_of_pages = 0, current_page = 1)
    if (rank_type == "my_position" || rank_type ==  "trirank") && my_position
      current_page = get_pages(my_position, RANKING_USER_PER_PAGE)
    end
    off = (current_page.to_i - 1) * RANKING_USER_PER_PAGE
    rank_list = rank_list.slice(off, RANKING_USER_PER_PAGE)
    {rank_list: rank_list, rank_type: rank_type, ranking: ranking, current_page: current_page, my_position: my_position, total: total, number_of_pages: number_of_pages}
  end
  
  def ballando_compose_triranking_info(rank_type, ranking, rank_list, my_position, total = 0, number_of_pages = 0, current_page = 1)
    rank_list = ballando_prepare_trirank_list(rank_list, my_position)
    {rank_list: rank_list, rank_type: rank_type, ranking: ranking, current_page: current_page, my_position: my_position, total: total, number_of_pages: number_of_pages}
  end
  
  def ballando_prepare_trirank_list(rank_list, my_position)
    if my_position
      if my_position == 1
        off = my_position - 1
      elsif my_position == rank_list.count
        off = my_position - 3
      else
        off = my_position - 2
      end
      rank_list.slice(off, 3)
    else
      []
    end
  end
  
  def compose_vote_ranking_info(rank_type, ranking, rank_list, total = 0, number_of_pages = 0)
    current_page = 1
    off = 0
    rank_list = rank_list.slice(off, RANKING_USER_PER_PAGE)
    {rank_list: rank_list, rank_type: rank_type, ranking: ranking, current_page: current_page, total: total, number_of_pages: number_of_pages}
  end
    
  def ballando_populate_rankings(ranking_names)
    cache_short(get_ranking_page_key) do
      rankings = Hash.new
      ranking_names.each do |rn|
        rank = Ranking.find_by_name(rn)
        if rank.people_filter != "all"
          rankings[rn] = send("get_#{rank.people_filter}_rank", rank)
        else
          rankings[rn] = ballando_get_full_rank(rank)
        end
      end
      rankings['general_user_position'] = ballando_create_general_user_position($context_root)
      rankings
    end
  end
  
  def ballando_populate_ranking(ranking_name)
    cache_short(get_single_ranking_page_key(ranking_name)) do
      rankings = Hash.new
      rank = Ranking.find_by_name(ranking_name)
      if rank.people_filter != "all"
        rankings[ranking_name] = send("get_#{rank.people_filter}_rank", rank)
      else
        rankings[ranking_name] = ballando_get_full_rank(rank)
      end
      rankings['general_user_position'] = ballando_create_current_chart_user_position(rank)
      rankings
    end
  end
  
  def ballando_create_general_user_position(property = nil)
    if property.nil?
      ranking = Ranking.find_by_name("general-chart")
    else
      ranking = Ranking.find_by_name("#{property}-general-chart")
    end
    rank = ballando_get_ranking(ranking)
    if rank
      rank.user_to_position
    end
  end
  
  def ballando_create_current_chart_user_position(ranking)
    rank = ballando_get_ranking(ranking)
    if rank
      rank.user_to_position
    end
  end
  
  def ballando_prepare_rank_for_json(ranking, user_position_hash)
    positions = Array.new
    i = 1
    ranking.each do |r|
      positions << { 
        "position" => i,
        "general_position" => user_position_hash[r.user.id], 
        "avatar" => r.user.avatar_selected_url, 
        "user" => extract_name_or_username(r.user),
        "user_id" => r.user.id, 
        "counter" => r.counter 
      }
      i += 1
    end
    positions
  end
  
  def ballando_generate_user_position_hash(rankings)
    user_position_hash = Hash.new
    position = 1
    rankings.each do |r|
      user_position_hash[r.user_id] = position
      position += 1
    end
    user_position_hash
  end
  
  def ballando_get_ranking_settings
    cache_short(get_ranking_settings_key) do
      setting = Setting.find_by_key(RANKING_SETTINGS_KEY)
      setting.value.split(",")
    end
  end
  
end