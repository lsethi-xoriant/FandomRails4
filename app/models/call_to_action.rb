class CallToAction < ActiveRecordWithJSON

  include ActionView::Helpers::TextHelper
  include CallToActionHelper
  include ApplicationHelper
  include DateMethods
  
  attr_accessible :title, 
    :media_data, 
    :media_image, 
    :media_type, 
    :activated_at, 
    :interactions_attributes,
  	:activation_date_time, 
    :slug, 
    :enable_disqus, 
    :description, 
  	:approved, 
    :user_id, 
    :interaction_watermark_url, 
    :name, 
    :thumbnail, 
    :releasing_file_id, 
    :release_required,
    :privacy_required, 
    :privacy, 
    :valid_from, 
    :valid_to, 
    :valid_from_date_time, 
    :valid_to_date_time, 
    :aux, 
    :extra_fields,
    :secondary_id,
    :button_label, 
    :alternative_description, 
    :enable_for_current_user, 
    :shop_url,
    :aws_transcoding, 
    :media_image_content_type, 
    :media_image_file_size, 
    :media_image_file_name

  json_attributes [[:aux, EmptyAux], [:extra_fields, EmptyAux]]

  extend FriendlyId
  friendly_id :name, use: [:slugged, :finders]

  attr_accessor :activation_date_time, :interaction_watermark_url, :release_required, :privacy_required,
                :button_label, :alternative_description, :enable_for_current_user, :shop_url, 
                :aws_transcoding, :valid_from_date_time, :valid_to_date_time

  validates_presence_of :title
  validates_presence_of :name
  validates_uniqueness_of :name
  validate :uniqueness_of_name_field
  validates_presence_of :media_image, if: Proc.new { |c| user_id.present? }
  validates_associated :releasing_file, if: Proc.new { |c| release_required }
  validate :interaction_resource
  validate :check_video_interaction, if: Proc.new { |c| media_type == "YOUTUBE" || media_type == "KALTURA" || media_type == "FLOWPLAYER" }
  validates_associated :interactions
  validates :privacy, :acceptance => { :accept => true }, if: Proc.new { |c| privacy_required }

  before_save :set_activated_at # handles the activated_at fields when updating the model from easyadmin
  # before_save :set_extra_options

  has_attached_file :media_image,
    processors: lambda { |calltoaction|
      if calltoaction.media_image_content_type =~ %r{^(image|(x-)?application)/(x-png|pjpeg|jpeg|jpg|png|gif)$}
        [:watermark]
      end
    },
    styles: lambda { |image| 
      if image.content_type =~ %r{^(image|(x-)?application)/(x-png|pjpeg|jpeg|jpg|png|gif)$}
        {
          :extra_large => { :geometry => "1024x768>", :quality => 90, :watermark_path => image.instance.get_watermark },
          :large => { :geometry => "600x600>", :watermark_path => image.instance.get_watermark },
          :extra => { :geometry => '260x150#' },
          :medium => { :geometry => '300x300#' },
          :thumb => { :geometry => '100x100#' }
        }
      elsif image.content_type =~ %r{^(image|(x-)?application)/(pdf)$}
        { }
      else
        { }
      end
     },
     default_url: "/assets/media-image-default.jpg"

  has_attached_file :thumbnail, 
    :styles => { 
      :carousel => "1024x320^", 
      :medium => "524x393^", 
      :thumb => "262x147^",
      :wide => "1024x576"
    }, 
    :convert_options => { 
      :carousel => " -crop '1024x320+0+40'", 
      :medium => " -crop '524x393+0+0'", 
      :thumb => " -crop '262x147+0+0'" 
    }

  has_many :interaction_call_to_actions
  has_many :interactions, dependent: :destroy
  has_many :call_to_action_tags, dependent: :destroy
  has_many :answers
  has_many :rewards
  belongs_to :releasing_file
  belongs_to :user
  has_one :user_upload_interaction

  accepts_nested_attributes_for :interactions

  # TODO: in every place :active has been used, it should be substituted either with active_with_media or with active_with_media_not_from_user
  scope :active, -> { where("call_to_actions.activated_at <= ? AND call_to_actions.activated_at IS NOT NULL", Time.now).order("call_to_actions.activated_at DESC") }
  
  scope :active_with_media, -> { where("call_to_actions.activated_at <= ? AND call_to_actions.activated_at IS NOT NULL AND call_to_actions.media_type <> 'VOID'", Time.now).order("call_to_actions.activated_at DESC") }
  scope :active_with_media_not_from_user, -> { where("call_to_actions.activated_at <= ? AND call_to_actions.activated_at IS NOT NULL AND call_to_actions.media_type <> 'VOID' AND call_to_actions.user_id IS NULL", Time.now).order("call_to_actions.activated_at DESC") }
  
  scope :valid, -> { where("call_to_actions.valid_from <= ? AND call_to_actions.valid_to >= ? AND
                            call_to_actions.valid_to IS NOT NULL AND call_to_actions.valid_from IS NOT NULL AND 
                            call_to_actions.user_id IS NULL", Time.now, Time.now) }

  def media_image_url
    media_image.url
  end

  def thumbnail_url
    thumbnail.url
  end

  def media_type_enum
    MEDIA_TYPES
  end

  def allowed_upload_media_type_enum
    ALLOWED_UPLOAD_MEDIA_TYPES
  end

  def check_video_interaction
    play_inter = false
    interactions.each do |i|
      play_inter = true if i.resource_type == "Play"
    end

    errors.add(:media_type, "devi agganciare una interazione di tipo Play per questa call to action") unless play_inter
  end

  def interaction_resource
     interactions.each do |e|
      if e.errors.any?
        e.errors.each do |key, message|
          errors.add("interactions.#{key}", message) unless errors["interactions.#{key}"].include?(message)
        end
      end
    end
  end

  def set_activated_at
    if self.activation_date_time.present?
      datetime_utc = time_parsed_to_utc("#{activation_date_time}")
      write_attribute :activated_at, "#{datetime_utc}"
      activation_date_time = nil
    elsif self.activated_at.nil?
      write_attribute :activated_at, nil
    end

    if valid_from_date_time.present?
      datetime_utc = time_parsed_to_utc("#{valid_from_date_time}")
      write_attribute :valid_from, "#{datetime_utc}"
      valid_from_date_time = nil
    else
      write_attribute :valid_from, nil
    end

    if valid_to_date_time.present?
      datetime_utc = time_parsed_to_utc("#{valid_to_date_time}")
      write_attribute :valid_to, "#{datetime_utc}"
      valid_to_date_time = nil
    else
      write_attribute :valid_to, nil
    end
  end
  
  def get_watermark
    if !user_id.nil? && interaction_watermark_url
      interaction_watermark_url
    else
      nil
    end
  end

  def enable_for_current_user?
    if aux
      JSON.parse(aux)["enable_for_current_user"] == "1"
    else
      false
    end
  end
  
  def set_extra_options
    write_attribute :aux, { 
        button_label: button_label, 
        alternative_description: alternative_description,
        shop_url: shop_url,
        enable_for_current_user: enable_for_current_user
      }.to_json
  end

  def uniqueness_of_name_field
    if Tag.where(:name => self.name).any?
      errors.add(name, 'presente come nome di un Tag')
    elsif Reward.where(:name => self.name).any?
      errors.add(name, 'presente come nome di un Reward')
    end
  end

end
