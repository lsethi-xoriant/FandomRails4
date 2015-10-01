class Tag < ActiveRecordWithJSON

  include ActionView::Helpers::TextHelper
  include DateMethods

  attr_accessible :name, :title, :description, :locked, :extra_fields, :created_at, :updated_at, :valid_from, :valid_to,
                  :valid_from_date_time, :valid_to_date_time, :slug

  attr_accessor :valid_from_date_time, :valid_to_date_time

  json_attributes [[:extra_fields, EmptyAux]]

  extend FriendlyId
  friendly_id :name, use: [:slugged, :finders]

  validates_presence_of :name
  validates :name, uniqueness: true
  validate :uniqueness_of_name_field
  validate :absence_of_spaces_in_slug

  has_many :call_to_action_tags, dependent: :destroy
  has_many :reward_tags, dependent: :destroy
  has_many :tags_tags, dependent: :destroy
  has_many :vote_ranking_tags, dependent: :destroy

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

  def uniqueness_of_name_field
    if CallToAction.where(:name => self.name).any?
      errors.add(name, 'presente come nome di una CallToAction')
    elsif Reward.where(:name => self.name).any?
      errors.add(name, 'presente come nome di un Reward')
    end
  end

  def absence_of_spaces_in_slug
    if slug.include?(" ")
      errors.add(slug, 'contiene degli spazi')
    end
  end

end
