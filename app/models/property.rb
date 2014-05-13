class Property < ActiveRecord::Base  
  extend FriendlyId
	friendly_id :name, use: :slugged

  attr_accessible :name, :color_code, :activated_at, :activation_date, :activation_time, :background, :description,
	:default_interaction_points_attributes
  attr_accessor :activation_date, :activation_time # Attributi di appoggio per l'easyadmin.

  has_attached_file :background

  before_save :set_activated_at # Costruisco la data di attivazione se arrivo dall'easyadmin.

	has_many :rewarding_users
	has_many :calltoactions
	has_many :badges
	has_many :levels
	has_many :default_interaction_points
	has_many :promocodes

	accepts_nested_attributes_for :default_interaction_points

	scope :active, -> { where("activated_at<=? AND activated_at IS NOT NULL", Time.now).order("activated_at DESC") }

	def set_activated_at
  	if activation_date.present? && activation_time.present?
  		write_attribute :activated_at, "#{activation_date} #{activation_time}"
  		activation_date = activation_time = nil
  	end
	end
end
