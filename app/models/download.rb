class Download < ActiveRecord::Base
  attr_accessible :title, :attachment, :ical_fields

  has_attached_file :attachment
  
  has_one :interaction, as: :resource

  validates_presence_of :attachment, unless: Proc.new { |c| ical_fields }

  def one_shot
    false
  end
end
