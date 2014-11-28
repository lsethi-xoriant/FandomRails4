class Tag < ActiveRecord::Base

  include ActionView::Helpers::TextHelper
  include DateMethods

  attr_accessible :name,  :description, :locked, :tag_fields_attributes, :created_at, :updated_at, :valid_from, :valid_to,
                  :valid_from_date, :valid_from_time, :valid_to_date, :valid_to_time

  attr_accessor :valid_from_date, :valid_from_time, :valid_to_date, :valid_to_time

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

  def to_category
    has_thumb = tag_fields.find_by_name("thumbnail") && tag_fields.find_by_name("thumbnail").upload.present?
    thumb_url = tag_fields.find_by_name("thumbnail").upload.url if tag_fields.find_by_name("thumbnail")
    if tag_fields.find_by_name("description")
      description = truncate(tag_fields.find_by_name("description").value, :length => 150, :separator => ' ')
      long_description = tag_fields.find_by_name("description").value
    else
      description = ""
      long_description = ""
    end
    header_image = tag_fields.find_by_name("header_image").upload.url if tag_fields.find_by_name("header_image")
    icon = tag_fields.find_by_name("icon") if tag_fields.find_by_name("icon")
    category_icon = tag_fields.find_by_name("category_icon").upload.url if tag_fields.find_by_name("category_icon")
    BrowseCategory.new(
      id: id,
      has_thumb: has_thumb, 
      thumb_url: thumb_url,
      title: tag_fields.find_by_name("title").try(:value),
      long_description: long_description,
      description: description,  
      detail_url: "/browse/category/#{id}",
      created_at: created_at.to_time.to_i,
      header_image_url: header_image,
      icon: icon,
      category_icon: category_icon
    )
  end

end
