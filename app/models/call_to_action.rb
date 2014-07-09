class CallToAction < ActiveRecord::Base
  attr_accessible :title, :media_data, :media_image, :media_type, :activated_at, :interactions_attributes,
  					:activation_date, :activation_time, :slug, :enable_disqus, :secondary_id, :description

  extend FriendlyId
  friendly_id :title, use: :slugged

  attr_accessor :activation_date, :activation_time # Attributi di appoggio per l'easyadmin.

  validates_presence_of :title

  before_save :set_activated_at # Costruisco la data di attivazione se arrivo dall'easyadmin.

  has_attached_file :media_image, :styles => { :large => "600x600", extra: "260x150#", :medium => "300x300#", :thumb => "100x100#" }, :default_url => "/assets/video1.jpg"
  
  has_many :interactions, dependent: :destroy
  has_many :call_to_action_tags, dependent: :destroy
  has_many :answers
  belongs_to :user

  validates_associated :interactions
  validate :interaction_resource
  validate :check_video_interaction, if: Proc.new { |c| media_type == "YOUTUBE" }

  accepts_nested_attributes_for :interactions

  scope :active, -> { includes(:call_to_action_tags, call_to_action_tags: :tag).where("activated_at<=? AND activated_at IS NOT NULL AND media_type<>'VOID' AND (call_to_action_tags.id IS NULL OR tags.name NOT IN (?))", Time.now, ["step"]).order("activated_at DESC") }

  def media_image_url
    media_image.url
  end

  def media_type_enum
    ["IMAGE", "YOUTUBE", "IFRAME", "VOID"]
  end

  def check_video_interaction
    play_inter = false
    interactions.each do |i|
      play_inter = true if i.resource_type == "Play"
    end

    errors.add(:media_type, "devi agganciare un interazione di tipo Play per questa calltoaction") unless play_inter
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
