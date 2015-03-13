class Sites::Orzoro::CupRedeemerController < ApplicationController

  before_filter :set_menu

  def set_menu
    @aux_other_params = { 
      page_tag: {
        miniformat: {
          name: "tazze"
        }
      }
    }
  end

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

    validates_presence_of :first_name, :last_name, :gender, :email, :day_of_birth, :month_of_birth, :year_of_birth, 
                          :state, :province, :privacy
    validates :email, format: { with: %r{.+@.+\..+} }
    validate :is_13?

    def is_13?
      unless User.has_age?(self.year_of_birth, self.month_of_birth, self.day_of_birth, Time.now.to_s, 13)
        errors.add(:base, "Devi aver compiuto 13 anni per poter richiedere le tazze")
      end
    end

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
    @cup_tag = Tag.find_by_name("cup-redeemer")
    @cup_tag_extra_fields = get_extra_fields!(@cup_tag)
    render template: "cup_redeemer/index"
  end

  def step_1
    if getSessionId.nil?
      redirect_to "/tazze"
    else
      @provinces_array = ITALIAN_PROVINCES.map { |province| [province, province] }.unshift(["Provincia", ""])
      @states_array = states_array = WORLD_STATES.map { |state| [state, state] }#.unshift(["Stato", ""])
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
    @provinces_array = ITALIAN_PROVINCES.map { |province| [province, province] }.unshift(["Provincia", ""])
    @states_array = states_array = WORLD_STATES.map { |state| [state, state] }#.unshift(["Stato", ""])
    @cup_redeemer = CupRedeemerStep1.new(params[:sites_orzoro_cup_redeemer_controller_cup_redeemer_step1])
    if @cup_redeemer.valid?
      cache_value = { "identity" => params[:sites_orzoro_cup_redeemer_controller_cup_redeemer_step1] }
      cache_write("cup-redeemer-#{getSessionId}", cache_value, 1.hour)
      redirect_to "/tazze/step_2"
    else
      render template: "cup_redeemer/step_1"
    end
  end

  def step_2
    @cup_tag_extra_fields = get_extra_fields!(Tag.find_by_name("cup-redeemer"))
    cache_value = cache_read("cup-redeemer-#{getSessionId}")
    if getSessionId.nil? || cache_value.nil? || cache_value["identity"].nil?
      redirect_to "/tazze/step_1"
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
      redirect_to "/tazze/step_3"
    elsif cache_value.nil?
      redirect_to "/tazze/step_1"
    else
      render template: "cup_redeemer/step_2"
    end
  end

  def step_3
    @cup_redeemer = CupRedeemerStep3.new
    cache_value = cache_read("cup-redeemer-#{getSessionId}")
    if getSessionId.nil? || cache_value.nil? || cache_value["identity"].nil? || cache_value["receipt"].nil?
      redirect_to "/tazze/step_1"
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
      redirect_to "/tazze/request_completed"
    elsif cache_value.nil?
      redirect_to "/tazze/step_1"
    else
      render template: "cup_redeemer/step_3"
    end
  end

  def request_completed
    @cup_tag_extra_fields = get_extra_fields!(Tag.find_by_name("cup-redeemer"))
    cache_value = cache_read("cup-redeemer-#{getSessionId}")
    if getSessionId.nil? || cache_value.nil? || cache_value["identity"].nil? || cache_value["receipt"].nil? || cache_value["address"].nil?
      redirect_to "/tazze/step_1"
    else
      info = build_info(cache_value)
      user = User.find_by_email(cache_value["identity"]["email"])
      new_user = user.nil?

      if new_user
        info[:email] = cache_value["identity"]["email"]
        info[:confirmation_token] = Digest::MD5.hexdigest(info[:email] + Rails.configuration.secret_token)[0..31]
        user = User.new(info)
        user_created_flag = true
        aux_hash = { "terms" => cache_value["identity"]["terms"], "sync_timestamp" => "" }
      else
        aux_hash = JSON.parse(user.aux) rescue {}
      end

      if new_user || user.confirmation_token
        @message_title = "Controlla la tua casella di posta elettronica"
        @message_description = "per confermare la registrazione e completare la tua richiesta"
      else
        @message_title = "Ti abbiamo inviato una e-mail di conferma nella tua casella di posta"
      end

      if receipt_already_redeemed(aux_hash, cache_value["receipt"]["receipt_number"])
        flash[:error] = "Hai gia' richiesto tazze per questo scontrino"
      else
        cache_value["request_timestamp"] = Time.now
        redeem_array = aux_hash["cup_redeem"].nil? ? [cache_value] : aux_hash["cup_redeem"] + [cache_value]
        aux_hash["cup_redeem"] = redeem_array
        user.aux = aux_hash.to_json
        user.assign_attributes(info) if (!user_created_flag && redeem_array.size == 1)
        user.confirmation_sent_at = Time.now if user.confirmation_token.present?
        user.save(:validate => false)
        if user.confirmation_token.present?
          SystemMailer.orzoro_registration_confirmation(cache_value, user).deliver
        else
          SystemMailer.orzoro_cup_redeem_confirmation(cache_value).deliver
        end
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

  def build_info(cache_value)
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

  def complete_registration
    if Digest::MD5.hexdigest(params[:email] + Rails.configuration.secret_token)[0..31] == params[:token]
      user = User.find_by_email(params[:email])
      if user.present?
        if Time.now - user.confirmation_sent_at < 7.days
          if user.confirmation_token
            user.update_attributes(:confirmation_token => nil, :confirmed_at => Time.now)
            @message = "Complimenti! Hai confermato la tua registrazione."
          else
            @message = "Indirizzo mail verificato in precedenza."
          end
        else
          @message = "Token di conferma scaduto. Compila nuovamente la richiesta."
        end
      end
    else
      @message = "Link non valido."
    end
    render template: "cup_redeemer/complete_registration"
  end

end