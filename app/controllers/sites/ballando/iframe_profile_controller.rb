class Sites::Ballando::IframeProfileController < ApplicationController
  include NoticeHelper

  before_filter :check_registration_ga, :if => proc {|c| ga_code().present? }
  
  def check_registration_ga
    @registration_ga = cookies[:after_registration].present?
    cookies.delete(:after_registration)
  end
  
  def show
    @notices_count = get_unread_notifications_count
    @profile_url = Rails.configuration.deploy_settings["sites"]["ballando"]["profile_url"]
    render template: "/iframe_profile/show"
  end
  
end

