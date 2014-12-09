class TagField < ActiveRecord::Base
  attr_accessible :name, :field_type, :value, :tag_id, :upload
  
  has_attached_file :upload #, :styles => { :medium => "400x400>", :thumb => "100x100>" }, :default_url => ""

  validates_presence_of :name
  
  belongs_to :tag
  
  #validate :validate_name
  
  # TODO: ultimate validation name function
  def validate_name
    tags_tags = TagsTag.where("other_tag_id IS NOT NULL")
  end
  
end
