class Sites::Disney::ProfileController < ProfileController
  include DisneyHelper

  def complete_registration
    user_params = params[:user]
    
    required_attrs = ["username", "username_length"]
    user_params = user_params.merge(required_attrs: required_attrs)

    response = {}
    if !current_user.update_attributes(user_params)
      response[:errors] = current_user.errors.full_messages
    else
      response[:username] = current_user.username
      response[:avatar] = current_user.avatar_selected_url 
      log_audit("registration completion", { 'form_data' => params[:user], 'user_id' => current_user.id })
    end

    respond_to do |format|
      format.json { render json: response.to_json }
    end
  end

  def rankings
    rank = Ranking.find_by_name("#{get_disney_property}-general-chart")
    @property_rank = get_full_rank(rank)
    
    @fan_of_days = []
    (1..6).each do |i|
      day = Time.now - i.day
      @fan_of_days << {"day" => "#{day.strftime('%d %b.')}", "winner" => get_winner_of_day(day)}
    end
    
    if small_mobile_device?
      render template: "profile/rankings_mobile"
    else
      render template: "profile/rankings"
    end
  end
  
  def index_mobile
    @level = disney_get_current_level;
    @my_position, total = get_my_position 
  end
  
  def rewards
    if small_mobile_device?
      levels, levels_use_prop = rewards_by_tag("level")
      @levels = disney_prepare_levels_to_show(levels)
      badges, badges_use_prop = rewards_by_tag("badge")
      @badges = badges.nil? ? nil : badges[get_disney_property]
      render template: "/profile/rewards_mobile"
    else
      levels, levels_use_prop = rewards_by_tag("level")
      @levels = disney_prepare_levels_to_show(levels)
      @my_levels = get_other_property_rewards("level")
      badges, badges_use_prop = rewards_by_tag("badge")
      @badges = badges.nil? ? nil : badges[get_disney_property]
      @mybadges = get_other_property_rewards("badge")
    end
    
  end
  
  def notices
    Notice.mark_all_as_viewed()
    notices = Notice.where("user_id = ?", current_user.id).order("created_at DESC")
    @notices_list = group_notice_by_date(notices)
    if small_mobile_device?
      render template: "/profile/notices_mobile"
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