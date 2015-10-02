module RankingHelper
    
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

  def get_number_of_page(elements, per_page)
    if elements == 0
      0
    elsif elements < per_page
      1
    elsif elements % per_page == 0
      elements / per_page
    else
      (elements / per_page) + 1
    end
  end
  
  def get_my_position(ranking_name)
    if current_user
      get_my_general_position(ranking_name, current_user.id)
    else
      nil
    end
  end
  
  def get_my_general_position(ranking_name, user_id)
    version_rank = CacheVersion.where("name = ?", ranking_name).order("version desc").first
    if version_rank
      version = version_rank.version
      total = version_rank.data['total']
    else
      version = 0
      total = 0
    end
    position = cache_huge(get_user_position_rank_cache_key(user_id, ranking_name, version)) do
      user_position = CacheRanking.where("user_id = ? and name = ? and version = ?", user_id, ranking_name, version).first
      if user_position
        user_position.position
      else
          nil       
      end
    end
    [position, total]
  end

  def get_general_ranking
    property = get_property()
    if $site.id == 'ballando' || $site.id == 'forte'
      ranking = Ranking.find_by_name("general_chart")
    elsif property.present?
      property_name = property.name
      ranking = Ranking.find_by_name("#{property_name}-general-chart")
    else
      ranking = Ranking.find_by_name("general-chart")
    end
    ranking    
  end

  def get_my_general_position_in_property
    ranking = get_general_ranking()
    if ranking && current_user
      get_my_general_position(ranking.name, current_user.id)
    else
      [nil, nil]
    end
  end
  
  def get_reward_points_in_period(period_kind, reward_name)    
    reward_points = get_counter_about_user_reward(reward_name, true)
    reward_points[period_kind].present? ? reward_points[period_kind] : 0
  end
  
  def get_ranking(ranking, page = 0)
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
    version_rank = CacheVersion.where("name = ?", ranking_name).order("version desc").first
    if version_rank
      version = version_rank.version
      total = version_rank.data['total']
    else
      version = 0
      total = 0
    end
    positions = cache_huge(get_rank_page_cache_key(ranking_name, page, version)) do
      offset = (page-1).to_i * RANKING_USER_PER_PAGE;
      CacheRanking.where("name = ? and version = ?", ranking_name, version).order("position asc").offset(offset).limit(RANKING_USER_PER_PAGE).to_a
    end
    [positions, total]
  end
  
  def get_vote_ranking(tag_name, page)
    offset = (page-1).to_i * RANKING_USER_PER_PAGE;
    cta_ids = get_ctas_with_tag(tag_name).map{|cta| cta.id}
    version_rank = CacheVersion.where("name = 'votes-chart'").order("version desc").first
    if version_rank
      version = version_rank.version
      total = CacheVote.where("gallery_name = ? AND version = ?", tag_name, version).count
    else
      version = 0
      total = 0
    end
    positions = cache_huge(get_rank_page_cache_key(tag_name, page, version)) do
      CacheVote.where("gallery_name = ? AND version = ?", tag_name, version).order("vote_sum desc").offset(offset).limit(RANKING_USER_PER_PAGE).to_a
    end
    positions = prepare_vote_rankings_for_json(positions, offset)
    [positions, total]
  end
  
  def prepare_vote_rankings_for_json(rankings, offset)
    positions = Array.new
    ctas_info = get_call_to_actions_info(rankings.map{|r| r.call_to_action_id})
    rankings.each_with_index do |r, index|
      extra_data = r.data
      positions << {
        "position" => (index + 1) + offset,
        "general_position" => (index + 1) + offset, 
        "avatar" => extra_data['avatar_selected_url'], 
        "user" => extra_data['username'].blank? ? "#{extra_data['first_name']} #{extra_data['last_name']}" : extra_data['username'],
        "user_id" => extra_data['user_id'], 
        "counter" => r.vote_sum,
        "cta_url" => "/call_to_action/#{r.call_to_action_id}",
        "cta_image" => ctas_info[r.call_to_action_id]['thumb_url'],
        "title" => ctas_info[r.call_to_action_id]['title']
      }
    end
    positions
  end
  
  def get_call_to_actions_info(cta_ids)
    ctas = CallToAction.where("id in (?)", cta_ids)
    ctas_info = {}
    ctas.each do |cta|
      ctas_info[cta.id] = { "thumb_url" => cta.thumbnail.url(:thumb), "title" => cta.title }
    end
    ctas_info
  end
  
  # day is in datetime format
  def get_winner_of_day(day)
    period = Period.where("start_datetime < ? and end_datetime > ? and kind = ?", day, day, PERIOD_KIND_DAILY).first
    if period.nil?
      nil
    else
      cache_medium("winner_of_day_#{day.to_time.to_i}") do
        if !$context_root.nil? && !$context_root == "all"
          reward_id = Reward.find_by_name("#{$context_root}-point").id
        else
          reward_id = Reward.find_by_name("point").id
        end
        UserReward.includes(:user).where("user_rewards.reward_id = ? AND user_rewards.period_id = ? AND user_rewards.user_id <> ?", reward_id, period.id, anonymous_user.id).references(:users).order("user_rewards.counter DESC, user_rewards.updated_at ASC, user_rewards.user_id ASC").first
      end
    end
  end
  
  def get_full_rank(ranking, page = 1)
    rank = get_ranking(ranking, page)
    if current_user
      my_position, total = get_my_general_position(ranking.name, current_user.id)
    else
      my_position = -1
    end
    
    if ranking.rank_type == "trirank"
      compose_triranking_info(ranking.rank_type, ranking, rank.rankings, my_position, rank.total, rank.number_of_pages)
    else
      compose_ranking_info(ranking.rank_type, ranking, rank.rankings, my_position, rank.total, rank.number_of_pages, page.to_i)
    end
    
  end
  
  def get_full_vote_rank(tag, page = 1)
    rank, total = get_vote_ranking(tag.name, page)
    number_of_page = get_number_of_page(total, RANKING_USER_PER_PAGE)
    compose_vote_ranking_info(rank, tag, page, total, number_of_page)
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
  
  def compose_vote_ranking_info(rank_list, gallery, current_page = 1, total = 0, number_of_pages = 1)
    {rank_list: rank_list, rank_type: "full", ranking: gallery, current_page: current_page, total: total, number_of_pages: number_of_pages}
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
  
  def populate_vote_ranking(tag_name)
    @rankings = cache_short(get_vote_ranking_page_key(tag_name)) do 
      get_full_vote_rank(tag_name)
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
  
  def prepare_rank_for_json(rankings, ranking)
    positions = Array.new
    rankings.each do |r|
      extra_data = r.data
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