class Calltoaction < ActiveRecord::Base
  attr_accessible :title, :video_url, :image, :activated_at, :mobile_url, :interactions_attributes,
  					:activation_date, :activation_time, :cta_template_type, :property_id, :slug, :enable_disqus, :media_type,
            :secondary_id, :description

  extend FriendlyId
  friendly_id :title, use: :slugged

  attr_accessor :activation_date, :activation_time # Attributi di appoggio per l'easyadmin.

  validates_presence_of :property_id
  validates_presence_of :title

  before_save :set_activated_at # Costruisco la data di attivazione se arrivo dall'easyadmin.

  has_attached_file :image, :styles => { :large => "600x600", extra: "260x150#", :medium => "300x300#", :thumb => "100x100#" }, :default_url => "/assets/video1.jpg"
  
  has_many :interactions, dependent: :destroy
  has_many :calltoaction_tags, dependent: :destroy
  has_many :answer

  belongs_to :property

  validates_associated :interactions
  validate :interaction_resource
  validate :check_video_interaction, unless: Proc.new { |c| video_url.blank? }

  accepts_nested_attributes_for :interactions

  scope :active, -> { includes(:calltoaction_tags, calltoaction_tags: :tag).where("activated_at<=? AND activated_at IS NOT NULL AND media_type<>'VOID' AND (calltoaction_tags.id IS NULL OR (tags.text<>'step' AND tags.text<>'extra' AND tags.text<>'youtube'))", Time.now).order("activated_at DESC") }
  scope :active_no_order, -> { includes(:calltoaction_tags, calltoaction_tags: :tag).where("activated_at<=? AND activated_at IS NOT NULL AND media_type<>'VOID' AND (calltoaction_tags.id IS NULL OR (tags.text<>'step' AND tags.text<>'extra' AND tags.text<>'youtube'))", Time.now) }

  scope :future_no_order, -> { includes(:calltoaction_tags, calltoaction_tags: :tag).where("activated_at>? AND activated_at IS NOT NULL AND media_type<>'VOID' AND (calltoaction_tags.id IS NULL OR (tags.text<>'step' AND tags.text<>'extra' AND tags.text<>'youtube'))", Time.now) }

  def image_url
    image.url
  end

  def media_type_enum
    ["IMAGE", "VIDEO", "VOID"]
  end

  def check_video_interaction
    play_inter = false
    interactions.each do |i|
      play_inter = true if i.resource_type == "Play"
    end

    errors.add("video_url", "devi agganciare un interazione di tipo Play per questa calltoaction") unless play_inter
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
  	if activation_date.present? && activation_time.present?
  		write_attribute :activated_at, "#{activation_date} #{activation_time}"
  		activation_date = nil
  		activation_time = nil
  	end
  end

end
