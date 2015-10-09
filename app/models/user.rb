# encoding: utf-8

class User < ActiveRecordWithJSON
  # this is from simple_token_authentication used by API
  acts_as_token_authenticatable

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  attr_accessible :email, :password, :password_confirmation, :remember_me, :role, :role, :first_name, :last_name, :privacy,
    :avatar_selected, :avatar, :swid, :cap, :location, :province, :address, :phone, :number, :rule, :birth_date,
    :day_of_birth, :month_of_birth, :year_of_birth, :user_counter_id, :username, :newsletter, :required_attrs, :avatar_selected_url,
    :major_date, :gender, :aux, :confirmation_token, :confirmation_sent_at, :confirmed_at,
    :encrypted_password, :reset_password_token, :reset_password_sent_at, :remember_created_at, :sign_in_count, :current_sign_in_at, 
    :last_sign_in_at, :current_sign_in_ip, :last_sign_in_ip, :unconfirmed_email, :authentication_token, :created_at, :updated_at, 
    :avatar_file_name, :avatar_content_type, :avatar_file_size, :avatar_updated_at, :anonymous_id

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
                    :convert_options => { :medium => '-quality 60', :thumb => '-quality 60' }
  validates_attachment :avatar, content_type: { content_type: ["image/jpg", "image/jpeg", "image/png", "image/gif"] }

  validates_length_of :username, maximum: 15, if: Proc.new { |f| required_attr?("username_length") }
  validates_presence_of :location, if: Proc.new { |f| required_attr?("location") }
  validates_presence_of :gender, if: Proc.new { |f| required_attr?("gender") }
  validates_presence_of :province, if: Proc.new { |f| required_attr?("province") }
  validate :presence_of_birth_date, if: Proc.new { |f| required_attr?("birth_date") }
  validates_presence_of :first_name, if: Proc.new { |f| required_attr?("first_name") }
  validates_presence_of :last_name, if: Proc.new { |f| required_attr?("last_name") }
  validate :privacy_accepted, if: Proc.new { |f| required_attr?("privacy") }
  validate :newsletter_acceptance, if: Proc.new { |f| required_attr?("newsletter") }
  validates_presence_of :username, if: Proc.new { |f| required_attr?("username") }
  validates_uniqueness_of :username, case_sensitive: false, if: Proc.new { |f| required_attr?("username") }
  validate :major, if: Proc.new { |f| major_date.present? }

  after_initialize :set_attrs

  def set_username_if_not_required
    if !required_attr?("username") && self.username.blank?
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
    begin
      if !day_of_birth.present? && birth_date
        self.day_of_birth = birth_date.strftime("%d").to_i
      else
        self.day_of_birth = ""
      end
  
      if !month_of_birth.present? && birth_date
        self.month_of_birth = birth_date.strftime("%m").to_i
      else
        self.month_of_birth = ""
      end
  
      if !year_of_birth.present? && birth_date
        self.year_of_birth = birth_date.strftime("%Y").to_i
      else
        self.year_of_birth = ""
      end
    rescue Exception => e
    end
  end


  def presence_of_birth_date
    unless (year_of_birth.present? && month_of_birth.present? && day_of_birth.present?) || birth_date.present?
      errors.add(:birth_date, :blank)
    end
  end

  def required_attr?(attr_name)
    if required_attrs.present?
      required_attrs.include?(attr_name)
    elsif $site.required_attrs.present?
      $site.required_attrs.include?(attr_name)
    else
      false
    end
  end

  def self.has_age?(year_of_birth, month_of_birth, day_of_birth, now, age)
    return (Time.parse(now) - Time.parse("#{year_of_birth}/#{month_of_birth}/#{day_of_birth}"))/1.year >= age
  end

  def major
    unless self.has_age?(year_of_birth, month_of_birth, day_of_birth, major_date, 18)
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
    self.avatar_selected_url = avatar.url(:thumb) if avatar.present?
  end
  
  def default_values
    self.avatar_selected_url ||= nil # ActionController::Base.helpers.asset_path("#{$site.assets["anon_avatar"]}")
  end
  
end
