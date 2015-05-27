class Reward < ActiveRecordWithJSON
  include DateMethods

  attr_accessible :name,
    :title, 
    :short_description, 
    :long_description, 
    :preview_image, 
    :main_image,
    :not_awarded_image,
    :not_winnable_image,
    :button_label, 
    :cost,
    :video_url, 
    :valid_from, 
    :valid_to, 
    :media_type, 
    :valid_from_date_time, 
    :valid_to_date_time, 
    :media_file,
    :currency_id,
    :spendable,
    :countable,
    :numeric_display,
    :call_to_action_id,
    :reward_tag_ids,
    :aux,
    :extra_fields

  attr_accessor :valid_from_date_time, :valid_to_date_time # Accessor attributes for easyadmin.

  json_attributes [[:aux, EmptyAux], [:extra_fields, EmptyAux]]

  validates_presence_of :title
  validates_presence_of :name
  validates_uniqueness_of :name
  validate :uniqueness_of_name_field

  has_attached_file :main_image, :styles => { :medium => "400x400#", :thumb => "100x100#" }, 
                    :convert_options => { :medium => '-quality 60', :thumb => '-quality 60' }, 
                    :default_url => ""
  has_attached_file :preview_image, :styles => { :thumb => "100x100#", }, 
                    :convert_options => { :thumb => '-quality 60' }, 
                    :default_url => ""
  has_attached_file :not_awarded_image, :styles => { :thumb => "100x100#", }, 
                    :convert_options => { :thumb => '-quality 60' }, 
                    :default_url => ""
  has_attached_file :not_winnable_image, :styles => { :thumb => "100x100#", }, 
                    :convert_options => { :thumb => '-quality 60' }, 
                    :default_url => ""
  has_attached_file :media_file
  do_not_validate_attachment_file_type :main_image, :preview_image, :not_awarded_image, :not_winnable_image

  has_many :reward_tags
  has_many :user_rewards
  belongs_to :currency, :class_name => "Reward", :foreign_key => 'currency_id'
  belongs_to :call_to_action

  before_save :set_active_at # Costruisco la data di attivazione se arrivo dall'easyadmin.
  before_save :set_expire_at # Costruisco la data di disattivazione se arrivo dall'easyadmin.

  def set_active_at
    if valid_from_date_time.present?
      datetime_utc = time_parsed_to_utc("#{valid_from_date_time}")
      write_attribute :valid_from, "#{datetime_utc}"
      valid_from_date_time = nil
    end
  end
  
  def set_expire_at
    if valid_to_date_time.present?
      datetime_utc = time_parsed_to_utc("#{valid_to_date_time}")
      write_attribute :valid_to, "#{datetime_utc}"
      valid_to_date_time = nil
    end
  end
  
  def is_published
    from_valid = valid_from.nil? || Time.now.utc > valid_from
    to_valid =  valid_to.nil? || Time.now.utc < valid_to
    return from_valid && to_valid
  end
  
  def is_expired
    to_valid =  valid_to.nil? || Time.now.utc < valid_to
    return !to_valid
  end

  def uniqueness_of_name_field
    if CallToAction.where(:name => self.name).any?
      errors.add(name, 'presente come nome di una CallToAction')
    elsif Tag.where(:name => self.name).any?
      errors.add(name, 'presente come nome di un Tag')
    end
  end

end