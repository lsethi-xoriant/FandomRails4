class Api::V2::ProfileController < Api::V2::BaseController
  
  include RankingHelper
  
  def index

    my_position, total = get_my_general_position_in_property
    response = {}
    elements = []
    
    response["header"] = {
      "type" => "nickname",
      "info" => {
        "nickname" => extract_username_or_name(current_user),
      }
    }
    
    level = get_current_level
    
    elements << {
      "type" => "level",
      "info" => {
        "level" => level,
        "level_image" => get_reward_image_for_status(level["level"])
      } 
    }
    
    elements << {
      "type" => "ranking",
      "info" => {
        "my_position" => my_position,
        "total_users" => total
      }
    }
    
    badge = get_last_badge_obtained
    
    elements << {
      "type" => "badge",
      "info" => {
        "level" => {
          "level" => badge
        },
        "level_image" => get_reward_image_for_status(badge)
      } 
    }
    
    elements << {
      "type" => "notice",
      "info" => {
        "unread_notice_count" => get_unread_notifications_count
      }
    }
    
    elements << {
      "type" => "points",
      "info" => {
        "points" => get_point,
      }
    }
    
    elements << {
      "type" => "credits",
      "info" => {
        "credits" => get_counter_about_user_reward("credit")
      }
    }
    
    response["profileElements"] = elements
    
    respond_with response.to_json
    
  end
  
  def levels
    response = {}
    level_response = []
    
    property = get_property()
    if property.present?
      property_name = property.name
    end

    levels, levels_use_prop = rewards_by_tag("level")
    levels = levels.present? ? prepare_levels_to_show(levels, property_name) : nil
    
    if levels_use_prop
      my_levels = get_other_property_rewards("level", property_name)
    end
    
    level_response = level_response + prepare_levels(levels)
    level_response = level_response + prepare_other_rewards(my_levels)
    
    response["title"] = "Levels"
    response["icon_class"] = "fa fa-shield"
    response["rewards"] = level_response
    
    respond_with response.to_json
    
  end
  
  def prepare_level(level) 
      
      {
        "image_url" => get_reward_image_for_status(level["level"]),
        "title" => level["level"].title,
        "short_description" => level["level"].short_description,
        "progress" => level["progress"]
      }

  end
  
  def prepare_badge(badge)
    {
      "image_url" => get_reward_image_for_status(badge),
      "title" => badge.title,
      "short_description" => badge.short_description
    }
  end
  
  def prepare_levels(levels)
    level_elements = []
    
    i = 1
    tmp = []
    levels.each do |key, level|
      tmp << prepare_level(level)
      if i % 2 == 0
        level_elements << {
          "type" => "reward",
          "rewards" => tmp
        }
        tmp = []
      end
      i += 1
    end
    
    unless tmp.empty?
      level_elements << {
        "type" => "reward",
        "rewards" => tmp
      }
    end
    
    level_elements
  end
  
  def prepare_other_rewards(my_rewards)
    
    level_elements = []
    
    my_rewards.each do |my_reward|
      if !my_reward["reward"].nil?
        level_elements  << {
          "type" => "other_reward",
          "property_image" => my_reward["property"].extra_fields["image"]["url"],
          "reward" => prepare_badge(my_reward["reward"])
        }
      end
    end
    
    level_elements
  end
  
  def badges
    response = {}
    badge_response = []
    
    property = get_property()
    if property.present?
      property_name = property.name
    end
    
    badge_tag = Tag.find_by_name("badge")
    badges, badges_use_prop = rewards_by_tag("badge")
    
    if badges && badges_use_prop
      badges = badges[property_name]
      if badges
        badges = order_elements(badge_tag, badges)
      end
    end
    
    if badges_use_prop
      mybadges = get_other_property_rewards("badge", property_name)
    end
    
    badge_response = badge_response + prepare_badges(badges)
    badge_response = badge_response + prepare_other_rewards(mybadges)
    
    response["title"] = "Badges"
    response["icon_class"] = "fa fa-trophy"
    response["rewards"] = badge_response
    
    respond_with response.to_json
  end
  
  def prepare_badges(badges)
    badge_elements = []
    
    i = 1
    tmp = []
    badges.each do |badge|
      tmp << prepare_badge(badge)
      if i % 2 == 0
        badge_elements << {
          "type" => "reward",
          "rewards" => tmp
        }
        tmp = []
      end
      i += 1
    end
    
    badge_elements
  end
  
  def profile_avatars
    response = {}
    response["avatar_list"] = get_avatar_list
    respond_with response.to_json
  end
  
  def update_profile_info
    response = {}
    user = User.find(params[:user_id])
    user.update_attributes(:avatar_selected_url => params["avatar_selected_url"], :username => params[:username])
    
    if user.errors.any?
      errors = user.errors.join("\n")
      response["success"] = false
      response["message"] = "Errori nel salvataggio profilo:\n#{errors}"
    else
      response["success"] = true
      response["message"] = "Profilo aggiornato correttamente!"
    end
    
    respond_with response.to_json
  end
  
  def notices
    Notice.mark_all_as_viewed()
    expire_cache_key(notification_cache_key(current_user.id))
    notices = Notice.where("user_id = ?", current_user.id).order("created_at DESC")
    notices_list = group_notice_by_date(notices)
    
    response = {}
    
    response["html"] = prepare_html_notice(notices_list)
    
    respond_with response.to_json
  end
  
  def prepare_html_notice(notices_list)
    current_property = get_property()
    if current_property != nil && get_extra_fields!(current_property)["background_color"]
      background_color = get_extra_fields!(current_property)["background_color"]
    else
      background_color = "#3399ff" 
    end
    html = render_to_string "/profile/_notices_mobile_api", layout: "ios_application", locals: { notices_list: notices_list, bg_color: background_color }, formats: :html

  end
  
  def rankings
    response = {}
    rank = get_general_ranking()
    
    property_rank = get_full_rank(rank)
    my_position, total = get_my_position(rank.name)
    response["ranking_list"] = []
    
    response["ranking_list"] << prepare_ranking(property_rank, "point", property_rank[:total])
    
    if my_position && my_position > 10
      response["ranking_list"].first["position_list"].unshift(prepare_my_position(my_position, rank.reward.name))
    end
    
    fan_of_days = []
    (1..8).each do |i|
      day = Time.now - i.day
      winner = get_winner_of_day(day)
      fan_of_days << {"day" => "#{day.strftime('%d')} #{calculate_month_string_ita(day.strftime('%m').to_i)[0..2].camelcase}", "winner" => winner} if winner
    end
    
    response["ranking_list"] << prepare_ranking_from_fan_of_the_day(fan_of_days, "point")
    
    response["ranking_list"] = response["ranking_list"] + get_vote_rankings
    
    respond_with response.to_json
  end
  
  def get_vote_rankings
    
    page = params[:page] ? params[:page].to_i : 1
    
    gallery_tags = get_tags_with_tag("gallery")
    gallery_tag = Tag.find_by_name("gallery")
    
    gallery_tags = get_gallery_for_ranking_by_property(gallery_tags)
    galleries = order_elements(gallery_tag, gallery_tags.sort_by{ |tag| tag.created_at }.reverse)
    
    gallery_rankings = []
    
    galleries.each do |gallery|
      rank = get_full_vote_rank(gallery, page)
      
      if rank[:rank_list].count > 0
        gallery_rankings << prepare_ranking(rank, "vote", rank[:total])
      end
    end
    
    gallery_rankings
    
  end
  
  def load_more_ranking
    positions, total = get_ranking_page(params[:ranking_name], params[:page].to_i)
    position_list = []
    positions.each do |position|
      position_list << {
        "rank" => "#" + "#{position.position}",
        "avatar_url" => position.data["avatar_selected_url"],
        "username" => position.data["username"],
        "counter" => position.data["counter"] 
      }
    end
    
    respond_with position_list.to_json 
  end
  
  def prepare_my_position(my_position, reward_name)
    {
      "rank" => "# #{my_position}",
      "avatar_url" => current_user.avatar_selected_url,
      "username" => current_user.username,
      "counter" => get_counter_about_user_reward(reward_name),
      "user_id" => current_user.id 
    }
    
  end
  
  def prepare_ranking(rank, type, total = 0)
    ranking_element = {}
    ranking_element["title"] = rank[:ranking].title
    ranking_element["name"] = rank[:ranking].name
    ranking_element["type"] = type
    position_list = []
    rank[:rank_list].each do |re|
      position_list << {
        "rank" => "#" + "#{re["position"]}",
        "avatar_url" => re["avatar"],
        "username" => re["user"],
        "counter" => re["counter"],
        "image" => re["cta_image"],
        "title" => re["title"],
        "user_id" => re["user_id"]
      }
    end
    ranking_element["position_list"] = position_list
    ranking_element["total"] = total
    
    ranking_element
  end
  
  def prepare_ranking_from_fan_of_the_day(rank, type)
    ranking_element = {}
    ranking_element["title"] = "Fan del giorno"
    ranking_element["type"] = type
    position_list = []
    rank.each do |winner|
      if winner["winner"]
        position = {
          "rank" => winner["day"],
          "avatar_url" => winner["winner"].user.avatar_selected_url,
          "username" => winner["winner"].user.username,
          "counter" => winner["winner"].counter 
        }
        position_list << position
      end
    end
    ranking_element["position_list"] = position_list
    ranking_element["total"] = position_list.count
    
    ranking_element
  end
  
end