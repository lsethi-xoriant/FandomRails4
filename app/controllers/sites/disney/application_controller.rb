class Sites::Disney::ApplicationController < ApplicationController
  include RankingHelper
  include DisneyHelper

  def iur
    cookies[:from_iur_authenticate] = request.referrer
  end
  
  def rankings
    rank = Ranking.find_by_name("#{$context_root}_general_chart")
    @property_rank = get_full_rank(rank)
    
    @fan_of_days = []
    (1..6).each do |i|
      day = Time.now - i.day
      @fan_of_days << {"day" => "#{day.strftime('%d %b.')}", "winner" => get_winner_of_day(day)}
    end
    
    render template: "profile/rankings"
  end
  
  def populate_rankings
    
  end

  def init_aux()
    filters = get_tags_with_tag("featured")
    current_property = get_tag_from_params(get_disney_property())

    current_property_info = {
      "id" => current_property.id,
      "background" => get_extra_fields!(current_property)["label-background"],
      "logo" => (get_extra_fields!(current_property)["logo"]["url"] rescue nil),
      "title" => get_extra_fields!(current_property)["title"],
      "image" => (get_upload_extra_field_processor(get_extra_fields!(current_property)["image"], :custom) rescue nil) 
    }

    if filters.any?
      if $context_root
        filters = filters & get_tags_with_tag(get_disney_property())
      end
      filter_info = []
      filters.each do |filter|
        filter_info << {
          "id" => filter.id,
          "background" => get_extra_fields!(filter)["label-background"],
          "icon" => get_extra_fields!(filter)["icon"],
          "title" => get_extra_fields!(filter)["title"],
          "image" => (get_upload_extra_field_processor(get_extra_fields!(filter)["image"], :custom) rescue nil) 
        }
      end
    end

    properties = get_tags_with_tag("property")

    if properties.any?
      property_info = []
      properties.each do |property|
        property_info << {
          "id" => property.id,
          "background" => get_extra_fields!(property)["label-background"],
          "title" => (get_extra_fields!(property)["title"].downcase rescue nil),
          "image" => (get_upload_extra_field_processor(get_extra_fields!(property)["image"], :custom) rescue nil) 
        }
      end
    end

    calltoaction_evidence_info = cache_short(get_evidence_calltoactions_cache_key()) do   
      highlight_calltoactions = get_highlight_calltoactions()
      active_calltoactions_without_rewards = CallToAction.includes(:rewards).active.where("rewards.id IS NULL")
      if highlight_calltoactions.any?
        last_calltoactions = active_calltoactions_without_rewards.where("call_to_actions.id NOT IN (?)", highlight_calltoactions.map { |calltoaction| calltoaction.id }).limit(3).to_a
      else
        last_calltoactions = active_calltoactions_without_rewards.active.limit(3).to_a
      end
      calltoactions = highlight_calltoactions + last_calltoactions
      calltoaction_evidence_info = []
      calltoactions.each do |calltoaction|
        calltoaction_evidence_info << {
          "id" => calltoaction.id,
          "status" => compute_call_to_action_completed_or_reward_status(MAIN_REWARD_NAME, calltoaction),
          "thumbnail_carousel_url" => calltoaction.thumbnail(:carousel),
          "title" => calltoaction.title,
          "description" => calltoaction.description
        }
      end
      calltoaction_evidence_info
    end

    {
      "tenant" => get_site_from_request(request)["id"],
      "anonymous_interaction" => get_site_from_request(request)["anonymous_interaction"],
      "main_reward_name" => MAIN_REWARD_NAME,
      "kaltura" => get_deploy_setting("sites/#{request.site.id}/kaltura", nil),
      "filter_info" => filter_info,
      "property_info" => property_info,
      "current_property_info" => current_property_info,
      "calltoaction_evidence_info" => calltoaction_evidence_info
    }
  end
  
end