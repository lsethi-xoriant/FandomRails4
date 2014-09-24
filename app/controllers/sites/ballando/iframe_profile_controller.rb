class Sites::Ballando::IframeProfileController < ApplicationController
  def show
    @notices_count = 0 #current_user ? Notice.where("user_id = ? AND viewed = ?", current_user.id, false).count : 0
    @profile_url = Rails.configuration.deploy_settings["sites"]["ballando"]["profile_url"]
    render template: "/iframe_profile/show"
  end
end

