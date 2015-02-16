class Sites::Disney::ProfileController < ProfileController
  include DisneyHelper
  
  skip_before_filter :check_user_logged, :only => :rankings
  
  def complete_registration

    user_params = params[:user]
    required_attrs = ["username", "username_length"]
    user_params = user_params.merge(required_attrs: required_attrs)

    response = {}
    current_user.assign_attributes(user_params)

    if !current_user.valid?
      response[:errors] = current_user.errors.full_messages
    else
      current_user.aux = { 
        "profile_completed" => true, 
      }.to_json
      if current_user.save
        response[:username] = current_user.username
        response[:avatar] = current_user.avatar_selected_url 
        log_audit("registration completion", { 'form_data' => params[:user], 'user_id' => current_user.id })
      else
        response[:errors] = current_user.errors.full_messages
      end
    end

    respond_to do |format|
      format.json { render json: response.to_json }
    end
  end

  def rankings
    rank = Ranking.find_by_name("#{get_disney_property}-general-chart")
    @property_rank = get_full_rank(rank)
    
    @fan_of_days = []
    (1..8).each do |i|
      day = Time.now - i.day
      winner = get_winner_of_day(day)
      @fan_of_days << {"day" => "#{day.strftime('%d')} #{calculate_month_string_ita(day.strftime('%m').to_i)[0..2].camelcase}", "winner" => winner} if winner
    end
    
    @property_rankings = get_property_rankings
    
    galleries = get_gallery_for_current_property
    @galleries = order_elements(Tag.find_by_name("gallery"), galleries.sort_by{|tag| tag.created_at}.reverse)
    
    if small_mobile_device?
      render template: "profile/rankings_mobile"
    else
      render template: "profile/rankings"
    end
  end
  
  def get_property_rankings
    cache_short(get_property_rankings_cache_key(get_disney_property)) do
      property_rankings = Array.new
      properties = get_tags_with_tag("property")
      properties.each do |p|
        if get_disney_property != p.name
          thumb_url = get_upload_extra_field_processor(get_extra_fields!(p)['thumbnail'], :medium) rescue ""
          property_ranking = {"title" => p.title, "thumb" => thumb_url, "link" => "#{get_disney_root_path_for_property_name(p.name)}/profile/rankings"}
          property_rankings << property_ranking
        end  
      end
      property_rankings
    end
  end
  
  def index_mobile
    @level = disney_get_current_level;
    @my_position, total = get_my_general_position_in_property
  end
  
  def index
    if small_mobile_device?
      redirect_to "/profile/index"
    else
      if $context_root.nil?
        redirect_to "/users/edit"
      else
        redirect_to "/#{get_disney_property}/users/edit"
      end
    end
  end
  
  def rewards
    if small_mobile_device?
      levels, levels_use_prop = rewards_by_tag("level")
      @levels = disney_prepare_levels_to_show(levels)
      badges, badges_use_prop = rewards_by_tag("badge")
      @badges = badges.nil? ? nil : badges[get_disney_property]
      @badges = order_elements(Tag.find_by_name("badge"), @badges)
      render template: "/profile/rewards_mobile"
    else
      levels, levels_use_prop = rewards_by_tag("level")
      @levels = disney_prepare_levels_to_show(levels)
      @my_levels = get_other_property_rewards("level")
      badges, badges_use_prop = rewards_by_tag("badge")
      @badges = badges.nil? ? nil : badges[get_disney_property]
      @badges = order_elements(Tag.find_by_name("badge"), @badges)
      @mybadges = get_other_property_rewards("badge")
    end
    
  end
  
  def get_gallery_for_current_property
    gallery_tags = get_tags_with_tag("gallery")
    if get_disney_property == "disney-channel"
      gallery_tags
    else
      cache_short(get_galleries_for_property_cache_key(get_disney_property)) do
        Tag.includes(:tags_tags => :other_tag).where("other_tags_tags_tags.name = ? AND tags.id in (?)", get_disney_property, gallery_tags.map{|t| t.id}).to_a
      end
    end
  end
  
  def load_more_notice
    notices = Notice.where("user_id = ?", current_user.id).order("created_at DESC").limit(params[:count])
    notices_list = group_notice_by_date(notices)
    respond_to do |format|
      format.json { render :json => notices_list.to_json }
    end
  end
  
  def get_other_property_rewards(reward_name)
    myrewards, use_prop = rewards_by_tag(reward_name, current_user)
    other_rewards = []
    unless myrewards.nil?
      get_tags_with_tag("property").each do |property|
        if myrewards[property.name] && property.name != get_disney_property
          reward = get_max(myrewards[property.name]) do |x,y| if x.updated_at > y.updated_at then -1 elsif x.updated_at < y.updated_at then 1 else 0 end end
          other_rewards << { "reward" => reward, "property" => property }
        end
      end
    end
    other_rewards
  end
  
end