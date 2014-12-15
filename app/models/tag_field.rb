class TagField < ActiveRecord::Base
  attr_accessible :name, :field_type, :value, :tag_id, :upload
  
  has_attached_file :upload,
    :styles => { 
      :original => "100%", 
      :carousel => "1024x320^", 
      :medium => "524x393^", 
      :thumb => "262x147^" 
    }, 
    :convert_options => { 
      :original => " -quality 60", 
      :carousel => " -gravity center -crop '1024x320+0+0' -quality 60", 
      :medium => " -gravity center -crop '524x393+0+0' -quality 60", 
      :thumb => " -gravity center -crop '262x147+0+0' -quality 60" 
    }

  validates_presence_of :name
  
  belongs_to :tag
  
  #validate :validate_name
  
  # TODO: ultimate validation name function
  def validate_name
    tags_tags = TagsTag.where("other_tag_id IS NOT NULL")
  end
  
end
