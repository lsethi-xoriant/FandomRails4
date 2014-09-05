# encoding: utf-8

class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  attr_accessible :email, :password, :password_confirmation, :remember_me, :role, :role, :first_name, :last_name, :privacy,
    :avatar_selected, :avatar, :swid, :cap, :location, :province, :address, :phone, :number, :rule, :birth_date,
    :day_of_birth, :month_of_birth, :year_of_birth, :user_counter_id

  attr_accessor :day_of_birth, :month_of_birth, :year_of_birth

  has_many :authentications, dependent: :destroy
  has_many :user_interactions
  has_many :user_comment_interactions
  has_many :user_rewards
  has_many :user_counters
  has_many :user_upload_interactions

  before_save :set_date_of_birth

  has_attached_file :avatar, :styles => { :medium => "300x300#", :thumb => "100x100#" }, :default_url => "/assets/anon.png"

  validates_presence_of :first_name
  validates_presence_of :last_name
  validates :privacy, :acceptance => { :accept => true }

  def major
    if self.year_of_birth.present? && self.month_of_birth.present? && self.day_of_birth.present?
      errors.add(" ", "Come stabilito dal regolamento devi essere maggiorenne per poter partecipare al concorso") if (Time.parse("2014-06-03") - Time.parse("#{self.year_of_birth}-#{self.month_of_birth}-#{self.day_of_birth}"))/1.year < 18
    end
  end

  def set_date_of_birth
    if year_of_birth.present? && month_of_birth.present? && day_of_birth.present?
      write_attribute :birth_date, "#{year_of_birth}/#{month_of_birth}/#{day_of_birth}"
      year_of_birth = nil
      month_of_birth = nil
      day_of_birth = nil
    end
  end

  def twitter(tenant)
    tt_user = self.authentications.find_by_provider("twitter_#{tenant}")
    if tt_user
      @twitter ||= Twitter::REST::Client.new do |config|
        config.consumer_key = Rails.configuration.deploy_settings["sites"][tenant]["authentications"]["twitter"]["app_id"]
        config.consumer_secret = Rails.configuration.deploy_settings["sites"][tenant]["authentications"]["twitter"]["app_secret"]
        config.access_token = tt_user.oauth_token
        config.access_token_secret = tt_user.oauth_secret
      end
    end
  end

  def facebook(tenant)
    begin
      fb_user = self.authentications.find_by_provider("facebook_#{tenant}")
      @facebook ||= Koala::Facebook::API.new(fb_user.oauth_token) if fb_user
    rescue Exception => e
    end 
  end

  def logged_from_omniauth auth, provider
    # Se il PROVIDER era agganciato ad un altro utente lo sgancio e lo attacco all'utente corrente.
    user_auth = Authentication.find_by_provider_and_uid(provider, auth.uid);
    if user_auth
      user_auth.update_attributes(
          uid: auth.uid,
          name: auth.info.name,
          oauth_token: auth.credentials.token,
          oauth_secret: (provider.include?("twitter") ? auth.credentials.secret : ""),
          oauth_expires_at: (provider == "facebook" ? Time.at(auth.credentials.expires_at) : ""),
          avatar: auth.info.image,
          user_id: self.id
      )
    else
      self.authentications.build(
          uid: auth.uid,
          name: auth.info.name,
          oauth_token: auth.credentials.token,
          oauth_secret: (provider.include?("twitter") ? auth.credentials.secret : ""),
          oauth_expires_at: (provider == "facebook" ? Time.at(auth.credentials.expires_at) : ""),
          provider: provider,
          avatar: auth.info.image,
          user_id: self.id
      )
    end 

    self.save
    return self
  end

  # Metodo statico (User.not_logged_from_omniauth).
  def self.not_logged_from_omniauth auth, provider  
    user_auth =  Authentication.find_by_provider_and_uid(provider, auth.uid);
    if user_auth
      # Ho gia' agganciato questo PROVIDER, mi basta recuperare l'utente per poi aggiornarlo.
      # Da tenere conto che vengono salvate informazioni differenti a seconda del PROVIDER di provenienza.
      user = user_auth.user
      user_auth.update_attributes(
          uid: auth.uid,
          name: auth.info.name,
          oauth_token: auth.credentials.token,
          oauth_secret: (provider.include?("twitter") ? auth.credentials.secret : ""),
          oauth_expires_at: (provider == "facebook" ? Time.at(auth.credentials.expires_at) : ""),
          avatar: auth.info.image,
      )

      from_registration = false

    else
      # Verifico se esiste l'utente con l'email del provider selezionato.
      unless auth.info.email && (user = User.find_by_email(auth.info.email))
        password = Devise.friendly_token.first(8)
        user = User.new(
          password: password,
          password_confirmation: password,
          first_name: auth.info.first_name,
          last_name: auth.info.last_name,
          email: auth.info.email,
          avatar_selected: provider,
          privacy: true
          )
        from_registration = true
      else
        from_registration = false
      end 

      # Recupero l'autenticazione associata al provider selezionato.
      # Da tenere conto che vengono salvate informazioni differenti a seconda del provider di provenienza.
      user.authentications.build(
          uid: auth.uid,
          name: auth.info.name,
          oauth_token: auth.credentials.token,
          oauth_secret: (provider.include?("twitter") ? auth.credentials.secret : ""),
          oauth_expires_at: (provider == "facebook" ? Time.at(auth.credentials.expires_at) : ""),
          provider: provider,
          avatar: auth.info.image
      )

      user.save
    end 
    
    return user, from_registration
  end

  # Update the user without ask the account password again.
  def update_with_password(params={}) 
    if params[:password].blank? 
      params.delete(:password) 
      params.delete(:password_confirmation) if params[:password_confirmation].blank? 
    end 
    update_attributes(params) 
  end

end
