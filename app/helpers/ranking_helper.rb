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
  
  def get_my_position(ranking_name)
      if current_user
        get_my_general_position(ranking_name, current_user.id)
      else
        nil
      end
  end
  
  def get_my_general_position(ranking_name, user_id)
    version_rank = CacheVersion.where("name = ?", ranking_name).first
    version = version_rank.version
    total = JSON.parse(version_rank.data)['total']
    position = cache_huge(get_user_position_rank_cache_key(user_id, ranking_name, version)) do
      user_position = CacheRanking.where("user_id = ? and name = ?", user_id, ranking_name).first
      if user_position
        user_position.position
      else
          nil       
      end
    end
    [position, total]
  end
  
  def get_reward_points_in_period(period_kind, reward_name)    
    reward_points = get_counter_about_user_reward(reward_name, true)
    reward_points[period_kind].present? ? reward_points[period_kind] : 0
  end
  
  def get_ranking(ranking, page)
    if ranking
      rankings, total = get_ranking_page(ranking.name, page)
      rank = RankingElement.new(
        period: ranking.period,
        title: ranking.title,
        rankings: prepare_rank_for_json(rankings, ranking),
        total: total,
        number_of_pages: get_pages(total, RANKING_USER_PER_PAGE) 
      )
    end
  end
  
  def get_ranking_page(ranking_name, page)
    version_rank = CacheVersion.where("name = ?", ranking_name).first
    version = version_rank.version
    total = JSON.parse(version_rank.data)['total']
    positions = cache_huge(get_rank_page_cache_key(ranking_name, page, version)) do
      offset = (page-1).to_i * RANKING_USER_PER_PAGE;
      CacheRanking.where("name = ?", ranking_name).order("position asc").offset(offset).limit(RANKING_USER_PER_PAGE).to_a
    end
    [positions, total]
  end
  
  # day is in datetime format
  def get_winner_of_day(day)
    period = Period.where("start_datetime < ? and end_datetime > ? and kind = ?", day, day, PERIOD_KIND_DAILY).first
    if period.nil?
      nil
    else
      cache_medium("winner_of_day_#{day.to_time.to_i}") do
        unless $context_root.nil?
          reward_id = Reward.find_by_name("#{$context_root}-point").id
        else
          reward_id = Reward.find_by_name("point").id
        end
        UserReward.includes(:user).where("reward_id = ? and period_id = ? and user_id <> ?", reward_id, period.id, anonymous_user.id).order("counter DESC, updated_at ASC, user_id ASC").first
      end
    end
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
  
  def get_full_rank(ranking, page = 1)
    rank = get_ranking(ranking, page)
    if current_user
      my_position = get_my_general_position(ranking.name, current_user.id)
    else
      my_position = -1
    end
    
    if ranking.rank_type == "trirank"
      compose_triranking_info(ranking.rank_type, ranking, rank.rankings, my_position, rank.total, rank.number_of_pages)
    else
      compose_ranking_info(ranking.rank_type, ranking, rank.rankings, my_position, rank.total, rank.number_of_pages, page.to_i)
    end
    
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
    if (rank_type == "my_position" || rank_type ==  "trirank") && my_position
      current_page = get_pages(my_position, RANKING_USER_PER_PAGE)
    end
    {rank_list: rank_list, rank_type: rank_type, ranking: ranking, current_page: current_page, my_position: my_position, total: total, number_of_pages: number_of_pages}
  end
  
  def compose_triranking_info(rank_type, ranking, rank_list, my_position, total = 0, number_of_pages = 0, current_page = 1)
    rank_list = prepare_trirank_list(rank_list, my_position)
    {rank_list: rank_list, rank_type: rank_type, ranking: ranking, current_page: current_page, my_position: my_position, total: total, number_of_pages: number_of_pages}
  end
  
  def prepare_trirank_list(rank_list, my_position)
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
    
  def populate_rankings(ranking_names)
    cache_short(get_ranking_page_key) do
      rankings = Hash.new
      ranking_names.each do |rn|
        rank = Ranking.find_by_name(rn)
        if rank.people_filter != "all"
          rankings[rn] = send("get_#{rank.people_filter}_rank", rank)
        else
          rankings[rn] = get_full_rank(rank)
        end
      end
      rankings['general_user_position'] = create_general_user_position($context_root)
      rankings
    end
  end
  
  def populate_ranking(ranking_name)
    cache_short(get_single_ranking_page_key(ranking_name)) do
      rankings = Hash.new
      rank = Ranking.find_by_name(ranking_name)
      if rank.people_filter != "all"
        rankings[ranking_name] = send("get_#{rank.people_filter}_rank", rank)
      else
        rankings[ranking_name] = get_full_rank(rank)
      end
      rankings
    end
  end
  
  def populate_vote_rankings(vote_ranking_names)
    cache_short(get_vote_ranking_page_key) do 
      rankings = Hash.new
      vote_ranking_names.each do |rn|
        rank = VoteRanking.find_by_name(rn)
        rankings[rn] = get_full_vote_rank(rank)
      end
      rankings
    end
  end
  
  def create_general_user_position(property = nil)
    if property.nil?
      ranking = Ranking.find_by_name("general-chart")
    else
      ranking = Ranking.find_by_name("#{property}-general-chart")
    end
    rank = get_ranking(ranking)
    if rank
      rank.user_to_position
    end
  end
  
  def create_current_chart_user_position(ranking)
    rank = get_ranking(ranking)
    if rank
      rank.user_to_position
    end
  end
  
  def prepare_rank_for_json(rankings, ranking)
    positions = Array.new
    rankings.each do |r|
      extra_data = JSON.parse(r.data)
      positions << {
        "position" => r.position,
        "general_position" => r.position, 
        "avatar" => extra_data['avatar_selected_url'], 
        "user" => extra_data['username'].blank? ? "#{extra_data['first_name']} #{extra_data['last_name']}" : extra_data['username'],
        "user_id" => r.user_id, 
        "counter" => extra_data['counter']
      }
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
        user_name = extract_name_or_username(r[:user])
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
        "user" => extract_name_or_username(user),
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
  
  def get_active_ranking
    Ranking.all.to_a
  end
  
  def get_ranking_settings
    cache_short(get_ranking_settings_key) do
      setting = Setting.find_by_key(RANKING_SETTINGS_KEY)
      setting.value.split(",")
    end
  end
  
end