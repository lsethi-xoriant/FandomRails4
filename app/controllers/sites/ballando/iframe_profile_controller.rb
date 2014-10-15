class Sites::Ballando::IframeProfileController < ApplicationController
  include NoticeHelper

  before_filter :check_registration_ga

  def check_registration_ga
    if ga_code().present? 
      @registration_ga = cookies[:after_registration].present?
      cookies.delete(:after_registration)
    end
  end
  
  def show
    @notices_count = get_unread_notifications_count
    @profile_url = Rails.configuration.deploy_settings["sites"]["ballando"]["profile_url"]
    render template: "/iframe_profile/show"
  end
  
end

