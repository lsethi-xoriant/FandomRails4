class TagsTag < ActiveRecord::Base

  attr_accessible :tag_id, :other_tag_id

  belongs_to :tag, class_name: "Tag", foreign_key: "tag_id"
  belongs_to :other_tag, class_name: "Tag", foreign_key: "other_tag_id"
  
end