class Sites::Ballando::IframeProfileController < ApplicationController
  def show
    @notices_count = current_user ? Notice.where("user_id = ? AND viewed = ?", current_user.id, false).count : 0
    render template: "/iframe_profile/show"
  end
end

