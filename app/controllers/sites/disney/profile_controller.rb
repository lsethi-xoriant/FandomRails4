class Sites::Disney::ProfileController < ProfileController
  include DisneyHelper
  
  def get_current_property
    get_disney_property
  end
  
  def rankings
    rank = Ranking.find_by_name("#{get_current_property}_general_chart")
    @property_rank = get_full_rank(rank)
    
    @fan_of_days = []
    (1..6).each do |i|
      day = Time.now - i.day
      @fan_of_days << {"day" => "#{day.strftime('%d %b.')}", "winner" => get_winner_of_day(day)}
    end
    
    render template: "profile/rankings"
  end
  
  def rewards
    levels, levels_use_prop = rewards_by_tag("level")
    @levels = levels.nil? ? nil : levels[get_current_property]
    @my_levels = get_other_property_rewards("level")
    badges, badges_use_prop = rewards_by_tag("badge")
    @badges = badges.nil? ? nil : badges[get_current_property]
    @mybadges = get_other_property_rewards("badge")
  end
  
  def get_other_property_rewards(reward_name)
    myrewards, use_prop = rewards_by_tag(reward_name, current_user)
    other_rewards = []
    unless myrewards.nil?
      get_tags_with_tag("property").each do |property|
        if myrewards[property.name]
          reward = get_max(myrewards[property.name]) do |x,y| if x.updated_at > y.updated_at then -1 elsif x.updated_at < y.updated_at then 1 else 0 end end
          other_rewards << { "reward" => reward, "property" => property }
        end
      end
    end
    other_rewards
  end
  
end