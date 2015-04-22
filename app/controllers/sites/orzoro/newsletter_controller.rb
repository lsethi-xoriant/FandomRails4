class Sites::Orzoro::NewsletterController < ApplicationController

  class Subscription
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
        errors.add(:base, "Devi aver compiuto 13 anni per poter registrarti alla newsletter")
      end
    end

  end

  def subscribe
    @provinces_array = ITALIAN_PROVINCES.map { |province| [province, province] }.unshift(["Provincia", ""])
    @states_array = states_array = WORLD_STATES.map { |state| [state, state] }#.unshift(["Stato", ""])
    @subscription = Subscription.new
    render template: "newsletter/subscribe"
  end

  def send_request
    @provinces_array = ITALIAN_PROVINCES.map { |province| [province, province] }.unshift(["Provincia", ""])
    @states_array = states_array = WORLD_STATES.map { |state| [state, state] }#.unshift(["Stato", ""])
    aux_params = params[:sites_orzoro_newsletter_controller_subscription]
    @subscription = Subscription.new(aux_params)
    if @subscription.valid?
      @assets_extra_fields = get_extra_fields!(Tag.find_by_name("assets"))
      info = build_info(aux_params)
      user = User.find_by_email(info[:email])
      new_user = user.nil?

      if new_user
        info[:confirmation_token] = Digest::MD5.hexdigest(info[:email] + Rails.configuration.secret_token)[0..31]
        user = User.new(info)
        user_created_flag = true
        aux_hash = { "terms" => aux_params["terms"], "sync_timestamp" => "" }
      else
        aux_hash = JSON.parse(user.aux) rescue {}
      end

      if new_user || user.confirmation_token
        @message_title = "Controlla la tua casella di posta elettronica"
        @message_description = "per confermare la tua registrazione"
      else
        @message_title = "Ti abbiamo inviato una e-mail di conferma nella tua casella di posta"
      end

      aux_params["request_timestamp"] = Time.now
      aux_params["entry_point"] = "subscribe_newsletter"
      redeem_array = aux_hash["cup_redeem"].nil? ? [{ "identity" => aux_params }] : aux_hash["cup_redeem"] + [{ "identity" => aux_params }]
      aux_hash["cup_redeem"] = redeem_array
      user.aux = aux_hash.to_json
      user.assign_attributes(info) if (!user_created_flag && redeem_array.size == 1)
      user.confirmation_sent_at = Time.now if user.confirmation_token.present?
      user.save(:validate => false)
      if user.confirmation_token.present?
        SystemMailer.orzoro_registration_confirmation_from_newsletter(info, user).deliver
      else
        SystemMailer.orzoro_newsletter_confirmation(info).deliver
      end
      render template: "newsletter/request_completed"
    else
      render template: "newsletter/subscribe"
    end
  end

  def build_info(params)
    { :email => params["email"], 
      :first_name => params["first_name"], :last_name => params["last_name"], 
      :province => params["province"], :phone => params["phone"], 
      :birth_date => "#{params['year_of_birth']}-#{(sprintf '%02d', params['month_of_birth'])}-#{(sprintf '%02d', params['day_of_birth'])}", 
      :gender => params["gender"], :username => params["email"] 
    }
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
    @assets_extra_fields = get_extra_fields!(Tag.find_by_name("assets"))
    render template: "newsletter/complete_registration"
  end

end