class Tag < ActiveRecord::Base
  
  include ActionView::Helpers::TextHelper
  
  attr_accessible :name,  :description, :locked, :tag_fields_attributes, :created_at, :updated_at

  validates_presence_of :name
  validates :name, uniqueness: true
  
  has_many :call_to_action_tags
  has_many :reward_tags
  has_many :tags_tags, dependent: :destroy
  has_many :tag_fields, dependent: :destroy
  
  accepts_nested_attributes_for :tag_fields
  
  validates_associated :tag_fields
  
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
    icon = tag_fields.find_by_name("icon").upload.url if tag_fields.find_by_name("icon")
    BrowseCategory.new(
      id: id,
      has_thumb: has_thumb, 
      thumb_url: thumb_url,
      title: tag_fields.find_by_name("title").try(:value),  
      description: description,
      detail_url: "/browse/category/#{id}",
      created_at: created_at.to_time.to_i,
      header_image_url: header_image,
      icon_url: icon
    )
  end
  
end
