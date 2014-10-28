class Sites::Ballando::IframeCarouselController < ApplicationController
  include HomeLauncherHelper
  include CallToActionHelper
  
  def main
    @calltoactions = cache_short("iframe_carousel_calltoactions") do     
      highlight_calltoactions = get_highlight_calltoactions()
      active_calltoactions_without_rewards = CallToAction.includes(:rewards).active.where("rewards.id IS NULL")
      if highlight_calltoactions.any?
        last_calltoactions = active_calltoactions_without_rewards.where("call_to_actions.id NOT IN (?)", highlight_calltoactions.map { |calltoaction| calltoaction.id }).limit(3).to_a
      else
        last_calltoactions = active_calltoactions_without_rewards.active.limit(3).to_a
      end
      highlight_calltoactions + last_calltoactions
    end

    @calltoaction_reward_status = Hash.new
    @calltoactions.each do |calltoaction|
      @calltoaction_reward_status[calltoaction.id] = compute_call_to_action_completed_or_reward_status(MAIN_REWARD_NAME, calltoaction)
    end
      
    # Removed
    # @active_home_launchers = active_home_launchers()

    @stream_url = Rails.configuration.deploy_settings["sites"]["ballando"]["stream_url"]
    @profile_url = Rails.configuration.deploy_settings["sites"]["ballando"]["profile_url"]

    render template: "/iframe_carousel/main"
  end

  def footer
    @calltoactions = cache_short("iframe_carousel_footer_calltoactions") do
      CallToAction.includes(:rewards).active.where("rewards.id IS NULL").limit(8).to_a
    end
    
    @calltoaction_reward_status = Hash.new
    @calltoactions.each do |calltoaction|
      @calltoaction_reward_status[calltoaction.id] = compute_call_to_action_completed_or_reward_status(MAIN_REWARD_NAME, calltoaction)
    end

    @calltoaction_count = @calltoactions.count

    @calltoactions_for_page = 4
    @calltoaction_pages = (@calltoaction_count.to_f / @calltoactions_for_page).ceil

    render template: "/iframe_carousel/footer"
  end
  
end

