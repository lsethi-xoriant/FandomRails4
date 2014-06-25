class Reward < ActiveRecord::Base
  attr_accessible :name,
    :title, 
    :short_description, 
    :long_description, 
    :preview_image, 
    :main_image,
    :not_awarded_image,
    :button_label, 
    :cost,
    :video_url, 
    :valid_from, 
    :valid_to, 
    :media_type, 
    :valid_from_date, 
    :valid_from_time, 
    :valid_to_date, 
    :valid_to_time, 
    :media_file,
    :currency_id,
    :spendable,
    :countable,
    :numeric_display,
    :reward_id

  attr_accessor :valid_from_date, :valid_from_time, :valid_to_date, :valid_to_time # Attributi di appoggio per l'easyadmin.

  has_attached_file :main_image     #, :styles => { :medium => "400x400>", :thumb => "100x100>" }, :default_url => ""
  has_attached_file :preview_image  #, :styles => { :big => "100x100>", :thumb => "50x50>" }, :default_url => ""
  has_attached_file :not_awarded_image  #, :styles => { :big => "100x100>", :thumb => "50x50>" }, :default_url => ""
  has_attached_file :media_file
  
  has_many :reward_tags
  has_many :user_rewards
  belongs_to :currency, :class_name => "Reward", :foreign_key => 'currency_id'
  
  before_save :set_active_at # Costruisco la data di attivazione se arrivo dall'easyadmin.
  before_save :set_expire_at # Costruisco la data di disattivazione se arrivo dall'easyadmin.
  
  def set_active_at
    if valid_from_date.present? && valid_from_time.present?
      write_attribute :valid_from, Time.parse("#{valid_from_date} #{valid_from_time} Rome")
      valid_from_date = nil
      valid_from_time = nil
    end
  end
  
  def set_expire_at
    if valid_to_date.present? && valid_to_time.present?
      write_attribute :publish_time_end, Time.parse("#{valid_to_date} #{valid_to_time} Rome")
      valid_to_date = nil
      valid_to_time = nil
    end
  end

  def self.get_names_and_countable_pairs
    Reward.select("name, countable").all
  end

  def get_all_names
    cache_short do
      select("name")
    end
  end

end