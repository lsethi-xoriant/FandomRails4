class Tag < ActiveRecordWithJSON

  include ActionView::Helpers::TextHelper
  include DateMethods

  attr_accessible :name, :title, :description, :locked, :extra_fields, :tag_fields_attributes, :created_at, :updated_at, :valid_from, :valid_to,
                  :valid_from_date, :valid_from_time, :valid_to_date, :valid_to_time

  attr_accessor :valid_from_date, :valid_from_time, :valid_to_date, :valid_to_time

  json_attributes [[:extra_fields, EmptyAux]]

  validates_presence_of :name
  validates :name, uniqueness: true

  has_many :call_to_action_tags, dependent: :destroy
  has_many :reward_tags, dependent: :destroy
  has_many :tags_tags, dependent: :destroy
  has_many :tag_fields, dependent: :destroy
  has_many :vote_ranking_tags, dependent: :destroy

  accepts_nested_attributes_for :tag_fields

  validates_associated :tag_fields

  before_save :set_active_at # Costruisco la data di attivazione se arrivo dall'easyadmin.
  before_save :set_expire_at # Costruisco la data di disattivazione se arrivo dall'easyadmin.

  def set_active_at
    if valid_from_date.present? && valid_from_time.present?
      # write_attribute :valid_from, Time.parse("#{valid_from_date} #{valid_from_time} Rome")
      datetime_utc = time_parsed_to_utc("#{valid_from_date} #{valid_from_time}")
      write_attribute :valid_from, "#{datetime_utc}"
      valid_from_date = nil
      valid_from_time = nil
    end
  end

  def set_expire_at
    if valid_to_date.present? && valid_to_time.present?
      #write_attribute :valid_to, Time.parse("#{valid_to_date} #{valid_to_time} Rome")
      datetime_utc = time_parsed_to_utc("#{valid_to_date} #{valid_to_time}")
      write_attribute :valid_to, "#{datetime_utc}"
      valid_to_date = nil
      valid_to_time = nil
    end
  end

end
