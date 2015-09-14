class Api::V2::ProfileController < Api::V2::BaseController
  
  include RankingHelper
  
  def index

    my_position, total = get_my_general_position_in_property
    response = {}
    elements = []
    
    response["header"] = {
      "type" => "nickname",
      "info" => {
        "nickname" => extract_name_or_username(current_user),
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
  
end