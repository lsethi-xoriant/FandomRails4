class TagTag < ActiveRecord::Base

  attr_accessible :tag_id, :belongs_tag_id

  belongs_to :tag, class_name: "Tag", foreign_key: "tag_id"
  belongs_to :belongs_tag, class_name: "Tag", foreign_key: "belongs_tag_id"
  
end