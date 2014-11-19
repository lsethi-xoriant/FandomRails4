
class Sites::Coin::ApplicationController < ApplicationController

  def registration_fully_completed?
    current_user.province.present? && current_user.birth_date.present?
  end
  
end