# encoding: utf-8

class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  attr_accessible :email, :password, :password_confirmation, :remember_me, :role, :role, :first_name, :last_name, :privacy,
    :avatar_selected, :avatar, :swid

  has_many :authentications, dependent: :destroy
  has_many :rewarding_users, dependent: :destroy
  has_many :userinteractions
  has_many :user_comments

  after_save :append_rewarding_user # With invitation is enable: if: Proc.new { |u| u.invitation_token.blank? }
  has_one :general_rewarding_user

  has_attached_file :avatar, :styles => { :medium => "300x300#", :thumb => "100x100#" }

  validates_presence_of :first_name
  validates_presence_of :last_name
  validates :privacy, :acceptance => { :accept => true }

  def append_rewarding_user
    Property.active.each do |p|
      registration_calltoaction = p.calltoactions.includes(:interactions).where("interactions.resource_type='Registration'").first
      if registration_calltoaction
        registration_intr = registration_calltoaction.interactions.find_by_resource_type("Registration")
        unless Userinteraction.find_by_user_id_and_interaction_id(self.id, registration_intr.id)
          Userinteraction.create(user_id: self.id, interaction_id: registration_intr.id, points: registration_intr.points)
        end
      end
    end
  end

  def twitter
    tt_user = self.authentications.find_by_provider("twitter")
    if tt_user
      @twitter ||= Twitter::REST::Client.new do |config|
        config.consumer_key = ENV["TWITTER_APP_ID"]
        config.consumer_secret = ENV["TWITTER_APP_SECRET"]
        config.access_token = tt_user.oauth_token
        config.access_token_secret = tt_user.oauth_secret
      end
    end
  end

  def facebook
    begin
      fb_user = self.authentications.find_by_provider("facebook")
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
          oauth_secret: (provider == "twitter" ? auth.credentials.secret : ""),
          oauth_expires_at: (provider == "facebook" ? Time.at(auth.credentials.expires_at) : ""),
          avatar: auth.info.image,
          user_id: self.id
      )
    else
      self.authentications.build(
          uid: auth.uid,
          name: auth.info.name,
          oauth_token: auth.credentials.token,
          oauth_secret: (provider == "twitter" ? auth.credentials.secret : ""),
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
          oauth_secret: (provider == "twitter" ? auth.credentials.secret : ""),
          oauth_expires_at: (provider == "facebook" ? Time.at(auth.credentials.expires_at) : ""),
          avatar: auth.info.image
      )
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
          privacy: true
          )
      end 

      # Recupero l'autenticazione associata al provider selezionato.
      # Da tenere conto che vengono salvate informazioni differenti a seconda del provider di provenienza.
      user.authentications.build(
          uid: auth.uid,
          name: auth.info.name,
          oauth_token: auth.credentials.token,
          oauth_secret: (provider == "twitter" ? auth.credentials.secret : ""),
          oauth_expires_at: (provider == "facebook" ? Time.at(auth.credentials.expires_at) : ""),
          provider: provider,
          avatar: auth.info.image
      )
    end 

    user.save
    return user
  end

  # Permette di aggiornare l'utente senza un nuovo inserimento della password.
  def update_with_password(params={}) 
    if params[:password].blank? 
      params.delete(:password) 
      params.delete(:password_confirmation) if params[:password_confirmation].blank? 
    end 
    update_attributes(params) 
  end


end
