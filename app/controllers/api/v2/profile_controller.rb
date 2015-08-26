class Api::V2::ProfileController < Api::V2::BaseController
  
  include RankingHelper
  
  def index

    my_position, total = get_my_general_position_in_property
    response = {}
    elements = []
    
    elements << {
      "type" => "nickname",
      "info" => {
        "nickname" => extract_name_or_username(current_user),
      }
    }
    
    elements << {
      "type" => "points",
      "info" => {
        "points" => get_point,
        "credits" => get_counter_about_user_reward("credit")
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
    
    elements << {
      "type" => "notice",
      "info" => {}
    }
    
    response["profileElements"] = elements
    
    respond_with response.to_json
    
  end
  
end