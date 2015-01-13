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
    @levels = prepare_levels_to_show(levels)
    @my_levels = get_other_property_rewards("level")
    badges, badges_use_prop = rewards_by_tag("badge")
    @badges = badges.nil? ? nil : badges[get_current_property]
    @mybadges = get_other_property_rewards("badge")
  end
  
  def prepare_levels_to_show(levels)
    levels = levels[get_current_property] 
    order_rewards(levels.to_a, "cost")
    prepared_levels = {}
    if levels
      index = 0
      level_before_point = 0
      level_before_status = nil
      levels.each do |level|
        if level_before_status.nil? || level_before_status == "gained"
          progress = disney_calculate_level_progress(level, level_before_point, get_current_property)
          if progress > 100
            level_before_status = "gained"
            prepared_levels["#{index+1}"] = {"level" => level, "level_number" => index+1, "progress" => 100, "status" => level_before_status }
          else
            level_before_status = "progress"
            prepared_levels["#{index+1}"] = {"level" => level, "level_number" => index+1, "progress" => progress, "status" => level_before_status }
          end
        else
          progress = 0
          level_before_status = "locked"
          prepared_levels["#{index+1}"] = {"level" => level, "level_number" => index+1, "progress" => progress, "status" => level_before_status }
        end
        index += 1
      end
    end
    prepared_levels
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