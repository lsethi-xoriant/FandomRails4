class Sites::Orzoro::CupRedeemerController < ApplicationController

  class CupRedeemerStep1
    include ActiveAttr::Attributes
    include ActiveAttr::Model

    attribute :first_name, type: String
    attribute :last_name, type: String
    attribute :email, type: String
    attribute :gender, type: String
    attribute :state, type: String
    attribute :province, type: String
    attribute :phone, type: String
    attribute :day_of_birth, type: Integer
    attribute :month_of_birth, type: Integer
    attribute :year_of_birth, type: Integer
    attribute :terms, type: Boolean
    attribute :newsletter, type: Boolean
    attribute :privacy, type: Boolean

    validates_presence_of :first_name, :last_name, :email, :day_of_birth, :month_of_birth, :year_of_birth, :state, :province, :phone,
      :terms, :newsletter, :privacy
    validates :email, format: { with: %r{.+@.+\..+} }
  end

   class CupRedeemerStep2
    include ActiveAttr::Attributes
    include ActiveAttr::Model

    attribute :package_count, type: Integer


    validates_presence_of :package_count
  end

  def step_1
    @cup_redeemer = CupRedeemerStep1.new
    render template: "cup_redeemer/step_1"
  end

  def step_1_update   
    @cup_redeemer = CupRedeemerStep1.new(params[:sites_orzoro_cup_redeemer_controller_cup_redeemer_step1])
    if @cup_redeemer.valid?
      cache_value = { "cup_redeemer_step_1" => params[:sites_orzoro_cup_redeemer_controller_cup_redeemer_step1] }
      cache_write(session[:session_id], cache_value, 1.hour)
      redirect_to "/cup_redeemer/step_2"
    else
      render template: "cup_redeemer/step_1"
    end
  end

  def step_2
    @cup_tag_extra_fields = get_extra_fields!(Tag.find_by_name("cup-redeemer"))
    @cup_redeemer = CupRedeemerStep2.new
    render template: "cup_redeemer/step_2"
  end

end