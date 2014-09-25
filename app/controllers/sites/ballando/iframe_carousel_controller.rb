class Sites::Ballando::IframeCarouselController < ApplicationController
  include HomeLauncherHelper
  include CallToActionHelper
  
  def show
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
    render template: "/iframe_carousel/show"
  end
  
end

