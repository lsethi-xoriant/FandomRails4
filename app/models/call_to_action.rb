class CallToAction < ActiveRecord::Base

  include ActionView::Helpers::TextHelper
  include DateMethods
  
  attr_accessible :title, :media_data, :media_image, :media_type, :activated_at, :interactions_attributes,
  					:activation_date, :activation_time, :slug, :enable_disqus, :secondary_id, :description, 
  					:approved, :user_id, :interaction_watermark_url, :name, :thumbnail, :releasing_file_id, :release_required,
            :privacy_required, :privacy, :button_label, :alternative_description, :enable_for_current_user,
            :valid_from, :valid_to, :shop_url

  extend FriendlyId
  friendly_id :title, use: :slugged

  attr_accessor :activation_date, :activation_time, :interaction_watermark_url, :release_required, :privacy_required,
            :button_label, :alternative_description, :enable_for_current_user, :shop_url

  validates_presence_of :title
  validates_presence_of :name
  validates_uniqueness_of :name
  validates_presence_of :media_image, if: Proc.new { |c| user_id.present? }
  validates_associated :releasing_file, if: Proc.new { |c| release_required }
  validate :interaction_resource
  validate :check_video_interaction, if: Proc.new { |c| media_type == "YOUTUBE" }
  validates_associated :interactions
  validates :privacy, :acceptance => { :accept => true }, if: Proc.new { |c| privacy_required }

  before_save :set_activated_at # Costruisco la data di attivazione se arrivo dall'easyadmin.
  before_save :set_extra_options
  
  has_attached_file :media_image,
    processors: [:watermark],
    styles: lambda { |image| 
        if image.content_type =~ %r{^(image|(x-)?application)/(x-png|pjpeg|jpeg|jpg|png|gif)$}
          {
            :original => { :geometry => '100%', :quality => 60 },
            :large => { :geometry => "600x600>", :quality => 60, :watermark_path => image.instance.get_watermark }, 
            :extra => { :geometry => '260x150#', :quality => 60 },
            :medium => { :geometry => '300x300#', :quality => 60 },
            :thumb => { :geometry => '100x100#', :quality => 60 }
          }
        else
          {}
        end
     },
     default_url: "/assets/media-image-default.jpg"

  has_attached_file :thumbnail, :styles => { :original => "100%", :large => "600x600#", :medium => "300x300#", :thumb => "100x100#" }, 
                    :convert_options => { :original => '-quality 60', :large => '-quality 60', :medium => '-quality 60', :thumb => '-quality 60' }

  has_many :interactions, dependent: :destroy
  has_many :call_to_action_tags, dependent: :destroy
  has_many :answers
  has_many :rewards
  belongs_to :releasing_file
  belongs_to :user
  has_one :user_upload_interaction

  accepts_nested_attributes_for :interactions

  scope :active, -> { where("call_to_actions.activated_at <= ? AND call_to_actions.activated_at IS NOT NULL AND call_to_actions.media_type <> 'VOID' AND call_to_actions.user_id IS NULL", Time.now).order("call_to_actions.activated_at DESC") }
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

  def check_video_interaction
    play_inter = false
    interactions.each do |i|
      play_inter = true if i.resource_type == "Play"
    end

    errors.add(:media_type, "devi agganciare una interazione di tipo Play per questa calltoaction") unless play_inter
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
    if self.activation_date.present? && self.activation_time.present?
      datetime_utc = time_parsed_to_utc("#{activation_date} #{activation_time}")
      write_attribute :activated_at, "#{datetime_utc}"
      activation_date = nil
      activation_time = nil
    end
  end
  
  def get_watermark
    if !user_id.nil? && interaction_watermark_url
      interaction_watermark_url
    else
      nil
    end
  end
  
  def to_category
    BrowseCategory.new(
      id: id, 
      has_thumb: media_image.present?, 
      thumb_url: media_image.url, 
      title: title, 
      description: truncate(description, :length => 150, :separator => ' '),
      long_description: description,
      detail_url: "/call_to_action/#{id}",
      created_at: created_at.to_time.to_i
    )
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
        enable_for_current_user: enable_for_current_user,
        shop_url: shop_url
      }.to_json
  end

end
