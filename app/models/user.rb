# encoding: utf-8

class User < ActiveRecordWithJSON
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  attr_accessible :email, :password, :password_confirmation, :remember_me, :role, :role, :first_name, :last_name, :privacy,
    :avatar_selected, :avatar, :swid, :cap, :location, :province, :address, :phone, :number, :rule, :birth_date,
    :day_of_birth, :month_of_birth, :year_of_birth, :user_counter_id, :username, :newsletter, :required_attrs, :avatar_selected_url,
    :major_date, :gender, :aux

  json_attributes [[:aux, EmptyAux]]

  attr_accessor :day_of_birth, :month_of_birth, :year_of_birth, :required_attrs, :major_date

  has_many :authentications, dependent: :destroy
  has_many :user_interactions
  has_many :user_comment_interactions
  has_many :user_rewards, dependent: :destroy
  has_many :user_counters
  has_many :user_upload_interactions
  has_many :call_to_actions

  before_save :set_date_of_birth
  before_save :set_username_if_not_required
  before_update :set_current_avatar
  before_create :default_values

  has_attached_file :avatar, :styles => { :medium => "300x300#", :thumb => "100x100#" }, 
                    :convert_options => { :medium => '-quality 60', :thumb => '-quality 60' }, 
                    :default_url => "/assets/anon.png"

  validates_presence_of :location, if: Proc.new { |f| required_attr?("location") }
  validates_presence_of :gender, if: Proc.new { |f| required_attr?("gender") }
  validates_presence_of :province, if: Proc.new { |f| required_attr?("province") }
  validate :presence_of_birth_date, if: Proc.new { |f| required_attr?("birth_date") }
  validates_presence_of :first_name, if: Proc.new { |f| required_attr?("first_name") }
  validates_presence_of :last_name, if: Proc.new { |f| required_attr?("last_name") }
  validate :privacy_accepted
  validate :newsletter_acceptance, if: Proc.new { |f| required_attr?("newsletter") }
  validates_presence_of :username, if: Proc.new { |f| required_attr?("username") }
  validates :username, uniqueness: true, if: Proc.new { |f| required_attr?("username") }
  validate :major, if: Proc.new { |f| major_date.present? }

  after_initialize :set_attrs

  def set_username_if_not_required
    unless required_attr?("username")
      self.username = email
    end
  end

  def newsletter_acceptance
    errors.add(:newsletter, :accepted) unless newsletter
  end

  def privacy_accepted
    errors.add(:privacy, :accepted) unless privacy
  end

  def set_attrs
    if !day_of_birth.present? && birth_date
      self.day_of_birth = birth_date.strftime("%d")
    else
      self.day_of_birth = ""
    end

    if !month_of_birth.present? && birth_date
      self.month_of_birth = birth_date.strftime("%m")
    else
      self.month_of_birth = ""
    end

    if !year_of_birth.present? && birth_date
      self.year_of_birth = birth_date.strftime("%Y")
    else
      self.year_of_birth = ""
    end
  end


  def presence_of_birth_date
    unless (year_of_birth.present? && month_of_birth.present? && day_of_birth.present?) || birth_date.present?
      errors.add(:birth_date, :blank)
    end
  end

  def required_attr?(attr_name)
    if $site.required_attrs.present?
      $site.required_attrs.include?(attr_name)
    else
      false
    end
  end

  def major
    if self.year_of_birth.present? && self.month_of_birth.present? && self.day_of_birth.present? &&
       (Time.parse(major_date) - Time.parse("#{year_of_birth}/#{month_of_birth}/#{day_of_birth}"))/1.year < 18
      errors.add(:birth_date, :major)
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

  def logged_from_omniauth(auth, provider)
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

    self.aux = JSON.parse(self.aux) if self.aux.present?
    self.save
    return self
  end

  # Update the user without ask the account password again.
  def update_with_password(params={}) 
    if params[:password].blank? 
      params.delete(:password) 
      params.delete(:password_confirmation) if params[:password_confirmation].blank? 
    end 
    update_attributes(params) 
  end

  # Specifies that this is a real user, not somebody used just interanlly by the system, such as to evaluate rules
  def mocked?
    false
  end
  
  def set_current_avatar
    if avatar.present?
      self.avatar_selected_url = avatar.url(:thumb)
    end
  end
  
  def default_values
    self.avatar_selected_url ||= "/assets/anon.png"
  end
  
end
