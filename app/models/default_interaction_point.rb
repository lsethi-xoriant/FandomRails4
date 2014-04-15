class DefaultInteractionPoint < ActiveRecord::Base
  attr_accessible :property_id, :points, :added_points, :interaction_type
  
  belongs_to :property

  validates_presence_of :interaction_type
  validates_uniqueness_of :interaction_type, :scope => :property_id

  def interaction_type_enum
    ["TRIVIA", "VERSUS", "SHARE", "CHECK", "LIKE", "DOWNLOAD"]
  end
end
