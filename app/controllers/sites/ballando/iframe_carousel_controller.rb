class Sites::Ballando::IframeCarouselController < ApplicationController
  include HomeLauncherHelper
  include CallToActionHelper
  
  def main
    if current_user
      @calltoactions = cache_short("iframe_carousel_calltoactions") do
        CallToAction.active.limit(3).to_a
      end
      @calltoaction_reward_status = Hash.new
      @calltoactions.each do |calltoaction|
        @calltoaction_reward_status[calltoaction.id] = get_current_call_to_action_reward_status(MAIN_REWARD_NAME, calltoaction)
      end
    else
      @active_home_launchers = active_home_launchers()
    end
    @stream_url = Rails.configuration.deploy_settings["sites"]["ballando"]["stream_url"]
    render template: "/iframe_carousel/main"
  end

  def footer
    @calltoactions = cache_short("iframe_carousel_footer_calltoactions") do
      CallToAction.active.limit(8).to_a
    end
    
    @calltoaction_reward_status = Hash.new
    @calltoactions.each do |calltoaction|
      @calltoaction_reward_status[calltoaction.id] = get_current_call_to_action_reward_status(MAIN_REWARD_NAME, calltoaction)
    end

    @calltoaction_count = @calltoactions.count

    unless mobile_device?()
      @calltoactions_for_page = 4
      @calltoaction_pages = (@calltoaction_count.to_f / @calltoactions_for_page).ceil
    end

    render template: "/iframe_carousel/footer"
  end
  
end

