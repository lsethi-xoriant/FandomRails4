class Sites::Ballando::IframeProfileController < ApplicationController
  include NoticeHelper
  
  def show
    @notices_count = get_unread_notifications_count
    @profile_url = Rails.configuration.deploy_settings["sites"]["ballando"]["profile_url"]
    render template: "/iframe_profile/show"
  end
  
end

