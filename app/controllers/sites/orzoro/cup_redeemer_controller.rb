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

    validates_presence_of :first_name, :last_name, :email, :day_of_birth, :month_of_birth, :year_of_birth, 
                          :state, :province, :terms, :newsletter, :privacy
    validates :email, format: { with: %r{.+@.+\..+} }
  end

  class CupRedeemerStep2
    include ActiveAttr::Attributes
    include ActiveAttr::Model

    attribute :package_count, type: Integer
    attribute :cup_selected, type: String
    attribute :receipt_number, type: String
    attribute :day_of_emission, type: String
    attribute :month_of_emission, type: String
    attribute :year_of_emission, type: String
    attribute :hour_of_emission, type: String
    attribute :minute_of_emission, type: String
    attribute :receipt_total, type: Float

    validates_presence_of :package_count, :receipt_number, :day_of_emission, :month_of_emission, :year_of_emission, 
                          :hour_of_emission, :minute_of_emission
    validates :receipt_total, presence: true, numericality: { only_float: true }
    validates_presence_of :cup_selected, :if => :two_packages_selected?

    def two_packages_selected?
      package_count == 2
    end

  end

  class CupRedeemerStep3
    include ActiveAttr::Attributes
    include ActiveAttr::Model

    attribute :first_name, type: String
    attribute :last_name, type: String
    attribute :address, type: String
    attribute :street_number, type: String
    attribute :city, type: String
    attribute :province, type: String
    attribute :cap, type: String

    validates_presence_of :first_name, :last_name, :address, :street_number, :city, :province, :cap
    validates :cap, format: { with: /\d{5}/ }
  end

  def index
    debugger
    @cup_tag_extra_fields = get_extra_fields!(Tag.find_by_name("cup-redeemer"))
    render template: "cup_redeemer/index"
  end

  def step_1
    if getSessionId.nil?
      redirect_to "/cup_redeemer/index"
    else
      @provinces_array = ITALIAN_PROVINCES.map { |province| [province, province] }.unshift(["Provincia", ""])
      # @states_array = states_array = WORLD_STATES.map { |state| [state, state] }.unshift(["Stato", ""])
      @states_array = ["Italia"]
      cache_value = cache_read("cup-redeemer-#{getSessionId}")
      if cache_value
        @cup_redeemer = CupRedeemerStep1.new(cache_value["identity"])
      else
        @cup_redeemer = CupRedeemerStep1.new
      end
      render template: "cup_redeemer/step_1"
    end
  end

  def step_1_update
    @cup_redeemer = CupRedeemerStep1.new(params[:sites_orzoro_cup_redeemer_controller_cup_redeemer_step1])
    if @cup_redeemer.valid?
      cache_value = { "identity" => params[:sites_orzoro_cup_redeemer_controller_cup_redeemer_step1] }
      cache_write("cup-redeemer-#{getSessionId}", cache_value, 1.hour)
      redirect_to "/cup_redeemer/step_2"
    else
      render template: "cup_redeemer/step_1"
    end
  end

  def step_2
    @cup_tag_extra_fields = get_extra_fields!(Tag.find_by_name("cup-redeemer"))
    cache_value = cache_read("cup-redeemer-#{getSessionId}")
    if getSessionId.nil? || cache_value.nil? || cache_value["identity"].nil?
      redirect_to "/cup_redeemer/step_1"
    else
      @cup_redeemer = CupRedeemerStep2.new(cache_value["receipt"])
      render template: "cup_redeemer/step_2"
    end
  end

  def step_2_update
    @cup_tag_extra_fields = get_extra_fields!(Tag.find_by_name("cup-redeemer"))
    @cup_redeemer = CupRedeemerStep2.new(params[:sites_orzoro_cup_redeemer_controller_cup_redeemer_step2])
    cache_value = cache_read("cup-redeemer-#{getSessionId}")
    if @cup_redeemer.valid?
      new_cache_value = cache_value.merge({ "receipt" => params[:sites_orzoro_cup_redeemer_controller_cup_redeemer_step2] }) if cache_value
      cache_write("cup-redeemer-#{getSessionId}", new_cache_value, 1.hour)
      redirect_to "/cup_redeemer/step_3"
    elsif cache_value.nil?
      redirect_to "/cup_redeemer/step_1"
    else
      render template: "cup_redeemer/step_2"
    end
  end

  def step_3
    @cup_redeemer = CupRedeemerStep3.new
    cache_value = cache_read("cup-redeemer-#{getSessionId}")
    if getSessionId.nil? || cache_value.nil? || cache_value["identity"].nil? || cache_value["receipt"].nil?
      redirect_to "/cup_redeemer/step_1"
    else
      @cup_redeemer = CupRedeemerStep3.new(cache_value["address"])
      render template: "cup_redeemer/step_3"
    end
  end

  def step_3_update
    @cup_redeemer = CupRedeemerStep3.new(params[:sites_orzoro_cup_redeemer_controller_cup_redeemer_step3])
    cache_value = cache_read("cup-redeemer-#{getSessionId}")
    if @cup_redeemer.valid?
      new_cache_value = cache_value.merge({ "address" => params[:sites_orzoro_cup_redeemer_controller_cup_redeemer_step3] }) if cache_value
      cache_write("cup-redeemer-#{getSessionId}", new_cache_value, 1.hour)
      redirect_to "/cup_redeemer/request_completed"
    elsif cache_value.nil?
      redirect_to "/cup_redeemer/step_1"
    else
      render template: "cup_redeemer/step_3"
    end
  end

  def request_completed
    @cup_tag_extra_fields = get_extra_fields!(Tag.find_by_name("cup-redeemer"))
    cache_value = cache_read("cup-redeemer-#{getSessionId}")
    if getSessionId.nil? || cache_value.nil? || cache_value["identity"].nil? || cache_value["receipt"].nil? || cache_value["address"].nil?
      redirect_to "/cup_redeemer/step_1"
    else
      infos = build_infos(cache_value)
      user = User.find_by_email(cache_value["identity"]["email"])
      if user.nil?
        infos[:email] = cache_value["identity"]["email"]
        # infos[:password] = (0...8).map { (97 + rand(26)).chr }.join # random generated
        user = User.create(infos)
        user_created_flag = true
      end
      aux_hash = user.aux.nil? ? {} : JSON.parse(user.aux)
      if receipt_already_redeemed(aux_hash, cache_value["receipt"]["receipt_number"])
        flash[:error] = "Hai gia' richiesto tazze per questo scontrino"
      else
        redeem_array = aux_hash["cup_redeem"].nil? ? [cache_value] : aux_hash["cup_redeem"] + [cache_value]
        aux_hash["cup_redeem"] = redeem_array
        user.aux = aux_hash.to_json
        user.update_attributes(infos) if (!user_created_flag and redeem_array.size == 1)
        user.save(:validate => false)
      end
      render template: "cup_redeemer/request_completed"
    end
  end

  def receipt_already_redeemed(aux_hash, receipt_number)
    if aux_hash["cup_redeem"].nil?
      return false
    else
      aux_hash["cup_redeem"].each do |request|
        if request["receipt"]["receipt_number"] == receipt_number
          return true
        end
      end
      return false
    end
  end

  def build_infos(cache_value)
    { :first_name => cache_value["identity"]["first_name"], :last_name => cache_value["identity"]["last_name"], 
        :cap => cache_value["address"]["cap"], :location => cache_value["address"]["city"], 
        :province => cache_value["address"]["province"], :address => cache_value["address"]["address"], 
        :number => cache_value["address"]["street_number"], :phone => cache_value["identity"]["phone"], 
        :birth_date => "#{cache_value['identity']['year_of_birth']}-
          #{(sprintf '%02d', cache_value['identity']['month_of_birth'])}-
          #{(sprintf '%02d', cache_value['identity']['day_of_birth'])}", 
        :gender => cache_value["identity"]["gender"], :username => cache_value["identity"]["email"] }
  end

  def getSessionId
    request.session_options[:id]
  end

end